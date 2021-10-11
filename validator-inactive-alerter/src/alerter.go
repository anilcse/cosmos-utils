package src

import (
	"log"
	"strings"

	"github.com/vitwit/cosmos-utils/validator-inactive-alerter/alerting"
	"github.com/vitwit/cosmos-utils/validator-inactive-alerter/config"
)

// SendTelegramAlert sends the alert to telegram chat
func SendTelegramAlert(msg string, cfg *config.Config) error {
	if strings.EqualFold(cfg.EnableAlerts, "yes") == true {
		if err := alerting.NewTelegramAlerter().Send(msg, cfg.Telegram.BotToken, cfg.Telegram.ChatID); err != nil {
			log.Printf("failed to send telegram alert: %v", err)
			return err
		}
	}
	return nil
}
