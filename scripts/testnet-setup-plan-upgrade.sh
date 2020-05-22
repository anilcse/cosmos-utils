#/bin/sh

export DENOM=akt
export CHAINID=testchain
export VOTING_PERIOD=120000000000 #2 minutes
export NODE=http://localhost:26657
export DAEMON=akashd
export CLI=akashctl
export UPGRADE_BLOCK_HEIGHT=80
export UPGRADE_TITLE=test2-upgrade
export TESTFAUCETKEY=testkeyfaucet
export TESTVALKEY=testkeyvalidator

echo "--------Installing pre-requisistes---------"
sudo apt update
sudo apt install build-essential git -y

# Install latest go version https://golang.org/doc/install
wget https://dl.google.com/go/go1.14.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.14.linux-amd64.tar.gz

# Add $GOPATH, $GOBIN and both to $PATH
echo "" >> ~/.profile
echo 'export GOPATH=$HOME/go' >> ~/.profile
echo 'export GOBIN=$GOPATH/bin' >> ~/.profile
echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.profile
source ~/.profile

echo "---------Install Akash---------"
go get github.com/ovrclk/akash
cd $GOPATH/src/github.com/ovrclk/akash
make install

# check version
akashd version --long

echo "----------Create test keys-----------"
## This script assumes following keys to be created before hand. Create keys if not present.
$CLI keys add $TESTVALKEY --keyring-backend test
$CLI keys add $TESTFAUCETKEY --keyring-backend test


echo "---------Initializing the chain ($CHAINID)---------"
rm -rf ~/.$DAEMON

$DAEMON init --chain-id $CHAINID $CHAINID

echo "----------Update chain config---------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:26657#g' ~/.$DAEMON/config/config.toml
sed -i "s/172800000000000/$VOTING_PERIOD/g" ~/.$DAEMON/config/genesis.json
sed -i "s/stake/$DENOM/g" ~/.$DAEMON/config/genesis.json
sed -i 's/"signed_blocks_window": "100"/"signed_blocks_window": "10"/g' ~/.$DAEMON/config/genesis.json #10 blocks slashing window to test slashing
sed -i 's/pruning = "syncable"/pruning = "nothing"/g' ~/.$DAEMON/config/app.toml

echo "----------Genesis creation---------"
# Now its time to construct the genesis file
$DAEMON add-genesis-account $($CLI keys show $TESTVALKEY -a --keyring-backend test) 100000000000$DENOM
$DAEMON add-genesis-account $($CLI keys show $TESTFAUCETKEY -a --keyring-backend test) 10000000000000$DENOM
$DAEMON gentx --name $TESTVALKEY --amount 90000000000$DENOM  --keyring-backend test
$DAEMON collect-gentxs

echo "---------Creating system file---------"

echo "[Unit]
Description=${DAEMON} daemon
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which akashd) start --pruning=nothing
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
">$DAEMON.service

sudo mv $DAEMON.service /lib/systemd/system/$DAEMON.service

echo "-------Start akashd service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON

sleep 10s

echo "Checking chain status"

$CLI status --chain-id $CHAINID

echo 
echo

echo "All set!!! Let's try some upgrade"

echo "Submit upgrade proposal"
$CLI tx gov submit-proposal software-upgrade "$UPGRADE_TITLE" --upgrade-height $((UPGRADE_BLOCK_HEIGHT + 0)) --title "$UPGRADE_TITLE" --description "$UPGRADE_TITLE" --deposit 10000000$DENOM --from $TESTFAUCETKEY --chain-id $CHAINID --node $NODE -y  --keyring-backend test
sleep 7
echo
echo "Query proposal"
$CLI query gov proposal 1 --chain-id $CHAINID  -o json --node $NODE --trust-node
echo
echo "Vote for proposal"
$CLI tx gov vote 1 yes --from $TESTVALKEY --chain-id $CHAINID --node $NODE -y  --keyring-backend test
$CLI tx gov vote 1 yes --from $TESTFAUCETKEY --chain-id $CHAINID --node $NODE -y  --keyring-backend test
sleep 10
echo
echo "Query proposal votes"
$CLI query gov votes 1 --chain-id $CHAINID  -o json --node $NODE --trust-node
echo
echo "Query proposal"
$CLI query gov proposal 1 --chain-id $CHAINID  -o json --node $NODE --trust-node
echo "Your proposal submitted successfully. The chain will halt for upgrade at height: $((CURRENT_BLOCK_HEIGHT))"
echo "Just wait and check service logs for UPGRADE NEEDED message and then execute handle_upgrade.sh"

