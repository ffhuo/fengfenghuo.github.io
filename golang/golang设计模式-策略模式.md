# golang设计模式-策略模式

策略模式定义了一系列算法，将每一个算法封装起来，并让它们可以互相替换。策略模式让算法独立于使用它的客户而变化

容易变动的代码从主逻辑中分离，通过接口规范它们的形式，主逻辑中将任务委托给策略，既减少了对主逻辑代码修改的可能性，也增加了可拓展性。对拓展开放，对修改关闭

```go
type Strategier interface {
    Compute(num1, num2 int) int
}

type Division struct{}
func (p Division) Computer(num1, num2 int) int {
    defer func(){
        if f:= recover(); f != nil {
            fmt.Println(f)
            return
        }  
    }()
    
    if num2 == 0 {
        panic("num2 must not be 0!")
    }
    
    return num1 / num2
}

func NewStrategy(t string)(res Strategire) {
    switch t{
        case "-":
        //
        case "+":
        //
        case "*":
        //
        case "/":
        res = Division{}
        default:
        //
    }
    return
}

type Computer struct {
    num1, num2 int
    strate Strategier
}

func (p *Computer)SetStrategy(strate Strategier) {
    p.strate = starte
}

func (p Computer)Do() int {
    defer func() {
        if f := recover(); f != nil {
            fmt.Printfln(f)
        }
    }()
    
    if p.strate == nil {
        panic("Strategier is null")
    }
    
    return p.strate.Computer(p.num1, p.num2)
}

func main() {
    com := Computer{num1: 10, num2: 5}
    starte := NewStartegy("/")
    com.SetStrategy(strate)
    fmt.Println(com.Do())
}
```

策略接口Strategier，实现的策略之一是Division

工厂方法NewStrategy，根据不同的type返回不同的类型

主流程Computer，包括：

- 成员：操作数num1，num2
- 成员：策略接口
- 方法：设置策略的SetStrategy

Do中委托给了Strategier



