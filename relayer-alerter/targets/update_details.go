package targets

import (
	"fmt"

	"gopkg.in/mgo.v2/bson"

	"github.com/vitwit/cosmos-utils/relayer-alerter/config"
	"github.com/vitwit/cosmos-utils/relayer-alerter/db"
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

		err := db.UpdateAddress(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating threshold : %v", err)
			if err.Error() == "not found" {
				msg = fmt.Sprintf("Account %s and address %s NOT FOUND in database", accName, address)
			}
			return msg
		}

		err = db.UpdateAccBalance(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating threshold : %v", err)
			return msg
		}

	} else {
		msg = fmt.Sprintf("Please check your input format\n- Format:  /update_threshold <accountNickName> <accountAddress> <threshold>\n\n- Example:: /update_threshold akash-relayer akash1qwlcuf2c2dhtgy8z5y7xmqev56km0n5axnpeqq 5")
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

		err := db.UpdateAddress(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating rpc : %v", err)
			if err.Error() == "not found" {
				msg = fmt.Sprintf("Address %s not found in database.", address)
			}
			return msg
		}
	} else {
		msg = fmt.Sprintf("Please check your input format\n- Format: /update_rpc <accountAddress> <rpc>\n\n Example :: /update_rpc akash1qwlcuf2c2dhtgy8z5y7xmqev56km0n5axnpeqq https://localhost:26657")
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

		err := db.UpdateAddress(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating lcd : %v", err)
			if err.Error() == "not found" {
				msg = fmt.Sprintf("Address %s NOT FOUND in database.", address)
			}
			return msg
		}

		err = db.UpdateAccBalance(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating lcd address : %v", err)
			return msg
		}

	} else {
		msg = fmt.Sprintf("Please check your input format\n- Format ::  /update_lcd <accountAddress> <lcd>\n\n- Example :: /update_lcd akash1qwlcuf2c2dhtgy8z5y7xmqev56km0n5axnpeqq https://localhost:1317")
		return msg
	}

	msg = "LCD updated successfully!!"

	return msg
}
