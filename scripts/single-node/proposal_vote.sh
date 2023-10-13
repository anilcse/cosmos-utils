#/bin/sh

echo "--------- Get validator addresses -----------"
va1=$("${DAEMON}" keys show validator1 --keyring-backend test --output json)
v1=$(echo "${va1}" | jq -r '.address')
echo "** validator1 address :: $v1 **"

va2=$("${DAEMON}" keys show validator2 --keyring-backend test --output json)
v2=$(echo "${va2}" | jq -r '.address')
echo "** validator2 address :: $v2 **"

va3=$("${DAEMON}" keys show validator3 --keyring-backend test --output json)
v3=$(echo "${va3}" | jq -r '.address')
echo "** validator3 address :: $v3 **"

va4=$("${DAEMON}" keys show validator4 --keyring-backend test --output json)
v4=$(echo "${va4}" | jq -r '.address')
echo "** validator4 address :: $v4 **"

echo

echo "--------Get voting period proposals--------------"
vp=$("${DAEMON}" q gov proposals --status voting_period --output json)
len=$(echo "${vp}" | jq -r '.proposals | length' )
echo "** Length of voting period proposals : $len **"
echo

for row in $(echo "${vp}" | jq -r '.proposals | .[] | @base64'); do

  PID=$(echo "${row}" | base64 --decode | jq -r '.proposal_id')
  echo
  echo
  echo "** Checking votes for proposal id : $PID **"

  for a in 1 2 3 4
  do
    if [ $a == 1 ]
    then
      FROMKEY="validator1"
      VOTER=$v1
    elif [ $a == 2 ]
    then
      FROMKEY="validator2"
      VOTER=$v2
    elif [ $a == 3 ]
    then
      FROMKEY="validator3"
      VOTER=$v3
    else [ $a == 4 ]
      VOTER=$v4
      FROMKEY="validator4"
    fi
    # Check vote status
    getVote=$( ("${DAEMON}" q gov vote "${PID}" "${VOTER}" --output json) 2>&1)
   
    if [ "$?" -eq 0 ];  #0 indiactes no reponse with gov vote query so we can proceed further
    then
      voted=$(echo "${getVote}" | jq -r '.option')
      #echo "*** Proposal Id : $PID and VOTER : $VOTER and VOTE OPTION : $voted ***"
      #cast vote
      castVote=$( ("${DAEMON}" tx gov vote "${PID}" yes --from "${FROMKEY}" --fees 1000"${DENOM}" --chain-id "${CHAINID}" --node "${NODE}" -keyring-backend test -y) 2>&1) 
      #echo "$?... $castVote"
      checkVote=$(echo "${castVote}"| jq -r '.code')
      #echo "check vote response err : $checkVote"
      txHash=$(echo "${castVote}"| jq -r '.txhash')
      if [[ "$checkVote" != "" ]];
      then
        if [ "$checkVote" -eq 0 ];
        then
          echo "**** $FROMKEY successfully voted on the proposal :: (proposal ID : $PID and address $VOTER ) !!  txHash is : $txHash ****"
        else 
          echo "**** $FROMKEY getting error while casting vote for ( Proposl ID : $PID and address $VOTER )!!!!  txHash is : $txhash and REASON : $(echo "${castVote}" | jq '.raw_log') ****"
        fi
      fi
    else
      echo "Error while getting votes of proposal ID : $PID of $FROMKEY address : $VOTER"
    fi
  done
done