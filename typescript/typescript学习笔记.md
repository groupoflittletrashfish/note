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
* 对象数组
    ~~~ts
    //对象数组，但是这种方式不能重复利用对象，所以可以使用类型别名
    const c: { name: string, age: number }[] = [
        {name: 'noname', age: 11},
        {name: 'binbin', age: 12}
    ]

    //对象别名，然后就可以直接使用
    type dataType = { name: string, age: number }
    const d: dataType[] = [
        {name: 'noname', age: 11},
        {name: 'binbin', age: 12}
    ]
    ~~~ 

### 元组
* 元组可以理解为加强版的数组，但实际上很少会使用到，它可以限定每个元素的类型
    ~~~ts
    //这是一个数组
    const a: (string | number)[] = ['1', 2]

    //这是一个元组,它可以限定每个元素的类型
    const b: [string, string, number] = ['1', '2', 3]
    //这是一个元组数组
    const c: [string, string, number][] = [
        ['1', '2', 3],
        ['4', '5', 6],
        ['7', '8', 9]
    ]
    ~~~

### 接口
* 接口的作用更贴近于java面向对象的思想。主要是参数类型的重复使用
    ~~~ts
    //此处有两个方法，a和b，他们的参数类型其实是一样的，不用接口的时候实现就是最单纯的写法
    const a = (name: string, age: number, bust: number) => {
        age < 24 && bust > 90 && console.log('面试通过')
        age > 24 || bust < 90 && console.log('淘汰')
    }

    const b = (name: string, age: number, bust: number) => {
        console.log(name)
        console.log(age)
        console.log(bust)
    }

    //--------------------使用接口的方式----------------------//
    interface param {
        name: string;
        age: number;
        bust: number;
    }

    const c = (data: param) => {
        data.age < 24 && data.bust > 90 && console.log('面试通过')
        data.age > 24 || data.bust < 90 && console.log('淘汰')
    }

    const d = (data: param) => {
        console.log(data.name)
        console.log(data.age)
        console.log(data.bust)
    }

    const girl: param = {
        name: 'noname',
        age: 18,
        bust: 100
    }

    c(girl)
    d(girl)
    ~~~
* 接口还支持动态属性，也可以定义函数
    ~~~ts
    interface param {
        name: string;
        age: number;
        bust: number;
        waistline?: number;

        // 属性的Key可以是任意string类型，值是any,即任意类型。propname并不是固定的，也可以写成a,b,c等任意变量名
        [propname: string]: any;

        //申明一个方法，该方法必须存在，且返回值一定是string类型
        say(): string;
    }

    const d = (data: param) => {
        console.log(data.name)
        console.log(data.age)
        console.log(data.bust)
        data.waistline && console.log(data.waistline)
        data.money && console.log(`存款有${data.money}`)
        console.log(data.say())
    }

    const girl: param = {
        name: 'noname',
        age: 18,
        bust: 100,
        money: 10,
        say() {
            return "hello world"
        }
    }

    d(girl)
    ~~~
* 接口之间的继承，就和java相同，也能扩展接口本身的函数变量等信息
    ~~~ts
    interface param {
        name: string;
        age: number;
        bust: number;
        waistline?: number;

        // 属性的Key可以是任意string类型，值是any,即任意类型。propname并不是固定的，也可以写成a,b,c等任意变量名
        [propname: string]: any;

        //申明一个方法，该方法必须存在，且返回值一定是string类型
        say(): string;
    }


    interface teacher extends param {
        teach(): void
    }

    const d = (data: teacher) => {
        console.log(data.name)
        console.log(data.age)
        console.log(data.bust)
        data.waistline && console.log(data.waistline)
        data.money && console.log(`存款有${data.money}`)
        console.log(data.say())
        data.teach()
    }

    const girl: teacher = {
        name: 'noname',
        age: 18,
        bust: 100,
        money: 10,
        say() {
            return "hello world"
        },
        teach() {
            console.log("接口的继承就如java一样")
        }
    }

    d(girl)
    ~~~

### 类
* 基本与java相同，一个最简单的类和类的继承如下
    ~~~ts
    class Girl {
        dialog = '吃饭睡觉'

        say() {
            console.log(this.dialog)
        }
    }

    class Lady extends Girl {
        play() {
            //支持super关键字
            super.say()
            console.log("玩")
        }

        //支持方法的重写
        say() {
            console.log("重写")
        }
    }

    const instance = new Girl()
    instance.say()
    const ladyInstance = new Lady();
    ladyInstance.play()
    ~~~

### 类的访问类型
* 同样的与java一样，有public(默认),protected,private，实际效果也和java的一样，不过做多阐述

### 类的构造函数
* 和java一样，只是有简便写法。但似乎构造器只允许存在一个
    ~~~ts
    class Person {
        name: string

        constructor(name: string) {
            this.name = name
        }
    }

    //简便写法，与上面的构造是一样的
    class PersonB {
        constructor(public name: string) {
        }
    }

    //如果是继承关系的话，必须得有super(),即使父类没有构造器也必须得有
    class Teacher extends Person {
        constructor(name: string) {
            super(name);
        }
    }


    console.log(new Person('noname').name)
    console.log(new PersonB('binbin').name)
    ~~~

### 类的get/set
* 理解上和java是相同的，但是使用的语法上差异很大，注意点较多，如下
    ~~~ts
    class Person {
        // 规范上讲私有属性使用_开头
        constructor(private _age: number) {
        }

        // get
        get age() {
            return this._age
        }

        //set
        set age(age: number) {
            this._age = age
        }
    }

    //注意，获取是age，而不是age()
    console.log(new Person(11).age)

    const p = new Person(20)
    //注意，get和set其实不属于函数，这个是set的用法
    p.age = 22
    console.log(p.age)
    ~~~

### 类的静态函数
* 和java一样
    ~~~ts
    class Person{
        static eat(){
            console.log('静态函数，同java')
        }
    }

    Person.eat()
    ~~~

### 类的只读属性
* 类似于final
    ~~~ts
    class Person {
        //被readonly修饰了的属性，无法被二次修改
        public readonly _name: string

        constructor(name: string) {
            this._name = name
        }
    }

    const p = new Person('noname')
    console.log(p)
    ~~~

### 抽象类
* 同java
    ~~~ts
    abstract class Girl {
        //指定一下返回类型，不然有可能报错
        abstract play(): any
    }

    class Teacher extends Girl {
        play() {
            console.log('玩')
        }
    }

    new Teacher().play()
    ~~~

### typescript配置文件
* 可以通过指令：tsc -init 来初始化一个配置文件 tsconfig.json
* 几个和编译相关的属性,正常情况下编译使用 tsc 指令，如果要编辑个别文件，可以修改以下值
    ~~~json
    // 需要编译的文件，支持通配符，如：/**/*.ts
    "include": ["demo.ts","demo2.ts"],
    // 排除编译的文件
    "exclude": [],
    // 基本和include相同，但是只能是文件且如果有异常就会停止编译
    "files": [],
    ~~~
* 另一个重要的配置就是compilerOptions，也就是编译的配置项，里面有很多子项，如 strict，默认是true,表示严格模式，同时开启 alwaysStrict, noImplicitAny, noImplicitThis 和 strictNullChecks (2.3 以上)，这些配置都是会在编译时候需要检查的，而IDE也会有相应的错误提示。稍作了解即可
* 指定源文件的目录，"rootDir": "./src",一般指的是ts的路径
* 指定编译后的文件的存放路径，"outDir": "./build"
* 其他配置文件的配置可参看
* > https://www.cnblogs.com/cczlovexw/p/11527708.html


### 联合类型和类型守护
* 是指在方法的形参类型不明确包含多种类型
    ~~~ts
    interface Girl {
        age: number
        name: string
        play: boolean

        seeTv(): void
    }

    interface Man {
        age: number
        name: string
        play: boolean

        game(): void
    }

    //联合类型,person即可能是Girl也可能是Man
    function doThing(person: Girl | Man) {
        //类型断言,如果对象的play是true,则断言为Girl,调用play函数
        if (person.play) {
            (person as Girl).seeTv()
        } else {
            (person as Man).game()
        }
    }

    const a: Man = {
        name: 'noname',
        age: 11,
        play: false,
        game: () => {
            console.log('打游戏')
        }
    }

    const b: Girl = {
        name: '1',
        age: 2,
        play: true,
        seeTv() {
            console.log('看电视')
        }
    }

    doThing(a)
    console.log('-----------------------------')
    doThing(b)
    ~~~
* 如上是通过属性去判断的，也可以通过是否存在 XX 函数来确定对象，局部代码
    ~~~ts
    //联合类型,person即可能是Girl也可能是Man
    function doThing(person: Girl | Man) {
        //类型断言,如果对象存在seeTV函数，则断言为Girl,调用play函数
        if ('seeTv' in person) {
            (person as Girl).seeTv()
        } else {
            (person as Man).game()
        }
    }
    ~~~
* 还有一种比较常用的判断方式，instanceof，作用和java中的相同，但限定类
    ~~~ts
    class Girl {
        play: boolean | undefined

        seeTv() {
            console.log('看电视')
        };
    }

    class Man {
        play: boolean | undefined

        game() {
            console.log('打游戏')
        }
    }

    //联合类型,person即可能是Girl也可能是Man
    function doThing(person: Girl | Man) {
        //类型断言，instanceof 和java的作用是一样的，也是判断类的类型，则断言为Girl,调用play函数
        if (person instanceof Girl) {
            (person as Girl).seeTv()
        } else {
            (person as Man).game()
        }
    }

    const a = new Man()

    const b = new Girl()

    doThing(a)
    console.log('-----------------------------')
    doThing(b)

    ~~~

### 枚举
* 比较简单，直接上图
    ~~~ts
    enum STATUS {
        STATUS_0,
        STATUS_1,
        STATUS_2,
        STATUS_
    }


    console.log(`根据索引查询枚举:${STATUS[0]}`)
    console.log(`根据值查询索引:${STATUS.STATUS_0}`)
    ~~~

### 泛型
* 还是和java类似，如下最简单的方法使用泛型
    ~~~ts
    function a<T>(p: T) {
        console.log(p)
    }

    a('牛逼')
    ~~~
* 泛型约束，基本和java相同
    ~~~ts
    //还是比较简单的，泛型的类型约束，泛型必须是string或者number
    class Girl<T extends string | number> {
        constructor(private things: T[]) {
        }
    }

    const a = new Girl(['1','2','3',4,5,6,7])
    ~~~

### 命名空间
* 命名空间一个最明确的目的就是解决重名问题。也可以解决全局变量污染
* 在没用命名空间前，如下两个文件代码:demo.html   demo.ts
    ~~~html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Title</title>
        <!--    这个地方是引用的自定义的js,该js又是通过ts编译过来的-->
        <script src="./demo.js"></script>
    </head>
    <body>
    <script>
        //自定义ts中的对象
        new Header();
        new Content()
    </script>
    </body>
    </html>
    ~~~
    ~~~ts
    class Header {
        constructor() {
            const elem = document.createElement('div')
            elem.innerText = 'This is Header'
            document.body.appendChild(elem)
        }
    }

    class Content {
        constructor() {
            const elem = document.createElement('div')
            elem.innerText = 'This is Content'
            document.body.appendChild(elem)
        }
    }
    ~~~
* 访问该html文件后是可以正常展示的，但类似的写法会有一个全局变量污染的问题，为了解决这个问题，引入了命名空间，修改后如下
    ~~~html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Title</title>
        <!--    这个地方是引用的自定义的js,该js又是通过ts编译过来的-->
        <script src="./demo.js"></script>
    </head>
    <body>
    <script>
        //Home暴露了Index这个类，所以可以访问到，反之则不行
        new Home.Index()
    </script>
    </body>
    </html>
    ~~~
    ~~~ts
    namespace Home {
        //命名空间内的变量无法被直接访问到，除非是通过export暴露出来
        class Header {
            constructor() {
                const elem = document.createElement('div')
                elem.innerText = 'This is Header'
                document.body.appendChild(elem)
            }
        }

        //命名空间内的变量无法被直接访问到，除非是通过export暴露出来
        class Content {
            constructor() {
                const elem = document.createElement('div')
                elem.innerText = 'This is Content'
                document.body.appendChild(elem)
            }
        }

        //暴露上面的两个类
        export class Index {
            constructor() {
                new Header()
                new Content()
            }
        }
    }
    ~~~
* <hl>另外命名空间是可以嵌套的，只要了解即可</hl>

## Vue整合typescript
### Vue脚手架安装
* 此处忽略
### Vue+typescript项目的创建
* 使用脚手架创建项目，一般选择默认即可
* 项目创建完以后，进入该项目，使用 add @vue/typescript ，全部选择Y即可
* 与传统的Vue项目还是有一些不同的，稍微有一些小的变动
    ~~~ts
    <template>
    <div>这是一个标题</div>
    </template>

    <script lang="ts">
    import {Component, Vue} from "vue-property-decorator";

    // @Component 这个注解表明这是一个组件
    @Component
    export default class MenuBar extends Vue{

    }

    </script>

    <style scoped>

    </style>
    ~~~
    ~~~ts
    <template>
    <div id="app">
        <MenuBar/>
    </div>
    </template>
    <!--此处要添加lang=ts，指定是ts语法-->
    <script lang="ts">
    import {Component, Vue} from 'vue-property-decorator';
    import MenuBar from "@/components/MenuBar.vue";

    @Component({
    components: {
        //引入的组件
        MenuBar
    },
    })
    export default class App extends Vue {
    }
    </script>
    ~~~