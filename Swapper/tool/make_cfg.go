// 生成配置文件中的加密项
// 先输入AES的密钥。紧接着一次原文、一次密文

package main

import (
    "bufio"
    "fmt"
    "io"
    "os"
    "strings"
    "parcelx.io/Swapper/util"
)

func main() {
	fmt.Printf("AES Key: ")
	var key string
	fmt.Scan(&key)
	key = strings.TrimSpace(key)

	if len(key) == 0 || len(key) > 16 {
		fmt.Println("Key must be 1~16 in length")
		return 
	}

	// 开始配置项的加密	
    reader := bufio.NewReader(os.Stdin)
    reader.ReadString('\n') // 很奇怪，用了Scan之后，reader第1次会落空

    for {
        line, err := reader.ReadString('\n')
        if err == io.EOF {
        	fmt.Printf("<EOF>")
            break
        }
        line = strings.TrimSpace(line)
        if line == "" {
        	fmt.Printf("<END>")
        	break
        }

        value, err := util.ExpressAesEncrypt(key, line)
        if err != nil {
        	panic(err)
        }

        fmt.Println(value)
     	// 这步是验证 fmt.Println(util.ExpressAesDecrypt(key, value))
           
    }
}
