package targets

import (
	"fmt"
	"log"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
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
		log.Fatalf("Please configure telegram bot token :", err)
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

	msg = msg + `/add_address - is to add a new account address into database

		format: /add_address <networkName> <accountNickName> <accountAddress> <rpc> <lcd> <denom> <displayDenom> <threshold>
		
		`

	msg = msg + `/get_details - is to get account details for given address
		
		format: /get_details accountAddress
		
		`

	msg = msg + `/delete_address - is to delete the address from database and once deleted you won't get the alerts related to it
		
		/delete_address accountNickName accountAddress
		
		`

	msg = msg + "/list - list out the available commands"

	return msg
}
