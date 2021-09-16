#/bin/sh

display_usage() {
    printf "** Please check the exported values:: **\n Daemon : $DAEMON\n Key : $KEY\n ChainID : $CHAINID\n Node : $NODE\n FEE :$FEE\n Amount : $AMOUNT\n"
    # exit 1
}

if [ -z $DAEMON ] || [ -z $KEY ] || [ -z $CHAINID ] || [ -z $NODE ] || [ -z $FEE ] || [ -z $AMOUNT]
then 
    display_usage
fi

echo

echo "--------- Get validator address -----------"
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

#Start of for loop
for a in 1 2 3
do
    # if a is equal to 5 break the loop
    if [ $a == 1 ]
    then
        from=$v1
        to=$v2
        key="validator1"
        key2="validator2"
    elif [ $a == 2 ]
    then
        from=$v2
        to=$v3
        key="validator2"
        key2="validator3"
    else [ $a == 3 ]
        from=$v3
        to=$v4
        key="validator3"
        key2="validator4"
    fi
    # Print the value
    echo "Iteration no $a and values from : $from to : $to"
    echo "--------- Delegation from $key to $key2-----------"

    dTx=$("${DAEMON}" tx staking delegate "${to}" "${AMOUNT}" --from $key --fees "${FEE}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
    dTxCode=$(echo "${dTx}"| jq -r '.code')
    dtxHash=$(echo "${dTx}" | jq '.txhash')
    echo "Code is : $dTxCode"
    echo
    if [ "$dTxCode" -eq 0 ];
    then
        echo "**** Delegation from $key to $key2 is SUCCESSFULL!!  txHash is : $dtxHash ****"
    else 
        echo "**** Delegation from $key to $key2 has FAILED!!!!   txHash is : $dtxHash and REASON : $(echo "${dTx}" | jq '.raw_log')***"
    fi
done

exit 1

echo "--------- Delegation from validator1 to validator2-----------"

dTx=$("${DAEMON}" tx staking delegate "${v2}" "${AMOUNT}" --from validator1 --fees "${FEE}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
dTxCode=$(echo "${dTx}"| jq -r '.code')
dtxHash=$(echo "${dTx}" | jq '.txhash')
echo "Code is : $dTxCode"
echo
if [ "$dTxCode" -eq 0 ];
then
    echo "**** Delegation from validator1 to validator2 is SUCCESSFULL!!  txHash is : $dtxHash ****"
else 
    echo "**** Delegation from validator1 to validator2 has FAILED!!!!   txHash is : $dtxHash and REASON : $(echo "${dTx}" | jq '.raw_log')***"
fi

echo
echo "--------- Delegation from validator2 to validator3-----------"

dTx=$("${DAEMON}" tx staking delegate "${v3}" "${AMOUNT}" --from validator2 --fees "${FEE}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
dTxCode=$(echo "${dTx}"| jq -r '.code')
dtxHash=$(echo "${dTx}" | jq '.txhash')
echo "Code is : $dTxCode"
echo
if [ "$dTxCode" -eq 0 ];
then
    echo "**** Delegation from validator2 to validator3 is SUCCESSFULL!!  txHash is : $dtxHash ****"
else 
    echo "**** Delegation from validator2 to validator3 has FAILED!!!!   txHash is : $dtxHash and REASON : $(echo "${dTx}" | jq '.raw_log')***"
fi

echo

echo
echo "--------- Delegation from validator3 to validator4 -----------"

dTx=$("${DAEMON}" tx staking delegate "${v4}" "${AMOUNT}" --from validator3 --fees "${FEE}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
dTxCode=$(echo "${dTx}"| jq -r '.code')
dtxHash=$(echo "${dTx}" | jq '.txhash')
echo "Code is : $dTxCode"
echo
if [ "$dTxCode" -eq 0 ];
then
    echo "**** Delegation from validator3 to validator4 is SUCCESSFULL!!  txHash is : $dtxHash ****"
else 
    echo "**** Delegation from validator3 to validator4 has FAILED!!!!   txHash is : $dtxHash and REASON : $(echo "${dTx}" | jq '.raw_log')***"
fi

echo

echo "--------- Redelegation from validator4 to validator3 -----------"

rdTx=$("${DAEMON}" tx staking redelegate "${v4}" "${v3}" "${AMOUNT}" --from $KEY --fees "${FEE}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
rdTxCode=$(echo "${rdTx}"| jq -r '.code')
rdtxHash=$(echo "${rdTx}" | jq '.txhash')
echo "Code is : $rdTxCode"
echo
if [ "$rdTxCode" -eq 0 ];
then
    echo "**** Redelegation from validator4 to validator3 is SUCCESSFULL!!  txHash is : $rdtxHash ****"
else 
    echo "**** Redelegation from validator4 to validator3 has FAILED!!!!   txHash is : $rdtxHash and REASON : $(echo "${rdTx}" | jq '.raw_log') ***"
fi

echo


echo

echo "--------- Running unbond tx command-----------"

ubTx=$("${DAEMON}" tx staking unbond "${VALADDRESS}" "${AMOUNT}" --from $KEY --fees "${FEE}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
#echo $ubTx 1000 or 10000stake to be replaced in amount
ubTxCode=$(echo "${ubTx}"| jq -r '.code')
ubtxHash=$(echo "${ubTx}" | jq '.txhash')
echo "Code is : $ubTxCode"
echo
if [ "$ubTxCode" -eq 0 ];
then
    echo "**** Unbond tx is SUCCESSFULL!!  txHash is : $ubtxHash ****"
else 
    echo "**** Unbond tx is FAILED!!!!   txHash is : $ubtxHash  and REASON : $(echo "${ubTx}" | jq '.raw_log')  ***"
fi

echo