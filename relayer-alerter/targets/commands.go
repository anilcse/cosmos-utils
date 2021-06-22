package targets

import (
	"fmt"
	"log"
	"net/http"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api"
	"gopkg.in/mgo.v2/bson"

	"github.com/vitwit/cosmos-utils/relayer-alerter/config"
	"github.com/vitwit/cosmos-utils/relayer-alerter/db"
)

// Update is a Telegram object that the handler receives every time an user interacts with the bot.
type U struct {
	UpdateId int `json:"update_id"`
	Message  M   `json:"message"`
}

// Message is a Telegram object that can be found in an update.
type M struct {
	Text string `json:"text"`
	Chat C      `json:"chat"`
}

// A Telegram Chat indicates the conversation to which the message belongs.
type C struct {
	Id int `json:"id"`
}

// TelegramAlerting
func TelegramAlerting(cfg *config.Config) {
	// var c client.Client
	bot, err := tgbotapi.NewBotAPI(cfg.Telegram.BotToken)
	if err != nil {
		log.Fatalf("Please configure telegram bot token : %v", err)
	}

	bot.Debug = true

	log.Printf("Authorized on account %s", bot.Self.UserName)

	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	updates, err := bot.GetUpdatesChan(u)

	log.Println("len of update.", len(updates))

	msgToSend := ""

	for update := range updates {
		if update.Message == nil { // ignore any non-Message Updates
			continue
		}

		arguments := strings.Split(update.Message.Text, " ")
		log.Printf("Len of input arguments : %d", len(arguments))

		if update.Message.Text == "/add_address" || arguments[0] == "/add_address" {
			msgToSend = AddAddress(cfg, arguments)
		} else if update.Message.Text == "/delete_address" || arguments[0] == "/delete_address" {
			msgToSend = DeleteAddressFromDB(cfg, arguments)
		} else if update.Message.Text == "/get_details" || arguments[0] == "/get_details" {
			msgToSend = ListAddressDetails(cfg, arguments)
		} else if update.Message.Text == "/update_threhold" || arguments[0] == "/update_threshold" {
			msgToSend = UpdateAlertingThershold(cfg, arguments)
		} else if update.Message.Text == "/update_rpc" || arguments[0] == "/update_rpc" {
			msgToSend = UpdateRPC(cfg, arguments)
		} else if update.Message.Text == "/update_lcd" || arguments[0] == "/update_lcd" {
			msgToSend = UpdateLCD(cfg, arguments)
		} else if update.Message.Text == "/get_started" {
			msgToSend = GetCommandInfo()
		} else if update.Message.Text == "/rpc_status" {
			msgToSend = GetRPCStatus(cfg)
		} else if update.Message.Text == "/list_all_addresses" {
			msgToSend = GetAllAddressFromDB(cfg)
		} else if update.Message.Text == "/list" {
			msgToSend = GetHelp()
		} else {
			text := strings.Split(update.Message.Text, "")
			if len(text) != 0 {
				if text[0] == "/" {
					msgToSend = "Command not found do /list to know about available commands"
				} else {
					msgToSend = " "
				}
			}
		}

		log.Printf("[%s] %s", update.Message.From.UserName, msgToSend)

		if msgToSend != " " {
			msg := tgbotapi.NewMessage(update.Message.Chat.ID, msgToSend)
			msg.ReplyToMessageID = update.Message.MessageID

			bot.Send(msg)
		}
	}
}

// GetHelp returns the msg to show for /help
func GetHelp() string {
	msg := fmt.Sprintf("List of available commands\n")

	msg = msg + fmt.Sprintf("/get_started - if you have doubts in giving inputs and how to start, just use this once.\n\n")

	msg = msg + fmt.Sprintf("/add_address - is to add a new account address into database\n- Format: /add_address <networkName> <accountNickName> <accountAddress> <rpc> <lcd> <denom> <displayDenom> <threshold>\n\n - Example :: /add_address akash akash-relayer akash1qwlcuf2c2dhtgy8z5y7xxqev76km0n5mmnpeqq https://localhost:26657 https://localhost:1317 uakt AKT 5\n\n")

	msg = msg + fmt.Sprintf("/get_details - is to get account details for given address\n- format: /get_details <accountAddress>\n\n")

	msg = msg + fmt.Sprintf("/delete_address - is to delete the address from database and once deleted you won't get the alerts related to it\n format: /delete_address <accountNickName> <accountAddress>\n\n")

	msg = msg + fmt.Sprintf("/update_threshold - update account balance alerting thershold\n- format: /update_threshold <accountNickName> <accountAddress> <threshold>\n\n")

	msg = msg + fmt.Sprintf("/update_rpc - update rpc of your particular account address\n- format: /update_rpc <accountAddress> <rpc>\n\n")

	msg = msg + fmt.Sprintf("/update_lcd- update lcd of your particular account address\n- format: /update_lcd <accountAddress> <lcd>\n\n")

	msg = msg + fmt.Sprintf("/list_all_addresses - list out all addresses which were added into the database\n\n")

	msg = msg + fmt.Sprintf("/rpc_status - returns the status of RPC and LCD\n\n")

	msg = msg + "/list - list out the available commands"

	return msg
}

func GetCommandInfo() string {
	var msg string

	msg = msg + fmt.Sprintf("!!! Hello there, Follow these instructions before starting !!!\n\n - You can manage your accounts from this telegram chat.\n\n - You can be notified about your daily balance changes\n\n - It also alerts about your account balance when it drops below configured thershold. \n\n- Remember while using /add_address or other commands i.e., which takes arguments, should be space seperated.\n\n - For example /get_details <accountAddress>  --- which takes input of account address, so the command should be like /get_details cosmosalpad8aaklkas19lpbcaaa1212\n\n - After adding account addresses please run /get_details command to cross check the insrted values in db correct or not, if you have any doubt.\n\n Thank you !!!")

	return msg
}

// GetRPCStatus retsurns status of the configured endpoints i.e, rpc and lcd.
func GetRPCStatus(cfg *config.Config) string {
	var ops HTTPOptions
	var msg string

	addresses, err := db.GetAllAddress(bson.M{}, bson.M{}, cfg.MongoDB.Database)
	if err != nil {
		log.Printf("Error while getting addresses list from db : %v", err)
		if err.Error() == "not found" {
			msg = "No addresses found in database"
			return msg
		}
		// return err
	}

	for _, value := range addresses {
		ops = HTTPOptions{
			Endpoint: value.RPC + "/status",
			Method:   http.MethodGet,
		}

		_, err := HitHTTPTarget(ops)
		if err != nil {
			log.Printf("Error in rpc: %v", err)
			msg = msg + fmt.Sprintf("⛔ Unreachable to RPC :: %s of %s and the ERROR is : %v\n", ops.Endpoint, value.NetworkName, err.Error())
		} else {
			msg = msg + fmt.Sprintf("RPC of %s ( %s ):  ✅\n", value.NetworkName, ops.Endpoint)
		}

		ops = HTTPOptions{
			Endpoint: value.LCD + "/node_info",
			Method:   http.MethodGet,
		}

		_, err = HitHTTPTarget(ops)
		if err != nil {
			log.Printf("Error in lcd endpoint: %v", err)
			msg = msg + fmt.Sprintf("⛔ Unreachable to LCD :: %s of %s and the ERROR is : %v\n\n", ops.Endpoint, value.NetworkName, err.Error())
		} else {
			msg = msg + fmt.Sprintf("LCD of %s ( %s )  ✅\n\n", value.NetworkName, ops.Endpoint)
		}
	}

	return msg
}
