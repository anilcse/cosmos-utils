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

echo "--------- Install $DAEMON ---------"
go get $GH_URL
cd ~/go/src/$GH_URL
git fetch && git checkout $CHAIN_VERSION
make install

# check version
$DAEMON version --long

#echo "----------Create test keys-----------"

echo "---------Initializing the chain ($CHAINID)---------"

$DAEMON unsafe-reset-all  --home $DAEMON_HOME_1
$DAEMON unsafe-reset-all  --home $DAEMON_HOME_2
$DAEMON unsafe-reset-all  --home $DAEMON_HOME_3
$DAEMON unsafe-reset-all  --home $DAEMON_HOME_4
rm -rf ~/.$DAEMON/config/gen*

echo "-----Create daemon home directories if not exist------"

mkdir -p "$DAEMON_HOME_1"
mkdir -p "$DAEMON_HOME_2"
mkdir -p "$DAEMON_HOME_3"
mkdir -p "$DAEMON_HOME_4"

echo "--------Start initializing the chain ($CHAINID)---------"

$DAEMON init --chain-id $CHAINID $CHAINID --home $DAEMON_HOME_1
$DAEMON init --chain-id $CHAINID $CHAINID --home $DAEMON_HOME_2
$DAEMON init --chain-id $CHAINID $CHAINID --home $DAEMON_HOME_3
$DAEMON init --chain-id $CHAINID $CHAINID --home $DAEMON_HOME_4

echo "----------Update chain config---------"

echo "----------Updating $DEAMON_HOME_1 chain config-----------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:16657#g' $DAEMON_HOME_1/config/config.toml
sed -i 's#tcp://127.0.0.1:26656#tcp://0.0.0.0:16656#g' $DAEMON_HOME_1/config/config.toml
sed -i 's/"timeout_commit" = "5s"'
sed -i 's#0.0.0.0:9090#0.0.0.0:1090#g' $DAEMON_HOME_1/config/app.toml
sed -i 's#0.0.0.0:9091#0.0.0.0:1091#g' $DAEMON_HOME_1/config/app.toml
sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_1/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_1/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_1/config/genesis.json

echo "----------Updating $DEAMON_HOME_2 chain config-----------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:26657#g' $DAEMON_HOME_2/config/config.toml
sed -i 's#tcp://127.0.0.1:26656#tcp://0.0.0.0:26656#g' $DAEMON_HOME_2/config/config.toml
sed -i 's/"timeout_commit" = "5s"'
sed -i 's#0.0.0.0:9090#0.0.0.0:2090#g' $DAEMON_HOME_2/config/app.toml
sed -i 's#0.0.0.0:9091#0.0.0.0:2091#g' $DAEMON_HOME_2/config/app.toml
sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_2/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_2/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_2/config/genesis.json

echo "----------Updating $DEAMON_HOME_3 chain config------------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:36657#g' $DAEMON_HOME_3/config/config.toml
sed -i 's#tcp://127.0.0.1:26656#tcp://0.0.0.0:36656#g' $DAEMON_HOME_3/config/config.toml
sed -i 's/"timeout_commit" = "5s"'
sed -i 's#0.0.0.0:9090#0.0.0.0:3090#g' $DAEMON_HOME_3/config/app.toml
sed -i 's#0.0.0.0:9091#0.0.0.0:3091#g' $DAEMON_HOME_3/config/app.toml
sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_3/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_3/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_3/config/genesis.json

echo "----------Updating $DEAMON_HOME_4 chain config------------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:46657#g' $DAEMON_HOME_4/config/config.toml
sed -i 's#tcp://127.0.0.1:26656#tcp://0.0.0.0:46656#g' $DAEMON_HOME_4/config/config.toml
sed -i 's/"timeout_commit" = "5s"'
sed -i 's#0.0.0.0:9090#0.0.0.0:4090#g' $DAEMON_HOME_4/config/app.toml
sed -i 's#0.0.0.0:9091#0.0.0.0:4091#g' $DAEMON_HOME_4/config/app.toml
sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_4/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_4/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_4/config/genesis.json

echo "---------Create four keys-------------"

$DAEMON keys add validator1 --keyring-backend test --home $DAEMON_HOME_1
$DAEMON keys add validator2 --keyring-backend test --home $DAEMON_HOME_2
$DAEMON keys add validator3 --keyring-backend test --home $DAEMON_HOME_3
$DAEMON keys add validator4 --keyring-backend test --home $DAEMON_HOME_4

echo "----------Genesis creation---------"

$DAEMON --home $DAEMON_HOME_1 add-genesis-account validator1 1000000000000$DENOM  --keyring-backend test
$DAEMON --home $DAEMON_HOME_2 add-genesis-account validator2 1000000000000$DENOM  --keyring-backend test
$DAEMON --home $DAEMON_HOME_3 add-genesis-account validator3 1000000000000$DENOM  --keyring-backend test
$DAEMON --home $DAEMON_HOME_4 add-genesis-account validator4 1000000000000$DENOM  --keyring-backend test

$DAEMON gentx validator1 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME_1
$DAEMON gentx validator2 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME_2
$DAEMON gentx validator3 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME_3
$DAEMON gentx validator4 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME_4

echo "---------Copy all the genesis to $DAEMON_HOME_1----------"

sudo cp $DAEMON_HOME_2/config/gentx/*.json $DAEMON_HOME_1/config/gentx/
sudo cp $DAEMON_HOME_3/config/gentx/*.json $DAEMON_HOME_1/config/gentx/
sudo cp $DAEMON_HOME_4/config/gentx/*.json $DAEMON_HOME_1/config/gentx/

$DAEMON collect-gentxs --home $DAEMON_HOME_1

echo "---------Distribute genesis.json to remaining nodes-------"

sudo cp $DAEMON_HOME_1/config/genesis.json $DAEMON_HOME_2/config/
sudo cp $DAEMON_HOME_1/config/genesis.json $DAEMON_HOME_3/config/
sudo cp $DAEMON_HOME_1/config/genesis.json $DAEMON_HOME_4/config/


echo "---------Creating $DAEMON_HOME_1 system file---------"

echo "[Unit]
Description=${DAEMON} daemon
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which $DAEMON) start --home $DAEMON_HOME_1
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
">$DAEMON_HOME_1.service

sudo mv $DAEMON_HOME_1.service /lib/systemd/system/$DAEMON_HOME_1.service

echo "-------Start $DAEMON_HOME_1 service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON_HOME_1

sleep 10s

echo "Checking $DAEMON_HOME_1 chain status"

$CLI status --home $DAEMON_HOME_1

echo
echo

echo "---------Creating $DAEMON_HOME_2 system file---------"

echo "[Unit]
Description=${DAEMON} daemon
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which $DAEMON) start --home $DAEMON_HOME_2
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
">$DAEMON_HOME_2.service

sudo mv $DAEMON_HOME_2.service /lib/systemd/system/$DAEMON_HOME_2.service

echo "-------Start $DAEMON_HOME_2 service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON_HOME_2

sleep 10s

echo "Checking $DAEMON_HOME_2 chain status"

$CLI status --home $DAEMON_HOME_2

echo
echo

echo "---------Creating $DAEMON_HOME_3 system file---------"

echo "[Unit]
Description=${DAEMON} daemon
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which $DAEMON) start --home $DAEMON_HOME_3
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
">$DAEMON_HOME_3.service

sudo mv $DAEMON_HOME_3.service /lib/systemd/system/$DAEMON_HOME_3.service

echo "-------Start $DAEMON_HOME_3 service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON_HOME_3

sleep 10s

echo "Checking $DAEMON_HOME_3 chain status"

$CLI status --home $DAEMON_HOME_3

echo
echo

echo "---------Creating $DAEMON_HOME_4 system file---------"

echo "[Unit]
Description=${DAEMON} daemon
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which $DAEMON) start --home $DAEMON_HOME_4
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
">$DAEMON_HOME_4.service

sudo mv $DEAMON_HOME_4.service /lib/systemd/system/$DAEMON_HOME_4.service

echo "-------Start $DAEMON_HOME_4 service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON_HOME_4

sleep 10s

echo "Checking $DAEMON_HOME_4 chain status"

$CLI status --home $DEAMON_HOME_4

echo