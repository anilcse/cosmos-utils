#/bin/sh

echo "--------- Run withdraw-rewards command-----------"

tx=$(regen tx bank send test1 regen1jmwm6xxwgzwmsfmwjz7eqfmqtupfks8jd40npy 1000uregen --fees 10uregen --chain-id test -y)
#echo "${tx}"
code=$(echo "${tx}"| jq -r '.code')
txHash=$(echo "${tx}" | jq -r '.txhash')
echo $code
echo $txHash
if [ "$code" -eq 0 ];
then
    echo "Send tx is successfull!!  txHash is : $txHash"
else 
    echo "Send tx is failed!!!!   txHash is : $txHash"
fi



#$DAEMON tx distribution withdraw-rewards --from $KEY --fees $FEE --chain-id $CHAINID --keyring-backend test --node $NODE -y
#sleep 10