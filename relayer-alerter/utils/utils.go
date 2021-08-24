package utils

import (
	"fmt"
	"log"
	"math"
	"strconv"

	"golang.org/x/text/language"
	"golang.org/x/text/message"
)

// ConvertToFolat64 converts balance from string to float64
func ConvertValue(balance string, denom string) float64 {
	bal, _ := strconv.ParseFloat(balance, 64)

	var a1 float64

	if denom == "uiris" || denom == "basecro" {
		a1 = bal / math.Pow(10, 8)
	} else {
		a1 = bal / math.Pow(10, 6)
	}

	amount := fmt.Sprintf("%.6f", a1)

	a, err := strconv.ParseFloat(amount, 64)
	if err != nil {
		log.Printf("Error while converting string to folat64 : %v", err)
	}

	return a
}

func ConvertToCommaSeparated(amt string) string {
	a, err := strconv.Atoi(amt)
	if err != nil {
		log.Printf("Converting string to int : %v", err)
		return amt
	}
	p := message.NewPrinter(language.English)
	return p.Sprintf("%d", a)
}
