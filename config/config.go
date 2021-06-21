package config

import (
	log "github.com/sirupsen/logrus"
	"github.com/spf13/viper"
	"gopkg.in/go-playground/validator.v9"
)

type (
	// Telegram bot config details
	TelegramBotConfig struct {
		BotToken string `mapstructure:"tg_bot_token"`
		ChatID   int64  `mapstructure:"tg_chat_id"`
	}

	// EmailConfig
	EmailConfig struct {
		SendGridAPIToken    string `mapstructure:"sendgrid_token"`
		ReceiverMailAddress string `mapstructure:"email_address"`
	}

	//InfluxDB details
	MongoDB struct {
		Database string `mapstructure:"database"`
		Username string `mapstructure:"username"`
		Password string `mapstructure:"password"`
	}

	//Scraper time interval
	Scraper struct {
		Rate        string `mapstructure:"rate"`
		DailyAlerts string `mapstructure:"validator_rate"`
	}

	// RegularStatusAlerts defines time-slots to receive validator status alerts
	RegularStatusAlerts struct {
		// AlertTimings is the array of time slots to send validator status alerts
		AlertTimings []string `mapstructure:"alert_timings"`
	}

	// Config defines all the app configurations
	Config struct {
		Telegram            TelegramBotConfig   `mapstructure:"telegram"`
		SendGrid            EmailConfig         `mapstructure:"sendgrid"`
		MongoDB             MongoDB             `mapstructure:"mongodb"`
		Scraper             Scraper             `mapstructure:"scraper"`
		EnableAlerts        string              `mapstructure:"enable_alerts"`
		RegularStatusAlerts RegularStatusAlerts `mapstructure:"regular_status_alerts"`
	}
)

// ReadConfigFromFile to read config details using viper
func ReadConfigFromFile() (*Config, error) {
	v := viper.New()
	v.AddConfigPath(".")
	v.AddConfigPath("./config/")
	v.SetConfigName("config")
	if err := v.ReadInConfig(); err != nil {
		log.Fatalf("error while reading config.toml: %v", err)
	}

	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		log.Fatalf("error unmarshaling config.toml to application config: %v", err)
	}

	if err := cfg.Validate(); err != nil {
		log.Fatalf("error occurred in config validation: %v", err)
	}

	return &cfg, nil
}

// Validate config struct
func (c *Config) Validate(e ...string) error {
	v := validator.New()
	if len(e) == 0 {
		return v.Struct(c)
	}
	return v.StructExcept(c, e...)
}
