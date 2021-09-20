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
len=$(echo "${vp}" | jq -r '.proposals | length' )
echo "** Length of voting period proposals : $len **"

for row in $(echo "${vp}" | jq -r '.proposals | .[] | @base64'); do
  # _jq() {
  #   echo ${row} | base64 --decode | jq -r ${1}
  # }
  echo ${row} | base64 --decode | jq -r '.proposal_id'
done

arr=$(echo "${vp}" | jq -r '.proposals | map(.proposal_id)')
echo $arr
for i in ${arr[@]}; do
  echo "Value.....$i"
done
#echo ${arr[0]}
#echo ${arr[@]:1:2}
#echo ${arr[@]:0:1}

echo "Print all : ${arr[@]}   and ${arr[0]}"
# iterate through the Bash array
#for item in "${arr[@]}"; do
   #echo $item
   #echo "In loop ${arr[@]:item-1:item}"
  # do your stuff
#done

echo "ele ${arr[@]:0:1}"
echo "ele ${arr[@]:1:2}"
echo "ele ${arr[@]:2:3}"
echo "ele ${arr[@]:3:4}"

tl=`expr $len + $len - 1`
echo "total len: $s"

for i in $(seq 1 $tl);
do
    j=`expr $i - 1`
    PID=${arr[@]:j:i}
    echo "Proposal id i ${i} and j ${j} ${PID}" #print porposal ids

    echo "${i} and ${j}  ${arr[@]:2:3} "


    #echo "In loop ${arr[@]:item-1:item}"
   # echo $(echo "${vp}" | jq -c '.proposals[] | .proposal_id')
done

