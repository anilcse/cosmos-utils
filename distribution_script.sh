#/bin/sh

echo "--------- Run withdraw-rewards command-----------"

tx=$(regen tx bank send test1 regen1jmwm6xxwgzwmsfmwjz7eqfmqtupfks8jd40npy 1000uregen --fees 10uregen --chain-id test -y)
code=$(echo "${tx}"| jq -r '.code')
echo $code



#$DAEMON tx distribution withdraw-rewards --from $KEY --fees $FEE --chain-id $CHAINID --keyring-backend test --node $NODE -y
#sleep 10