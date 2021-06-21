package targets

import (
	"log"
	"time"

	"gopkg.in/mgo.v2"

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
		Database: "relayer",
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
