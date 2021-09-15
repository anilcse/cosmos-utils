#/bin/sh

printf "Exported values::\n Daemon : $DAEMON\n Key : $KEY\n ChainID : $CHAINID\n Node : $NODE\n FEE :$FEE\n ValidatorAddress : $VALADDRESS\n Amount : $AMOUNT\n"

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