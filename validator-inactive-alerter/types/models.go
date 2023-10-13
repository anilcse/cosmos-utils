package types

import (
	"time"

	"gopkg.in/mgo.v2/bson"
)

type (
	ValidatorSet struct {
		ID               bson.ObjectId `json:"_id" bson:"_id,omitempty"`
		ValidatorAddress string        `json:"validator_address" bson:"validator_address"`
		UpdatedAt        time.Time     `json:"updated_at" bson:"updated_at"`
		HexAddress       string        `json:"hex_address" bson:"hex_address"`
		Status           string        `json:"status" bson:"status"`
	}
)
