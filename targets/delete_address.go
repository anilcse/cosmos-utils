package targets

import (
	"fmt"

	"gopkg.in/mgo.v2/bson"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
)

func DeleteAddressFromDB(cfg *config.Config, args []string) string {
	var msg string

	if len(args) != 0 && len(args) == 3 {
		accName := args[1]
		address := args[2]

		query := bson.M{
			"account_nick_name": accName,
			"account_address":   address,
		}

		err := DeleteAddress(query, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while deleting address from db : %v", err)
		}

		err = DeleteBalance(query, cfg.MongoDB.Database)
		if err != nil {
			msg = fmt.Sprintf("Error while deleting address from db : %v", err)
			return msg
		}
	} else {
		msg = fmt.Sprintf("Please check your input format\n Ex:  /delete_address accountNickName accountAddress")
		return msg
	}

	msg = "Deleted Successfully!!"

	return msg
}
