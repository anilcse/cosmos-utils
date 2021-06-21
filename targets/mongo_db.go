package targets

import (
	"log"
	"time"

	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"

	"github.com/PrathyushaLakkireddy/relayer-alerter/config"
)

var MongoSession *mgo.Session
var err error

func InitDB(cfg *config.Config) {

	MongoDbUrl := &mgo.DialInfo{
		Addrs:    []string{string("localhost")},
		Timeout:  30 * time.Second,
		Username: "",
		Password: "",
		Database: cfg.MongoDB.Database,
	}

	MongoSession, err = mgo.DialWithInfo(MongoDbUrl)

	if err != nil {
		log.Fatalf("Error while connecting to database", err)
	}

	if err = MongoSession.Ping(); err != nil {
		defer MongoSession.Close()
		log.Fatalf("Error while connecting to Database ", err)
	}
	// defer MongoSession.Close()
	log.Println("Database connected successfully")
}

func InsertNewAddress(address Address, db string) error {
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

func GetAddress(query bson.M, selectObj bson.M, db string) (address Address, err error) {
	var c = MongoSession.DB(db).C("address")

	err = c.Find(query).Select(selectObj).One(&address)
	return address, err
}

func GetAllAddress(query bson.M, selectObj bson.M, db string) (addresses []Address, err error) {
	var c = MongoSession.DB(db).C("address")

	err = c.Find(query).Select(selectObj).All(&addresses)
	return addresses, err
}

func DeleteAddress(query bson.M, db string) (err error) {
	var c = MongoSession.DB(db).C("address")

	err = c.Remove(query)
	return err
}

//**** balances ****

func AddAccBalance(bal Balances, db string) error {
	var c = MongoSession.DB(db).C("balance")

	err := c.Insert(&bal)
	if err != nil {
		log.Println("Error while inserting account balances ", err)
	}

	return err
}

func GetAccBalance(query bson.M, selectObj bson.M, db string) (bal Balances, err error) {
	var c = MongoSession.DB(db).C("balance")

	err = c.Find(query).Select(selectObj).One(&bal)
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
