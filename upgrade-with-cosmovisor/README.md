
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
export CHAIN_VERSION=aleem/523-state-export
export UPGRADE_VERSION=am/fix-upgrade
export DENOM=uregen
export CHAINID=testnet
export NODE=http://localhost:26657
export DAEMON=regen
export DAEMON_HOME=~/.regen
export CLI=regen
export UPGRADE_BLOCK_HEIGHT=2000
export UPGRADE_TITLE=v0.43.0-rc0-upgrade
export COSMOVISOR_VERSION=anil/add_backup_option
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
```

## Execute script

```sh
./upgrade-with-cosmovisor/scripts.sh
```
