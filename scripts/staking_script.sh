#/bin/sh

printf "Exported values::\n Daemon : $DAEMON\n Key : $KEY\n ChainID : $CHAINID\n Node : $NODE\n FEE :$FEE\n ValidatorAddress : $VALADDRESS\n DestinationValidatorAddress: $DSTVALADDR\n Amount : $AMOUNT\n"

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
    echo "**** Delegate tx is FAILED!!!!   txHash is : $dtxHash  ***"
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
    echo "**** Delegate tx is SUCCESSFULL!!  txHash is : $rdtxHash ****"
else 
    echo "**** Delegate tx is FAILED!!!!   txHash is : $rdtxHash  ***"
fi

echo