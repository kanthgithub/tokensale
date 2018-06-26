package util

import (
	"fmt"
	"os"
	"bytes"
    "math/rand"
    "time"
)



func ExitErrorf(msg string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, msg+"\n", args...)
	os.Exit(1)
}

func RandomString(l int) string {
    var result bytes.Buffer
    var temp string
    for i := 0; i < l; {
        if string(RandInt(65, 90)) != temp {
            temp = string(RandInt(65, 90))
            result.WriteString(temp)
            i++
        }
    }
    return result.String()
}

func RandInt(min int, max int) int {
    rand.Seed(time.Now().UTC().UnixNano())
    return min + rand.Intn(max-min)
}
