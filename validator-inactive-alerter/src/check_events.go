package src

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"log"
	"strings"

	"github.com/cosmos/cosmos-sdk/types/bech32"
	slashingTypes "github.com/cosmos/cosmos-sdk/x/slashing/types"
	rpchttp "github.com/tendermint/tendermint/rpc/client/http"
	ctypes "github.com/tendermint/tendermint/rpc/core/types"
	"github.com/tendermint/tendermint/types"

	"github.com/vitwit/cosmos-utils/validator-inactive-alerter/config"
)

var eventTypes = []string{
	"NewBlock",
}

func SubscribeTMEvents(client *rpchttp.HTTP, ctx context.Context) (map[string]<-chan ctypes.ResultEvent, error) {
	eventList := make(map[string]<-chan ctypes.ResultEvent)
	for _, event := range eventTypes {
		evName := fmt.Sprintf("tm.event = '%s'", event)
		ev, err := client.Subscribe(ctx, event, evName)
		if err != nil {
			log.Printf("Event subscribe failed : %v", err)
			return nil, err
		} else {
			log.Printf("Event subscribe is done : %v", err)
			eventList[event] = ev
		}
	}

	return eventList, nil
}

// SubscribeEvents will subscribe the rpc events
func SubscribeEvents(client *rpchttp.HTTP, ctx context.Context, cfg *config.Config) {
	eventList, err := SubscribeTMEvents(client, ctx)
	if err != nil {
		log.Printf("failed to subscribe to tx events : %v", err)
		return
	}

	cAddr, err := ConsAddressFromHex(cfg.HexAddress)
	if err != nil {
		log.Printf("Error while converting hex to cons address : %v", err)
	}

	valConsAddr, err := bech32.ConvertAndEncode(cfg.ConsAddrPrefix, cAddr)
	if err != nil {
		log.Printf("Error while converting hex to cons add : %v", err)
	}
	log.Printf("Converted val cons address : %v", valConsAddr)

	for {
		select {
		case block := <-eventList["NewBlock"]:
			eventBlock := block.Data.(types.EventDataNewBlock)
			log.Printf("Check for slash events..")

			for _, value := range eventBlock.ResultBeginBlock.Events {
				if value.Type == slashingTypes.EventTypeSlash {
					log.Printf("slash response : %v", value.Attributes)
					for _, a := range value.Attributes {
						log.Printf("key : %v and value : %v", string(a.Key), string(a.Value))

						if string(a.Key) == "address" && string(a.Value) == valConsAddr {

							err = SendTelegramAlert(fmt.Sprintf("Your %s validator %s has been slashed", cfg.NetworkName, cfg.Moniker), cfg)
							if err != nil {
								log.Printf("Error while sending telegram alert : %v", err)
							}
						}
					}
				}
			}
		}
	}
}

type ConsAddress []byte

func addressBytesFromHexString(address string) ([]byte, error) {
	if len(address) == 0 {
		return nil, errors.New("decoding Bech32 address failed: must provide an address")
	}

	return hex.DecodeString(address)
}

// ConsAddressFromHex creates a ConsAddress from a hex string.
func ConsAddressFromHex(address string) (ConsAddress, error) {
	bz, err := addressBytesFromHexString(address)
	return bz, err
}

func GetHex(ConsAddress string) string {
	_, converted, err := bech32.DecodeAndConvert(ConsAddress)
	if err != nil {
		fmt.Println("unable to decode bech32")
	}
	hexAddr := hex.EncodeToString(converted)

	newHex := strings.ToUpper(hexAddr)

	return newHex
}
