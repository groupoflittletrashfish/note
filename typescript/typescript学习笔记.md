<head>
  <style>
    .c{
      font-size: 14px;
    }
    hl{
      background:#3E74;
      display:inline-block;
      padding:1px
    }
  </style>
</head>

<font class= 'c'>

[toc]

### 简介
* TypeScript是微软2012年推出的一种编程语言，属于 JavaScript 的超集，可以编译为 JavaScript 执行。它最大特点是强大的类型系统和对ES6的支持，TypeScript托管于GitHub上面。

* TypeScript代码，通过编译可以转换为纯正的 JavaScript代码，且编译出来的 JavaScript代码能够运行在任何浏览器上。TypeScript 的编译工具也可以运行在任何服务器和任何系统上。

### 安装
* 安装是通过node.js来执行的，所以需要先安装好
* 下载官网最新版：npm install typescript -g
* 安装完成后可以通过 tsc -v来确定是否安装成功
* 由于typescript 类似于java的编译，所以还需要安装ts-node
* 通过node.js可以安装：npm install -g ts-node

### Hello World
* 新建一个ts文件，如Demo.ts
    ~~~ts
    function test(){
        let web :string = "Hello World"
        console.log(web)
    }


    test()
    ~~~
* 由于已经安装了ts-node,那么则可以通过ts-node Demo.ts 直接来执行

### 静态类型
* 即对变量指定固定的类型，与java相同，指定类型的变量必须匹配类型，否则报错
    ~~~ts
    // 自定义类型,可以理解为java的pojo
    interface man {
        name: string,
        age: number
    }

    //实例化对象,指定类型必须是自定义的man类型
    let xiaoming: man = {
        name: '小明',
        age: 11
    }
    console.log(xiaoming)
    ~~~
* 通过ts-node Demo.ts 可以执行输出 { name: '小明', age: 11 }

### 基础静态类型和对象静态类型
* 如下展示一些变量的创建，都有注释
    ~~~ts
    //对象类型,直接可以申明自定义类型并赋值
    const a: {
        name: string,
        age: number
    } = {
        name: 'noname',
        age: 11
    }
    console.log(a)


    //数组类型
    const b: string[] = ['a', 'b', 'c']
    console.log(b)


    //以类的形式,就如java一样
    class C {}
    let cInstance :C = new C()
    console.log(cInstance)

    //函数类型,d:()=>string 表示这是一个函数,并且返回值必须是string类型
    const d:()=>string = ()=>{return 'd'}
    console.log(d())
    ~~~

### 类型注解
* 所谓类型注解，就是人为为一个变量指定类型。其实上面的例子都已经在使用了
    ~~~ts
    let a: number
    a = 100
    console.log(a)
    ~~~

### 类型推断
* 所谓类型推断就是TypeScript可以通过变量值倒推变量类型。因此在绝大部分情况下，我们是不需要去写类型注解的
* 当然在一些情况下是无法进行类型推断的，比如下面代码
    ~~~ts
    function getSum(a, b) {
        return a + b;
    }
    const num = getSum(1, 2);
    console.log(num)
    ~~~
* 上面的代码在执行的时候将会抛出异常，因为无法进行类型推断，形参a和b无法确定具体的类型。那么只需要指定其类型即可，更改如下
    ~~~ts
    function getSum(a: number, b: number) {
        return a + b;
    }

    const num = getSum(1, 2);
    console.log(num)
    ~~~

### 函数的参数与返回类型
* 上面的例子已经可以指明函数的参数类型了，接下来需要指定函数的返回类型
    ~~~ts
    function getSum(a: number, b: number) : number {
        return a + b
    }
    ~~~
* 如果没有返回类型，则可以通过:void注明
    ~~~ts
    function fun(a: number, b: number): void {
        console.log(a + b)
    }
    ~~~
* 形参类型,即对象如果要指定类型,则可以采用{a,b}:{a:X,b:X}的形式
    ~~~ts
    function getNum({one, two}: { one: number, two: number }) {
        return one + two
    }

    getNum({one: 1, two: 2})
    ~~~

### 数组
* 常规的数据结构之前已经介绍过了,但是有一些比较特殊的数据类型
    ~~~ts
    // undefined类型,元素则必须是undefined 
    const a: undefined[] = [undefined]
    ~~~
* 混合类型的数组
    ~~~ts
    //默认的情况下,类型推断是可以推断出数组中的元素类型的,这两句的意思是相同的
    const a = [1, '2', 3]
    const b: (number | string)[] = [1, '2', 3]
    ~~~