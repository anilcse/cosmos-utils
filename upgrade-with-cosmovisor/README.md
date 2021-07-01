
## Clone the repo

```sh
git clone https://github.com/vitwit/cosmos-utils.git

cd cosmos-utils
```

## Set executable permissions

```sh
chmod +x ./upgrade-with-cosmovisor/script.sh
```

## Set ENV variables
```sh
export GH_URL=github.com/regen-network/regen-ledger
export CHAIN_VERSION=v1.0.0
export UPGRADE_VERSION=v1.1.0-alpha2
export DENOM=uregen
export CHAINID=testnet
export NODE=http://localhost:26657
export DAEMON=regen
export DAEMON_HOME=~/.regen_tmp
export CLI=regen
export UPGRADE_BLOCK_HEIGHT=150
export UPGRADE_TITLE=v0.43.0-rc0-upgrade
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
```

## Execute script