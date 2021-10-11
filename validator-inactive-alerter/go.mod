module github.com/vitwit/cosmos-utils/validator-inactive-alerter

go 1.15

require (
	github.com/cosmos/cosmos-sdk v0.44.0
	github.com/go-telegram-bot-api/telegram-bot-api v4.6.4+incompatible
	github.com/sirupsen/logrus v1.6.0
	github.com/spf13/viper v1.8.0
	github.com/technoweenie/multipartstreamer v1.0.1 // indirect
	github.com/tendermint/tendermint v0.34.12
	gopkg.in/go-playground/validator.v9 v9.31.0
)

replace github.com/gogo/protobuf => github.com/regen-network/protobuf v1.3.3-alpha.regen.1