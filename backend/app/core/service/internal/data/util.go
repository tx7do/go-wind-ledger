package data

import (
	"strconv"
	"time"
)

// StrToFloat converts a string to float64, returns 0 on error.
func StrToFloat(s string) float64 {
	f, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0
	}
	return f
}

// FloatToStr converts a float64 to string.
func FloatToStr(f float64) string {
	return strconv.FormatFloat(f, 'f', 2, 64)
}

// strPtrToFloatPtr converts a *string containing a numeric value to *float64.
func strPtrToFloatPtr(s *string) *float64 {
	if s == nil {
		return nil
	}
	f, err := strconv.ParseFloat(*s, 64)
	if err != nil {
		return nil
	}
	return &f
}

// nowAddr returns a pointer to current time
func nowAddr() *time.Time {
	t := time.Now()
	return &t
}
