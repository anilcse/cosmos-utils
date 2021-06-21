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
				"threshold": threshold,
			},
		}

		err := UpdateAddress(query, update, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while updating threshold : %v", err)
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
