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

[TOC]

## 概念及参考博客
> https://blog.csdn.net/qq_41910252/article/details/122517092 

## 官网
* https://seata.io/zh-cn/docs/dev/mode/at-mode.html

## 安装和服务端启动
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
* 如上是最简单的配置，接下来通过指令的形式来导入修改的配置文件到nacos
* 进入到seata-1.3.0\script\config-center\nacos这个文件夹，由于nacos等都在本地环境上，直接双击nacos-config.sh即可。成功完成以后打开nacos，可以在配置列表中看到一大堆的配置
* 如果nacos等环境不在本机上，就不能直接运行指令了，需要指定一些环境参数，如：
    ~~~shell
    sh ${SEATAPATH}/script/config-center/nacos/nacos-config.sh -h localhost -p 8848 -g SEATA_GROUP -t 029072a9-5a32-4756-94f8-705956db764c
    ~~~
* 参数介绍：
  * -h: host，默认值localhost
  * -p: port，默认值8848
  * -g:  配置分组，默认值为"SEATA_GROUP"
  * -t: 租户信息，对应Nacos的命名空间ID，默认值为空
* 都配置完成以后就可以启动seata-server了，最简单的启动方式即双击/bin/seata-server.bat即可
* 如果想要指定一些参数的话也可以通过指令，如：
    ~~~shell
    seata-server.sh -h 127.0.0.1 -p 8091 -m db -n 1 -e test
    ~~~
* 参数介绍：
  * -h：指定注册到注册中心的ip
  * -p：指定server启动的端口号
  * -m：事务日志存储方式，支持file、db、redis，默认file，Seata-Server 1.3及以上版本支持redis
  * -n：用于指定seata-server节点ID，如1,2,3，... 默认为1
  * -e：指定seata-server运行环境，如:dev,test等，服务启动时会使用registry-dev.conf这样的配置
* 如上都是单机部署的情况下，如果想要集群部署，那么直接在启动的时候指定不同的端口和节点ID即可
    ~~~shell
    seata-server.sh  -p 8091 -n 1
    seata-server.sh  -p 8092 -n 2
    seata-server.sh  -p 8093 -n 3
    ~~~
* 启动完成以后就可以在Nacos的服务列表中能查看到该服务了


## Springboot 集成Seata
* 此处新建两个项目，项目还是最简单的Springboot+mybatis,此处就不再赘述了。当然也要新建两个数据库，此处就用最简单的seata1和seata2库
* 在两个数据库中都需要添加一张undo_log表
    ~~~sql
    -- 注意此处0.3.0+ 增加唯一索引 ux_undo_log
    CREATE TABLE `undo_log` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `branch_id` bigint(20) NOT NULL,
    `xid` varchar(100) NOT NULL,
    `context` varchar(128) NOT NULL,
    `rollback_info` longblob NOT NULL,
    `log_status` int(11) NOT NULL,
    `log_created` datetime NOT NULL,
    `log_modified` datetime NOT NULL,
    `ext` varchar(100) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `ux_undo_log` (`xid`,`branch_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
    ~~~
* 添加依赖，关于Spring和Cloud的版本，可以参照下面的版本，这个是比较标准的
    ~~~xml
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
        <modelVersion>4.0.0</modelVersion>
        <groupId>com.noname</groupId>
        <artifactId>seata</artifactId>
        <version>0.0.1-SNAPSHOT</version>
        <name>seata</name>
        <description>Demo project for Spring Boot</description>

        <properties>
            <java.version>1.8</java.version>
            <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
            <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
            <spring-boot.version>2.4.2</spring-boot.version>
            <spring-cloud.version>2020.0.1</spring-cloud.version>
            <aliababa.version>2021.1</aliababa.version>
            <feign.version>2.2.5.RELEASE</feign.version>
            <mybatis-plus-version>3.2.0</mybatis-plus-version>
        </properties>

        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter</artifactId>
            </dependency>

            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-test</artifactId>
                <scope>test</scope>
                <exclusions>
                    <exclusion>
                        <groupId>org.junit.vintage</groupId>
                        <artifactId>junit-vintage-engine</artifactId>
                    </exclusion>
                </exclusions>
            </dependency>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-jdbc</artifactId>
            </dependency>
            <dependency>
                <groupId>mysql</groupId>
                <artifactId>mysql-connector-java</artifactId>
                <scope>runtime</scope>
            </dependency>
            <dependency>
                <groupId>com.baomidou</groupId>
                <artifactId>mybatis-plus-boot-starter</artifactId>
                <version>${mybatis-plus-version}</version>
            </dependency>
            <dependency>
                <groupId>com.baomidou</groupId>
                <artifactId>mybatis-plus-generator</artifactId>
                <version>${mybatis-plus-version}</version>
            </dependency>
            <dependency>
                <groupId>org.apache.velocity</groupId>
                <artifactId>velocity-engine-core</artifactId>
                <version>2.0</version>
            </dependency>
            <dependency>
                <groupId>org.apache.commons</groupId>
                <artifactId>commons-lang3</artifactId>
                <version>3.10</version>
            </dependency>
            <dependency>
                <groupId>com.alibaba.cloud</groupId>
                <artifactId>spring-cloud-starter-alibaba-seata</artifactId>
            </dependency>
            <!--        服务注册/发现-->
            <dependency>
                <groupId>com.alibaba.cloud</groupId>
                <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
            </dependency>
            <!--        配置中心来做配置管理-->
            <dependency>
                <groupId>com.alibaba.cloud</groupId>
                <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
            </dependency>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
            </dependency>
        </dependencies>

        <dependencyManagement>
            <dependencies>
                <dependency>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-dependencies</artifactId>
                    <version>${spring-boot.version}</version>
                    <type>pom</type>
                    <scope>import</scope>
                </dependency>
                <dependency>
                    <groupId>org.springframework.cloud</groupId>
                    <artifactId>spring-cloud-dependencies</artifactId>
                    <version>${spring-cloud.version}</version>
                    <type>pom</type>
                    <scope>import</scope>
                </dependency>
                <!-- spring cloud alibaba 依赖 -->
                <dependency>
                    <groupId>com.alibaba.cloud</groupId>
                    <artifactId>spring-cloud-alibaba-dependencies</artifactId>
                    <version>${aliababa.version}</version>
                    <type>pom</type>
                    <scope>import</scope>
                </dependency>
            </dependencies>
        </dependencyManagement>

        <build>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <version>3.8.1</version>
                    <configuration>
                        <source>1.8</source>
                        <target>1.8</target>
                        <encoding>UTF-8</encoding>
                    </configuration>
                </plugin>
                <plugin>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-maven-plugin</artifactId>
                    <version>2.3.7.RELEASE</version>
                    <configuration>
                        <mainClass>com.noname.seata.SeataApplication</mainClass>
                    </configuration>
                    <executions>
                        <execution>
                            <id>repackage</id>
                            <goals>
                                <goal>repackage</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>
            </plugins>
        </build>

    </project>
    ~~~
* 添加配置文件，由于两个项目的配置文件基本一样，所以只给出一个例子,核心的配置文件如下：
    ~~~yaml
    #seata的核心配置
    seata:
        service:
            grouplist:
            #seata的服务地址端口
            seata-server: localhost:8091
        #注册到注册中心的信息
        registry:
            type: nacos
            nacos:
            application: seata-server
            serverAddr: localhost:8848
            group: SEATA_GROUP
            cluster: default
        #      namespace: 69aee9e4-5654-4f6b-87f6-47c88b7fdb28
        #配置中心的信息
        config:
            type: nacos
            nacos:
            serverAddr: localhost:8848
            group: SEATA_GROUP
        #      namespace: 69aee9e4-5654-4f6b-87f6-47c88b7fdb28
    ~~~
* 还需要配置一个tx-service-group属性，这个属性也非常重要，在下面讲解
    ~~~yaml
    spring:
        cloud:
            alibaba:
                seata:
                    #非常关键，必须与config.txt中的service.vgroupMapping.XXXX保持一致
                    tx-service-group: my_test_tx_group
    ~~~
* 完整的yaml配置文件如下，两个服务都需要配置seata的内容：
- ~~~yaml
  server:
    port: 1000
  spring:
    application:
      name: seata
    datasource:
      driver-class-name: com.mysql.cj.jdbc.Driver
      url: jdbc:mysql://localhost:3306/seata1?useUnicode=true&characterEncoding=UTF-8&useSSL=false&&serverTimezone=UTC
      username: root
      password: root
      #时间处理
      jackson:
        date-format: yyyy-MM-dd HH:mm:ss
        time-zone: GMT+8
        serialization:
          write-dates-as-timestamps: false
    #Nacos配置和Seata配置
    cloud:
      nacos:
        discovery:
          server-addr: 127.0.0.1:8848
      alibaba:
        seata:
          #非常关键，必须与config.txt中的service.vgroupMapping.XXXX保持一致
          tx-service-group: my_test_tx_group
  mybatis-plus:
    configuration:
      map-underscore-to-camel-case: true
      auto-mapping-behavior: full
      log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
    mapper-locations: classpath*:mapper/**/*Mapper.xml
    global-config:
      # 逻辑删除配置
      db-config:
        # 删除前
        logic-not-delete-value: 1
        # 删除后
        logic-delete-value: 0
  #seata的核心配置
  seata:
    service:
      grouplist:
        #seata的服务地址端口
        seata-server: localhost:8091
    #注册到注册中心的信息
    registry:
      type: nacos
      nacos:
        application: seata-server
        serverAddr: localhost:8848
        group: SEATA_GROUP
        cluster: default
    #      namespace: 69aee9e4-5654-4f6b-87f6-47c88b7fdb28
    #配置中心的信息
    config:
      type: nacos
      nacos:
        serverAddr: localhost:8848
        group: SEATA_GROUP
  #      namespace: 69aee9e4-5654-4f6b-87f6-47c88b7fdb28
  ~~~

* tx-service-group该属性是在\script\config-center\config.txt文件中默认配置的，有一个默认的属性service.vgroupMapping.my_test_tx_group=default，当然如果想要修改的话也是可以的，比如在yaml文件中想命名为noname,那么就需要修改\script\config-center\config.txt中service.vgroupMapping.noname=default即可。当然修改完需要重新导入配置并重启
* 完成上述配置以后，做一个简单的演示，在seata2项目中写一个Controller，来让seata1项目通过feign的形式调用来测试
    ~~~java
    @RestController
    public class DemoController {

        @Resource
        private Demo2Mapper demo2Mapper;

        @GetMapping("/test")
        public void test() {
            Demo2 demo1 = new Demo2();
            demo1.setId(2);
            demo1.setNum(2);
            demo2Mapper.insert(demo1);
        }
    }
    ~~~
* 由于Seata1项目需要Feign调用Seata2项目的接口，所以需要添加依赖并在启动类上开启@EnableFeignClients
    ~~~xml
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-starter-openfeign</artifactId>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-starter-loadbalancer</artifactId>
            </dependency>
    ~~~
* 定义一个Feign的调用接口
    ~~~java
    @FeignClient(value = "seata2")
    public interface Seata2Feign {

        @GetMapping("/test")
        void test();
    }
    ~~~
* 定义一个测试用的Controller,核心注解：@GlobalTransactional
    ~~~java
    @RestController
    public class DemoController {

        @Resource
        private Demo1Mapper demo1Mapper;
        @Resource
        private Seata2Feign seata2Feign;

        @GetMapping("/test")
        @GlobalTransactional
        public String test() {
            Demo1 demo1 = new Demo1();
            demo1.setId(1);
            demo1.setNum(1);
            demo1Mapper.insert(demo1);

            //feign调用seata2的服务
            seata2Feign.test();

            return "success";
        }
    }
    ~~~
* 此时启动两边的服务，就可以测试了，正常运行的话会打印出类似于如下的信息
    ~~~log
    2022-06-22 09:35:37.097  INFO 11672 --- [nio-1000-exec-2] i.seata.tm.api.DefaultGlobalTransaction  : Begin new global transaction [192.168.1.236:8091:282807394203779072]
    Creating a new SqlSession
    SqlSession [org.apache.ibatis.session.defaults.DefaultSqlSession@80a1120] was not registered for synchronization because synchronization is not active
    JDBC Connection [io.seata.rm.datasource.ConnectionProxy@6cdee51] will not be managed by Spring
    ==>  Preparing: INSERT INTO demo1 ( id, num ) VALUES ( ?, ? ) 
    ==> Parameters: 1(Integer), 1(Integer)
    <==    Updates: 1
    Closing non transactional SqlSession [org.apache.ibatis.session.defaults.DefaultSqlSession@80a1120]
    2022-06-22 09:35:37.437  INFO 11672 --- [nio-1000-exec-2] i.seata.tm.api.DefaultGlobalTransaction  : [192.168.1.236:8091:282807394203779072] commit status: Committed
    2022-06-22 09:35:37.521  INFO 11672 --- [h_RMROLE_1_1_24] i.s.c.r.p.c.RmBranchCommitProcessor      : rm client handle branch commit process:xid=192.168.1.236:8091:282807394203779072,branchId=282807394304442369,branchType=AT,resourceId=jdbc:mysql://localhost:3306/seata1,applicationData=null
    2022-06-22 09:35:37.524  INFO 11672 --- [h_RMROLE_1_1_24] io.seata.rm.AbstractRMHandler            : Branch committing: 192.168.1.236:8091:282807394203779072 282807394304442369 jdbc:mysql://localhost:3306/seata1 null
    2022-06-22 09:35:37.527  INFO 11672 --- [h_RMROLE_1_1_24] io.seata.rm.AbstractRMHandler            : Branch commit result: PhaseTwo_Committed
    ~~~
* 日志的核心信息也就是xid 和 global transaction，这一句表示最终都提交了：Branch commit result: PhaseTwo_Committed，很关键
* 测试一下seata1正常插入，seata2插入失败后 seata1是否会回滚，此处seata2使用主键冲突的异常方式，测试的打印日志如下：
    ~~~log
    2022-06-22 09:42:52.734  INFO 11672 --- [nio-1000-exec-7] i.seata.tm.api.DefaultGlobalTransaction  : Begin new global transaction [192.168.1.236:8091:282809221397790720]
    Creating a new SqlSession
    SqlSession [org.apache.ibatis.session.defaults.DefaultSqlSession@4bf6fb06] was not registered for synchronization because synchronization is not active
    JDBC Connection [io.seata.rm.datasource.ConnectionProxy@45311c08] will not be managed by Spring
    ==>  Preparing: INSERT INTO demo1 ( id, num ) VALUES ( ?, ? ) 
    ==> Parameters: 1(Integer), 1(Integer)
    <==    Updates: 1
    Closing non transactional SqlSession [org.apache.ibatis.session.defaults.DefaultSqlSession@4bf6fb06]
    2022-06-22 09:42:52.766  INFO 11672 --- [h_RMROLE_1_3_24] i.s.c.r.p.c.RmBranchRollbackProcessor    : rm handle branch rollback process:xid=192.168.1.236:8091:282809221397790720,branchId=282809221498454017,branchType=AT,resourceId=jdbc:mysql://localhost:3306/seata1,applicationData=null
    2022-06-22 09:42:52.766  INFO 11672 --- [h_RMROLE_1_3_24] io.seata.rm.AbstractRMHandler            : Branch Rollbacking: 192.168.1.236:8091:282809221397790720 282809221498454017 jdbc:mysql://localhost:3306/seata1
    2022-06-22 09:42:52.769  INFO 11672 --- [h_RMROLE_1_3_24] i.s.r.d.undo.AbstractUndoLogManager      : xid 192.168.1.236:8091:282809221397790720 branch 282809221498454017, undo_log deleted with GlobalFinished
    2022-06-22 09:42:52.769  INFO 11672 --- [h_RMROLE_1_3_24] io.seata.rm.AbstractRMHandler            : Branch Rollbacked result: PhaseTwo_Rollbacked
    2022-06-22 09:42:52.775  INFO 11672 --- [nio-1000-exec-7] i.seata.tm.api.DefaultGlobalTransaction  : [192.168.1.236:8091:282809221397790720] rollback status: Rollbacked
    ~~~
* 其他的都不用看，最核心的 Branch Rollbacked result: PhaseTwo_Rollbacked，表示回滚，再次检查数据库发现两张表的数据确实没有插入，验证成功