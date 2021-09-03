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

	// Config
	Config struct {
		RPCEndpoint    string            `mapstructure:"rpc_endpoint"`
		LCDEndpoint    string            `mapstructure:"lcd_endpoint"`
		ConsAddrPrefix string            `mapstructure:"cons_addr_prefix"`
		HexAddress     string            `mapstructure:"hex_address"`
		Telegram       TelegramBotConfig `mapstructure:"telegram"`
		EnableAlerts   string            `mapstructure:"enable_alerts"`
		Moniker        string            `mapstructure:"moniker"`
		NetworkName    string            `mapstructure:"network_name"`
	}
)

// ReadConfigFromFile to read config details from file using viper
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
