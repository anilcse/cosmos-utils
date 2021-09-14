#/bin/sh

printf "Exported values::\n Daemon : $DAEMON\n Key : $KEY\n ChainID : $CHAINID\n Node : $NODE\n FEE :$FEE\n ValidatorAddress : $VALADDRESS\n"

echo "--------- Running withdraw-rewards command-----------"

wrTx=$("${DAEMON}" tx distribution withdraw-rewards "${VALADDRESS}" --from $KEY --fees "${FEE}" --chain-id "${CHAINID}" --node "${NODE}" -y)
#echo $wrTx
wrCode=$(echo "${wrTx}"| jq -r '.code')
wrtxHash=$(echo "${wrTx}" | jq '.txhash')
echo $wrCode
echo $wrtxHash
if [ "$wrCode" -eq 0 ];
then
    echo "withdraw-rewards tx is successfull!!  txHash is : $wrtxHash"
else 
    echo "withdraw-rewards tx is failed!!!!   txHash is : $wrtxHash"
fi

echo "------ Running withdraw-all-rewards tx --------"

tx=$($DAEMON tx distribution withdraw-all-rewards --from $KEY --fees $FEE --chain-id $CHAINID --node $NODE -y)
#echo "${tx}"
code=$(echo "${tx}"| jq -r '.code')
txHash=$(echo "${tx}" | jq -r '.txhash')
echo $code
echo $txHash
if [ "$code" -eq 0 ];
then
    echo "withdraw-all-rewards tx is successfull!!  txHash is : $txHash"
else 
    echo "withdraw-all-rewards tx is failed!!!!   txHash is : $txHash"
fi



#$DAEMON tx distribution withdraw-rewards --from $KEY --fees $FEE --chain-id $CHAINID --keyring-backend test --node $NODE -y
#sleep 10
#tx=$("${DAEMON}" tx bank send test1 regen1jmwm6xxwgzwmsfmwjz7eqfmqtupfks8jd40npy 1000uregen --fees 10uregen --chain-id "${CHAINID}" -y)
