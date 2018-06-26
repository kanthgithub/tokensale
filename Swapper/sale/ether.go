// Background data structures defined for ETH
//

package eth

import "strconv"
import "strings"

//代表一笔以太坊的转账
type Transaction struct {
	Action string
	Address string
    TimeStamp string
    Hash string
    BlockNumber int
    From string  
    To string  
    Value string
    Confirmations int
    Input string
}

const (
	TxnTypeSend = "send"
	TxnTypeReceive = "receive"
	TxnTypeCreate = "create"
	TxnTypeCall = "call"
	TxnTypeUnknown = "unknown"
)


// 换算成浮点型
func (tnx *Transaction) GetEther() float64 {
	value := tnx.Value
	if value == "" || value == "0" || len(value) <= 15 {
		return 0.0
	}
	value = value[:len(value) - 15]
	fval, _ := strconv.ParseFloat(value, 64)
	return fval / 1000.0
}

func (tnx *Transaction) GetTxnType() string {
	if tnx.Value == "0" {
		if tnx.To == "" {
			return TxnTypeCreate
		}
		if len(tnx.Input) > 2 {
			return TxnTypeCall
		}
		return TxnTypeUnknown
	} else {
		if strings.EqualFold(tnx.Address, tnx.To)  {
			return TxnTypeReceive
		}
		if strings.EqualFold(tnx.Address, tnx.From)  {
			return TxnTypeSend
		}
		return TxnTypeUnknown
	}
	
}
