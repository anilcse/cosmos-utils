#/bin/sh

command_exists () {
    type "$1" &> /dev/null ;
}

if command_exists go ; then
    echo "Golang is already installed"
else
  echo "Install dependencies"
  sudo apt update
  sudo apt install build-essential jq -y

  wget https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz
  tar -xvf go1.15.2.linux-amd64.tar.gz
  sudo mv go /usr/local

  echo "" >> ~/.profile
  echo 'export GOPATH=$HOME/go' >> ~/.profile
  echo 'export GOROOT=/usr/local/go' >> ~/.profile
  echo 'export GOBIN=$GOPATH/bin' >> ~/.profile
  echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.profile

  #source ~/.profile
  . ~/.profile

  go version
fi

sudo service cosmovisor stop

# $DAEMON unsafe-reset-all --home $DAEMON_HOME
rm -rf $DAEMON_HOME

echo "--------- Install $DAEMON ---------"
go get $GH_URL
cd ~/go/src/$GH_URL
git fetch && git checkout $CHAIN_VERSION
make install

# check version
$DAEMON version --long

echo "Installing cosmovisor - an upgrade manager..."

# rm -rf $GOPATH/src/github.com/cosmos/cosmos-sdk
git clone https://github.com/cosmos/cosmos-sdk $GOPATH/src/github.com/cosmos/cosmos-sdk
cd $GOPATH/src/github.com/cosmos/cosmos-sdk
git fetch
git checkout $COSMOVISOR_VERSION
git pull origin  $COSMOVISOR_VERSION
cd cosmovisor
make cosmovisor
cp cosmovisor $GOBIN/cosmovisor

echo "Setting up cosmovisor directories"
mkdir -p $DAEMON_HOME/cosmovisor
mkdir -p $DAEMON_HOME/cosmovisor/genesis/bin
cp $(which regen) $DAEMON_HOME/cosmovisor/genesis/bin/

mkdir -p $DAEMON_HOME/cosmovisor/upgrades/$UPGRADE_TITLE/bin

cd ~/go/src/$GH_URL
git fetch && git checkout $UPGRADE_VERSION
make build
mv ./build/$DAEMON $DAEMON_HOME/cosmovisor/upgrades/$UPGRADE_TITLE/bin/
echo "Upgradable binary version"
$DAEMON_HOME/cosmovisor/upgrades/$UPGRADE_TITLE/bin/$DAEMON version

echo "---------Initializing the chain ($CHAINID)---------"


$DAEMON init --chain-id $CHAINID $CHAINID --home $DAEMON_HOME

echo "----------Update chain config---------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:26657#g' $DAEMON_HOME/config/config.toml
sed -i '/minimum-gas-prices =/c\minimum-gas-prices = "'"0.0025$DENOM"'"' $DAEMON_HOME/config/app.toml
# sed -i '/pruning = "default"/c\pruning = "nothing"' $DAEMON_HOME/config/app.toml
sed -i '/timeout_commit = "5s"/c\timeout_commit = "300ms"' $DAEMON_HOME/config/config.toml

sed -i "s/172800000000000/60000000000/g" $DAEMON_HOME/config/genesis.json
sed -i "s/172800s/60s/g" $DAEMON_HOME/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME/config/genesis.json
#sed -i 's/"signed_blocks_window": "100"/"signed_blocks_window": "10"/g' $DAEMON_HOME/config/genesis.json #10 blocks slashing window to test slashing

$DAEMON keys add w1 --keyring-backend test --home $DAEMON_HOME
$DAEMON keys add w2 --keyring-backend test --home $DAEMON_HOME
$DAEMON keys add w3 --keyring-backend test --home $DAEMON_HOME
$DAEMON keys add w4 --keyring-backend test --home $DAEMON_HOME
$DAEMON keys add w5 --keyring-backend test --home $DAEMON_HOME
$DAEMON keys add faucet --keyring-backend test --home $DAEMON_HOME
$DAEMON keys add validator --keyring-backend test --home $DAEMON_HOME

echo "----------Genesis creation---------"

# Now its time to construct the genesis file
CURRENT_TIME_SECONDS=$(date +%s)
VESTING_STARTTIME=$(( $CURRENT_TIME_SECONDS + 10 ))
VESTING_ENDTIME=$(( $CURRENT_TIME_SECONDS + 10000 ))

$DAEMON add-genesis-account w1 --keyring-backend test 1000000000000$DENOM --vesting-amount 1000000000000$DENOM --vesting-start-time $VESTING_STARTTIME --vesting-end-time $VESTING_ENDTIME --home $DAEMON_HOME
$DAEMON add-genesis-account w5 1000000000000$DENOM  --keyring-backend test --home $DAEMON_HOME
$DAEMON add-genesis-account validator 1000000000000$DENOM  --keyring-backend test --home $DAEMON_HOME
$DAEMON add-genesis-account faucet 1000000000000$DENOM  --keyring-backend test --home $DAEMON_HOME
$DAEMON add-genesis-account w2 --keyring-backend test 1000000000000$DENOM --vesting-amount 100000000000$DENOM --vesting-start-time $VESTING_STARTTIME --vesting-end-time $VESTING_ENDTIME --home $DAEMON_HOME
$DAEMON add-genesis-account w3 --keyring-backend test 1000000000000$DENOM --vesting-amount 500000000000$DENOM --vesting-start-time $VESTING_STARTTIME --vesting-end-time $VESTING_ENDTIME --home $DAEMON_HOME
$DAEMON add-genesis-account w4 --keyring-backend test 1000000000000$DENOM --vesting-amount 500000000000$DENOM --vesting-start-time $VESTING_STARTTIME --vesting-end-time $VESTING_ENDTIME --home $DAEMON_HOME

$DAEMON gentx validator 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME
$DAEMON collect-gentxs --home $DAEMON_HOME

VAL_OPR_ADDRESS=$($CLI keys show validator -a --bech val --keyring-backend test --home $DAEMON_HOME)

echo "---------Creating system file---------"

echo "[Unit]
Description=Cosmovisor daemon
After=network-online.target
[Service]
Environment="DAEMON_NAME=regen"
Environment="DAEMON_HOME=${DAEMON_HOME}"
Environment="DAEMON_RESTART_AFTER_UPGRADE=on"
Environment="DAEMON_POLL_INTERVAL=1000"
Environment="DAEMON_UPGRADE_INFO_FILE=${DAEMON_HOME}/data/upgrade-info.json"
User=${USER}
ExecStart=${GOBIN}/cosmovisor start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" >cosmovisor.service

sudo mv cosmovisor.service /lib/systemd/system/cosmovisor.service
sudo -S systemctl daemon-reload
sudo -S systemctl start cosmovisor

sleep 10s

echo "Checking chain status"

$CLI status

echo

echo

sleep 2s

$CLI tx staking delegate $VAL_OPR_ADDRESS 100000000000$DENOM  --from w1 --keyring-backend test --chain-id $CHAINID --node $NODE -y --home $DAEMON_HOME --fees 5000$DENOM
$CLI tx staking delegate $VAL_OPR_ADDRESS 100000000000$DENOM  --from w1 --keyring-backend test --chain-id $CHAINID --node $NODE -y --home $DAEMON_HOME --fees 5000$DENOM
$CLI tx staking delegate $VAL_OPR_ADDRESS 100000000000$DENOM  --from w1 --keyring-backend test --chain-id $CHAINID --node $NODE -y --home $DAEMON_HOME --fees 5000$DENOM
$CLI tx staking delegate $VAL_OPR_ADDRESS 100000000000$DENOM  --from w2 --keyring-backend test --chain-id $CHAINID --node $NODE -y --home $DAEMON_HOME --fees 5000$DENOM
$CLI tx staking delegate $VAL_OPR_ADDRESS 600000000000$DENOM  --from w3 --keyring-backend test --chain-id $CHAINID --node $NODE -y --home $DAEMON_HOME --fees 5000$DENOM
$CLI tx staking delegate $VAL_OPR_ADDRESS 900000000000$DENOM  --from w5 --keyring-backend test --chain-id $CHAINID --node $NODE -y --home $DAEMON_HOME --fees 5000$DENOM
$CLI tx staking unbond $VAL_OPR_ADDRESS 100000000000$DENOM  --from w1 --keyring-backend test --chain-id $CHAINID --node $NODE -y --home $DAEMON_HOME --fees 5000$DENOM

$CLI query staking validators -o json 

echo "All set!!! Let's try some upgrade"

echo "Submit upgrade proposal"
$CLI tx gov submit-proposal software-upgrade "$UPGRADE_TITLE" --upgrade-height $((UPGRADE_BLOCK_HEIGHT)) --title "$UPGRADE_TITLE" --description "$UPGRADE_TITLE" --deposit 10000000$DENOM --from w5 --chain-id $CHAINID --node $NODE -y --keyring-backend test --home $DAEMON_HOME --fees 5000$DENOM
sleep 2
echo
echo "Query proposal"
$CLI query gov proposal 1 --chain-id $CHAINID  -o json --node $NODE --home $DAEMON_HOME
echo
echo "Vote for proposal"
$CLI tx gov vote 1 yes --from validator --chain-id $CHAINID --node $NODE -y --keyring-backend test --home $DAEMON_HOME --fees 5000$DENOM
$CLI tx gov vote 1 yes --from w3 --chain-id $CHAINID --node $NODE -y --keyring-backend test --home $DAEMON_HOME --fees 5000$DENOM
sleep 2
echo
echo "Query proposal votes"
$CLI query gov votes 1 --chain-id $CHAINID  -o json --node $NODE
echo
echo "Query proposal"
$CLI query gov proposal 1 --chain-id $CHAINID  -o json --node $NODE
echo "Your proposal submitted successfully. The chain will halt for upgrade at height: $((UPGRADE_BLOCK_HEIGHT))"
echo "Just wait and check service logs for UPGRADE NEEDED message and then execute handle_upgrade.sh"
echo
echo "####################################################"
# echo "You can view logs by executing `journalctl -u $DAEMON -f`"
journalctl -u cosmovisor -f