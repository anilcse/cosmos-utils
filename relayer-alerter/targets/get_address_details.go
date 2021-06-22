package targets

import (
	"fmt"
	"log"

	"gopkg.in/mgo.v2/bson"

	"github.com/vitwit/cosmos-utils/relayer-alerter/config"
	"github.com/vitwit/cosmos-utils/relayer-alerter/db"
	"github.com/vitwit/cosmos-utils/relayer-alerter/utils"
)

func ListAddressDetails(cfg *config.Config, args []string) string {
	msg := fmt.Sprint("Your ccount details::\n")

	if len(args) != 0 && len(args) == 2 {
		address := args[1]

		query := bson.M{
			"account_address": address,
		}

		details, err := db.GetAddress(query, bson.M{}, cfg.MongoDB.Database)
		if err != nil {
			// msg = fmt.Sprintf("Error while getting address details from db : %v", err)
			if err.Error() == "not found" {
				msg = "Address NOT FOUND in database"
			}
			return msg
		}

		bal, err := db.GetAccBalance(query, bson.M{}, cfg.MongoDB.Database)
		if err != nil {
			// msg = fmt.Sprintf("Error while getting details from db : %v", err)
			if err.Error() == "not found" {
				msg = "Address NOT FOUND in database"
			}
			return msg
		}

		a := fmt.Sprintf("%f", utils.ConvertValue(bal.Balance, details.Denom))
		amount := utils.ConvertToCommaSeparated(a) + details.DisplayDenom
		b := fmt.Sprintf("%s", amount)

		text := fmt.Sprintf("Network Name : %s\nAccount Nick Name : %s\nAccount Address: %s\nRPC: %s\nLCD: %s\nDenom: %s\nDisplayDenom: %s\nThreshold: %s\nBalance: %s\n",
			details.NetworkName, details.AccountNickName, details.AccountAddress, details.RPC, details.LCD, details.Denom, details.DisplayDenom, details.Threshold, b)

		msg = msg + text

	} else {
		msg = fmt.Sprintf("Please check your input format\n Ex:  /get_details akash1qwlcuf2c2dhtgy8z5y7xmqev56km0n5axnpeqq")
		return msg
	}

	return msg
}

func GetAllAddressFromDB(cfg *config.Config) string {
	var msg string
	addresses, err := db.GetAllAddress(bson.M{}, bson.M{}, cfg.MongoDB.Database)
	if err != nil {
		log.Printf("No addresses found in db:")
		if err.Error() == "not found" {
			msg = "No addresses found in database"
		}
	}

	if len(addresses) == 0 {
		msg = "No addresses were added in database"
	} else {
		for _, details := range addresses {
			msg = msg + fmt.Sprintf("Network Name : %s\nAccount Nick Name : %s\nAccount Address: %s\nRPC: %s\nLCD: %s\nDenom: %s\nDisplayDenom: %s\nThreshold: %s\n\n",
				details.NetworkName, details.AccountNickName, details.AccountAddress, details.RPC, details.LCD, details.Denom, details.DisplayDenom, details.Threshold)

			msg = msg + "---------\n"
		}
	}

	return msg
}
