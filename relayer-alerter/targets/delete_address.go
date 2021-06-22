package targets

import (
	"fmt"

	"gopkg.in/mgo.v2/bson"

	"github.com/vitwit/cosmos-utils/relayer-alerter/config"
	"github.com/vitwit/cosmos-utils/relayer-alerter/db"
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

		err := db.DeleteAddress(query, cfg.MongoDB.Database)
		if err != nil {
			// msg = fmt.Sprintf("Error while deleting address from db : %v", err)
			if err.Error() == "not found" {
				msg = "Address NOT FOUND in database"
			}
			return msg
		}

		err = db.DeleteBalance(query, cfg.MongoDB.Database)
		if err != nil {
			// msg = fmt.Sprintf("Error while deleting address from db : %v", err)
			if err.Error() == "not found" {
				msg = "Address NOT FOUND in database"
			}
			return msg
		}

	} else {
		msg = fmt.Sprintf("Please check your input format\n Example:  /delete_address akash-relayer akash1qwlcuf2c2dhtgy8z5y7xmqev56km0n5axnpeqq")
		return msg
	}

	msg = "Deleted Successfully!!"

	return msg
}
