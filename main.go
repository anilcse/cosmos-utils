package main

import (
	"log"
	"sync"
	"time"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
	"github.com/PrathyushaLakkireddy/relayer-alerter/targets"
)

func main() {
	cfg, err := config.ReadConfigFromFile()
	if err != nil {
		log.Fatal(err)
	}

	targets.InitDB(cfg)
	defer targets.MongoSession.Close()

	var wg sync.WaitGroup
	wg.Add(1)

	// Calling go routine to send alerts for missed blocks
	go func() {
		for {
			targets.TelegramAlerting(cfg)
			time.Sleep(4 * time.Second)
		}
	}()

	// Calling go routine to send alert about validator status
	go func() {
		for {
			// if err := server.ValidatorStatusAlert(cfg); err != nil {
			// 	fmt.Println("Error while sending jailed alerts", err)
			// }
			time.Sleep(60 * time.Second)
		}
	}()

	wg.Wait()

	// m := targets.InitTargets(cfg)
	// runner := targets.NewRunner()

	// c, err := client.NewHTTPClient(client.HTTPConfig{
	// 	Addr:     fmt.Sprintf("http://localhost:%s", cfg.InfluxDB.Port),
	// 	Username: cfg.InfluxDB.Username,
	// 	Password: cfg.InfluxDB.Password,
	// })
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// defer c.Close()

	// var wg sync.WaitGroup
	// for _, tg := range m.List {
	// 	wg.Add(1)
	// 	go func(target targets.Target) {
	// 		scrapeRate, err := time.ParseDuration(target.ScraperRate)
	// 		if err != nil {
	// 			log.Fatal(err)
	// 		}
	// 		for {
	// 			runner.Run(target.Func, target.HTTPOptions, cfg, c)
	// 			time.Sleep(scrapeRate)
	// 		}
	// 	}(tg)
	// }
	// wg.Wait()
}
