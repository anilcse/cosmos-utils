# Generate sign messages and broadcast to rpc 
## Install deps 
```bash
## Install python3 and pip-env 
$ pipenv shell
$ pipenv install 
```
## CSV File Format 
```csv
validator_address,amount
pasgvaloper1djp5ru64djz3g8ngf26tcw203xd6tq2auzu5vp,100
pasgvaloper1djp5ru64djz3g8ngf26tcw203xd6tq2auzu5vp,20
pasgvaloper1djp5ru64djz3g8ngf26tcw203xd6tq2auzu5vp,30
```
##  Genetate unsigned message for delegations
```bash 
$ python main.py inp.csv --from_addr {FROM_ADDR} --granter {GRANTER} --memo {MEMO} --output unsigned_message.json
```

## Sign the message 
```
$ simd tx sign unsigned_message.json --from test --chain-id test-chain > sign.json 
```

## Broadcast the sign message 
```bash
$ simd tx broadcast signed_message.json 
```