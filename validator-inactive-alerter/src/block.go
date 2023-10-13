package src

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/vitwit/cosmos-utils/validator-inactive-alerter/config"
	"github.com/vitwit/cosmos-utils/validator-inactive-alerter/types"
)

func GetBlockSigns(cfg *config.Config) error {
	var latestBlock types.LatestBlock

	ops := HTTPOptions{
		Endpoint: cfg.LCDEndpoint + "/blocks/latest",
		Method:   http.MethodGet,
	}

	resp, err := HitHTTPTarget(ops)
	if err != nil {
		log.Printf("Error while getting latest block info: %v", err)
		return err
	}

	err = json.Unmarshal(resp.Body, &latestBlock)
	if err != nil {
		log.Printf("Error while unmarshelling Block response: %v", err)
		return err
	}

	previousBlock, err := strconv.Atoi(latestBlock.Block.Header.Height)
	if err != nil {
		log.Printf("Error while converting height to int")
	}

	previousBlockHeight := strconv.Itoa(previousBlock - 1)
	ops = HTTPOptions{
		Endpoint: "http://" + cfg.RPCEndpoint + "/block?height=" + previousBlockHeight,
		Method:   http.MethodGet,
	}

	res, err := HitHTTPTarget(ops)
	if err != nil {
		log.Printf("Error while getting previous block details: %v", err)
		return err
	}

	var pBlock types.Block
	err = json.Unmarshal(res.Body, &pBlock)
	if err != nil {
		log.Printf("Error while unmarshelling previous Block response: %v", err)
		return err
	}

	log.Printf("Len of latest block sign : %v and previous block : %v", len(latestBlock.Block.LastCommit.Signatures), len(pBlock.Result.Block.LastCommit.Signatures))

	count := 0
	for _, v1 := range latestBlock.Block.LastCommit.Signatures {
		count = 0
		val := v1.ValidatorAddress
		for _, v2 := range pBlock.Result.Block.LastCommit.Signatures {
			if val == v2.ValidatorAddress {
				count++
				break
			}
		}
		if count == 0 {
			log.Printf("This validator has missed : %v", val)
		}
	}

	return nil
}
