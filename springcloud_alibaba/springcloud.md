<head>
  <style>
    .c{
      font-size: 12px;
    }
    hl{
      background:#3E74;
      display:inline-block;
      padding:1px
    }
  </style>
</head>

<font class= 'c'>

#### 前置环境
1. Node.js安装
2. 需要注册小程序服务，进入到微信平台https://mp.weixin.qq.com/wxamp/thirdtools/extend?token=674389291&lang=zh_CN，此时可以登录，用的是小号的微信，注册的邮箱是552427758@qq.com，密码：1e2ghj89,进入到开发管理->开发设置中，将APPID复制到前端项目的porject.config.json对应的appid属性上
3. 下载小程序开发工具
4. 统计目录包含一个前端项目，需要使用node.js运行
5. 进入到项目的根目录，执行npm --registry https://registry.npm.taobao.org install
6. 安装完成后就可以运行项目了：npm run dev
7. 打开小程序工具，将项目导入到工具中边可以运行

### Spring Cloud Alibaba
##### 版本与兼容
 | springboot版本 | Spring Cloud版本 |
 | :--------------:|:----------------:|
 | 1.2.x          |Angel版本        |
 | 1.3.x         |	Brixton版本       |
 | 1.4.x stripes  |Camden版本       |
 | 1.5.x          |Dalston版本、Edgware版本|
 | 2.0.x          |Finchley版本        |
 | 2.1.x          |Greenwich版本        |
1. <hl>本示例使用的版本如下</hl>
   |springboot | spring cloid alibaba | spring cloud |
   |:--:|:--:|:--:|
   |2.2.0.RELEASE|2.2.0.RELEASE|Hoxton.SR1|

2. 项目中需要先添加依赖，注意是放在dependencyManagement标签内
    ```
    <!--    dependencyManagement标签并不会真正引入依赖-->
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.alibaba.cloud</groupId>
                <artifactId>spring-cloud-alibaba-dependencies</artifactId>
                <version>2.2.0.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Hoxton.SR1</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    </dependencyManagement>
    ```
3. 服务的注册与发现(Nacos)
    * 添加依赖
      ```
      <!--nacos依赖，不需要指定版本，因为在dependencyManagement标签中已经指定过了-->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
        </dependency>
      ``` 
    * 
### nacos
1. Nacos = Spring Cloud Eureka + Spring Cloud Config
2. 安装
   * 下载之前需要先确认对应的版本，可以在pom文件中spring-cloud-alibaba-dependencies依赖点击进入，找到<hl><nacos.client.version></hl>标签所对应的版本
   * 可以从github上下载：https://github.com/alibaba/nacos ，版本尽量对应
   * 解压文件并进入到bin目录下
   * 环境需要JDK1.8
   * 执行启动指令：`sh startup.sh -m standalone`
   * 如果是Windows系统，则执行执行cmd文件即可
   * 此时可以访问前端路径 `http://localhost:8848/nacos/#/login`
   * 默认的账号密码都是nacos

3. 注册服务到Nacos
    * 添加依赖，即Nacos的依赖，上面已经添加过了
    * 现在已经不需要添加注解了，直接配置即可
      ```yaml
        spring:
          cloud:
            nacos:
              discovery:
                #指定nacos服务的地址，不需要加入前缀http等信息
                server-addr: localhost:8848
          application:
                #服务名称需要指定，但尽量使用-，不要使用_
            name: user-center
      ``` 
    * 此时启动服务，便可以在前端的Nacos中查看到
      ![](.\nacos注册.png)
    * nocos的领域模型如下图
      ![领域模型](.\nacos领域模型.png)
      * NameSpace：命名空间，默认的NameSpace是public。主要作用还是隔离空间
      * group：分组，也比较好理解，主要作用也是隔离
      * cluster：集群。举个简单的例子：南京/北京集群，南京地区优先调用南京，北京地区优先调用北京，而只有在本地的集群都不能正常工作的时候才会去调用其他的集群
### 指定NameSpace（命名空间）和 cluster（集群）
* 需要在nacos的前端页面->命名空间菜单下->新建命名空间
* 创建完成以后将会生成一个命名空间ID
* 在yml中指定<hl>命名空间的ID，而不是命名空间的名称</hl>
  ~~~yaml
  spring:
    cloud:
      nacos:
        discovery:
          #指定nacos服务的地址，不需要加入前缀http等信息
          server-addr: localhost:8848
          #指定命名空间
          namespace: a8160e47-763a-4c0c-9ccc-20ca9026d3cf
          #指定集群名称
          cluster-name: NJ
  ~~~
* <hl>如果两个服务在不同的NameSpace下，那么是无法相互调用的</hl> 
### 元数据（MetaData）
* Nacos数据（如配置和服务）描述信息，如服务版本、权重、容灾策略、负载均衡策略、鉴权配置、各种自定义标签 (label)，从作用范围来看，分为服务级别的元信息、集群的元信息及实例的元信息。此处中间讲解<hl>实例元信息</hl>
*  元数据的写入主要有两种形式，nacos前端页面和配置文件方式
* ![前端方式](.\元数据设置.png)两个标记处分别代表服务元数据和集群元数据修改，使用json方式即可
* 配置文件方式如下
  ```yaml
  spring:
    cloud:
      nacos:
        discovery:
          #指定nacos服务的地址，不需要加入前缀http等信息
          server-addr: localhost:8848
          #指定命名空间
          namespace: a8160e47-763a-4c0c-9ccc-20ca9026d3cf
          #指定集群名称
          cluster-name: NJ
          #元数据的配置，键值对形式即可
          metadata:
            name: noname,
            age: 14
            grade: 3
  ```
### 负载均衡（Ribbon）
   * 依赖已经集成在nacos的依赖中了
   * Ribbon一般都会使用Springboot提供的RestTemplate来作为Restful调用工具，随意需要在该单例上使用@LoadBalanced注解，该示例的Bean对象放在启动类上，当然也可以单独创建一个
   ```java
    @SpringBootApplication
    @MapperScan("com.itmuch")
    public class ContentcenterApplication {

        public static void main(String[] args) {
            SpringApplication.run(ContentcenterApplication.class, args);
        }


        @Bean
        @LoadBalanced
        public RestTemplate restTemplate(){
            return new RestTemplate();
        }

    }
   ``` 
   * 此时便可以使用Ribbon+RestTemplate的形式进行调用,<hl>该方式并不推荐，使用Feign</hl>
   ~~~java
    public ShareDTO findById(Integer id) {
        //获取分享详情
        Share share = this.shareMapper.selectByPrimaryKey(id);
        //发布人id
        Integer userId = share.getUserId();
        //直接使用RestTemplate进行调用，地址使用的是在Nacos中注册的名称即可
        UserDTO userDTO = restTemplate.getForObject("http://user-center/users/{id}", UserDTO.class, userId);

        //消息装配
        ShareDTO shareDTO = new ShareDTO();
        BeanUtils.copyProperties(share, shareDTO);
        shareDTO.setWxNickname(userDTO.getWxNickname());
        return shareDTO;
    }
   ~~~ 
### Ribbon的负载均衡策略
  |策略|策略描述|
  |:-:|:-:|
  |BestAvailableRule|选择一个最小的并发请求的server|
  |AvailabilityFilteringRule|过滤掉那些因为一直连接失败的被标记为circuit tripped的后端server，并过滤掉那些高并发的的后端server（activeconnections 超过配置的阈值）|
  WeightedResponseTimeRule|根据相应时间分配一个weight，相应时间越长，weight越小，被选中的可能性越低。
  |RetryRule|对选定的负载均衡策略机上重试机制|
  RoundRobinRule|轮询方式轮询选择server|
  RandomRule|随机选择一个server|
  ZoneAvoidanceRule|复合判断server所在区域的性能和server的可用性选择server|
### Ribbon负载均衡策略的定义（配置文件方式）
* 可以使用java代码的形式，但是不大好用，可以自行百度
* 在配置文件中定义，如果A项目需要调用其他服务的接口，如B，那么则在A项目的配置文件中定义负载均衡策略
* ~~~
  #Ribbon的负载均衡策略，此处使用随机，user-center是指调用服务的名称
  user-center:
    ribbon:
      NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RandomRule
  ~~~

### Ribbon负载均衡策略的定义（全局）
* 目前已知只能通过代码方式
* 先创建一个RibbonConfiguration类，<hl>该类一定要在启动类的子包下（未测试)</hl>
  ~~~java
  package com.itmuch.contentcenter.ribbonconfiguration;

  import com.netflix.loadbalancer.IRule;
  import com.netflix.loadbalancer.RandomRule;
  import org.springframework.context.annotation.Bean;
  import org.springframework.context.annotation.Configuration;

  /**
  * @author ：liwuming
  * @date ：Created in 2021/9/14 16:27
  * @description ：
  * @modified By：
  * @version:
  */
  @Configuration
  public class RibbonConfiguration {
      @Bean
      public IRule ribbonRule() {
          return new RandomRule();
      }
  }
    ~~~
* 再创建一个全局的配置类，<hl>该类一定要在启动类的子包下（未测试)</hl>
  ~~~java
  package com.itmuch.contentcenter.configuration;

  import com.itmuch.contentcenter.ribbonconfiguration.RibbonConfiguration;
  import org.springframework.cloud.netflix.ribbon.RibbonClients;
  import org.springframework.context.annotation.Configuration;

  /**
  * @author ：liwuming
  * @date ：Created in 2021/9/14 16:22
  * @description ：ribbon负载均衡全局配置，注意该类不能和启动类放在同一个包下,RibbonConfiguration该类是自己定义的
  * @modified By：
  * @version:
  */

  @Configuration
  @RibbonClients(defaultConfiguration = RibbonConfiguration.class)
  public class UerCenterRibbonConfiguration {

  }
  ~~~
### 饥饿加载
* 当首次请求接口的时候会出现请求很慢的情况，是因为Ribbon是懒加载形式的，当第一次访问的时候才会去加载。此时可以开启饥饿加载
* 同样在A项目的配置文件中开启
  ~~~yaml
  ribbon:
    #饥饿加载
    eager-load:
      enabled: true
      #哪些服务是需要饥饿加载的，可以多个，使用逗号分隔
      clients: user-center
  ~~~ 
### Ribbon对于权重的支持
* <hl>Spring cloud Alibaba 是通过整个Ribbon的方式实现的负载均衡。所以通过Nacos设置的权重无法起到作用。</hl>
* 权重可以通过Nacos的可视化页面设置。要想支持Nacos的权重可以写一个类
  ~~~java
  package com.itmuch.contentcenter.configuration;

  import com.alibaba.cloud.nacos.NacosDiscoveryProperties;
  import com.alibaba.cloud.nacos.ribbon.NacosServer;
  import com.alibaba.nacos.api.exception.NacosException;
  import com.alibaba.nacos.api.naming.NamingService;
  import com.alibaba.nacos.api.naming.pojo.Instance;
  import com.netflix.client.config.IClientConfig;
  import com.netflix.loadbalancer.AbstractLoadBalancerRule;
  import com.netflix.loadbalancer.BaseLoadBalancer;
  import com.netflix.loadbalancer.Server;
  import lombok.extern.slf4j.Slf4j;
  import org.springframework.beans.factory.annotation.Autowired;

  /** 
  * @author ：liwuming
  * @date ：Created in 2021/9/14 17:55
  * @description ：通过该方式可以让Ribbon支持Nacos的权重
  * @modified By：
  * @version:
  */
  @Slf4j
  public class NacosWeightedRule extends AbstractLoadBalancerRule {
      @Autowired
      private NacosDiscoveryProperties nacosDiscoveryProperties;

      @Override
      public void initWithNiwsConfig(IClientConfig clientConfig) {
          // 读取配置文件，并初始化NacosWeightedRule，一般不用写
      }

      @Override
      public Server choose(Object key) {
          try {
              BaseLoadBalancer loadBalancer = (BaseLoadBalancer) this.getLoadBalancer();

              // 想要请求的微服务的名称
              String name = loadBalancer.getName();

              // 拿到服务发现的相关API
              NamingService namingService = nacosDiscoveryProperties.namingServiceInstance();

              // nacos client自动通过基于权重的负载均衡算法，给我们选择一个实例。
              Instance instance = namingService.selectOneHealthyInstance(name);

              log.info("选择的实例是：port = {}, instance = {}", instance.getPort(), instance);
              return new NacosServer(instance);
          } catch (NacosException e) {
              return null;
          }
      }
  }
  ~~~ 
* 此时就可以使用全局配置或者局部配置的方式来使用自定义的类，此处以全局配置举例：
  ~~~java
    package com.itmuch.contentcenter.ribbonconfiguration;

    import com.itmuch.contentcenter.configuration.NacosWeightedRule;
    import com.netflix.loadbalancer.IRule;
    import org.springframework.context.annotation.Bean;
    import org.springframework.context.annotation.Configuration;

    /**
    * @author ：liwuming
    * @date ：Created in 2021/9/14 16:27
    * @description ：
    * @modified By：
    * @version:
    */
    @Configuration
    public class RibbonConfiguration {
        @Bean
        public IRule ribbonRule() {
            //使用自定义的规则让Ribbon来兼容Nacos的权重
            return new NacosWeightedRule();
        }
    }
  ~~~ 
* 此时在Nacos的前端页面修改权重即可生效
### 扩展Ribbon-同一集群优先调用
* 即南京地区优先调用南京的集群，只有在南京集群都失效的情况下才调用其他的集群
* 同样的，需要自定义一个类，<hl>该类一定要放在启动类的子包下（未测试）</hl>
  ~~~java
  package com.itmuch.contentcenter.configuration;

  import com.alibaba.cloud.nacos.NacosDiscoveryProperties;
  import com.alibaba.cloud.nacos.ribbon.NacosServer;
  import com.alibaba.nacos.api.exception.NacosException;
  import com.alibaba.nacos.api.naming.NamingService;
  import com.alibaba.nacos.api.naming.pojo.Instance;
  import com.alibaba.nacos.client.naming.core.Balancer;
  import com.netflix.client.config.IClientConfig;
  import com.netflix.loadbalancer.AbstractLoadBalancerRule;
  import com.netflix.loadbalancer.BaseLoadBalancer;
  import com.netflix.loadbalancer.Server;
  import lombok.extern.slf4j.Slf4j;
  import org.springframework.beans.factory.annotation.Autowired;
  import org.springframework.util.CollectionUtils;

  import java.util.ArrayList;
  import java.util.List;
  import java.util.Objects;
  import java.util.stream.Collectors;

  /**
  * @author ：liwuming
  * @date ：Created in 2021/9/15 11:21
  * @description ：扩展Ribbon-同一集群优先调用
  * @modified By：
  * @version:
  */
  @Slf4j
  public class NacosSameClusterWeightedRule extends AbstractLoadBalancerRule {
      @Autowired
      private NacosDiscoveryProperties nacosDiscoveryProperties;

      @Override
      public void initWithNiwsConfig(IClientConfig clientConfig) {

      }

      @Override
      public Server choose(Object key) {
          try {
              // 拿到配置文件中的集群名称 BJ
              String clusterName = nacosDiscoveryProperties.getClusterName();

              BaseLoadBalancer loadBalancer = (BaseLoadBalancer) this.getLoadBalancer();
              // 想要请求的微服务的名称
              String name = loadBalancer.getName();

              // 拿到服务发现的相关API
              NamingService namingService = nacosDiscoveryProperties.namingServiceInstance();

              // 1. 找到指定服务的所有实例 A
              List<Instance> instances = namingService.selectInstances(name, true);

              // 2. 过滤出相同集群下的所有实例 B
              List<Instance> sameClusterInstances = instances.stream()
                      .filter(instance -> Objects.equals(instance.getClusterName(), clusterName))
                      .collect(Collectors.toList());

              // 3. 如果B是空，就用A
              List<Instance> instancesToBeChosen = new ArrayList<>();
              if (CollectionUtils.isEmpty(sameClusterInstances)) {
                  instancesToBeChosen = instances;
                  log.warn("发生跨集群的调用, name = {}, clusterName = {}, instances = {}",
                          name,
                          clusterName,
                          instances
                  );
              } else {
                  instancesToBeChosen = sameClusterInstances;
              }
              // 4. 基于权重的负载均衡算法，返回1个实例
              Instance instance = ExtendBalancer.getHostByRandomWeight2(instancesToBeChosen);
              log.info("选择的实例是 port = {}, instance = {}", instance.getPort(), instance);

              return new NacosServer(instance);
          } catch (NacosException e) {
              log.error("发生异常了", e);
              return null;
          }
      }
  }

  class ExtendBalancer extends Balancer {
      public static Instance getHostByRandomWeight2(List<Instance> hosts) {
          return getHostByRandomWeight(hosts);
      }
  }
  ~~~ 
* 同样的方式，指定自定义的类
  ~~~java
    package com.itmuch.contentcenter.ribbonconfiguration;

    import com.itmuch.contentcenter.configuration.NacosSameClusterWeightedRule;
    import com.netflix.loadbalancer.IRule;
    import org.springframework.context.annotation.Bean;
    import org.springframework.context.annotation.Configuration;

    /**
    * @author ：liwuming
    * @date ：Created in 2021/9/14 16:27
    * @description ：
    * @modified By：
    * @version:
    */
    @Configuration
    public class RibbonConfiguration {
        @Bean
        public IRule ribbonRule() {
            
            return new NacosSameClusterWeightedRule();
        }
    }
  ~~~
* 并且要在配置文件中指定集群的名称，cluster-name属性
  ~~~yaml
  spring:
    cloud:
      nacos:
        discovery:
          #指定nacos服务的地址，不需要加入前缀http等信息
          server-addr: localhost:8848
          cluster-name: NJ
  ~~~
* <hl>记得在被调用方的服务的配置文件中，也要加上cluster-name属性，这样如果集群名相同则会优先调用</hl>
### 扩展Ribbon-基于元数据的版本控制
* 简单来讲，多个服务的实例可以配置不同的元数据，而元数据可以理解为该实例的某些K-v参数，也就是说根据某些参数来进行优先调用，如果有该参数则优先调用，没有则使用其他元数据的实例，本质上和权重是类似的。这一块不作过多介绍，可以看下这个帖子
> https://www.cnblogs.com/xjknight/p/12349096.html

### Feign实现服务调用
* 首先需要添加Feign依赖
  ~~~xml
  <dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
  </dependency>
  ~~~
* 启动类上添加注解 @EnableFeignClients
* 定义一个接口，并且使用@FeignClient来指定服务，并指定接口的url路径
  ~~~java
    @FeignClient(name = "user-center")
    public interface UserCenterFeignClient {

        @GetMapping("/users/{id}")
        UserDTO findById(@PathVariable Integer id);

    }
  ~~~
* 此时就可以通过该接口来直接调用服务
  ~~~java
  @Service
  @RequiredArgsConstructor(onConstructor = @__(@Autowired))
  public class ShareService {

      private final ShareMapper shareMapper;
      private final RestTemplate restTemplate;
      private final UserCenterFeignClient userCenterFeignClient;

      public ShareDTO findById(Integer id) {
          //获取分享详情
          Share share = this.shareMapper.selectByPrimaryKey(id);
          //发布人id
          Integer userId = share.getUserId();
          //直接使用RestTemplate进行调用，地址使用的是在Nacos中注册的名称即可
          UserDTO userDTO = userCenterFeignClient.findById(userId);

          //消息装配
          ShareDTO shareDTO = new ShareDTO();
          BeanUtils.copyProperties(share, shareDTO);
          shareDTO.setWxNickname(userDTO.getWxNickname());
          return shareDTO;
      }
  }
  ~~~ 

### Feign的日志输出（细粒度）
* feign自定义的四种日志级别
  |级别|打印内容|
  |:-:|:-:|
  |NONE|不记录日志 (默认)|
  |BASIC|只记录请求方法和URL以及响应状态代码和执行时间|
  |HEADERS|记录请求和应答的头的基本信息|
  |FULL|记录请求和响应的头信息，正文和元数据|
* 使用java代码设置日志级别
  * 先定义一个配置类，用于指定日志级别,<hl>注意不要添加@Configuration注解</hl>
    ~~~java
    import feign.Logger;
    import org.springframework.context.annotation.Bean;

    /**
    * @author ：liwuming
    * @date ：Created in 2021/9/15 17:04
    * @description ：Feign之日级别配置
    * @modified By：
    * @version:
    */
    public class UserCenterFeignConfiguration {

        @Bean
        public Logger.Level level() {
            return Logger.Level.FULL;
        }
    }
    ~~~   
  * 在自定义声明的Feign服务接口上指定该配置类
    ~~~java
      @FeignClient(name = "user-center", configuration = UserCenterFeignConfiguration.class)
      public interface UserCenterFeignClient {

          @GetMapping("/users/{id}")
          UserDTO findById(@PathVariable Integer id);
      }
    ~~~ 
  * 最后还需要在配置文件中将该接口的日志级别调整为debug
    ~~~yaml
    logging:
      level:
        com.itmuch.contentcenter.feignclient.UserCenterFeignClient: debug
    ~~~
* 使用配置文件方式
  * 直接在配置文件中添加
    ~~~yaml
    logging:
      level:
        com.itmuch.contentcenter.feignclient.UserCenterFeignClient: debug
    feign:
      client:
        config:
          # 调用的服务名称
          user-center:
            loggerLevel: full
    ~~~ 
### Feign的日志输出（全局）
* 代码方式
  * 在启动类的@EnableFeignClients注解之中设置defaultConfiguration属性
    ~~~java 
    @SpringBootApplication
    @MapperScan("com.itmuch")
    @EnableFeignClients(defaultConfiguration = GlobalFeignConfiguration.class)
    public class ContentcenterApplication {

        public static void main(String[] args) {
            SpringApplication.run(ContentcenterApplication.class, args);
        }


        @Bean
        @LoadBalanced
        public RestTemplate restTemplate(){
            return new RestTemplate();
        }

    }
    ~~~ 
  * <hl>代码中的GlobalFeignConfiguration类就是细粒度配置方式中的UserCenterFeignConfiguration，此处改了个名称</hl>
* 配置方式
  * 与上面细粒度配置基本一样，唯一的区别是将服务的名称设置为default
    ~~~yaml
    feign:
      client:
        config:
          default:
            loggerLevel: full
    ~~~ 