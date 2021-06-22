package targets

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"

	"gopkg.in/mgo.v2/bson"

	"github.com/vitwit/cosmos-utils/relayer-alerter/config"
	"github.com/vitwit/cosmos-utils/relayer-alerter/db"
	"github.com/vitwit/cosmos-utils/relayer-alerter/utils"
)

func BalanceChangeAlerts(cfg *config.Config) error {
	addresses, err := db.GetAllAddress(bson.M{}, bson.M{}, cfg.MongoDB.Database)

	for _, add := range addresses {
		// if strings.EqualFold(add.NetworkName, "akash") == true || strings.EqualFold(add.NetworkName, "cosmos") == true || strings.EqualFold(add.NetworkName, "osmosis") == true ||
		// 	strings.EqualFold(add.NetworkName, "regen") == true || strings.EqualFold(add.NetworkName, "sentinel") == true {

		endPoint := add.LCD + "/cosmos/bank/v1beta1/balances/" + add.AccountAddress
		amount, denom, err := requestBal(endPoint)
		if err != nil {
			log.Printf("Error while getting response from balance endpoint : %v", err)
			return err
		}

		if amount != "" {
			// amount = accResp.Balances[0].Amount
			presentBal := utils.ConvertValue(amount, denom)

			// threshold := ConvertToFolat64(add.Threshold)
			threshold, err := strconv.ParseFloat(add.Threshold, 64)
			if err != nil {
				log.Printf("Error while conversting threshold value to float64 : %v", err)
			}

			if presentBal < threshold {
				t := add.Threshold + " " + add.DisplayDenom
				err = SendTelegramAlert(fmt.Sprintf("ACTION REQUIRED:\n- Your %s balance has dropped below %s\n -Current account balance : %f %s", add.AccountNickName, t, presentBal, add.DisplayDenom), cfg)
				if err != nil {
					log.Printf("Error while sending telegram alert : %v", err)
				}
			}

			query := bson.M{
				"lcd":             add.LCD,
				"network_name":    add.NetworkName,
				"account_address": add.AccountAddress,
			}

			updateObj := bson.M{
				"$set": bson.M{
					"denom":   denom,
					"balance": amount,
				},
			}

			err = db.UpdateAccBalance(query, updateObj, cfg.MongoDB.Database)
			if err != nil {
				log.Printf("Error while updating acc balance")
			}
			log.Printf("Address Balance: %s \t and denom : %s", amount, denom)
		}
		// }
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
			addresses, err := db.GetAllAddress(bson.M{}, bson.M{}, cfg.MongoDB.Database)

			msg := fmt.Sprintf("Daily balance update: \n")
			for _, add := range addresses {

				// if strings.EqualFold(add.NetworkName, "akash") == true || strings.EqualFold(add.NetworkName, "cosmos") == true || strings.EqualFold(add.NetworkName, "osmosis") == true ||
				// 	strings.EqualFold(add.NetworkName, "regen") == true || strings.EqualFold(add.NetworkName, "sentinel") == true {

				endPoint := add.LCD + "/cosmos/bank/v1beta1/balances/" + add.AccountAddress
				amount, denom, err := requestBal(endPoint)
				if err != nil {
					log.Printf("Error while getting data from %s", endPoint)
					return err
				}

				if amount != "" {
					// amount := accResp.Balances[0].Amount

					query := bson.M{
						"lcd":             add.LCD,
						"network_name":    add.NetworkName,
						"account_address": add.AccountAddress,
					}
					prevBalance, err := db.GetAccBalance(query, bson.M{}, cfg.MongoDB.Database)
					if err != nil {
						log.Printf("Error while getting prev balance : %v", err)

						if err.Error() == "not found" {
							log.Printf("Address not found %v", err)
						}
					}

					prevAmount := prevBalance.DialyBalance
					presentBal := utils.ConvertValue(amount, denom)
					prevBal := utils.ConvertValue(prevAmount, denom)

					diff := presentBal - prevBal
					if diff > 0 {
						a := utils.ConvertToCommaSeparated(fmt.Sprintf("%f", presentBal)) + " " + add.DisplayDenom
						msg = msg + fmt.Sprintf("%s : %s (%f %s is increased from last 12 hours)\n", add.AccountNickName, a, diff, add.DisplayDenom)
					} else if diff < 0 {
						a := utils.ConvertToCommaSeparated(fmt.Sprintf("%f", presentBal)) + " " + add.DisplayDenom
						msg = msg + fmt.Sprintf("%s : %s (%f %s is decreased from last 12 hours)\n", add.AccountNickName, a, -(diff), add.DisplayDenom)
					} else {
						a := utils.ConvertToCommaSeparated(fmt.Sprintf("%f", presentBal)) + " " + add.DisplayDenom
						msg = msg + fmt.Sprintf("%s : %s (Is same as last 12 hours)\n", add.AccountNickName, a)
					}

					updateObj := bson.M{
						"$set": bson.M{
							"daily_balance": amount,
						},
					}

					err = db.UpdateAccBalance(query, updateObj, cfg.MongoDB.Database)
					if err != nil {
						log.Printf("Error while updating acc balance")
					}
					log.Printf("Presnt Balance: %s \t and Previous Amount : %s", amount, prevAmount)
				}
				// }

			}

			err = SendTelegramAlert(msg, cfg)
			if err != nil {
				log.Printf("Error while sending telegram alert : %v", err)
				return err
			}

		}
	}
	return nil
}

func requestBal(endPoint string) (string, string, error) {
	var accResp AccountBalance
	var amount string
	var denom string

	ops := HTTPOptions{
		Endpoint: endPoint,
		Method:   http.MethodGet,
	}

	resp, err := HitHTTPTarget(ops)
	if err != nil {
		log.Printf("Error while getting balance info: %v", err)
		return amount, denom, err
	}
	err = json.Unmarshal(resp.Body, &accResp)
	if err != nil {
		log.Printf("Error while unmarshelling AccountResp: %v", err)
		return amount, denom, err
	}

	for _, value := range accResp.Balances {
		if value.Denom == "uakt" {
			amount = value.Amount
			denom = value.Denom
			break
		} else if value.Denom == "uosmo" {
			amount = value.Amount
			denom = value.Denom
			break
		} else if value.Denom == "uatom" {
			amount = value.Amount
			denom = value.Denom
			break
		} else if value.Denom == "uregen" {
			amount = value.Amount
			denom = value.Denom
			break
		} else if value.Denom == "udvpn" {
			amount = value.Amount
			denom = value.Denom
			break
		} else if value.Denom == "uxprt" {
			amount = value.Amount
			denom = value.Denom
			break
		} else if value.Denom == "uiris" {
			amount = value.Amount
			denom = value.Denom
			break
		} else if value.Denom == "basecro" {
			amount = value.Amount
			denom = value.Denom
			break
		} else {
			amount = value.Amount
			denom = value.Denom
		}
	}

	return amount, denom, nil
}
