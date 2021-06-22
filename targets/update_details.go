package targets

import (
	"fmt"

	"gopkg.in/mgo.v2/bson"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
)

func UpdateAlertingThershold(cfg *config.Config, args []string) string {
	var msg string

	if len(args) != 0 && len(args) == 4 {
		accName := args[1]
		address := args[2]
		threshold := args[3]

		query := bson.M{
			"account_nick_name": accName,
			"account_address":   address,
		}

		update := bson.M{
			"$set": bson.M{
				"threshold_alert": threshold,
			},
		}

		err := UpdateAddress(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating threshold : %v", err)
			if err.Error() == "not found" {
				msg = fmt.Sprintf("Account %s and address %s not found in database : %s", accName, address)
			}
			return msg
		}

		err = UpdateAccBalance(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating threshold : %v", err)
			return msg
		}

	} else {
		msg = fmt.Sprintf("Please check your input format\n Ex:  /update_threshold accountNickName accountAddress threshold")
		return msg
	}

	msg = "Updated Successfully!!"

	return msg
}

func UpdateRPC(cfg *config.Config, args []string) string {
	var msg string

	if len(args) != 0 && len(args) == 3 {
		address := args[1]
		rpc := args[2]

		query := bson.M{
			"account_address": address,
		}

		update := bson.M{
			"$set": bson.M{
				"rpc": rpc,
			},
		}

		err := UpdateAddress(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating rpc : %v", err)
			if err.Error() == "not found" {
				msg = fmt.Sprintf("Address %s not found in database.", address)
			}
			return msg
		}
	} else {
		msg = fmt.Sprintf("Please check your input format\n Ex:  /update_rpc accountAddress rpc")
		return msg
	}

	msg = "RPC updated successfully!!"

	return msg
}

func UpdateLCD(cfg *config.Config, args []string) string {
	var msg string

	if len(args) != 0 && len(args) == 3 {
		address := args[1]
		lcd := args[2]

		query := bson.M{
			"account_address": address,
		}

		update := bson.M{
			"$set": bson.M{
				"lcd": lcd,
			},
		}

		err := UpdateAddress(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating lcd : %v", err)
			if err.Error() == "not found" {
				msg = fmt.Sprintf("Address %s not found in database.", address)
			}
			return msg
		}

		err = UpdateAccBalance(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating lcd address : %v", err)
			return msg
		}

	} else {
		msg = fmt.Sprintf("Please check your input format\n Ex:  /update_lcd accountAddress lcd")
		return msg
	}

	msg = "LCD updated successfully!!"

	return msg
}
