package main

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"

	log "github.com/sirupsen/logrus"

	codecTypes "github.com/cosmos/cosmos-sdk/codec/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	tmTypes "github.com/tendermint/tendermint/abci/types"
)

const RequestPrefix = "https://api.cosmostation.io/v1/account/new_txs/"

type TxHeader struct {
	ID        int    `json:"id"`
	ChainID   string `json:"chain_id"`
	BlockID   int    `json:"block_id"`
	Timestamp string `json:"timestamp"`
}

type TxData struct {
	Height    string              `json:"height,omitempty"`
	TxHash    string              `json:"txhash,omitempty"`
	Codespace string              `json:"codespace,omitempty"`
	Code      int                 `json:"code,omitempty"`
	Data      string              `json:"data,omitempty"`
	RawLog    string              `json:"raw_log,omitempty"`
	Logs      sdk.ABCIMessageLogs `json:"logs"`
	Info      string              `json:"info,omitempty"`
	GasWanted string              `json:"gas_wanted,omitempty"`
	GasUsed   string              `json:"gas_used,omitempty"`
	Tx        *codecTypes.Any     `json:"tx,omitempty"`
	Timestamp string              `json:"timestamp,omitempty"`
	Events    []tmTypes.Event     `json:"events"`
}

type Tx struct {
	Header TxHeader `json:"header"`
	Data   TxData   `json:"data"`
}

func collectAllTxns(address string) error {
	fromId := "0"

	dataFile, err := os.Create("data.csv")
	if err != nil {
		return fmt.Errorf("Error in creating the CSV file: %s", err.Error())
	}

	defer dataFile.Close()

	writer := csv.NewWriter(dataFile)
	defer writer.Flush()

	header := []string{
		"ID",
		"ChainID",
		"BlockID",
		"Height",
		"TxHash",
		"Codespace",
		"Code",
		"Data",
		"RawLog",
		"Logs",
		"Info",
		"GasWanted",
		"GasUsed",
		"Tx",
		"Timestamp",
	}
	if err = writer.Write(header); err != nil {
		return fmt.Errorf("Error in writing header info: %s", err.Error())
	}

	for {
		req := RequestPrefix + address + "?limit=20&from=" + fromId
		log.Infof("Compiled request: %s", req)
		resp, err := http.Get(req)
		if err != nil {
			return fmt.Errorf("Error in fetching the txn data: %s", err.Error())
		}

		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return fmt.Errorf("Error in reading response body: %s", err.Error())
		}

		var txs []Tx
		if err = json.Unmarshal(body, &txs); err != nil {
			return fmt.Errorf("Error in unmarshaling the JSON data: %s", err.Error())
		}

		if len(txs) == 0 {
			break
		}

		for _, tx := range txs {
			logs, err := json.Marshal(tx.Data.Logs)
			if err != nil {
				return fmt.Errorf("Error in marshaling logs: %s", err.Error())
			}

			txn, err := json.Marshal(tx.Data.Tx)
			if err != nil {
				return fmt.Errorf("Error in marshaling Tx: %s", err.Error())
			}

			data := []string{
				strconv.Itoa(tx.Header.ID),
				tx.Header.ChainID,
				strconv.Itoa(tx.Header.BlockID),
				tx.Data.Height,
				tx.Data.TxHash,
				tx.Data.Codespace,
				strconv.Itoa(tx.Data.Code),
				tx.Data.Data,
				tx.Data.RawLog,
				string(logs),
				tx.Data.Info,
				tx.Data.GasWanted,
				tx.Data.GasUsed,
				string(txn),
				tx.Data.Timestamp,
			}

			if err = writer.Write(data); err != nil {
				return fmt.Errorf("Error in writing data: %s", err.Error())
			}
		}

		fromId = strconv.Itoa(txs[len(txs)-1].Header.ID)
	}

	return nil
}

func main() {
	args := os.Args
	if len(args) < 2 {
		log.Fatal("Failed to collect txs: address not provided")
	}
	address := args[1]
	log.Infof("Fetching the details of the txs for the address: %s", address)
	err := collectAllTxns(address)
	if err != nil {
		log.Errorf("collecting all transactions failed: %s", err.Error())
	} else {
		log.Info("fetching txs complete!")
	}
}
