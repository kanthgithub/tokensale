package eth


import (
	"fmt"
	"time"
	"regexp"
	"strconv"
 	"net/http"
	"io/ioutil"
	"github.com/bitly/go-simplejson"
	"parcelx.io/PX-ICOd/util"
)

type EtherScanError struct {
    detail string
}

func (e *EtherScanError) Error() string {
    return e.detail
}

/**
 * 合并好 txlist 和 txlistinternal 的请求，一同返回
 */
func RequestTransaction(action string, conf *util.Conf) ([]*Transaction, error) {

	if action != "txlist" && action != "txlistinternal" {
		panic("Action error ! " + action)
	}

	timeout := time.Duration(conf.GetInt("etherscan.io", "GET_TIMEOUT")) * time.Second
	client := http.Client {
	    Timeout: timeout,
	}
	
	api_account := fmt.Sprintf(`
        http://api.etherscan.io/api
            ? module = account
            & action = %s
            & address = %s
            & startblock = 0
            & endblock = 99999999
            & page = 1
            & offset = %d
            & sort = desc
            & apikey = %s
        `, action, 
        conf.Get("etherscan.io", "ICO_ADDRESS"), 
        conf.GetInt("etherscan.io", "GET_OFFSET"), 
        conf.GetInt("etherscan.io", "API_KEY") )
	re, _ := regexp.Compile("[\r\n \t]");
	api_account = re.ReplaceAllString(api_account, "");

    fmt.Println(api_account)

	resp, err := client.Get(api_account)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	json, err := simplejson.NewJson(body)
	if err != nil {
	    return nil, err
	}

	status, err := json.Get("status").String()
	if err != nil {
	    return nil, err
	}

	// 准备返回的结果值
	results := make([]*Transaction, 0)

	if status == "0" {
		return results, nil

	} else { 
		if status != "1" {
			return nil, &EtherScanError{"Invalid etherscan.io Status: " + status}
		}

		tnx_list, err := json.Get("result").Array()
	    if err != nil {
	        return nil, err
	    }

	    for _, item := range tnx_list {
	    	tnx, _ := item.(map[string]interface{})

	    	time_int64, _ := strconv.ParseInt(tnx["timeStamp"].(string), 10, 64)
			time_stamp := time.Unix(time_int64, 0).Format("2006-01-02 15:04:05")

			blockNumber, _ := strconv.Atoi(tnx["blockNumber"].(string))
	    	confirmations := 0
	    	if value, ok := tnx["confirmations"]; ok {
	    		confirmations, _ = strconv.Atoi(value.(string))
	    	}

	    	trans := &Transaction {
	    		action,
	    		conf.Get("etherscan.io", "ICO_ADDRESS"),
	    		time_stamp,
	    		tnx["hash"].(string),
	    		blockNumber,
	    		tnx["from"].(string),
	    		tnx["to"].(string),
	    		tnx["value"].(string),
	    		confirmations,
	    		tnx["input"].(string),
	    	}
	    	results = append(results, trans)
	    }

		return results, nil
	}

}

