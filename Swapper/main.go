package main


import (
 	"flag"
	"fmt"
	"parcelx.io/Swapper/util"
)

import _ "parcelx.io/Swapper/sale"

func main() {
	// 新Flag和Conf, 加载配置项
	var confPath = flag.String("conf", "conf/main.conf", "Config File Path")  
	flag.Parse() 
	fmt.Println("USE conf path:", *confPath)
	var conf *util.Conf = util.LoadConfig(*confPath)

	fmt.Println(conf.Get("monitor.listener", "LISTENERS"))


}

