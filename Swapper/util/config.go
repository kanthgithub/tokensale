package util

import (
    "io"
    "bufio"
    "os"
	"strconv"
    "fmt"
	"log"
    "strings"
	"github.com/larspensjo/config"
)

const (
	envSavingAesKey = "PARCELX_AES_KEY"
)

type Conf struct {
	items map[string]map[string]string
}


func LoadConfig(filename string) *Conf {

	cfg, err := config.ReadDefault(filename) //读取配置文件，并返回其Config

	if err != nil {
		log.Fatalf("Fail to find %v, %v", filename, err) // 这行好像会触发panic
		return nil
	}

	conf := new(Conf)
	conf.items = make(map[string]map[string]string)

	for _, section := range cfg.Sections() {
		options, err := cfg.SectionOptions(section) //获取一级标签的所有子标签options（只有标签没有值）
		if err == nil {
			bag := make(map[string]string)
			for _, optionKey := range options {
				optionValue, err := cfg.String(section, optionKey) //根据一级标签section和option获取对应的值
				if err == nil {
					bag[optionKey] = optionValue
				}
			}
			conf.items[section] = bag
		}
	}
	return conf
}


// 取不到直接Panic
func (c *Conf) Get(section string, key string) string {
	val, ok := get(c, section, key, false)
	if ok {
		return val
	} else {
		panic("Error to fetch " + key)
	}
}

// 返回int值，取不到直接Panic
func (c *Conf) GetInt(section string, key string) int {
	val, ok := get(c, section, key, false)
	if ! ok {
		panic("Error to fetch " + key)
	}
	intval, err := strconv.Atoi(val)
	if err != nil {
		panic("Error to convert int " + key)
	}
	return intval
}

// 取不到，直接Panic
func (c *Conf) GetSecret(section string, key string) string {
	val, ok := get(c, section, key, true)
	if ok {
		return val
	} else {
		panic("Error to fetch " + key)
	}
}

// 取不到，不会Panic
func (c *Conf) GetValue(section string, key string) (string, bool) {
	return get(c, section, key, false)
}

// 取不到，不会Panic
func (c *Conf) GetSecretValue(section string, key string) (string, bool) {
	return get(c, section, key, true)
}

func get(conf *Conf, section string, key string, secret bool) (string, bool) {
	bag, ok := conf.items[section]
	if !ok {
		return "", false
	}
	val, ok := bag[key]
	if !ok {
		return "", false
	}
	if secret {
		var aseKey string = aesKeyOfConfig()
		var err error
		val, err = ExpressAesDecrypt(aseKey, val)
		if err != nil {
			return "", false
		}
	}
	return val, true
}

// 从环境变量中，获取用于解密配置文件中加密项的ASE Key
// 如果环境变量中没有，则需要用户当场输入。输入一次后，就会被当前程序的环境变量记录下来
func aesKeyOfConfig() string {
    var key_val string = os.Getenv(envSavingAesKey)
    if key_val == "" {
        fmt.Printf("Input AES_KEY to Parse Config: ")

        reader := bufio.NewReader(os.Stdin)
        var err error
        key_val, err = reader.ReadString('\n')   // 注意，这里不能是 :=  不然key_val永远不会更新
        if err == io.EOF {
            panic("AES_KEY input error")
        }
        if key_val == "" {
            panic("AES_KEY input empty")
        }
        key_val = strings.TrimSpace(key_val)
        os.Setenv(envSavingAesKey, key_val)
    }
    return key_val
}

