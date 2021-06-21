package targets

import (
	"fmt"

	"gopkg.in/mgo.v2/bson"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
)

func ListAddressDetails(cfg *config.Config, args []string) string {
	msg := fmt.Sprint("Your ccount details::\n")

	if len(args) != 0 && len(args) == 2 {
		address := args[1]

		query := bson.M{
			"account_address": address,
		}

		details, err := GetAddress(query, bson.M{}, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while getting address details from db : %v", err)
		}

		bal, err := GetAccBalance(query, bson.M{}, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while getting details from db : %v", err)
			return msg
		}

		amount := convertToCommaSeparated(fmt.Sprintf("%f", ConvertToFolat64(bal.Balance))) + details.DisplayDenom
		b := fmt.Sprintf("%s", amount)

		text := fmt.Sprintf("Network Name : %s\n Account Nick Name : %s\n Account Address: %s\n RPC: %s\n LCD: %s\n Denom: %s\n DisplayDenom: %s\n Threshold: %s\n Balance: %s\n",
			details.NetworkName, details.AccountNickName, details.AccountAddress, details.RPC, details.LCD, details.Denom, details.DisplayDenom, details.Threshold, b)

		msg = msg + text

	} else {
		msg = fmt.Sprintf("Please check your input format\n Ex:  /get_details accountAddress")
		return msg
	}

	return msg
}
