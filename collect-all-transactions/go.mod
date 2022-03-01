module github.com/vitwit/cosmos-utils/collect-all-transactions

go 1.15

replace github.com/gogo/protobuf => github.com/regen-network/protobuf v1.3.3-alpha.regen.1

require (
	github.com/cosmos/cosmos-sdk v0.45.1
	github.com/sirupsen/logrus v1.8.1
	github.com/tendermint/tendermint v0.34.14
)
