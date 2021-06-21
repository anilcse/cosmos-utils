package targets

import (
	"encoding/json"
	"fmt"
	"log"
	"math"
	"net/http"
	"strconv"

	"golang.org/x/text/language"
	"golang.org/x/text/message"
	"gopkg.in/mgo.v2/bson"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
)

func BalanceChangeAlerts(cfg *config.Config) error {
	var ops HTTPOptions

	addresses, err := GetAllAddress(bson.M{}, bson.M{}, "relayer")

	for _, add := range addresses {
		if add.NetworkName == "akash" || add.NetworkName == "cosmos" || add.NetworkName == "osmosis" {

			ops = HTTPOptions{
				Endpoint: add.LCD + "/cosmos/bank/v1beta1/balances/" + add.AccountAddress,
				Method:   http.MethodGet,
			}

			resp, err := HitHTTPTarget(ops)
			if err != nil {
				log.Printf("Error in get account info: %v", err)
				return err
			}

			var accResp AccountBalance
			err = json.Unmarshal(resp.Body, &accResp)
			if err != nil {
				log.Printf("Error while unmarshelling AccountResp: %v", err)
				return err
			}

			if len(accResp.Balances) > 0 {
				amount := accResp.Balances[0].Amount

				query := bson.M{
					"lcd":             add.LCD,
					"network_name":    add.NetworkName,
					"account_address": add.AccountAddress,
				}
				prevBal, err := GetAccBalance(query, bson.M{}, "relayer")
				if err != nil {
					log.Printf("Error while getting prev balance : %v", err)

					if err.Error() == "not found" {
						log.Printf("Address not found %v", err)
					}
				}

				prevAmount := prevBal.Balance
				if prevAmount != amount {
					amount1 := ConvertToFolat64(prevAmount)
					amount2 := ConvertToFolat64(amount)
					balChange := amount1 - amount2
					if balChange < 0 {
						balChange = -(balChange)
					}
					if balChange > cfg.DelegationAlerts.AccBalanceChangeThreshold {
						a1 := convertToCommaSeparated(fmt.Sprintf("%f", amount1)) + add.DisplayDenom
						a2 := convertToCommaSeparated(fmt.Sprintf("%f", amount2)) + add.DisplayDenom
						_ = SendTelegramAlert(fmt.Sprintf("Your account balance has changed from  %s to %s", a1, a2), cfg)
						_ = SendEmailAlert(fmt.Sprintf("Your account balance has changed from  %s to %s", a1, a2), cfg)
					}
				}

				updateObj := bson.M{
					"$set": bson.M{
						"balance": amount,
					},
				}

				err = UpdateAccBalance(query, updateObj, "relayer")
				if err != nil {
					log.Printf("Error while updating acc balance")
				}
				log.Printf("Address Balance: %s \t and denom : %s", amount, prevAmount)
			}
		}
	}

	return err
}

// ConvertToFolat64 converts balance from string to float64
func ConvertToFolat64(balance string) float64 {
	bal, _ := strconv.ParseFloat(balance, 64)

	a1 := bal / math.Pow(10, 6)
	amount := fmt.Sprintf("%.6f", a1)

	a, err := strconv.ParseFloat(amount, 64)
	if err != nil {
		log.Printf("Error while converting string to folat64 : %v", err)
	}

	return a
}

func convertToCommaSeparated(amt string) string {
	a, err := strconv.Atoi(amt)
	if err != nil {
		return amt
	}
	p := message.NewPrinter(language.English)
	return p.Sprintf("%d", a)
}
