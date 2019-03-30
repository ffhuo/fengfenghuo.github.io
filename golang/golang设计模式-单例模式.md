# golang设计模式-单例模式

单例模式，其核心结构中只包含一个被称为单例的特殊类。通过单例模式可以保证系统中一个类只有一个实力且该实例易于外界访问，从而方便对实例个数的控制并节约系统资源

## 1.懒汉模式

最大缺点是非线程安全的

```go
type singleton struct {}

var instance *singleton

func GetInstance() *singleton {
    if instance == nil {
        instance = &singleton{}
    }
    return instance
}
```

然而并发时并不能保证实例唯一，因此给单例加锁

## 2. 带锁的单例模式

```go
type singleton struct {}

var instance *singleton
var mu sync.Mutex

func GetInstance() *singleton {
    mu.Lock()
    defer mu.Unlock()
    
    if instance == nil {
        instance = &singleton{}
    }
    return instance
}
```

这里使用GO的sync.Mutex，其工作模型类似Linux内核的futex对象，初始化时填入的0值将mutex设定在未锁定状态，同时保证时间开销最小，这一特性允许mutex作为其他对象的子对象使用

## 3. 双重锁

加了锁的单例虽然解决了并发问题，然而每次调用都会加锁，性能不高，使用双重锁，只在创建对象时加锁以提高效率

```go
type singleton struct {}

var instance *singleton
var mu sync.Mutex

func GetInstance() *singleton {
    if instance == nil {
        mu.Lock()
    	defer mu.Unlock()
        if instance == nil {
         	instance = &singleton{}   
        }
    }
    return instance
}
```

## 4. 更好的方式sync.Once

sync.Once可以控制函数只调用一次，不能多次重复调用

```go
type singleton struct {}

var instance *singleton
var once sync.Once

func GetInstance() *singleton {
    once.Do(func(){
        instance = &singleton{}
    })
    return instance
}
```

