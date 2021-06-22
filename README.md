# cosmos-testnet-utils

## Test an on-chain upgrade

Clone the repo
```sh
git clone https://github.com/anilCSE/cosmos-testnet-utils.git

cd cosmos-testnet-utils
```

#### Set executable permissions
```sh
chmod +x ./scripts/testnet-setup-plan-upgrade.sh
chmod +x ./scripts/handle-upgrade.sh
```

#### Configure ENV variables

```sh
export GH_URL=github.com/regen-network/regen-ledger
export CHAIN_VERSION=v1.0.0
export UPGRADE_VERSION=v1.1.0-alpha0
export DENOM=uregen
export CHAINID=testnet
export NODE=http://localhost:26657
export DAEMON=regen
export DAEMON_HOME=~/.regen
export CLI=regen
export UPGRADE_BLOCK_HEIGHT=150
export UPGRADE_TITLE=v0.43.0-beta1-upgrade
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
```

#### Start testnet and handle proposal:
```sh
./scripts/testnet-setup-plan-upgrade.sh
```
The script will start the testnet. It creates a software-upgrade proposal, sends deposit and votes for it.

Just wait for the chain to hit upgrade height and chain will halt there.

You can check `sudo service $DAEMON status` for the current height or query the chain `consensus_state` using `curl http://localhost:26657/consensus_state`

#### Handle upgrade
Ensure you execute this script only after hitting the upgrade height (i.e., 80 as mentioned in the testnet setup script)

Check the `$DAEMON` status to confirm if the chain is waiting for the upgrade. 
 `sudo service $DAEMON status`

 You should see a message like: `UPGRADE "<upgrade-name-here>" NEEDED at height: 150:  module=main`

```sh
./scripts/handle-upgrade.sh
```

Check the `$DAEMON` status, it should start producing the blocks again.
 `sudo service $DAEMON status`
