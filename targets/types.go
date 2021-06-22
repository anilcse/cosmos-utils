package targets

type (
	// QueryParams to map the query params of an url
	QueryParams map[string]string

	// HTTPOptions of a target
	HTTPOptions struct {
		Endpoint    string
		QueryParams QueryParams
		Body        []byte
		Method      string
	}

	// PingResp struct
	PingResp struct {
		StatusCode int
		Body       []byte
	}

	// AccountBalance struct which holds the parameters of an account amount
	AccountBalance struct {
		Balances []struct {
			Denom  string `json:"denom"`
			Amount string `json:"amount"`
		} `json:"balances"`
		Pagination interface{} `json:"pagination"`
	}

	// Address struct {
	// 	ID              bson.ObjectId `json:"_id" bson:"_id,omitempty"`
	// 	NetworkName     string        `json:"networkName" bson:"network_name"`
	// 	AccountNickName string        `json:"accountNickName" bson:"account_nick_name"`
	// 	AccountAddress  string        `json:"accontAddress" bson:"account_address"`
	// 	RPC             string        `json:"rpc" bson:"rpc"`
	// 	LCD             string        `json:"lcd" bson:"lcd"`
	// 	Denom           string        `json:"denom" bson:"denom"`
	// 	DisplayDenom    string        `json:"displayDenom" bson:"display_denom"`
	// 	Threshold       string        `json:"thresholdAlert" bson:"threshold_alert"`
	// }

	// Balances struct {
	// 	ID              bson.ObjectId `json:"_id" bson:"_id,omitempty"`
	// 	NetworkName     string        `json:"networkName" bson:"network_name"`
	// 	AccountNickName string        `json:"accountNickName" bson:"account_nick_name"`
	// 	AccountAddress  string        `json:"accontAddress" bson:"account_address"`
	// 	LCD             string        `json:"lcd" bson:"lcd"`
	// 	Denom           string        `json:"denom" bson:"denom"`
	// 	Balance         string        `json:"balance" bson:"balance"`
	// 	DialyBalance    string        `json:"daily_balance" bson:"daily_balance"`
	// 	Threshold       string        `json:"thresholdAlert" bson:"threshold_alert"`
	// }
)
