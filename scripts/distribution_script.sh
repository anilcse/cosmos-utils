#/bin/sh

display_usage() {
    printf "** Please check the exported values:: **\n Daemon : $DAEMON\n Key : $KEY\n ChainID : $CHAINID\n Node : $NODE\n FEE : $FEE\n ValidatorAddress : $VALADDRESS\n"
    # exit 1
}

if [ -z $DAEMON ] || [ -z $KEY ] || [ -z $CHAINID ] || [ -z $NODE ] || [ -z $FEE ] || [ -z $VALADDRESS ]
then 
    display_usage
fi

echo

echo "--------- Get validator addresses -----------"
va1=$("${DAEMON}" keys show validator1 --bech val --keyring-backend test --output json)
v1=$(echo "${va1}" | jq -r '.address')
echo "** validator1 address :: $v1 **"

va2=$("${DAEMON}" keys show validator2 --bech val --keyring-backend test --output json)
v2=$(echo "${va2}" | jq -r '.address')
echo "** validator2 address :: $v2 **"

va3=$("${DAEMON}" keys show validator3 --bech val --keyring-backend test --output json)
v3=$(echo "${va3}" | jq -r '.address')
echo "** validator3 address :: $v3 **"

va4=$("${DAEMON}" keys show validator4 --bech val --keyring-backend test --output json)
v4=$(echo "${va4}" | jq -r '.address')
echo "** validator4 address :: $v4 **"

echo

#Start of for loop to run delegation txs
for a in 1 2 3 4
do
    if [ $a == 1 ]
    then
        FROMKEY="validator1"
        VALADDRESS=$v1
    elif [ $a == 2 ]
    then
        FROMKEY="validator2"
        VALADDRESS=$v2
    elif [ $a == 3 ]
    then
        FROMKEY="validator3"
        VALADDRESS=$v3
    else [ $a == 4 ]
        FROMKEY="validator4"
        VALADDRESS=$v4
    fi
    # Print the value
    echo "Iteration no $a and values of address : $VALADDRESS and key : $FROMKEY"
    echo "--------- withdraw-rewards of $FROMKEY-----------"

    wrTx=$("${DAEMON}" tx distribution withdraw-rewards "${VALADDRESS}" --from $FROMKEY --fees 1000"${DENOM}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
    wrCode=$(echo "${wrTx}"| jq -r '.code')
    wrtxHash=$(echo "${wrTx}" | jq '.txhash')
    echo "Code is : $wrCode"
    if [ "$wrCode" -eq 0 ];
    then
        echo "**** withdraw-rewards of $VALADDRESS and key $FROMKEY is successfull!!  txHash is : $wrtxHash ****"
    else 
        echo "**** withdraw-rewards of $VALADDRESS and key $FROMKEY is failed!!!!   txHash is : $wrtxHash and REASON : wrtxHash=$(echo "${wrTx}" | jq '.raw_log') ****"
    fi
done
echo

echo "--------- Running withdraw-rewards tx-----------"

wrTx=$("${DAEMON}" tx distribution withdraw-rewards "${VALADDRESS}" --from $KEY --fees "${FEE}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
wrCode=$(echo "${wrTx}"| jq -r '.code')
wrtxHash=$(echo "${wrTx}" | jq '.txhash')
echo "Code is : $wrCode"
if [ "$wrCode" -eq 0 ];
then
    echo "**** withdraw-rewards tx is successfull!!  txHash is : $wrtxHash ****"
else 
    echo "**** withdraw-rewards tx is failed!!!!   txHash is : $wrtxHash and REASON : wrtxHash=$(echo "${wrTx}" | jq '.raw_log') ****"
fi

echo

echo "--------- Running withdraw-rewards commission tx-----------"

wrcTx=$("${DAEMON}" tx distribution withdraw-rewards "${VALADDRESS}" --from $KEY --commission --fees "${FEE}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
#echo $wrTx
wrcCode=$(echo "${wrcTx}"| jq -r '.code')
wrctxHash=$(echo "${wrcTx}" | jq '.txhash')
echo "Code is : $wrcCode"
if [ "$wrcCode" -eq 0 ];
then
    echo "**** withdraw-rewards commission tx is successfull!!  txHash is : $wrctxHash ****"
else 
    echo "**** withdraw-rewards comission tx is failed!!!!   txHash is : $wrctxHash and REASON : $(echo "${wrcTx}" | jq '.raw_log') ****"
fi

echo

echo "------ Running withdraw-all-rewards tx --------"

wartx=$($DAEMON tx distribution withdraw-all-rewards --from $KEY --fees $FEE --chain-id $CHAINID --keyring-backend test --node $NODE -y)
warcode=$(echo "${wartx}"| jq -r '.code')
wartxHash=$(echo "${wartx}" | jq -r '.txhash')
echo "Code is : $warcode"
if [ "$warcode" -eq 0 ];
then
    echo "**** withdraw-all-rewards tx is successfull!!  txHash is : $wartxHash ****"
else 
    echo "**** withdraw-all-rewards tx is failed!!!!   txHash is : $wartxHash and REASON : $(echo "${wartx}" | jq -r '.raw_log') ****"
fi

echo