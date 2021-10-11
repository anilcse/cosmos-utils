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
	// read config
	cfg, err := config.ReadConfigFromFile()
	if err != nil {
		log.Fatal(err)
	}

	// create a websocket client
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

	// subsrcibe events
	src.SubscribeEvents(client, ctx, cfg)
}
