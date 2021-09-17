#/bin/sh

display_usage() {
    printf "** Please check the exported values:: **\n Deamon : $DEAMON\n Denom : $DENOM\n ChainID : $CHAINID\n Node : $NODE\n"
    exit 1
}

if [ -z $DAEMON ] || [ -z $DENOM ] || [ -z $CHAINID ] || [ -z $NODE ]
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

#Start of for loop to run delegation txs
for a in 1 2 3
do
    if [ $a == 1 ]
    then
        fromKey="validator1"
        to=$v2
        toKey="validator2"
    elif [ $a == 2 ]
    then
        fromKey="validator2"
        to=$v3
        toKey="validator3"
    else [ $a == 3 ]
        fromKey="validator3"
        to=$v4
        toKey="validator4"
    fi
    # Print the value
    echo "Iteration no $a and values of from : $fromKey to : $to"
    echo "--------- Delegation from $from to $to-----------"

    dTx=$("${DAEMON}" tx staking delegate "${to}" 10000"${DENOM}" --from $fromKey --fees 1000"${DENOM}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
    dTxCode=$(echo "${dTx}"| jq -r '.code')
    dtxHash=$(echo "${dTx}" | jq '.txhash')
    echo "Code is : $dTxCode"
    echo
    if [ "$dTxCode" -eq 0 ];
    then
        echo "**** Delegation from $fromKey to $toKey is SUCCESSFULL!!  txHash is : $dtxHash ****"
    else 
        echo "**** Delegation from $fromKey to $toKey has FAILED!!!!   txHash is : $dtxHash and REASON : $(echo "${dTx}" | jq '.raw_log')***"
    fi
    echo
done

echo

#Start of for loop to run redelegation txs
for a in 1 2 3 4
do
    if [ $a == 1 ]
    then
        from=$v4
        to=$v3
        fromKey="validator4"
        toKey="validator3"
    elif [ $a == 2 ]
    then
        from=$v3
        to=$v2
        fromKey="validator3"
        toKey="validator2"
    elif [ $a == 3 ]
    then
        from=$v2
        to=$v1
        fromKey="validator2"
        toKey="validator1"
    else [$a == 4]
        from=$v4
        to=$v3
        fromKey="validator4"
        toKey="validator3"
    fi
    # Print the value
    echo "Iteration no $a and values of from : $from to : $to"
    echo "--------- Redelegation from $from to $to-----------"

    rdTx=$("${DAEMON}" tx staking redelegate "${from}" "${to}" 10000"${DENOM}" --from $fromKey --fees 1000"${DENOM}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
    rdTxCode=$(echo "${rdTx}"| jq -r '.code')
    rdtxHash=$(echo "${rdTx}" | jq '.txhash')
    echo "Code is : $rdTxCode"
    echo
    if [ "$rdTxCode" -eq 0 ];
    then
        echo "**** Redelegation from $fromKey to $toKey is SUCCESSFULL!!  txHash is : $rdtxHash ****"
    else 
        echo "**** Redelegation from $fromKey to $toKey has FAILED!!!!   txHash is : $rdtxHash and REASON : $(echo "${rdTx}" | jq '.raw_log') ***"
    fi
    echo
done
echo

#Start of for loop to run unbond txs
for a in 1 2 3 4
do
    if [ $a == 1 ]
    then
        from=$v1
        fromKey="validator1"
    elif [ $a == 2 ]
    then
        from=$v2
        fromKey="validator2"
    elif [ $a == 3 ]
    then
        from=$v3
        fromKey="validator3"
    else
        from=$v4
        fromKey="validator4"
    fi
    # Print the value
    echo "Iteration no $a and values of from : $from and fromKey : $fromKey"
    echo "--------- Running unbond tx command-----------"

    ubTx=$("${DAEMON}" tx staking unbond "${from}" 10000"${DENOM}" --from $fromKey --fees 1000"${DENOM}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
    ubTxCode=$(echo "${ubTx}"| jq -r '.code')
    ubtxHash=$(echo "${ubTx}" | jq '.txhash')
    echo "Code is : $ubTxCode"
    echo
    if [ "$ubTxCode" -eq 0 ];
    then
        echo "**** Unbond tx of $fromKey is SUCCESSFULL!!  txHash is : $ubtxHash ****"
    else 
        echo "**** Unbond tx of $fromKey if FAILED!!!!   txHash is : $ubtxHash  and REASON : $(echo "${ubTx}" | jq '.raw_log')  ***"
    fi
    echo
done
echo