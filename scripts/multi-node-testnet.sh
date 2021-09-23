#/bin/sh

display_usage() {
    printf "** Please check the exported values:: **\n Daemon : $DAEMON\n Denom : $DENOM\n ChainID : $CHAINID\n DaemonHome : $DAEMON_HOME\n \n Github URL : $GH_URL\n Chain Version : $CHAIN_VERSION\n"
    exit 1
}

if [ -z $DAEMON ] || [ -z $DENOM ] || [ -z $CHAINID ] || [ -z $DAEMON_HOME ] || [ -z $GH_URL ] || [ -z $CHAIN_VERSION ]
then 
    display_usage
fi

command_exists () {
    type "$1" &> /dev/null ;
}

cd $HOME


if command_exists go ; then
    echo "Golang is already installed"
else
  echo "Install dependencies"
  sudo apt update
  sudo apt-get -y upgrade
  sudo apt install build-essential jq -y

  wget https://dl.google.com/go/go1.16.8.linux-amd64.tar.gz
  tar -xvf go1.16.8.linux-amd64.tar.gz
  sudo mv go /usr/local
  rm go1.16.8.linux-amd64.tar.gz

  echo "------ Update bashrc ---------------"
  export GOPATH=$HOME/go
  export GOROOT=/usr/local/go
  export GOBIN=$GOPATH/bin
  export PATH=$PATH:/usr/local/go/bin:$GOBIN
  echo "" >> ~/.bashrc
  echo 'export GOPATH=$HOME/go' >> ~/.bashrc
  echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
  echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
  echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.bashrc

  source ~/.bashrc

  mkdir -p "$GOBIN"
  mkdir -p $GOPATH/src/github.com

  go version
fi

echo "--------- Install $DAEMON ---------"
git clone $GH_URL && cd $(basename $_ .git)
git fetch && git checkout $CHAIN_VERSION
make install

cd $HOME

# check version
$DAEMON version --long

#echo "----------Create test keys-----------"

export DAEMON_HOME_1=$DAEMON_HOME-1
export DAEMON_HOME_2=$DAEMON_HOME-2
export DAEMON_HOME_3=$DAEMON_HOME-3
export DAEMON_HOME_4=$DAEMON_HOME-4

printf " DAEMON_HOME_1 = $DAEMON_HOME_1\n DAEMON_HOME_2 = $DAEMON_HOME_2\n DAEMON_HOME_3=$DAEMON_HOME_3\n DAEMON_HOME_4=$DAEMON_HOME_4\n"

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

$DAEMON init --chain-id $CHAINID $DAEMON_HOME_1 --home $DAEMON_HOME_1
$DAEMON init --chain-id $CHAINID $DAEMON_HOME_2 --home $DAEMON_HOME_2
$DAEMON init --chain-id $CHAINID $DAEMON_HOME_3 --home $DAEMON_HOME_3
$DAEMON init --chain-id $CHAINID $DAEMON_HOME_4 --home $DAEMON_HOME_4

echo "----------Update node-id of $DAEMON_HOME_1 in remaining nodes---------"
nodeID=$("${DAEMON}" tendermint show-node-id --home $DAEMON_HOME_1)
echo $nodeID
PERSISTENT_PEERS="$nodeID@27.0.0.1:16656"
echo "PERSISTENT_PEERS : $PERSISTENT_PEERS"

echo "----------Updating $DAEMON_HOME_1 chain config-----------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:16657#g' $DAEMON_HOME_1/config/config.toml
sed -i 's#tcp://0.0.0.1:26656#tcp://0.0.0.0:16656#g' $DAEMON_HOME_1/config/config.toml
#sed -i '/timeout_commit =/c\timeout_commit = "5s"' $DAEMON_HOME_1/config/config.toml
sed -i 's#0.0.0.0:9090#0.0.0.0:1090#g' $DAEMON_HOME_1/config/app.toml
sed -i 's#0.0.0.0:9091#0.0.0.0:1091#g' $DAEMON_HOME_1/config/app.toml
sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_1/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_1/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_1/config/genesis.json

echo "----------Updating $DAEMON_HOME_2 chain config-----------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:26657#g' $DAEMON_HOME_2/config/config.toml
sed -i 's#tcp://0.0.0.1:26656#tcp://0.0.0.0:26656#g' $DAEMON_HOME_2/config/config.toml
sed -i '/persistent_peers =/c\persistent_peers = "'"$PERSISTENT_PEERS"'"' ~/.$DAEMON_HOME_2/config/config.toml
#sed -i '/timeout_commit =/c\timeout_commit = "5s"' $DAEMON_HOME_2/config/config.toml
sed -i 's#0.0.0.0:9090#0.0.0.0:2090#g' $DAEMON_HOME_2/config/app.toml
sed -i 's#0.0.0.0:9091#0.0.0.0:2091#g' $DAEMON_HOME_2/config/app.toml

echo "----------Updating $DAEMON_HOME_3 chain config------------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:36657#g' $DAEMON_HOME_3/config/config.toml
sed -i 's#tcp://0.0.0.1:26656#tcp://0.0.0.0:36656#g' $DAEMON_HOME_3/config/config.toml
sed -i '/persistent_peers =/c\persistent_peers = "'"$PERSISTENT_PEERS"'"' ~/.$DAEMON_HOME_3/config/config.toml
#sed -i '/timeout_commit =/c\timeout_commit = "5s"' $DAEMON_HOME_3/config/config.toml
sed -i 's#0.0.0.0:9090#0.0.0.0:3090#g' $DAEMON_HOME_3/config/app.toml
sed -i 's#0.0.0.0:9091#0.0.0.0:3091#g' $DAEMON_HOME_3/config/app.toml

echo "----------Updating $DAEMON_HOME_4 chain config------------"

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:46657#g' $DAEMON_HOME_4/config/config.toml
sed -i 's#tcp://0.0.0.0:26656#tcp://0.0.0.0:46656#g' $DAEMON_HOME_4/config/config.toml
sed -i '/persistent_peers =/c\persistent_peers = "'"$PERSISTENT_PEERS"'"' ~/.$DAEMON_HOME_4/config/config.toml
#sed -i '/timeout_commit =/c\timeout_commit = "5s"' $DAEMON_HOME_4/config/config.toml
sed -i 's#0.0.0.0:9090#0.0.0.0:4090#g' $DAEMON_HOME_4/config/app.toml
sed -i 's#0.0.0.0:9091#0.0.0.0:4091#g' $DAEMON_HOME_4/config/app.toml

echo "---------Create four keys-------------"

$DAEMON keys add validator1 --keyring-backend test --home $DAEMON_HOME_1
$DAEMON keys add validator2 --keyring-backend test --home $DAEMON_HOME_2
$DAEMON keys add validator3 --keyring-backend test --home $DAEMON_HOME_3
$DAEMON keys add validator4 --keyring-backend test --home $DAEMON_HOME_4

echo "----------Genesis creation---------"

$DAEMON --home $DAEMON_HOME_1 add-genesis-account validator1 1000000000000$DENOM  --keyring-backend test
$DAEMON --home $DAEMON_HOME_1 add-genesis-account $($DAEMON keys show validator2 -a --home $DAEMON_HOME_2 --keyring-backend test) 1000000000000$DENOM
$DAEMON --home $DAEMON_HOME_1 add-genesis-account $($DAEMON keys show validator3 -a --home $DAEMON_HOME_3 --keyring-backend test) 1000000000000$DENOM
$DAEMON --home $DAEMON_HOME_1 add-genesis-account $($DAEMON keys show validator4 -a --home $DAEMON_HOME_4 --keyring-backend test) 1000000000000$DENOM

echo "--------Gentx--------"

$DAEMON gentx validator1 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME_1
$DAEMON gentx validator2 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME_2
$DAEMON gentx validator3 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME_3
$DAEMON gentx validator4 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME_4

echo "---------Copy all the genesis to $DAEMON_HOME_1----------"

cp $DAEMON_HOME_2/config/gentx/*.json $DAEMON_HOME_1/config/gentx/
cp $DAEMON_HOME_3/config/gentx/*.json $DAEMON_HOME_1/config/gentx/
cp $DAEMON_HOME_4/config/gentx/*.json $DAEMON_HOME_1/config/gentx/

echo "----------collect-gentxs------------"

$DAEMON collect-gentxs --home $DAEMON_HOME_1

echo "---------Distribute genesis.json of $DAEMON_HOME_1 to remaining nodes-------"

cp $DAEMON_HOME_1/config/genesis.json $DAEMON_HOME_2/config/
cp $DAEMON_HOME_1/config/genesis.json $DAEMON_HOME_3/config/
cp $DAEMON_HOME_1/config/genesis.json $DAEMON_HOME_4/config/


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
WantedBy=multi-user.target" | sudo tee "/lib/systemd/system/$DAEMON-1.service"

echo "-------Start $DAEMON-1 service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON-1.service

sleep 5s

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
WantedBy=multi-user.target" | sudo tee "/lib/systemd/system/$DAEMON-2.service"

echo "-------Start $DAEMON_HOME_2 service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON-2.service

sleep 5s

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
WantedBy=multi-user.target" | sudo tee "/lib/systemd/system/$DAEMON-3.service"

echo "-------Start $DAEMON_HOME_3 service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON-3.service

sleep 5s

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
WantedBy=multi-user.target" | sudo tee "/lib/systemd/system/$DAEMON-4.service"

echo "-------Start $DAEMON_HOME_4 service-------"

sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON-4.service

sleep 5s

echo "Checking $DAEMON_HOME_4 chain status"

$CLI status --home $DAEMON_HOME_4

echo