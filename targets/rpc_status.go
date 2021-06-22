package targets

import (
	"fmt"
	"log"
	"net/http"

	"gopkg.in/mgo.v2/bson"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
)

// GetEndpointsStatus to get alert about endpoints status
func GetEndpointsStatus(cfg *config.Config) error {
	var ops HTTPOptions

	addresses, err := GetAllAddress(bson.M{}, bson.M{}, cfg.MongoDB.Database)
	if err != nil {
		log.Printf("Error while getting addresses list from db : %v", err)
		return err
	}
	var msg string

	for _, value := range addresses {
		ops = HTTPOptions{
			Endpoint: value.RPC + "/status",
			Method:   http.MethodGet,
		}

		_, err := HitHTTPTarget(ops)
		if err != nil {
			log.Printf("Error in rpc: %v", err)
			msg = msg + fmt.Sprintf("⛔⛔ Unreachable to RPC :: %s and the ERROR is : %v\n\n", ops.Endpoint, err.Error())
		}

		ops = HTTPOptions{
			Endpoint: value.LCD + "/node_info",
			Method:   http.MethodGet,
		}

		_, err = HitHTTPTarget(ops)
		if err != nil {
			log.Printf("Error in lcd endpoint: %v", err)
			msg = msg + fmt.Sprintf("⛔⛔ Unreachable to LCD :: %s and the ERROR is : %v\n\n", ops.Endpoint, err.Error())
		}
	}

	if msg != "" {
		_ = SendTelegramAlert(msg, cfg)
	}

	return nil
}
