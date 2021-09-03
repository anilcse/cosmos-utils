package main

import (
	"context"
	"fmt"
	"log"
	"time"

	rpchttp "github.com/tendermint/tendermint/rpc/client/http"

	"github.com/vitwit/cosmos-utils/validator-inactive-alerter/config"
	"github.com/vitwit/cosmos-utils/validator-inactive-alerter/src"
)

func main() {
	cfg, err := config.ReadConfigFromFile()
	if err != nil {
		log.Fatal(err)
	}

	client, err := rpchttp.New(fmt.Sprintf("tcp://%s", cfg.RPCEndpoint), "/websocket")
	if err != nil {
		log.Fatalf("Error while creating ws handshake : %v", err)
	}
	err = client.Start()
	if err != nil {
		log.Fatalf("Error while starting client : %v", err)
	}

	defer client.Stop()
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	src.SubscribeEvents(client, ctx, cfg)
}

// var eventTypes = []string{
// 	"Tx",
// 	"NewBlock",
// 	"ValidatorSetUpdates",
// }

// func SubscribeTMEvents(client *rpchttp.HTTP, ctx context.Context) (map[string]<-chan ctypes.ResultEvent, error) {
// 	eventList := make(map[string]<-chan ctypes.ResultEvent)
// 	for _, event := range eventTypes {
// 		evName := fmt.Sprintf("tm.event = '%s'", event)
// 		ev, err := client.Subscribe(ctx, event, evName)
// 		if err != nil {
// 			log.Printf("Event subscribe failed : %v", err)
// 			return nil, err
// 		} else {
// 			log.Printf("Event subscribe is done : %v", err)
// 			eventList[event] = ev
// 		}
// 	}

// 	return eventList, nil
// }

// // SubscribeEvents will subscribe the rpc events
// func SubscribeEvents(client *rpchttp.HTTP, ctx context.Context) {
// 	eventList, err := SubscribeTMEvents(client, ctx)
// 	if err != nil {
// 		log.Printf("failed to subscribe to tx events : %v", err)
// 		return
// 	}

// 	for {
// 		select {
// 		case block := <-eventList["NewBlock"]:
// 			eventBlock := block.Data.(types.EventDataNewBlock)
// 			// log.Printf("New block. : %v", eventBlock.ResultBeginBlock.Events)
// 			for _, value := range eventBlock.ResultBeginBlock.Events {
// 				// log.Println("Value...", value.Type)
// 				if value.Type == slashingTypes.EventTypeLiveness {
// 					log.Printf("liveness response : %v", value.Attributes)
// 					for _, a := range value.Attributes {
// 						// address := value.Attributes["address"]
// 						log.Printf("key : %v and value : %v", string(a.Key), string(a.Value))
// 						aa, bb := ConsAddressFromHex("82931915D1796FDB6F7237B586177623B74FF0A4")

// 						bech32Addr, err := bech32.ConvertAndEncode("akashvalcons", aa)
// 						if err != nil {
// 							panic(err)
// 						}

// 						log.Fatalf("aa and bb and cc and hex : %v and %v and %v and %v", aa, bech32Addr, bb, hex)
// 					}
// 				}
// 			}
// 		}
// 	}
// }

// type ConsAddress []byte

// func addressBytesFromHexString(address string) ([]byte, error) {
// 	if len(address) == 0 {
// 		return nil, errors.New("decoding Bech32 address failed: must provide an address")
// 	}

// 	return hex.DecodeString(address)
// }

// // ConsAddressFromHex creates a ConsAddress from a hex string.
// func ConsAddressFromHex(address string) (ConsAddress, error) {
// 	bz, err := addressBytesFromHexString(address)
// 	return bz, err
// }

// func GetHex(ConsAddress string) string {
// 	_, converted, err := bech32.DecodeAndConvert(ConsAddress)
// 	if err != nil {
// 		fmt.Println("unable to decode bech32")
// 	}
// 	hexAddr := hex.EncodeToString(converted)

// 	newHex := strings.ToUpper(hexAddr)

// 	return newHex
// }
