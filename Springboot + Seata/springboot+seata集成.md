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

## 概念及参考博客
> https://blog.csdn.net/qq_41910252/article/details/122517092 

## 官网
* https://seata.io/zh-cn/docs/dev/mode/at-mode.html

## 安装
* 使用的版本以1.3.0为例
* 下载地址：https://github.com/seata/seata/releases/tag/v1.3.0
* 新建数据库：seata-server
* 数据库sql在github中/script/server/db下，此处直接给出地址：https://github.com/seata/seata/tree/v1.3.0/script/server/db
* 修改/config/file.conf,主要修改store.mode和db相关的内容，内容如下
    ~~~json

    ## transaction log store, only used in seata-server
    store {
    ## store mode: file、db、redis
    mode = "db"

    ## file store property
    file {
        ## store location dir
        dir = "sessionStore"
        # branch session size , if exceeded first try compress lockkey, still exceeded throws exceptions
        maxBranchSessionSize = 16384
        # globe session size , if exceeded throws exceptions
        maxGlobalSessionSize = 512
        # file buffer size , if exceeded allocate new buffer
        fileWriteBufferCacheSize = 16384
        # when recover batch read size
        sessionReloadReadSize = 100
        # async, sync
        flushDiskMode = async
    }

    ## database store property
    db {
        ## the implement of javax.sql.DataSource, such as DruidDataSource(druid)/BasicDataSource(dbcp)/HikariDataSource(hikari) etc.
        datasource = "druid"
        ## mysql/oracle/postgresql/h2/oceanbase etc.
        dbType = "mysql"
        driverClassName = "com.mysql.jdbc.Driver"
        url = "jdbc:mysql://127.0.0.1:3306/seata-server"
        user = "root"
        password = "root"
        minConn = 5
        maxConn = 30
        globalTable = "global_table"
        branchTable = "branch_table"
        lockTable = "lock_table"
        queryLimit = 100
        maxWait = 5000
    }

    ## redis store property
    redis {
        host = "127.0.0.1"
        port = "6379"
        password = ""
        database = "0"
        minConn = 1
        maxConn = 10
        queryLimit = 100
    }

    }
    ~~~
* 修改registry.conf,由于测试使用的是nacos,所以需要修改registry.type与 config.type 及 nacos相关的配置，<hl>注意，修改的地方有两处，一个是registry下的，另一个是config下的</hl>
    ~~~json
    registry {
    # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
    type = "nacos"

    nacos {
        application = "seata-server"
        serverAddr = "127.0.0.1:8848"
        group = "SEATA_GROUP"
        namespace = ""
        cluster = "default"
        username = "nacos"
        password = "nacos"
    }
    eureka {
        serviceUrl = "http://localhost:8761/eureka"
        application = "default"
        weight = "1"
    }
    redis {
        serverAddr = "localhost:6379"
        db = 0
        password = ""
        cluster = "default"
        timeout = 0
    }
    zk {
        cluster = "default"
        serverAddr = "127.0.0.1:2181"
        sessionTimeout = 6000
        connectTimeout = 2000
        username = ""
        password = ""
    }
    consul {
        cluster = "default"
        serverAddr = "127.0.0.1:8500"
    }
    etcd3 {
        cluster = "default"
        serverAddr = "http://localhost:2379"
    }
    sofa {
        serverAddr = "127.0.0.1:9603"
        application = "default"
        region = "DEFAULT_ZONE"
        datacenter = "DefaultDataCenter"
        cluster = "default"
        group = "SEATA_GROUP"
        addressWaitTime = "3000"
    }
    file {
        name = "file.conf"
    }
    }

    config {
    # file、nacos 、apollo、zk、consul、etcd3
    type = "nacos"

    nacos {
        serverAddr = "127.0.0.1:8848"
        namespace = ""
        group = "SEATA_GROUP"
        username = "nacos"
        password = "nacos"
    }
    consul {
        serverAddr = "127.0.0.1:8500"
    }
    apollo {
        appId = "seata-server"
        apolloMeta = "http://192.168.1.204:8801"
        namespace = "application"
    }
    zk {
        serverAddr = "127.0.0.1:2181"
        sessionTimeout = 6000
        connectTimeout = 2000
        username = ""
        password = ""
    }
    etcd3 {
        serverAddr = "http://localhost:2379"
    }
    file {
        name = "file.conf"
    }
    }

    ~~~
* 同样的，下载资源文件：https://github.com/seata/seata/releases/tag/v1.3.0，最底下的Source code (zip)
* 进入script\config-center，修改config.txt，如下只列出需要修改的几个属性
~~~
store.mode=db

store.db.dbType=mysql
store.db.driverClassName=com.mysql.jdbc.Driver
store.db.url=jdbc:mysql://127.0.0.1:3306/seata-server?useUnicode=true
store.db.user=root
store.db.password=root
~~~