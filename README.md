# cosmos-testnet-utils

## Test an on-chain upgrade

Clone the repo
```sh
git clone https://github.com/anilCSE/cosmos-testnet-utils.git

cd cosmos-testnet-utils
```

#### Set executable permissions
```sh
sudo chmod +x ./scripts/testnet-setup-plan-upgrade.sh
sudo chmod +x ./scripts/handle-upgrade.sh
```

#### Start testnet and handle proposal:
```sh
./scripts/testnet-setup-plan-upgrade.sh
```
The script will start the testnet. It creates a software-upgrade proposal, sends deposit and votes for it.

Just wait for the chain to hit upgrade height and chain will halt there.

You can check `sudo service akashd status` for the current height or query the chain `consensus_state` using `curl http://localhost:26657/consensus_state`

#### Handle upgrade
Ensure you execute this script only after hitting the upgrade height (i.e., 80 as mentioned in the testnet setup script)

Check the `akashd` status to confirm if the chain is waiting for the upgrade. 
 `sudo service akashd status`

 You should see a message like: `UPGRADE "test2-upgrade" NEEDED at height: 200:  module=main`

```sh
./scripts/handle-upgrade.sh
```
Check the `akashd` status, it should start producing the blocks again.
 `sudo service akashd status`