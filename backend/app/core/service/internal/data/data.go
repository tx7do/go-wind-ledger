package data

import (
	"github.com/tx7do/go-utils/password"
)

func NewPasswordCrypto() password.Crypto {
	crypto, err := password.CreateCrypto("bcrypt")
	if err != nil {
		panic(err)
	}
	return crypto
}
