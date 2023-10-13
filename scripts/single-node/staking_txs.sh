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
        FROMKEY="validator1"
        TO=$v2
        TOKEY="validator2"
    elif [ $a == 2 ]
    then
        FROMKEY="validator2"
        TO=$v3
        TOKEY="validator3"
    else [ $a == 3 ]
        FROMKEY="validator3"
        TO=$v4
        TOKEY="validator4"
    fi
    # Print the value
    echo "Iteration no $a and values of from : $FROMKEY to : $TO"
    echo "--------- Delegation from $FROMKEY to $TO-----------"

    dTx=$("${DAEMON}" tx staking delegate "${TO}" 10000"${DENOM}" --from $FROMKEY --fees 1000"${DENOM}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
    dTxCode=$(echo "${dTx}"| jq -r '.code')
    dtxHash=$(echo "${dTx}" | jq '.txhash')
    echo "Code is : $dTxCode"
    echo
    if [ "$dTxCode" -eq 0 ];
    then
        echo "**** Delegation from $FROMKEY to $TOKEY is SUCCESSFULL!!  txHash is : $dtxHash ****"
    else 
        echo "**** Delegation from $FROMKEY to $TOKEY has FAILED!!!!   txHash is : $dtxHash and REASON : $(echo "${dTx}" | jq '.raw_log')***"
    fi
    echo
done

echo

#Start of for loop to run redelegation txs
for a in 1 2 3 4
do
    if [ $a == 1 ]
    then
        FROM=$v4
        TO=$v3
        FROMKEY="validator4"
        TOKEY="validator3"
    elif [ $a == 2 ]
    then
        FROM=$v3
        TO=$v2
        FROMKEY="validator3"
        TOKEY="validator2"
    elif [ $a == 3 ]
    then
        FROM=$v2
        TO=$v1
        FROMKEY="validator2"
        TOKEY="validator1"
    else [$a == 4]
        FROM=$v4
        TO=$v3
        FROMKEY="validator4"
        TOKEY="validator3"
    fi
    # Print the value
    echo "Iteration no $a and values of from : $FROM to : $TO"
    echo "--------- Redelegation from $FROM to $TO-----------"

    rdTx=$("${DAEMON}" tx staking redelegate "${FROM}" "${TO}" 10000"${DENOM}" --from "${FROMKEY}" --fees 1000"${DENOM}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
    rdTxCode=$(echo "${rdTx}"| jq -r '.code')
    rdtxHash=$(echo "${rdTx}" | jq '.txhash')
    echo "Code is : $rdTxCode"
    echo
    if [ "$rdTxCode" -eq 0 ];
    then
        echo "**** Redelegation from $FROMKEY to $TOKEY is SUCCESSFULL!!  txHash is : $rdtxHash ****"
    else 
        echo "**** Redelegation from $FROMKEY to $TOKEY has FAILED!!!!   txHash is : $rdtxHash and REASON : $(echo "${rdTx}" | jq '.raw_log') ***"
    fi
    echo
done
echo

#Start of for loop to run unbond txs
for a in 1 2 3 4
do
    if [ $a == 1 ]
    then
        FROM=$v1
        FROMKEY="validator1"
    elif [ $a == 2 ]
    then
        FROM=$v2
        FROMKEY="validator2"
    elif [ $a == 3 ]
    then
        FROM=$v3
        FROMKEY="validator3"
    else
        FROM=$v4
        FROMKEY="validator4"
    fi
    # Print the value
    echo "Iteration no $a and values of from : $FROM and fromKey : $FROMKEY"
    echo "--------- Running unbond tx command------------"

    ubTx=$("${DAEMON}" tx staking unbond "${FROM}" 10000"${DENOM}" --from "${FROMKEY}" --fees 1000"${DENOM}" --chain-id "${CHAINID}" --keyring-backend test --node "${NODE}" -y)
    ubTxCode=$(echo "${ubTx}"| jq -r '.code')
    ubtxHash=$(echo "${ubTx}" | jq '.txhash')
    echo "Code is : $ubTxCode"
    echo
    if [ "$ubTxCode" -eq 0 ];
    then
        echo "**** Unbond tx ( of $FROM and key $FROMKEY ) is SUCCESSFULL!!  txHash is : $ubtxHash ****"
    else 
        echo "**** Unbond tx ( of $FROM and key $FROMKEY ) if FAILED!!!!   txHash is : $ubtxHash  and REASON : $(echo "${ubTx}" | jq '.raw_log')  ***"
    fi
    echo
done
echo