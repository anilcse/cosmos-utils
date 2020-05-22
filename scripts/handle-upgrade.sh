#/bin/sh

export DENOM=akt
export CHAINID=testchain
export NODE=http://localhost:26657
export DAEMON=akashd
export CLI=akashctl

echo "---- Querying chain status------"
akashctl status --chain-id $CHAINID

echo "----akashd current version------"
akashd version --long

echo "----Install the upgrade release------"
cd $GOPATH/src/github.com/ovrclk/akash
git fetch && git checkout akhil/test-upgrade
make install

echo "----akashd version------"
akashd version --long

echo "----handle upgrade------"
sudo service $DAEMON stop
sudo service $DAEMON start

sleep 10

echo "---- Querying chain status------"
akashctl status --chain-id $CHAINID

echo "-----Upgraded successfully-----"
