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

echo "--------- Running withdraw-rewards commission command-----------"

wrcTx=$("${DAEMON}" tx distribution withdraw-rewards "${VALADDRESS}" --from $KEY --commission --fees "${FEE}" --chain-id "${CHAINID}" --node "${NODE}" -y)
#echo $wrTx
wrcCode=$(echo "${wrcTx}"| jq -r '.code')
wrctxHash=$(echo "${wrcTx}" | jq '.txhash')
echo $wrcCode
echo $wrctxHash
if [ "$wrcCode" -eq 0 ];
then
    echo "withdraw-rewards commission tx is successfull!!  txHash is : $wrctxHash"
else 
    echo "withdraw-rewards comission tx is failed!!!!   txHash is : $wrctxHash"
fi

echo "------ Running withdraw-all-rewards tx --------"

wartx=$($DAEMON tx distribution withdraw-all-rewards --from $KEY --fees $FEE --chain-id $CHAINID --node $NODE -y)
warcode=$(echo "${wartx}"| jq -r '.code')
wartxHash=$(echo "${wartx}" | jq -r '.txhash')
echo $warcode
echo $wartxHash
if [ "$warcode" -eq 0 ];
then
    echo "withdraw-all-rewards tx is successfull!!  txHash is : $wartxHash"
else 
    echo "withdraw-all-rewards tx is failed!!!!   txHash is : $wartxHash"
fi


#$DAEMON tx distribution withdraw-rewards --from $KEY --fees $FEE --chain-id $CHAINID --keyring-backend test --node $NODE -y
#sleep 10
#tx=$("${DAEMON}" tx bank send test1 regen1jmwm6xxwgzwmsfmwjz7eqfmqtupfks8jd40npy 1000uregen --fees 10uregen --chain-id "${CHAINID}" -y)
