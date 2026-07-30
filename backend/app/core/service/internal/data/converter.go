package data

import (
	"github.com/jinzhu/copier"
	"github.com/tx7do/go-utils/trans"
)

// float64StringConverters 桥接 ent 实体的 *float64 金额字段与 proto 的 *string 金额字段。
//
// 后端 repo 的读路径（Get/List/Create/Update 回显等）走 mapper.ToDTO，底层 jinzhu/copier
// 按字段名自动拷贝；对名字相同但类型不同的字段，仅当注册了对应 (SrcType,DstType) 的
// TypeConverter 时才调用 Fn 转换，否则跳过该字段。各 repo 的 init() 此前只注册了时间相关
// converter，导致 account/balance_flow/budget 的金额字段被跳过，proto 端为零值（空 string），
// 前端显示为 0。
//
// 此 converter pair 复用 util.go 中的 FloatToStr/StrToFloat，与写路径 strPtrToFloatPtr 的
// 转换语义保持一致（金额统一以 2 位小数字符串表示）。nil 安全：任一端为 nil 时返回 (nil,nil)。
var float64StringConverters = []copier.TypeConverter{
	{
		SrcType: trans.Float64(0),
		DstType: trans.String(""),
		Fn: func(src any) (any, error) {
			f, ok := src.(*float64)
			if !ok || f == nil {
				return nil, nil
			}
			return trans.String(FloatToStr(*f)), nil
		},
	},
	{
		SrcType: trans.String(""),
		DstType: trans.Float64(0),
		Fn: func(src any) (any, error) {
			s, ok := src.(*string)
			if !ok || s == nil {
				return nil, nil
			}
			return trans.Float64(StrToFloat(*s)), nil
		},
	},
}
