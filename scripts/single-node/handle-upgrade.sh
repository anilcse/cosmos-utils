#/bin/sh

echo "----$DAEMON current version------"
$DAEMON version

echo "----Install the upgrade release------"
cd ~/go/src/$GH_URL
git fetch && git checkout $UPGRADE_VERSION
EXPERIMENTAL=true make install

echo "----$DAEMON version------"
$DAEMON version

echo "----handle upgrade------"
sudo service $DAEMON stop

$DAEMON start

#sleep 20

#echo "---- Querying chain status------"
#$CLI status --chain-id $CHAINID

#echo "-----Upgraded successfully-----"
