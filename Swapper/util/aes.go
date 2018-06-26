package util

import (
    "fmt"
    "crypto/cipher"
    "crypto/aes"
    "bytes"
    "encoding/base64"
    "errors"
)

func pkcs5Padding(ciphertext []byte, blockSize int) []byte {
    padding := blockSize - len(ciphertext)%blockSize
    padtext := bytes.Repeat([]byte{byte(padding)}, padding)
    return append(ciphertext, padtext...)
}

// 这个函数，改造了一下
func pkcs5UnPadding(origData []byte) []byte {
    length := len(origData)
    unpadding := int(origData[length-1])
    if (length - unpadding) < 0 || (length - unpadding) > len(origData) {
        return nil
    }
    return origData[:(length - unpadding)]
}

func AesEncrypt(origData, key []byte) ([]byte, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, err
    }

    blockSize := block.BlockSize()
    origData = pkcs5Padding(origData, blockSize)
    blockMode := cipher.NewCBCEncrypter(block, key[:blockSize])
    crypted := make([]byte, len(origData))
    blockMode.CryptBlocks(crypted, origData)
    return crypted, nil
}

func AesDecrypt(crypted, key []byte) ([]byte, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, err
    }

    blockSize := block.BlockSize()
    blockMode := cipher.NewCBCDecrypter(block, key[:blockSize])
    origData := make([]byte, len(crypted))
    blockMode.CryptBlocks(origData, crypted)
    origData = pkcs5UnPadding(origData)
    if origData == nil {
        return nil, errors.New("Wrong AWS Key !!")
    } else {
        return origData, nil
    }
}

// 加密的user-friendly形式
func ExpressAesEncrypt(key string, body string) (string, error) {
    for len(key) < 16 {
        key = key + "0"
    }
    var aeskey = []byte(key)
    pass := []byte(body)
    xpass, err := AesEncrypt(pass, aeskey)
    if err != nil {
        return "", err
    }

    pass64 := base64.StdEncoding.EncodeToString(xpass)
    return pass64, nil
}

// 加密的user-friendly形式
func ExpressAesDecrypt(key string, pass64 string) (string, error) {
    for len(key) < 16 {
        key = key + "0"
    }
    var aeskey = []byte(key)

    bytesPass, err := base64.StdEncoding.DecodeString(pass64)
    if err != nil {
        return "", err
    }

    tpass, err := AesDecrypt(bytesPass, aeskey)
    if err != nil {
        return "", err
    }

    return fmt.Sprintf("%s", tpass), nil
}


func main2() {
    var aeskey = []byte("321423u9y8d2fwfl")
    pass := []byte("vdncloud123456")
    xpass, err := AesEncrypt(pass, aeskey)
    if err != nil {
        fmt.Println(err)
        return
    }

    pass64 := base64.StdEncoding.EncodeToString(xpass)
    fmt.Printf("加密后:%v\n",pass64)

    bytesPass, err := base64.StdEncoding.DecodeString(pass64)
    if err != nil {
        fmt.Println(err)
        return
    }

    tpass, err := AesDecrypt(bytesPass, aeskey)
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Printf("解密后:%s\n", tpass)
}
