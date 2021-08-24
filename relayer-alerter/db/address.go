package db

import (
	"log"

	"gopkg.in/mgo.v2/bson"

	"github.com/vitwit/cosmos-utils/relayer-alerter/types"
)

func InsertNewAddress(address types.Address, db string) error {
	var c = MongoSession.DB(db).C("address")

	err := c.Insert(&address)
	if err != nil {
		log.Println("Error while inserting new address details ", err)
	}

	return err
}

func UpdateAddress(query bson.M, updateObj bson.M, db string) error {
	var c = MongoSession.DB(db).C("address")
	err := c.Update(query, updateObj)
	return err
}

func GetAddress(query bson.M, selectObj bson.M, db string) (address types.Address, err error) {
	var c = MongoSession.DB(db).C("address")

	err = c.Find(query).Select(selectObj).One(&address)
	return address, err
}

func GetAllAddress(query bson.M, selectObj bson.M, db string) (addresses []types.Address, err error) {
	var c = MongoSession.DB(db).C("address")

	err = c.Find(query).Select(selectObj).All(&addresses)
	return addresses, err
}

func DeleteAddress(query bson.M, db string) (err error) {
	var c = MongoSession.DB(db).C("address")

	err = c.Remove(query)
	return err
}
