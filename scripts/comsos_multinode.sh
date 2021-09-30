#/bin/sh

display_usage() {
    printf "** Please check the exported values:: **\n Daemon : $DAEMON\n Denom : $DENOM\n ChainID : $CHAINID\n DaemonHome : $DAEMON_HOME\n \n Github URL : $GH_URL\n Chain Version : $CHAIN_VERSION\n"
    exit 1
}

if [ -z $DAEMON ] || [ -z $DENOM ] || [ -z $CHAINID ] || [ -z $DAEMON_HOME ] || [ -z $GH_URL ] || [ -z $CHAIN_VERSION ]
then 
    display_usage
fi

NODES=$1
if [ -z $NODES ]
then
    NODES=2
fi

echo "**** Number of nodes to be setup: $NODES ****"

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

# export daemon home paths
for (( a=1; a<=$NODES; a++ ))
do
    export DAEMON_HOME_$a=$DAEMON_HOME-$a
    echo "DAEMON_HOME_$a=$DAEMON_HOME-$a"

    echo "PATHHHH : $DAEMON_HOME_"
    echo "Deamon path :: $DAEMON_HOME-$a"

    $DAEMON unsafe-reset-all  --home $DAEMON_HOME-$a
    echo "****** here command $DAEMON unsafe-reset-all  --home $DAEMON_HOME-$a ******"
done

rm -rf ~/.$DAEMON/config/gen*

echo "-----Create daemon home directories if not exist------"

for (( a=1; a<=$NODES; a++ ))
do
    echo "****** create dir :: $DAEMON_HOME-$a ********"
    mkdir -p "$DAEMON_HOME-$a"
done

echo "--------Start initializing the chain ($CHAINID)---------"

for (( a=1; a<=$NODES; a++ ))
do
    echo "-------Init chain ${a}--------"
    echo "Deamon home :: $DAEMON_HOME-${a}"
    $DAEMON init --chain-id $CHAINID $DAEMON_HOME-${a} --home $DAEMON_HOME-${a}
done

echo "---------Creating $NODES keys-------------"

for (( a=1; a<=$NODES; a++ ))
do
    $DAEMON keys add "validator${a}" --keyring-backend test --home $DAEMON_HOME-${a}
done

echo "----------Genesis creation---------"

for (( a=1; a<=$NODES; a++ ))
do
    if [ $a == 1 ]
    then
        $DAEMON --home $DAEMON_HOME-$a add-genesis-account validator$a 1000000000000$DENOM  --keyring-backend test
        continue
    fi
    $DAEMON --home $DAEMON_HOME-$a add-genesis-account validator$a 1000000000000$DENOM  --keyring-backend test
    $DAEMON --home $DAEMON_HOME_1 add-genesis-account $($DAEMON keys show validator$a -a --home $DAEMON_HOME-$a --keyring-backend test) 1000000000000$DENOM
done

echo "--------Gentx--------"

for (( a=1; a<=$NODES; a++ ))
do
    $DAEMON gentx validator$a 90000000000$DENOM --chain-id $CHAINID  --keyring-backend test --home $DAEMON_HOME-$a
done

echo "---------Copy all node genesis to $DAEMON_HOME_1----------"

for (( a=2; a<=$NODES; a++ ))
do
    cp $DAEMON_HOME-$a/config/gentx/*.json $DAEMON_HOME_1/config/gentx/
done

echo "----------collect-gentxs------------"

$DAEMON collect-gentxs --home $DAEMON_HOME_1

echo "---------Updating $DAEMON_HOME_1 genesis.json ------------"

sed -i "s/172800000000000/600000000000/g" $DAEMON_HOME_1/config/genesis.json
sed -i "s/172800s/600s/g" $DAEMON_HOME_1/config/genesis.json
sed -i "s/stake/$DENOM/g" $DAEMON_HOME_1/config/genesis.json

echo "---------Distribute genesis.json of $DAEMON_HOME_1 to remaining nodes-------"

for (( a=2; a<=$NODES; a++ ))
do
    cp $DAEMON_HOME_1/config/genesis.json $DAEMON_HOME-$a/config/
done

echo "----------Update node-id of $DAEMON_HOME_1 in remaining nodes---------"
nodeID=$("${DAEMON}" tendermint show-node-id --home $DAEMON_HOME_1)
echo $nodeID
PERSISTENT_PEERS="$nodeID@$IP:16656"
echo "PERSISTENT_PEERS : $PERSISTENT_PEERS"

for (( a=2; a<=$NODES; a++ ))
do
    if [ $a == 1 ]
    then
        echo "----------Updating $DAEMON_HOME_1 chain config-----------"

        sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:16657#g' $DAEMON_HOME_1/config/config.toml
        sed -i 's#tcp://0.0.0.0:26656#tcp://0.0.0.0:16656#g' $DAEMON_HOME_1/config/config.toml
        sed -i '/persistent_peers =/c\persistent_peers = "'""'"' $DAEMON/config/config.toml
        sed -i 's#0.0.0.0:9090#0.0.0.0:1090#g' $DAEMON_HOME_1/config/app.toml
        sed -i 's#0.0.0.0:9091#0.0.0.0:1091#g' $DAEMON_HOME_1/config/app.toml

        sed -i '/max_num_inbound_peers =/c\max_num_inbound_peers = 140' $DAEMON_HOME_1/config/config.toml
        sed -i '/max_num_outbound_peers =/c\max_num_outbound_peers = 110' $DAEMON_HOME_1/config/config.toml
        continue
    fi

        echo "----------Updating $DAEMON_HOME-$a chain config-----------"

        sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:'"${a}6657"'#g' $DAEMON_HOME-$a/config/config.toml
        sed -i 's#tcp://0.0.0.0:26656#tcp://0.0.0.0:'"${a}6656"'#g' $DAEMON_HOME-$a/config/config.toml
        sed -i '/persistent_peers =/c\persistent_peers = "'"$PERSISTENT_PEERS"'"' $DAEMON_HOME-$a/config/config.toml
       
        sed -i 's#0.0.0.0:9090#0.0.0.0:'"${a}090"'#g' $DAEMON_HOME-$a/config/app.toml
        sed -i 's#0.0.0.0:9091#0.0.0.0:'"${a}091"'#g' $DAEMON_HOME-$a/config/app.toml

        sed -i '/max_num_inbound_peers =/c\max_num_inbound_peers = 140' $DAEMON_HOME-$a/config/config.toml
        sed -i '/max_num_outbound_peers =/c\max_num_outbound_peers = 110' $DAEMON_HOME-$a/config/config.toml

done

for (( a=1; a<=$NODES; a++ ))
do
    echo "---------Creating $DAEMON_HOME-$a system file---------"

    echo "[Unit]
    Description=${DAEMON} daemon
    After=network.target
    [Service]
    Type=simple
    User=$USER
    ExecStart=$(which $DAEMON) start --home $DAEMON_HOME-$a
    Restart=on-failure
    RestartSec=3
    LimitNOFILE=4096
    [Install]
    WantedBy=multi-user.target" | sudo tee "/lib/systemd/system/$DAEMON-${a}.service"

    echo "-------Start $DAEMON-${a} service-------"

    sudo -S systemctl daemon-reload
    sudo -S systemctl start $DAEMON-${a}.service

    sleep 5s

    echo "Checking $DAEMON_HOME-${a} chain status"

    $DAEMON status --node tcp://localhost:${a}6657

    echo
done

echo
