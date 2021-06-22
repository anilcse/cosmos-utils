package targets

import (
	"log"

	"gopkg.in/mgo.v2/bson"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
)

func AddAddress(cfg *config.Config, args []string) string {
	var msg = ""

	if len(args) != 0 && len(args) < 9 {
		msg := `Please check your input format, it should be

		/add_address <networkName> <accountNickName> <accountAddress> <rpc> <lcd> <denom> <displayDenom> <thresholdAlert>
	
		ex : /add_address osmosis regen-osmosis-relayer accountaddress https://... https://... uosmo OSMO 100
		`
		return msg
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

		err := InsertNewAddress(address, cfg.MongoDB.Database) // store in db
		if err != nil {
			log.Printf("Error while inserting new address details : %v", err)
			return err.Error()
		}

		endPoint := address.LCD + "/cosmos/bank/v1beta1/balances/" + address.AccountAddress
		bal, den, err := requestBal(endPoint)
		if err != nil {
			log.Printf("Error while getting balance from endpoint : %v", err)
		}
		balance := Balances{
			ID:              bson.NewObjectId(),
			NetworkName:     networkName,
			AccountNickName: accName,
			AccountAddress:  accAddress,
			LCD:             lcd,
			Balance:         bal,
			Denom:           den,
			DialyBalance:    bal,
			Threshold:       threshold,
		}

		err = AddAccBalance(balance, cfg.MongoDB.Database) // store in db
		if err != nil {
			log.Printf("Error while adding acc address details : %v", err)
			return err.Error()
		}

		msg = "Details added successfully!!"
	} else {
		msg := `Please check your input format, it should be

		/add_address <networkName> <accountNickName> <accountAddress> <rpc> <lcd> <denom> <displayDenom> <thresholdAlert>
	
		ex : /add_address osmosis regen-osmosis-relayer accountaddress https://... https://... uosmo OSMO 100
		`
		return msg
	}

	return msg
}
