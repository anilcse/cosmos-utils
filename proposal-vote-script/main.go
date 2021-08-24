package main

import (
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/vitwit/cosmos-utils/proposal-vote-script/config"
	"github.com/vitwit/cosmos-utils/proposal-vote-script/server"
)

func main() {
	cfg, err := config.ReadConfigFromFile()
	if err != nil {
		log.Fatal(err)
	}

	var wg sync.WaitGroup
	wg.Add(1)

	// Calling go routine to vote for the proposal if it's not voted
	go func() {
		for {
			if err := server.Vote(cfg); err != nil {
				fmt.Printf("Error while voting on new proposals : %v", err)
			}
			time.Sleep(5 * time.Second)
		}
	}()

	wg.Wait()
}
