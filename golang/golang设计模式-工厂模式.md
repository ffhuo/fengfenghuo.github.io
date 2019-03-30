# golang设计模式-工厂模式

## 1. 简单工厂

简单工厂模式的工厂类一般使用静态方法，通过接受的参数不同返回不同对象实例。

```go
type FruitFactory interface {
    MakeFruit()
}

type AppleFactory struct{}
func (apple *AppleFactory)MakeFruit(){
    
}

type OrangeFactory struct{}
func (orange *OrangeFactory)MakeFruit() {
    
}

type Factory struct{}

func NewFruitFactory() *Factory {
    return &Factory{}
}

func (factory *Factory)MakeFruit(name string) FruitFactory {
    switch name {
    case "apple":
        return &AppleFactory{}
    case "orange":
        return &OrangeFactory{}
    default:
        return nil
    }
} 

func main() {
    factory := NewFruitFactory().MakeFruit()
}


```

## 2. 工厂方法

```go

```

