#/bin/sh

#regen q gov proposals --status voting_period --output json
#regen q gov vote 1 regen1lwr6t4hx0kz3nps6xtrat44h7cumyk7qnug9m9 --chain-id test
#regen tx gov vote 1 yes --from test1 --fees 500uregen --chain-id test
#regen q gov proposals --status voting_period --output json

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
len=$(echo "${vp}" | jq '.proposals | length' )
echo "** Length of voting period proposals : $len **"

for i in $(seq 1 $len);
do
    echo $i
    echo $(echo "${vp}" | jq -r '.proposals[] | .proposal_id')
done

