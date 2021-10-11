package src

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
)
