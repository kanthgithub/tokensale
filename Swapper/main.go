package main


import (
 	"flag"
	"fmt"
	"os"
	"time"
	"strings"
	"net/http"
	"parcelx.io/Swapper/util"
)

import _ "parcelx.io/Swapper/sale"

var server *http.Server;

func main() {
	// load config firstly
	var confPath = flag.String("conf", "conf/online.conf", "Config File Path");
	flag.Parse();
	fmt.Println("USE conf path:", *confPath);
	var conf *util.Conf = util.LoadConfig(*confPath);

	fmt.Println(conf.GetSecret("mysql.cache", "USER_PASS"));

	// start the web server
	server = &http.Server{Addr: ":8080"};

	http.Handle("/", http.FileServer(http.Dir("./www")));
	http.HandleFunc("/shutdown/", shutdown);
	if err := server.ListenAndServe(); err != nil {
		fmt.Println("Shutdown:", err);
	} else {
		fmt.Println("Shutdown normally.");
	}
}

func shutdown(w http.ResponseWriter, r *http.Request) {
	pid := fmt.Sprintf("%d", os.Getpid());
	if (strings.HasSuffix(r.URL.Path, pid)) {
		w.Write([]byte("Shutdown Done."));
		go func() {
			time.Sleep(1 * time.Second);
			server.Shutdown(nil);
		}();
	} else {
		w.Write([]byte("Invalid Shutdown PID."));
	}
	
}
