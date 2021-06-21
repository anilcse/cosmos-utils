package targets

import (
	"log"

	"gopkg.in/mgo.v2/bson"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
)

func AddAddress(cfg *config.Config, args []string) string {
	// msg := `Please provide details in following way
	// /add_address <networkName> <accountNickName> <accountAddress> <rpc> <lcd> <denom> <displayDenom> <thresholdAlert>

	// ex : /add_address osmosis regen-osmosis-relayer accountaddress https://... https://... uosmo OSMO 100
	// `

	var msg = ""

	if len(args) != 0 && len(args) < 9 {
		return "Seems to be missing some values, please check your input"
	} else if len(args) == 9 {
		networkName := args[1]
		accName := args[2]
		accAddress := args[3]
		rpc := args[4]
		lcd := args[5]
		denom := args[6]
		disDenom := args[7]
		threshold := args[8]

		address := Address{
			ID:              bson.NewObjectId(),
			NetworkName:     networkName,
			AccountNickName: accName,
			AccountAddress:  accAddress,
			RPC:             rpc,
			LCD:             lcd,
			Denom:           denom,
			DisplayDenom:    disDenom,
			Threshold:       threshold,
		}

		err := InsertNewAddress(address, "relayer")
		if err != nil {
			log.Printf("Error while inserting new address details : %v", err)
			return err.Error()
		}

		msg = "Details added successfully!!"
	}

	return msg
}
