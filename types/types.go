package types

import (
	"gopkg.in/mgo.v2/bson"
)

type (
	Address struct {
		ID              bson.ObjectId `json:"_id" bson:"_id,omitempty"`
		NetworkName     string        `json:"network_name" bson:"network_name"`
		AccountNickName string        `json:"account_nick_name" bson:"account_nick_name"`
		AccountAddress  string        `json:"accont_address" bson:"account_address"`
		RPC             string        `json:"rpc" bson:"rpc"`
		LCD             string        `json:"lcd" bson:"lcd"`
		Denom           string        `json:"denom" bson:"denom"`
		DisplayDenom    string        `json:"display_denom" bson:"display_denom"`
		Threshold       string        `json:"threshold_alert" bson:"threshold_alert"`
	}

	Balances struct {
		ID              bson.ObjectId `json:"_id" bson:"_id,omitempty"`
		NetworkName     string        `json:"network_aame" bson:"network_name"`
		AccountNickName string        `json:"account_nick_ame" bson:"account_nick_name"`
		AccountAddress  string        `json:"accont_ddress" bson:"account_address"`
		LCD             string        `json:"lcd" bson:"lcd"`
		Denom           string        `json:"denom" bson:"denom"`
		Balance         string        `json:"balance" bson:"balance"`
		DialyBalance    string        `json:"daily_balance" bson:"daily_balance"`
		Threshold       string        `json:"threshold_alert" bson:"threshold_alert"`
	}
)
