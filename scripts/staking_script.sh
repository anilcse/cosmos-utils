#/bin/sh


display_usage() {
    printf "** Please check the exported values:: **\n Daemon : $DAEMON\n Key : $KEY\n ChainID : $CHAINID\n Node : $NODE\n FEE :$FEE\n ValidatorAddress : $VALADDRESS\n DestinationValidatorAddress: $DSTVALADDR\n Amount : $AMOUNT\n"
    exit 1
}

if [ -z $DAEMON ] || [ -z $KEY ] || [ -z $CHAINID ] || [ -z $NODE ] || [ -z $FEE ] || [ -z $VALADDRESS ] || [ -z $DSTVALADDR] || [ -z $AMOUNT]
then 
    display_usage
fi

echo
echo "--------- Running delegate tx command-----------"

dTx=$("${DAEMON}" tx staking delegate "${VALADDRESS}" "${AMOUNT}" --from $KEY --fees "${FEE}" --chain-id "${CHAINID}" --node "${NODE}" -y)
dTxCode=$(echo "${dTx}"| jq -r '.code')
dtxHash=$(echo "${dTx}" | jq '.txhash')
echo "Code is : $dTxCode"
echo
if [ "$dTxCode" -eq 0 ];
then
    echo "**** Delegate tx is SUCCESSFULL!!  txHash is : $dtxHash ****"
else 
    echo "**** Delegate tx is FAILED!!!!   txHash is : $dtxHash and REASON : $(echo "${dTx}" | jq '.raw_log')***"
fi

echo

echo "--------- Running redelegate tx command-----------"

rdTx=$("${DAEMON}" tx staking redelegate "${VALADDRESS}" "${DSTVALADDR}" "${AMOUNT}" --from $KEY --fees "${FEE}" --chain-id "${CHAINID}" --node "${NODE}" -y)
rdTxCode=$(echo "${rdTx}"| jq -r '.code')
rdtxHash=$(echo "${rdTx}" | jq '.txhash')
echo "Code is : $rdTxCode"
echo
if [ "$rdTxCode" -eq 0 ];
then
    echo "**** Redelegate tx is SUCCESSFULL!!  txHash is : $rdtxHash ****"
else 
    echo "**** Redelegate tx is FAILED!!!!   txHash is : $rdtxHash and REASON : $(echo "${rdTx}" | jq '.raw_log') ***"
fi

echo

echo "--------- Running unbond tx command-----------"

ubTx=$("${DAEMON}" tx staking unbond "${VALADDRESS}" "${AMOUNT}" --from $KEY --fees "${FEE}" --chain-id "${CHAINID}" --node "${NODE}" -y)
#echo $ubTx
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