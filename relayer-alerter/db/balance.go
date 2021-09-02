package db

import (
	"log"

	"gopkg.in/mgo.v2/bson"

	"github.com/vitwit/cosmos-utils/relayer-alerter/types"
)

func AddAccBalance(bal types.Balances, db string) error {
	var c = MongoSession.DB(db).C("balance")

	err := c.Insert(&bal)
	if err != nil {
		log.Println("Error while inserting account balances ", err)
	}

	return err
}

func GetAccBalance(query bson.M, selectObj bson.M, db string) (bal types.Balances, err error) {
	var c = MongoSession.DB(db).C("balance")

	err = c.Find(query).Select(selectObj).One(&bal)
	return bal, err
}

func GetAllAccBalances(query bson.M, selectObj bson.M, db string) (bal []types.Balances, err error) {
	var c = MongoSession.DB(db).C("balance")

	err = c.Find(query).Select(selectObj).All(&bal)
	return bal, err
}

func UpdateAccBalance(query bson.M, updateObj bson.M, db string) error {
	var c = MongoSession.DB(db).C("balance")
	err := c.Update(query, updateObj)
	return err
}

func DeleteBalance(query bson.M, db string) (err error) {
	var c = MongoSession.DB(db).C("balance")

	err = c.Remove(query)
	return err
}
