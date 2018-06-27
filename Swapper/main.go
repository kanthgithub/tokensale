package main


import (
 	"flag"
	"fmt"
	"os"
	"time"
	"io/ioutil"
	"strings"
	"net/http"
	"parcelx.io/Swapper/util"
)

import _ "parcelx.io/Swapper/sale"

var server *http.Server;

func main() {
	
	// load conf argument
	var confPath = flag.String("conf", "conf/online.conf", "Config File Path");
	var pidPath = flag.String("pid", "run.pid", "Process ID File");
	var aesKeyVal = flag.String("aes", "", "Specific AesKey Value");
	flag.Parse();
	
	// load config file and write pid file
	fmt.Println("USE conf path:", *confPath);
	fmt.Println("USE pid path:", *pidPath);
	var conf *util.Conf = util.LoadConfig(*confPath, *aesKeyVal);
	pidStr := fmt.Sprintf("%d", os.Getpid());
	if err := ioutil.WriteFile(*pidPath, []byte(pidStr), 0644); err != nil {
		panic(err.Error());
	}
	_ = conf;

	// start the web server
	server = &http.Server{Addr: ":8080"};

	http.Handle("/", http.FileServer(http.Dir("./www")));
	http.HandleFunc("/shutdown/", shutdown);
	http.HandleFunc("/test/", test);
	if err := server.ListenAndServe(); err != nil {
		fmt.Println("Shutdown:", err);
	} else {
		fmt.Println("Shutdown normally.");
	}
}


func test(w http.ResponseWriter, r *http.Request) {
	panic("EEEE");
}

func shutdown(w http.ResponseWriter, r *http.Request) {
	pidStr := fmt.Sprintf("%d", os.Getpid());
	if (strings.HasSuffix(r.URL.Path, pidStr)) {
		w.Write([]byte("Shutdown Done."));
		go func() {
			time.Sleep(1 * time.Second);
			server.Shutdown(nil);
		}();
	} else {
		w.Write([]byte("Invalid Shutdown PID."));
	}
	
}
