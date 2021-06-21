package targets

import (
	"encoding/json"
	"fmt"
	"log"
	"math"
	"net/http"
	"strconv"
	"time"

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
				presentBal := ConvertToFolat64(amount)

				threshold := ConvertToFolat64(add.Threshold)

				if presentBal < threshold {
					t := add.Threshold + add.DisplayDenom
					_ = SendTelegramAlert(fmt.Sprintf("ACTION REQUIRED\n Your %s balance has dropped below %s", add.AccountNickName, t), cfg)
				}

				query := bson.M{
					"lcd":             add.LCD,
					"network_name":    add.NetworkName,
					"account_address": add.AccountAddress,
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
				log.Printf("Address Balance: %s \t and denom : %s", amount, add.DisplayDenom)
			}
		}
	}

	return err
}

func DailyBalAlerts(cfg *config.Config) error {
	now := time.Now().UTC()
	currentTime := now.Format(time.Kitchen)

	var alertsArray []string

	for _, value := range cfg.RegularStatusAlerts.AlertTimings {
		t, _ := time.Parse(time.Kitchen, value)
		alertTime := t.Format(time.Kitchen)

		alertsArray = append(alertsArray, alertTime)
	}

	log.Printf("Current time :  %v and alerts array : %v", currentTime, alertsArray)

	for _, statusAlertTime := range alertsArray {
		if currentTime == statusAlertTime {
			addresses, err := GetAllAddress(bson.M{}, bson.M{}, "relayer")

			msg := fmt.Sprintf("Daily balance update: \n")
			for _, add := range addresses {

				if add.NetworkName == "akash" || add.NetworkName == "cosmos" || add.NetworkName == "osmosis" {
					endPoint := add.LCD + "/cosmos/bank/v1beta1/balances/" + add.AccountAddress
					accResp, err := requestBal(endPoint)
					if err != nil {
						log.Printf("Error while getting data from %s", endPoint)
						return err
					}

					if len(accResp.Balances) > 0 {
						amount := accResp.Balances[0].Amount

						query := bson.M{
							"lcd":             add.LCD,
							"network_name":    add.NetworkName,
							"account_address": add.AccountAddress,
						}
						prevBalance, err := GetAccBalance(query, bson.M{}, "relayer")
						if err != nil {
							log.Printf("Error while getting prev balance : %v", err)

							if err.Error() == "not found" {
								log.Printf("Address not found %v", err)
							}
						}

						prevAmount := prevBalance.DialyBalance
						presentBal := ConvertToFolat64(amount)
						prevBal := ConvertToFolat64(prevAmount)

						diff := presentBal - prevBal
						if diff > 0 {
							a := convertToCommaSeparated(fmt.Sprintf("%f", presentBal)) + add.DisplayDenom
							msg = msg + fmt.Sprintf("%s : %s (%f %s is increased from last day)\n", add.AccountNickName, a, diff, add.DisplayDenom)
						} else if diff < 0 {
							a := convertToCommaSeparated(fmt.Sprintf("%f", presentBal)) + add.DisplayDenom
							msg = msg + fmt.Sprintf("%s : %s (%f %s is decreased from last day)\n", add.AccountNickName, a, -(diff), add.DisplayDenom)
						} else {
							a := convertToCommaSeparated(fmt.Sprintf("%f", presentBal)) + add.DisplayDenom
							msg = msg + fmt.Sprintf("%s : %s (Is same as last day)\n", add.AccountNickName, a)
						}

						updateObj := bson.M{
							"$set": bson.M{
								"daily_balance": amount,
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
			err = SendTelegramAlert(msg, cfg)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func requestBal(endPoint string) (AccountBalance, error) {
	var accResp AccountBalance
	ops := HTTPOptions{
		Endpoint: endPoint,
		Method:   http.MethodGet,
	}

	resp, err := HitHTTPTarget(ops)
	if err != nil {
		log.Printf("Error in get account info: %v", err)
		return accResp, err
	}
	err = json.Unmarshal(resp.Body, &accResp)
	if err != nil {
		log.Printf("Error while unmarshelling AccountResp: %v", err)
		return accResp, err
	}

	return accResp, nil
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
