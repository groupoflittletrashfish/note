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

## 概念
* 概念部分来不及笔记了，直接查看：https://www.bilibili.com/video/BV1VE411h7aL?p=3&spm_id_from=pageDriver

## RBAC
### 概念
* 基础概念网上翻

### 基于角色的访问控制
* ![](RBAC基于角色的访问控制.jpg)
* 实用伪代码来实现如下
    ~~~java
    if(主体 hasRoles("总经理ID")){
        查询工资
    }
    ~~~
* 这个模型的最大问题，如果此时主管也允许可以查询工资了，那么就需要更改代码

### 基于资源的访问控制
* ![](RBAC基于资源的访问控制.jpg)
* 使用伪代码来实现如下
~~~java
if(主体 hasPermission("查询工资权限标识")){
        查询工资
    }
~~~

## Spring Security
### 搭建一个最简单的Spring Security项目
* 添加依赖
    ~~~xml
        <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-security</artifactId>
            </dependency>
            <dependency>
                <groupId>org.springframework.security</groupId>
                <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    ~~~
* 新建一个controller
    ~~~java
    @Controller
    public class LoginController {

        /**
        * 登录
        * @return
        */
        @RequestMapping("/login")
        public String login() {
            System.out.println("执行登录方法");
            return "redirect:main.html";
        }
    }
    ~~~
* 在resource/static下编写login.html
    ~~~html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <title>Title</title>
    </head>
    <body>
    <form action="/login" method="post">
        用户名:<input type="text" name="username"/><br/>
        密码:<input type="password" name="password"/> <br/>
        <input type="submit" value="登录"/>
    </form>
    </body>
    </html>
    ~~~
* 再添加一个main.html
    ~~~html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <title>Title</title>
    </head>
    <body>
        登录成功
    </body>
    </html>
    ~~~
* 此时启动服务，将会先请求Security的账号密码验证，默认用户名：user,密码在启动时打印出来

### 自定义登录逻辑
* 首先需要进行配置
    ~~~java
    @Configuration
    public class SecurityConfig {

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }

    }
    ~~~
* 继承UserDetailsService接口来实现自定义的登录逻辑
    ~~~java
    @Service
    public class UserDetailsServiceImpl implements UserDetailsService {

        @Resource
        private PasswordEncoder pw;


        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            //1.查询数据库判断用户名是否存在，如果不存在则会抛出异常UsernameNotFoundException,当然这边的话是写死了，正常情况的话是要从数据库查询的
            if (!"admin".equals(username)) {
                throw new UsernameNotFoundException("用户名不存在！");
            }

            //2.把查询出来的密码（这个密码是数据库查询出来的，一定是加密过的）进行解析，或者是直接把密码放入构造方法。这里的password变量应该是从数据库查询出来的。然后user.getPassword()
            //来获取，这样的话就不需要pw.encode（XXX）去加密了，因为此处的话是写死的值
            String password = pw.encode("123");
            //最后面一段是指用户的权限，暂时可以先不看，多个权限逗号分割，另外此处的User是Security包下的
            return new User(username, password, AuthorityUtils.commaSeparatedStringToAuthorityList("admin,normal"));
        }
    }
    ~~~
* 那么此时重启再次访问，默认的账号密码就是admin/123了

### 自定义登录页面
* Security的页面肯定是不符合日常的开发的，所以需要指定自定义的登录页面
* 首先需要继承WebSecurityConfigurerAdapter该类，并且重写 void configure(HttpSecurity http) 函数
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    //一定要指定登录的接口路径，也就是login.html中登录按钮触发的表单提交地址。这才才能走到service中的UserDetailsServiceImpl实现中
                    .loginProcessingUrl("/login")
                    //自定义登录页面，斜杠不能少
                    .loginPage("/login.html")
                    //登录（认证）成功以后跳转的页面，此处是POST请求，所以不能直接填写html页面，需要在controller层做一次重定向
                    .successForwardUrl("/toMain")
                    //登录失败后跳转的请求，同上。但是需要注意的是一定要在下面的拦截器里面放行，不然的话error.html又将会拦截并跳回到登录页面
                    .failureForwardUrl("/toError");
            //这段代码可以理解为一个拦截器
            http.authorizeRequests()
                    //这一句表示Login.html将会放行，并不会拦截触发重定向
                    .antMatchers("/login.html").permitAll()
                    //同上，error.html也一定要被放行，不然又将跳回到登录页面，很关键
                    .antMatchers("/error.html").permitAll()
                    //anyRequest().authenticated()表示任何请求都必须被认证（即登录）
                    .anyRequest().authenticated();
            //暂时理解为关闭了一个防火墙，如果没有这句，那么无法走到service中的UserDetailsServiceImpl实现中
            http.csrf().disable();
        }
    }
    ~~~
* 其实之前写的LoginController中的login函数没什么用了，因为在配置中已经指定了登录的页面了。如上配置中有个/toMain的地址，表示登录成功后跳转的路径，不要忘记添加一个RequestMapping。同样的还有/toError
    ~~~java
    @Controller
    public class LoginController {

        /**
        * 登录
        * @return
        */
        @RequestMapping("/toMain")
        public String toMain() {
            return "redirect:main.html";
        }


        @RequestMapping("/toError")
        public String toError() {
            return "redirect:error.html";
        }
    }
    ~~~
* error.html虽然简单，但也贴出来，如下
    ~~~html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <title>Title</title>
    </head>
    <body>
    操作失败，请重新登录 <a href="login.html">跳转</a>
    </body>
    </html>
    ~~~

### 自定义账户密码的参数名
* 默认情况下，form表单中的用户名和密码必须是username和password，如下
    ~~~html
    <form action="/login" method="post">
        用户名:<input type="text" name="username"/><br/>
        密码:<input type="password" name="password"/> <br/>
        <input type="submit" value="登录"/>
    </form>
    ~~~
* 如果想要更改，也可以在之前的那个配置类中添加.usernameParameter()和.passwordParameter()
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    //  ※※※※※※※※※自定义用户和密码的名称，一定要和form表单的名字匹配※※※※※※※※※※※※※
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    //一定要指定登录的接口路径，也就是login.html中登录按钮触发的表单提交地址。这才才能走到service中的UserDetailsServiceImpl实现中
                    .loginProcessingUrl("/login")
                    //自定义登录页面，斜杠不能少
                    .loginPage("/login.html")
                    //登录（认证）成功以后跳转的页面，此处是POST请求，所以不能直接填写html页面，需要在controller层做一次重定向
                    .successForwardUrl("/toMain")
                    //登录失败后跳转的请求，同上。但是需要注意的是一定要在下面的拦截器里面放行，不然的话error.html又将会拦截并跳回到登录页面
                    .failureForwardUrl("/toError");
            //这段代码可以理解为一个拦截器
            http.authorizeRequests()
                    //这一句表示Login.html将会放行，并不会拦截触发重定向
                    .antMatchers("/login.html").permitAll()
                    //同上，error.html也一定要被放行，不然又将跳回到登录页面，很关键
                    .antMatchers("/error.html").permitAll()
                    //anyRequest().authenticated()表示任何请求都必须被认证（即登录）
                    .anyRequest().authenticated();
            //暂时理解为关闭了一个防火墙，如果没有这句，那么无法走到service中的UserDetailsServiceImpl实现中
            http.csrf().disable();
        }
    }
    ~~~
* 相应的也要修改form表单中的参数
    ~~~html
    <form action="/login" method="post">
        用户名:<input type="text" name="username123"/><br/>
        密码:<input type="password" name="password123"/> <br/>
        <input type="submit" value="登录"/>
    </form>
    ~~~

### 自定义登录成功处理器
* 很多时候前后端是分离的情况下，无法通过.successForwardUrl("/toMain")这种方式去进行跳转，.successForwardUrl("http://www.baidu.com")也是不允许的，此时就需要重新自定义一个处理器
* 我们需要自己实现一个类来继承自AuthenticationSuccessHandler接口
    ~~~java
    public class MyAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

        private String url;

        public MyAuthenticationSuccessHandler(String url) {
            this.url = url;
        }

        @Override
        public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
            //登录人的信息
            User user = (User) authentication.getPrincipal();
            //账号
            System.out.println(user.getUsername());
            //注意：密码一定是null,主要是为了安全起见
            System.out.println(user.getPassword());
            //账号所拥有的权限，在认证通过时候已经加入了
            System.out.println(user.getAuthorities());
            response.sendRedirect(url);
        }
    }
    ~~~
* 然后就可以直接使用这个类了，由于上述的代码比较多，只截取一部分,只要更改successForwardUrl变成successHandler即可。注意这两个函数无法同时生效
    ~~~java
        http.formLogin()
                    //自定义用户和密码的名称，一定要和form表单的名字匹配
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    //一定要指定登录的接口路径，也就是login.html中登录按钮触发的表单提交地址。这才才能走到service中的UserDetailsServiceImpl实现中
                    .loginProcessingUrl("/login")
                    //自定义登录页面，斜杠不能少
                    .loginPage("/login.html")
                    //※※※※※※※※※※  使用自定义的handler来进行转发  ※※※※※※※※※※※
                    .successHandler(new MyAuthenticationSuccessHandler("http://www.baidu.com"))
                    //登录失败后跳转的请求，同上。但是需要注意的是一定要在下面的拦截器里面放行，不然的话error.html又将会拦截并跳回到登录页面
                    .failureForwardUrl("/toError");
    ~~~

### 自定义登录失败处理器
* 和登录成功处理器是一样的，自定义一个类继承自AuthenticationFailureHandler接口
    ~~~java
    public class MyAuthenticationFailtureHandler implements AuthenticationFailureHandler {

        private String url;

        public MyAuthenticationFailtureHandler(String url) {
            this.url = url;
        }

        @Override
        public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception) throws IOException, ServletException {
            response.sendRedirect(url);
        }
    }

    ~~~
* 在配置中使用自定义的类，将原来的.failureForwardUrl()替换成.failureHandler()函数
    ~~~java
        http.formLogin()
                    //自定义用户和密码的名称，一定要和form表单的名字匹配
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    //一定要指定登录的接口路径，也就是login.html中登录按钮触发的表单提交地址。这才才能走到service中的UserDetailsServiceImpl实现中
                    .loginProcessingUrl("/login")
                    //自定义登录页面，斜杠不能少
                    .loginPage("/login.html")
                    //使用自定义的handler来进行转发
                    .successHandler(new MyAuthenticationSuccessHandler("http://www.baidu.com"))
                    //※※※※※※※※※    使用自定义的登录失败处理器进行跳转    ※※※※※※※※※※
                    .failureHandler(new MyAuthenticationFailtureHandler("/error.html"));
    ~~~

### antMatchers详解
* 这个就是一个匹配，Security允许传多个值，一般的使用即是
    ~~~java
    //表示static下的/js    /images    /css下的所有资源被放行
    .antMatchers("/js/**","/images/**","/css/**").permitAll()
    ~~~

    ~~~java
    //表示static下的所有目录下.png结尾的资源，*：表示0个或多个字符
    .antMatchers("/**/*.png").permitAll()
    ~~~

### regexMatchers
* 就是正则匹配，没什么太多解释的
    ~~~java
    .regexMatchers(".+[.png]").permitAll()
    ~~~

### Spring Security内置访问控制
|访问控制|描述|
|:-:|:-:|
|permitAll|所匹配的 URL 任何人都允许访问|
|authenticated|所匹配的 URL 都需要被认证才能访问|
|anonymous|可以匿名访问匹配的 URL。和 permitAll()效果类 似，只是设置为 anonymous()的 url 会执行 filter 链|
|denyAll|匹配的 URL 都不允许被访问|
|rememberMe|被“remember me”的用户允许访问|
|fullyAuthenticated|如果用户不是被 remember me 的,才可以访问|


### 授权控制
* 如果想要指定进入某些页面必须要有XXX权限，则可以在配置中对它进行限定,使用 hasAuthority()
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    .loginProcessingUrl("/login")
                    .loginPage("/login.html")
                    .successForwardUrl("/toMain")
                    .failureHandler(new MyAuthenticationFailtureHandler("/error.html"));
            http.authorizeRequests()
                    //※※※※※※※※※    必须拥有manager权限才能访问main1.html，权限是可以给多个，只要满足一个即可，使用hasAnyAuthority  ※※※※※※※※※
                    .antMatchers("/main1.html").hasAuthority("manager")
                    .antMatchers("/login.html").permitAll()
                    .antMatchers("/error.html").permitAll()
                    .regexMatchers(".+[.png]").permitAll()
                    .anyRequest().authenticated();
            //暂时理解为关闭了一个防火墙，如果没有这句，那么无法走到service中的UserDetailsServiceImpl实现中
            http.csrf().disable();
        }
    }
    ~~~
* 由于在自定义的登录逻辑中指定了权限是admin和normal，所以即使登录成功，但是访问main1.html也会被拦截。此处的main1.html就不再贴出代码了，就是一句话。如下代码是之前自定义的登录逻辑，可以参照一下
    ~~~java
    @Service
    public class UserDetailsServiceImpl implements UserDetailsService {

        @Resource
        private PasswordEncoder pw;


        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            //1.查询数据库判断用户名是否存在，如果不存在则会抛出异常UsernameNotFoundException,当然这边的话是写死了，正常情况的话是要从数据库查询的
            if (!"admin".equals(username)) {
                throw new UsernameNotFoundException("用户名不存在！");
            }

            //2.把查询出来的密码（这个密码是数据库查询出来的，一定是加密过的）进行解析，或者是直接把密码放入构造方法。这里的password变量应该是从数据库查询出来的。然后user.getPassword()
            //来获取，这样的话就不需要pw.encode（XXX）去加密了，因为此处的话是写死的值
            String password = pw.encode("123");
            //最后面一段是指用户的权限，暂时可以先不看，多个权限逗号分割，另外此处的User是Security包下的
            return new User(username, password, AuthorityUtils.commaSeparatedStringToAuthorityList("admin,normal"));
        }
    }
    ~~~

### 角色控制
* 使用上基本和权限控制一样，使用的hasRole()
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    .loginProcessingUrl("/login")
                    .loginPage("/login.html")
                    .successForwardUrl("/toMain")
                    .failureHandler(new MyAuthenticationFailtureHandler("/error.html"));
            http.authorizeRequests()
                    //※※※※※※※※※    必须是abc的角色才有访问权限  ※※※※※※※※※
                    .antMatchers("/main1.html").hasRole("abc")
                    .antMatchers("/login.html").permitAll()
                    .antMatchers("/error.html").permitAll()
                    .regexMatchers(".+[.png]").permitAll()
                    .anyRequest().authenticated();
            //暂时理解为关闭了一个防火墙，如果没有这句，那么无法走到service中的UserDetailsServiceImpl实现中
            http.csrf().disable();
        }
    }
    ~~~
* 同样的ROLE的角色定义也同样是在登录的时候，也是和权限一样的，不同的是角色必须是ROLE_开头
    ~~~java
    @Service
    public class UserDetailsServiceImpl implements UserDetailsService {

        @Resource
        private PasswordEncoder pw;


        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            if (!"admin".equals(username)) {
                throw new UsernameNotFoundException("用户名不存在！");
            }

            String password = pw.encode("123");
            //※※※※※※※※※      与权限相同，只是角色要用ROLE_开头，ROLE_abc，即表示角色abc,注意逗号的大小写      ※※※※※※※※※※※
            return new User(username, password, AuthorityUtils.commaSeparatedStringToAuthorityList("admin,normal,ROLE_abc"));
        }
    }
    ~~~
* 需要注意的一点是虽然角色定义的名称是ROLE_abc，但在使用hasRole的时候是hasRole("abc")

### IP判断
* 由于比较简单，直接上代码,hasIpAddress()
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    .loginProcessingUrl("/login")
                    .loginPage("/login.html")
                    .successForwardUrl("/toMain")
                    .failureHandler(new MyAuthenticationFailtureHandler("/error.html"));
            http.authorizeRequests()
                    //※※※※※※※※※    远端地址判断，如果不满足条件将不被授权，如果是本地，浏览器输入localhost，此处写的是127.0.0.1将不被授权     ※※※※※※※※※※※※※※※※※
                    .antMatchers("/main1.html").hasIpAddress("127.0.0.1")
                    .antMatchers("/login.html").permitAll()
                    .antMatchers("/error.html").permitAll()
                    .regexMatchers(".+[.png]").permitAll()
                    .anyRequest().authenticated();
            //暂时理解为关闭了一个防火墙，如果没有这句，那么无法走到service中的UserDetailsServiceImpl实现中
            http.csrf().disable();
        }
    }
    ~~~

### 自定义403页面
* 想要自定义一个无权限的页面，我们需要自定义一个handler
    ~~~java
    @Component
    public class MyAcessDeniedHandler implements AccessDeniedHandler {

        @Override
        public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException, ServletException {
            //设置响应的状态码
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setHeader("Content-Type", "application-json");
            PrintWriter writer = response.getWriter();
            writer.write("{\"status\":\"error\",\"message\":\"权限不足，请联系管理员\"}");
            writer.flush();
        }
    }
    ~~~
* 并且在配置中添加自定义的handler处理:http.exceptionHandling().accessDeniedHandler(myAcessDeniedHandler);
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Resource
        private MyAcessDeniedHandler myAcessDeniedHandler;

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    .loginProcessingUrl("/login")
                    .loginPage("/login.html")
                    .successForwardUrl("/toMain")
                    .failureHandler(new MyAuthenticationFailtureHandler("/error.html"));
            http.authorizeRequests()
                    .antMatchers("/main1.html").hasIpAddress("127.0.0.1")
                    .antMatchers("/login.html").permitAll()
                    .antMatchers("/error.html").permitAll()
                    .regexMatchers(".+[.png]").permitAll()
                    .anyRequest().authenticated();
            http.csrf().disable();

            //※※※※※※※※※※    指定自定义的权限异常处理逻辑   ※※※※※※※※※※※※
            http.exceptionHandling().accessDeniedHandler(myAcessDeniedHandler);

        }
    }
    ~~~

### access
* 之前所有的权限操作，底层其实都是access来实现的，比如 permitAll() 等同于 access("permitAll()")，hasRole("abc") 等同于 access("hasRole('abc')")
* access也可以实现一些自定义的方法,下面就来实现一个必须拥有指定访问页面路径权限才能放行的自定义功能
    ~~~java
    @Service
    public class MyServiceImpl implements MyService {
        @Override
        public boolean hasPermisssion(HttpServletRequest request, Authentication authentication) {
            //获取用户对象
            Object obj = authentication.getPrincipal();
            if (obj instanceof UserDetails) {
                UserDetails userDetails = (UserDetails) obj;
                //获取用户所拥有的全部权限
                Collection<? extends GrantedAuthority> authorities = userDetails.getAuthorities();
                //检查用户是否拥有当前URI的权限
                return authorities.contains(new SimpleGrantedAuthority(request.getRequestURI()));
            }
            return false;
        }
    }
    ~~~
* 同样的在配置文件中需要声明
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Resource
        private MyAcessDeniedHandler myAcessDeniedHandler;

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    .loginProcessingUrl("/login")
                    .loginPage("/login.html")
                    .successForwardUrl("/toMain")
                    .failureHandler(new MyAuthenticationFailtureHandler("/error.html"));
            http.authorizeRequests()
                    //※※※※※※※※※   access来调用自定义的逻辑，语法就是这么操蛋   ※※※※※※※※※※※※
                    .antMatchers("/main1.html").access("@myServiceImpl.hasPermisssion(request,authentication)")
                    .antMatchers("/login.html").permitAll()
                    .antMatchers("/error.html").permitAll()
                    .regexMatchers(".+[.png]").permitAll()
                    .anyRequest().authenticated();
            http.csrf().disable();

            http.exceptionHandling().accessDeniedHandler(myAcessDeniedHandler);

        }
    }
    ~~~
* 此时访问main1.html肯定是访问不通的，因为登录时候赋予的权限肯定没有/main1.html
* 此时修改认证的逻辑，添加/main1.html就可以了
    ~~~java
    @Service
    public class UserDetailsServiceImpl implements UserDetailsService {

        @Resource
        private PasswordEncoder pw;


        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            if (!"admin".equals(username)) {
                throw new UsernameNotFoundException("用户名不存在！");
            }

            String password = pw.encode("123");
            //※※※※※※※※※   自定义的逻辑，必须得拥有对应路径的访问权限才可以，此处main1.html即是    ※※※※※※※※※※※※※※
            return new User(username, password, AuthorityUtils.commaSeparatedStringToAuthorityList("admin,normal,ROLE_abc,/main1.html"));
        }
    }
    ~~~

### 访问控制注解 Serured
* Spring Security有提供注解式的权限控制，首先需要在启动类上开启
    ~~~java
    @SpringBootApplication
    @EnableGlobalMethodSecurity(securedEnabled = true)
    public class SpringsecuritydemoApplication {

        public static void main(String[] args) {
            SpringApplication.run(SpringsecuritydemoApplication.class, args);
        }

    }
    ~~~
* 然后就可以在controller中使用 @Secured()来使用了
    ~~~java
    @Controller
    public class LoginController {

        /**
        * 登录
        * @return
        */
        @RequestMapping("/toMain")
        @Secured("ROLE_aaa")
        public String toMain() {
            return "redirect:main.html";
        }


        @RequestMapping("/toError")
        public String toError() {
            return "redirect:error.html";
        }
    }
    ~~~
* <hl>记得清除之前编写的配置类中的权限控制。另外由于登录没有设置ROLE_aaa角色，所以此时将会被限制，但是之前配置的自定义无访问权限是失效的，将会直接提示500错误页</hl>


### @PreAuthorize与@PostAuthorize
* Spring的 @PreAuthorize/@PostAuthorize 注解更适合方法级的安全,也支持Spring 表达式语言，提供了基于表达式的访问控制。一般常用的是@PreAuthorize ，它表示在类的执行之前执行授权
* 直接上代码，在启动类中需要添加 prePostEnabled = true
    ~~~java
    @SpringBootApplication
    @EnableGlobalMethodSecurity(securedEnabled = true,prePostEnabled = true)
    public class SpringsecuritydemoApplication {

        public static void main(String[] args) {
            SpringApplication.run(SpringsecuritydemoApplication.class, args);
        }

    }
    ~~~
* 在controller中直接进行限定只有abc的角色才可以授权
    ~~~java
    @Controller
    public class LoginController {

        /**
        * 登录
        * @return
        */
        @RequestMapping("/toMain")
        // PreAuthorize比较特殊，hasRole中即使填写ROLE_abc 也是可以正常执行的
        @PreAuthorize("hasRole('abc')")
        public String toMain() {
            return "redirect:main.html";
        }


        @RequestMapping("/toError")
        public String toError() {
            return "redirect:error.html";
        }
    }
    ~~~

### RememberMe
* 由于该功能是基于数据库的，所以需要引入MyBatis和jdbc的依赖
    ~~~xml
    <dependency>
        <groupId>org.mybatis.spring.boot</groupId>
        <artifactId>mybatis-spring-boot-starter</artifactId>
        <version>2.1.1</version>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>8.0.15</version>
    </dependency>
    ~~~
* 当然还有yml配置
    ~~~yaml
    server:
    port: 8081
    spring:
    datasource:
        username: root
        password: root
        url: jdbc:mysql://localhost:3306/security?useUnicode=true&characterEncoding=utf-8&useSSL=true&serverTimezone=UTC
        driver-class-name: com.mysql.jdbc.Driver
    ~~~
* 当然，不要忘记新建一个security的数据库
* 然后就是配置类了,<hl>关键的就是先告诉Security jdbc的连接，然后让其初始化一个表，然后便可以配置一些RememberMe的参数，指定自定义的认证逻辑，并且指定数据库的连接信息</hl>
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Resource
        private MyAcessDeniedHandler myAcessDeniedHandler;
        @Autowired
        @Lazy
        private UserDetailsService userDetailsService;
        @Resource
        private DataSource dataSource;

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    .loginProcessingUrl("/login")
                    .loginPage("/login.html")
                    .successForwardUrl("/toMain")
                    .failureHandler(new MyAuthenticationFailtureHandler("/error.html"));
            http.authorizeRequests()
                    .antMatchers("/login.html").permitAll()
                    .antMatchers("/error.html").permitAll()
                    .regexMatchers(".+[.png]").permitAll()
                    .anyRequest().authenticated();
            http.csrf().disable();

            http.exceptionHandling().accessDeniedHandler(myAcessDeniedHandler);

            //※※※※※※※※   记住我的代码    ※※※※※※※※
            http.rememberMe()
                    //自定义的登录（认证）逻辑，这个需要注入进来,如果没有会报错。但是会涉及到一个循环依赖的问题，所以在注入的时候要用上懒加载
                    .userDetailsService(userDetailsService)
                    //如果不指定，前端的复选框必须传递 remember-me
    //                .rememberMeParameter("remember")
                    //token的失效时间，也就是记住我能持续的时间，默认是2周
                    .tokenValiditySeconds(20)
                    //持久层对象
                    .tokenRepository(getPersistentTokenRepository());

        }


        /**
        * 这个Bean也是记住我功能的部分，初始化数据表
        * @return
        */
        @Bean
        public PersistentTokenRepository getPersistentTokenRepository() {
            JdbcTokenRepositoryImpl jdbcTokenRepository = new JdbcTokenRepositoryImpl();
            jdbcTokenRepository.setDataSource(dataSource);
            //自动创建表，第一次启动时候需要，第二次启动会报错，所以再创建完成表后需要注释掉
    //        jdbcTokenRepository.setCreateTableOnStartup(true);
            return jdbcTokenRepository;
        }
    }
    ~~~
* 当然，前端页面也是需要添加一个记住我的选择框，但是需要注意的是，name必须是remember-me
    ~~~html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <title>Title</title>
    </head>
    <body>
    <form action="/login" method="post">
        用户名:<input type="text" name="username123"/><br/>
        密码:<input type="password" name="password123"/> <br/>
        记住我:<input type="checkbox" name="remember-me" value="true"/> <br/>
        <input type="submit" value="登录"/>
    </form>
    </body>
    </html>
    ~~~
* 此时就可以验证了。第一次启动程序会在security的数据库中创建一张表。在浏览器输入admin/123后并且勾选记住我


### 整合thymeleaf
* 首选需要引入依赖
    ~~~xml
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-thymeleaf</artifactId>
            </dependency>
            <dependency>
                <groupId>org.thymeleaf.extras</groupId>
                <artifactId>thymeleaf-extras-springsecurity5</artifactId>
            </dependency>
    ~~~
* 在resource/templates下新建一个demo.html。<hl>Springboot默认的模板文件位置，也可以更改，自行百度</hl>
    ~~~html
    <!DOCTYPE html>
    <!--非常重要，这三个命名空间必须得有-->
    <html xmlns="http://www.w3.org/1999/xhtml"
        xmlns:th="http://www.thymeleaf.org"
        xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
    <head>
        <meta charset="UTF-8"/>
        <title>Title</title>
    </head>
    <body>
    <!--下面就是获取一些用户的信息-->
    登录账号：<span sec:authentication="name"></span><br/>
    登录账号：<span sec:authentication="principal.username"></span><br/>
    凭证：<span sec:authentication="credentials"></span><br/>
    权限与角色：<span sec:authentication="authorities"></span><br/>
    客户端地址：<span sec:authentication="details.remoteAddress"></span><br/>
    sessionId：<span sec:authentication="details.sessionId"></span><br/>
    </body>
    </html>
    ~~~
* 我们编写一个Controller层指向该页面,此处是指向demo.html
    ~~~java
    @Controller
    public class LoginController {

        /**
        * 登录
        *
        * @return
        */
        @RequestMapping("/toMain")
        @PreAuthorize("hasRole('abc')")
        public String toMain() {
            return "redirect:main.html";
        }


        @RequestMapping("/toError")
        public String toError() {
            return "redirect:error.html";
        }


        @RequestMapping("demo")
        public String demo() {
            return "demo";
        }
    }

    ~~~
* 此时再次登录admin/123，登录成功以后再去浏览器访问/demo路径，就可以看到用户的信息了
  
### thymeleaf 中的权限判断
* 首先更改一下demo.html
    ~~~html
    <!DOCTYPE html>
    <!--非常重要，这三个命名空间必须得有-->
    <html xmlns="http://www.w3.org/1999/xhtml"
        xmlns:th="http://www.thymeleaf.org"
        xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
    <head>
        <meta charset="UTF-8"/>
        <title>Title</title>
    </head>
    <body>
    通过权限判断
    <button sec:authorize="hasAuthority('/insert')">新增</button>
    <button sec:authorize="hasAuthority('/delete')">删除</button>
    <button sec:authorize="hasAuthority('/update')">修改</button>
    <button sec:authorize="hasAuthority('/select')">查看</button>

    <br/>

    通过角色判断
    <button sec:authorize="hasRole('abc')">新增</button>
    <button sec:authorize="hasRole('abc')">删除</button>
    <button sec:authorize="hasRole('abc')">修改</button>
    <button sec:authorize="hasRole('abc')">查看</button>
    </body>
    </html>
    ~~~
* 如上的代码即符合权限要求显示，不符合就不显示，所以我们需要更改下用户的权限信息
    ~~~java
    @Service
    public class UserDetailsServiceImpl implements UserDetailsService {

        @Resource
        private PasswordEncoder pw;


        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            if (!"admin".equals(username)) {
                throw new UsernameNotFoundException("用户名不存在！");
            }

            String password = pw.encode("123");
            //※※※※※※※※※   为用户添加两个/insert和/delete的权限    ※※※※※※※※※※※※※※
            return new User(username, password, AuthorityUtils.commaSeparatedStringToAuthorityList("admin,normal,ROLE_abc,/insert,/delete"));
        }
    }
    ~~~
* 那么此时我们启动访问，将会现实权限的新增删除，和4个角色的增删改查

### 退出登录
* 我们在demo.html中，直接使用a标签，指向/logout即可
    ~~~html
    <!DOCTYPE html>
    <!--非常重要，这三个命名空间必须得有-->
    <html xmlns="http://www.w3.org/1999/xhtml"
        xmlns:th="http://www.thymeleaf.org"
        xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
    <head>
        <meta charset="UTF-8"/>
        <title>Title</title>
    </head>
    <body>
    通过权限判断
    <button sec:authorize="hasAuthority('/insert')">新增</button>
    <button sec:authorize="hasAuthority('/delete')">删除</button>
    <button sec:authorize="hasAuthority('/update')">修改</button>
    <button sec:authorize="hasAuthority('/select')">查看</button>

    <br/>

    通过角色判断
    <button sec:authorize="hasRole('abc')">新增</button>
    <button sec:authorize="hasRole('abc')">删除</button>
    <button sec:authorize="hasRole('abc')">修改</button>
    <button sec:authorize="hasRole('abc')">查看</button>

    <!--只要一句话就可以了-->
    <a href="/logout">登出</a>
    </body>
    </html>
    ~~~
* 其实此时就可以生效了，但是在登出以后浏览器的地址后面会追加一个logout，我们也可以优化一下。同样的，也是在Security的配置中修改,配置http.logout()
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Resource
        private MyAcessDeniedHandler myAcessDeniedHandler;
        @Autowired
        @Lazy
        private UserDetailsService userDetailsService;
        @Resource
        private DataSource dataSource;

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    .loginProcessingUrl("/login")
                    .loginPage("/login.html")
                    .successForwardUrl("/toMain")
                    .failureHandler(new MyAuthenticationFailtureHandler("/error.html"));
            http.authorizeRequests()
                    .antMatchers("/login.html").permitAll()
                    .antMatchers("/error.html").permitAll()
                    .regexMatchers(".+[.png]").permitAll()
                    .anyRequest().authenticated();
            http.csrf().disable();

            http.exceptionHandling().accessDeniedHandler(myAcessDeniedHandler);

            http.rememberMe()
                    .userDetailsService(userDetailsService)
                    .tokenValiditySeconds(20)
                    .tokenRepository(getPersistentTokenRepository());

            http.logout()
                    // 登出之后跳转到指定的页面，这样的话就不会在链接后面多出一个?logout了
                    .logoutSuccessUrl("/login.html");
                    //这个可以指定登出API的路径，即前端a标签指向的地址，一般也不用更改
    //                .logoutUrl("/logout");
        }

        
        @Bean
        public PersistentTokenRepository getPersistentTokenRepository() {
            JdbcTokenRepositoryImpl jdbcTokenRepository = new JdbcTokenRepositoryImpl();
            jdbcTokenRepository.setDataSource(dataSource);
    //        jdbcTokenRepository.setCreateTableOnStartup(true);
            return jdbcTokenRepository;
        }
    }
    ~~~

### CSRF
* CSRF是指跨站请求伪造（Cross-site request forgery），是web常见的攻击之一。
从Spring Security 4.0开始，默认情况下会启用CSRF保护，以防止CSRF攻击应用程序，Spring Security CSRF会针对PATCH，POST，PUT和DELETE方法进行防护。
我这边是spring boot项目，在启用了@EnableWebSecurity注解后，csrf保护就自动生效了。
所以在默认配置下，即便已经登录了，页面中发起PATCH，POST，PUT和DELETE请求依然会被拒绝，并返回403，需要在请求接口的时候加入csrfToken才行。
* 想要解决这个问题，无非就两种
  * 关闭，但是这个当然是不安全的
  * 传递一个security生成的_csrf值
* <hl>为了展示效果，在resource/templates目录下新建一个login.html，因为要使用到thymeleaf的语法</hl>
    ~~~html
    <!DOCTYPE html>
    <!--不要遗漏这三个命名空间-->
    <html xmlns="http://www.w3.org/1999/xhtml"
        xmlns:th="http://www.thymeleaf.org"
        xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
    <head>
        <meta charset="UTF-8"/>
        <title>Title</title>
    </head>
    <body>
    <form action="/login" method="post">
        <!--    添加一个隐藏的元素，该元素就是security要验证的_csrf值,注意name必须是csrf-->
        <input type="hidden" th:value="${_csrf.token}" name="_csrf" th:if="${_csrf}">
        用户名:<input type="text" name="username123"/><br/>
        密码:<input type="password" name="password123"/> <br/>
        记住我:<input type="checkbox" name="remember-me" value="true"/> <br/>
        <input type="submit" value="登录"/>
    </form>
    </body>
    </html>
    ~~~
* 在Controller层添加一个跳转
    ~~~java
        @RequestMapping("showLogin")
        public String showLogin() {
            return "login";
        }
    ~~~
* 在Security的配置中也更改为跳转到这个新得login界面
    ~~~java
    @Configuration
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Resource
        private MyAcessDeniedHandler myAcessDeniedHandler;
        @Autowired
        @Lazy
        private UserDetailsService userDetailsService;
        @Resource
        private DataSource dataSource;

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {

            http.formLogin()
                    .usernameParameter("username123")
                    .passwordParameter("password123")
                    .loginProcessingUrl("/login")
                    // ※※※※※※※※※※※     登录的页面也需要更改成showLogin这个地址    ※※※※※※※※※※
                    .loginPage("/showLogin")
                    .successForwardUrl("/toMain")
                    .failureHandler(new MyAuthenticationFailtureHandler("/error.html"));
            http.authorizeRequests()
                    //※※※※※※※※※※※      不要忘记此处也需要放行      ※※※※※※※※※※
                    .antMatchers("/showLogin").permitAll()
                    .antMatchers("/error.html").permitAll()
                    .regexMatchers(".+[.png]").permitAll()
                    .anyRequest().authenticated();
            //※※※※※※※※   这个csrf必须去掉了    ※※※※※※※※※※※※
            //http.csrf().disable();

            http.exceptionHandling().accessDeniedHandler(myAcessDeniedHandler);

            http.rememberMe()
                    .userDetailsService(userDetailsService)
                    .tokenValiditySeconds(20)
                    .tokenRepository(getPersistentTokenRepository());

            http.logout()
                    .logoutSuccessUrl("/login.html");
        }


        @Bean
        public PersistentTokenRepository getPersistentTokenRepository() {
            JdbcTokenRepositoryImpl jdbcTokenRepository = new JdbcTokenRepositoryImpl();
            jdbcTokenRepository.setDataSource(dataSource);
    //        jdbcTokenRepository.setCreateTableOnStartup(true);
            return jdbcTokenRepository;
        }
    }
    ~~~
* 此时便可以在csrf开启的情况下正常认证了。核心的还是前端页面的一个_csrf传值


## Oauth2
### 概念
* OAuth（开放授权）是一个开放标准，允许用户授权第三方移动应用访问他们存储在另外的服务提供者上的信息，而不需要将用户名和密码提供给第三方移动应用或分享他们数据的所有内容，OAuth2.0是OAuth协议的延续版本，但不向后兼容OAuth 1.0即完全废止了OAuth1.0。
* 流程图如下
* ![](oauth2流程图.jpg)

### oauth2的四种授权
* <hl>很重要，但是东西又很多，所以直接查看博客吧,着重查看授权码模式</hl>
* > https://www.ruanyifeng.com/blog/2019/04/oauth-grant-types.html

### Spring Security Oauth2
* 这个名字一开始不是很理解，oauth2是一套标准，而Security套用了这套标准，所以本质上还是Security
* Security Oauth2的流程图如下
* ![](./SpringSecurityOauth2流程图.jpg)

### 授权模式项目基础环境说明
* 新建一个项目，共享在gitHub上:springsecurityoauth2demo
* 依赖引入,spring-cloud的版本为 Greenwich.SR2；Spring的版本为2.3.9.RELEASE，不要太高，不然启动报错
    ~~~xml
    <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>


            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-starter-oauth2</artifactId>
                <version>2.2.5.RELEASE</version>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-starter-security</artifactId>
                <version>2.2.0.RELEASE</version>
            </dependency>
    ~~~
* 新建一个pojo类，名为User,其实不建也没关系，只是稍微强化一下Security自带的User类
    ~~~java
    /**
    * @author ：liwuming
    * @date ：Created in 2022/2/18 10:20
    * @description ：自定义的User,同样继承了UserDetails，与Security提供的User一样，只是稍微强化了一下。但是默认生成的
    * 代码的几个函数返回值都是false,必须改成true,几个get函数都需要更改，还不如用他自带的，意义不大，完全跟着视频走
    * @modified By：
    * @version:
    */
    public class User implements UserDetails {

        private String username;
        private String password;
        private List<GrantedAuthority> authorityList;

        public User(String username, String password, List<GrantedAuthority> authorityList) {
            this.username = username;
            this.password = password;
            this.authorityList = authorityList;
        }

        @Override
        public Collection<? extends GrantedAuthority> getAuthorities() {
            return this.authorityList;
        }

        @Override
        public String getPassword() {
            return this.password;
        }

        @Override
        public String getUsername() {
            return this.username;
        }

        @Override
        public boolean isAccountNonExpired() {
            return true;
        }

        @Override
        public boolean isAccountNonLocked() {
            return true;
        }

        @Override
        public boolean isCredentialsNonExpired() {
            return true;
        }

        @Override
        public boolean isEnabled() {
            return true;
        }
    }
    ~~~
* 自定义认证（登录）逻辑
    ~~~java
    @Service
    public class UserService implements UserDetailsService {

        @Resource
        private PasswordEncoder passwordEncoder;

        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            String password = passwordEncoder.encode("123456");
            return new User("admin", password, AuthorityUtils.commaSeparatedStringToAuthorityList("admin"));
        }
    }
    ~~~
* Security配置类
    ~~~java
    @Configuration
    @EnableWebSecurity
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Bean
        public PasswordEncoder passwordEncoder() {
            return new BCryptPasswordEncoder();
        }

        @Override
        protected void configure(HttpSecurity http) throws Exception {
            //测试所以还是关闭了csrf
            http.csrf().disable().authorizeRequests()
                    .antMatchers("/oauth/**", "/login/**,/logout/**").permitAll()
                    .anyRequest().authenticated()
                    //and()没什么实际意义，只是一个连接符
                    .and()
                    //所有表单都放行
                    .formLogin().permitAll();

        }
    }
    ~~~
* 新建一个授权服务器的配置：<hl>所谓授权服务器即向资源服务器发起一起请求，资源服务器需要先认证，认证完成后将会返回一个授权码</hl>
~~~java
@Configuration
@EnableAuthorizationServer
public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

    @Resource
    private PasswordEncoder passwordEncoder;

    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        clients.inMemory()
                //配置Client-ID
                .withClient("admin")
                //配置Clinet-Secret
                .secret(passwordEncoder.encode("112233"))
                //配置访问Token的有效期
                .accessTokenValiditySeconds(3600)
                //配置认证成功后重定向的地址
                .redirectUris("http://www.baidu.com")
                //配置权限申请的范围
                .scopes("all")
                //篇日志grant_type,表示授权类型
                .authorizedGrantTypes("authorization_code");
    }
}
~~~
* 新建一个资源服务器的配置
    ~~~java
    @Configuration
    @EnableResourceServer
    public class ResouceServerConfig extends ResourceServerConfigurerAdapter {

        @Override
        public void configure(HttpSecurity http) throws Exception {
            http.authorizeRequests()
                    //所有请求都将做权限认证
                    .anyRequest().authenticated()
                    .and()
                    //指定路径放行
                    .requestMatchers().antMatchers("/user/**");
        }
    }
    ~~~

* 都配置完成以后，新建一个controller来测试一下
    ~~~java
    @RestController
    @RequestMapping("user)
    public class UserController {

        /**
        * 获取当前用户
        *
        * @param authentication
        * @return
        */
        @RequestMapping("/getCurrentUser")
        public Object getCurrentUser(Authentication authentication) {
            return authentication.getPrincipal();
        }
    }
    ~~~
* 在都配置完成以后就可以启动项目了
* <hl>此时我们可以访问http://localhost:8082/oauth/authorize?response_type=code&client_id=admin&redirect_url=http://www.baidu.com&scope=all</hl>
  * 这个地址是用来获取授权码的 
  * response_type 表示授权的类型,code表示是授权码
  * client_id：必须是授权服务中配置的，此处是admin
  * redirect_url：必须是授权服务中配置的
  * scope: 必须是授权服务中配置的
* <hl>此时有可能会跳转一个错误的404页面，无视即可，再次输入刚才的授权网址，将会看到一个Oauth Approval的页面，选择Approve 表示接受并点击授权，然后将会跳转到我们配置的百度页面，但是网址上会追加一个?code=XXXX,这个就是授权码。</hl>
* ![](授权页面.jpg)
* 下一步就是通过授权码来获取令牌，这个需要借助postman工具，使用POST访问 http://localhost:8082/oauth/token
* 必须先指定Authorization参数
* ![](postman指定Auth.jpg)
* 然后再指定body参数
* ![](postman指定body.jpg)
* 返回体即令牌的token
* 那么此时我们便可以正常请求我们自己的controller，依旧使用postman,发起 localhost:8082/user/getCurrentUser 请求，当然也要指定Authorization
* ![](postman访问接口指定Auth.jpg)
* 调用成功后即可返回用户的信息，以下是返回体
    ~~~json
    {
        "username": "admin",
        "password": "$2a$10$Ogs/uSYKAeSVdnga8vMNfeiVKZy4JR7CY2ldSnfLtvfgDeWw3pNhO",
        "enabled": true,
        "authorities": [
            {
                "authority": "admin"
            }
        ],
        "accountNonLocked": true,
        "credentialsNonExpired": true,
        "accountNonExpired": true
    }
    ~~~

### 密码模式
* <hl>直接在授权模式的基础上进行更改，只列出更改的部分</hl>
* 首先更改Security的配置文件
    ~~~java
    @Configuration
    @EnableWebSecurity
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        @Bean
        public PasswordEncoder passwordEncoder() {
            return new BCryptPasswordEncoder();
        }

        /**
        * ※※※※※※※※※※    密码模式下要添加这一段     ※※※※※※※※※※※
        *
        * @return
        * @throws Exception
        */
        @Bean
        @Override
        public AuthenticationManager authenticationManagerBean() throws Exception {
            return super.authenticationManagerBean();
        }

        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http.csrf().disable().authorizeRequests()
                    .antMatchers("/oauth/**", "/login/**,/logout/**").permitAll()
                    .anyRequest().authenticated()
                    .and()
                    .formLogin().permitAll();

        }
    }

    ~~~
* 更改授权服务器配置,将类型更改为密码类型
    ~~~java
    @Configuration
    @EnableAuthorizationServer
    public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

        @Resource
        private AuthenticationManager authenticationManager;
        @Resource
        private UserService userService;

        /**
        * ※※※※※※※※※    密码模式下要重写该函数   ※※※※※※※※※※※※
        *
        * @param endpoints
        * @throws Exception
        */
        @Override
        public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
            endpoints.authenticationManager(authenticationManager)
                    //指定自定义的登录逻辑
                    .userDetailsService(userService);
        }

        @Resource
        private PasswordEncoder passwordEncoder;

        @Override
        public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
            clients.inMemory()
                    .withClient("admin")
                    .secret(passwordEncoder.encode("112233"))
                    .accessTokenValiditySeconds(3600)
                    .redirectUris("http://www.baidu.com")
                    .scopes("all")
                    //※※※※※※※※※※     此处要更改为password      ※※※※※※※※※※
                    .authorizedGrantTypes("password");
        }
    }

    ~~~
* 那么我们进行测试，依旧使用postman，第一步依旧是获取令牌，其他的都一样，只是在通过http://localhost:8082/oauth/token 获取令牌时，传递的参数不一样。<hl>Authorization等信息依旧要传递。</hl>，具体的body参看截图
* ![](密码授权传参.jpg)
* 成功获取token以后即可和之前一样调用接口了


### Redis存储Token
* 引入Redis依赖
    ~~~xml
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-data-redis</artifactId>
                <version>2.5.5</version>
            </dependency>
    ~~~
* 建议配置下redis
    ~~~yaml
    spring:
    redis:
        host: localhost
    ~~~
* 对redis做以下简易的配置
    ~~~java
    @Configuration
    public class RedisConfig {

        @Resource
        private RedisConnectionFactory redisConnectionFactory;

        @Bean
        public TokenStore redisTokenStore() {
            //TokenStore和RedisTokenStore都是Security Oauth包下的，应该都是已经集成好的。将连接直接丢给这个类，它会自动将token保存到Redis中
            return new RedisTokenStore(redisConnectionFactory);
        }
    }
    ~~~
* 授权服务器的配置中需要引用一下自定义的配置类
    ~~~java
    @Configuration
    @EnableAuthorizationServer
    public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

        @Resource
        private AuthenticationManager authenticationManager;
        @Resource
        private UserService userService;
        @Autowired
        @Qualifier("redisTokenStore")
        private TokenStore tokenStore;

        /**
        * ※※※※※※※※※    密码模式下要重写该函数   ※※※※※※※※※※※※
        *
        * @param endpoints
        * @throws Exception
        */
        @Override
        public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
            endpoints.authenticationManager(authenticationManager)
                    .userDetailsService(userService)
                    //※※※※※※※※※    在密码模式中引入自定义的Bean     ※※※※※※※※※※
                    .tokenStore(tokenStore);
        }

        @Resource
        private PasswordEncoder passwordEncoder;

        @Override
        public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
            clients.inMemory()
                    .withClient("admin")
                    .secret(passwordEncoder.encode("112233"))
                    .accessTokenValiditySeconds(3600)
                    .redirectUris("http://www.baidu.com")
                    .scopes("all")
                    .authorizedGrantTypes("password");
        }
    }
    ~~~
* 重启服务我们访问授权接口后还是能正常返回token，此时查看redis中就可以查看到5个参数。由于没装可视化插件,只验证了其中一个key，key的值是access:[token],如：access:3cc78e65-8b5c-4e6f-8a1a-b11198cccb69

### JWT
#### 概念
* Json web token (JWT), 是为了在网络应用环境间传递声明而执行的一种基于JSON的开放标准（(RFC 7519).该token被设计为紧凑且安全的，特别适用于分布式站点的单点登录（SSO）场景。JWT的声明一般被用来在身份提供者和服务提供者间传递被认证的用户身份信息，以便于从资源服务器获取资源，也可以增加一些额外的其它业务逻辑所必须的声明信息，该token也可直接被用于认证，也可被加密。
* 概念性的东西直接百度吧
* > https://www.jianshu.com/p/576dbf44b2ae

#### Security+Oauth2+JWT整合
* <hl>有了JWT，其实可以不再使用redis,但是项目中其实并没有删除相关的依赖包</hl>
* 依旧使用之前的项目，只是将JWT作为token来代替之前的UUID形式的令牌
* 引入依赖
    ~~~xml
            <dependency>
                <groupId>io.jsonwebtoken</groupId>
                <artifactId>jjwt</artifactId>
                <version>0.9.0</version>
            </dependency>
    ~~~
* 新建一个配置类，JwtTokenStoreConfig来配置一些基础的内容
    ~~~java
    @Configuration
    public class JwtTokenStoreConfig {


        @Bean
        public TokenStore jwtTokenStore() {
            return new JwtTokenStore(jwtAccessTokenConverter());
        }


        @Bean
        public JwtAccessTokenConverter jwtAccessTokenConverter() {
            JwtAccessTokenConverter accessTokenConverter = new JwtAccessTokenConverter();
            //配置JWT的使用密钥
            accessTokenConverter.setSigningKey("test_key");
            return accessTokenConverter;
        }

    }
    ~~~
* 然后需要在授权服务器的配置中使用它
    ~~~java
    @Configuration
    @EnableAuthorizationServer
    public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

        @Resource
        private AuthenticationManager authenticationManager;
        @Resource
        private UserService userService;
    //    @Autowired
    //    @Qualifier("redisTokenStore")
    //    private TokenStore tokenStore;

        @Resource(name = "jwtTokenStore")
        private TokenStore tokenStore;
        @Resource
        private JwtAccessTokenConverter jwtAccessTokenConverter;


        @Override
        public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
            endpoints.authenticationManager(authenticationManager)
                    .userDetailsService(userService)
                    //※※※※※※※   配置存储令牌策略   ※※※※※※※※
                    .tokenStore(tokenStore)
                    //※※※※※※※   配置jwtToken转换  ※※※※※※※※
                    .accessTokenConverter(jwtAccessTokenConverter);
        }

        @Resource
        private PasswordEncoder passwordEncoder;

        @Override
        public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
            clients.inMemory()
                    .withClient("admin")
                    .secret(passwordEncoder.encode("112233"))
                    .accessTokenValiditySeconds(3600)
                    .redirectUris("http://www.baidu.com")
                    .scopes("all")
                    .authorizedGrantTypes("password");
        }
    }
    ~~~
* <hl>需要注意的是项目原本的RedisConfig中声明了TokenStore的类，可以先暂时注释掉</hl>
* 此时依旧使用postman做测试，会发现返回的token将不再是之前的UUID形式，而是JWT形式
    ~~~json
    {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDU0MTM3OTcsInVzZXJfbmFtZSI6ImFkbWluIiwiYXV0aG9yaXRpZXMiOlsiYWRtaW4iXSwianRpIjoiY2U2YTc0YjQtZjJiYi00ZWJiLTljMmItNWU5MDQ0MDZmZmVkIiwiY2xpZW50X2lkIjoiYWRtaW4iLCJzY29wZSI6WyJhbGwiXX0.a7K6b_w5cvzMFyT_3LJr9nggdd_zcyrDteTRSkpXIQg",
        "token_type": "bearer",
        "expires_in": 3599,
        "scope": "all",
        "jti": "ce6a74b4-f2bb-4ebb-9c2b-5e904406ffed"
    }
    ~~~
* 然后可以在jjwt的官网上进行反序列化来查看实体内容：https://jwt.io/

#### 自定义JWT扩展
* 在与Security结合使用时，需要扩展JWT本身添加一些额外的字段
* 新建一个扩展器，加入自定义的参数
    ~~~java
    public class JwtTokenEnhancer implements TokenEnhancer {
        @Override
        public OAuth2AccessToken enhance(OAuth2AccessToken oAuth2AccessToken, OAuth2Authentication oAuth2Authentication) {
            Map<String, Object> info = new HashMap<>(16);
            info.put("enhance", "enhance info");
            ((DefaultOAuth2AccessToken) oAuth2AccessToken).setAdditionalInformation(info);
            return oAuth2AccessToken;
        }
    }
    ~~~
* 这边的话还是以单例Bean引入的形式来为后面注入，所以在JwtTokenStoreConfig中新建了一个Bean
    ~~~java
    @Configuration
    public class JwtTokenStoreConfig {


        @Bean
        public TokenStore jwtTokenStore() {
            return new JwtTokenStore(jwtAccessTokenConverter());
        }


        @Bean
        public JwtAccessTokenConverter jwtAccessTokenConverter() {
            JwtAccessTokenConverter accessTokenConverter = new JwtAccessTokenConverter();
            accessTokenConverter.setSigningKey("test_key");
            return accessTokenConverter;
        }


        /**
        * ※※※※※※※※   将自定义的扩展器定义成一个bean作为单例     ※※※※※※※※※※
        * @return
        */
        @Bean
        public JwtTokenEnhancer jwtTokenEnhancer() {
            return new JwtTokenEnhancer();
        }

    }
    ~~~
* 然后就可以在授权服务器配置中添加相关的配置了
    ~~~java
    @Configuration
    @EnableAuthorizationServer
    public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

        @Resource
        private AuthenticationManager authenticationManager;
        @Resource
        private UserService userService;
    //    @Autowired
    //    @Qualifier("redisTokenStore")
    //    private TokenStore tokenStore;

        @Resource(name = "jwtTokenStore")
        private TokenStore tokenStore;
        @Resource
        private JwtAccessTokenConverter jwtAccessTokenConverter;
        @Resource
        private JwtTokenEnhancer jwtTokenEnhancer;

        @Override
        public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
            //※※※※※※※※※※    配置JWT内容增强器     ※※※※※※※※※※※※
            TokenEnhancerChain enhancerChain = new TokenEnhancerChain();
            List<TokenEnhancer> delegates = new ArrayList<>();
            delegates.add(jwtTokenEnhancer);
            //※※※※※※※※※※    必须指定转换器        ※※※※※※※※※※※※
            delegates.add(jwtAccessTokenConverter);
            enhancerChain.setTokenEnhancers(delegates);


            endpoints.authenticationManager(authenticationManager)
                    .userDetailsService(userService)
                    .tokenStore(tokenStore)
                    .accessTokenConverter(jwtAccessTokenConverter)
                    //※※※※※※※   指定增强器，不要忘记了   ※※※※※※※※※※※
                    .tokenEnhancer(enhancerChain);
        }

        @Resource
        private PasswordEncoder passwordEncoder;

        @Override
        public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
            clients.inMemory()
                    .withClient("admin")
                    .secret(passwordEncoder.encode("112233"))
                    .accessTokenValiditySeconds(3600)
                    .redirectUris("http://www.baidu.com")
                    .scopes("all")
                    .authorizedGrantTypes("password");
        }
    }
    ~~~
* 同样的，通过postman就可以获取到如下的token
    ~~~json
    {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJhZG1pbiIsInNjb3BlIjpbImFsbCJdLCJleHAiOjE2NDU0MTg1NjcsImF1dGhvcml0aWVzIjpbImFkbWluIl0sImp0aSI6IjExZGFjNTUyLWI5NmMtNGM2NC04MmJjLWJlMjA3NzA0OThiNCIsImNsaWVudF9pZCI6ImFkbWluIiwiZW5oYW5jZSI6ImVuaGFuY2UgaW5mbyJ9.ZUYeo7_SLFXXHzMQ12mzLi8R7TGBpK2qFphzvgtYNIc",
        "token_type": "bearer",
        "expires_in": 3599,
        "scope": "all",
        "enhance": "enhance info",
        "jti": "11dac552-b96c-4c64-82bc-be20770498b4"
    }
    ~~~
* 去JJWT官网：https://jwt.io/反序列化，实体内容如下
    ~~~json
    {
    "user_name": "admin",
    "scope": [
        "all"
    ],
    "exp": 1645418567,
    "authorities": [
        "admin"
    ],
    "jti": "11dac552-b96c-4c64-82bc-be20770498b4",
    "client_id": "admin",
    "enhance": "enhance info"
    }
    ~~~

#### 代码解析JWT实体
* 处于方便，我们在之前用于测试的 UserController中编写代码
    ~~~java
    @RestController
    @RequestMapping("user")
    public class UserController {

        /**
        * 获取当前用户
        *
        * @param authentication
        * @return
        */
        @RequestMapping("/getCurrentUser")
        public Object getCurrentUser(Authentication authentication, HttpServletRequest request) {
            /*
                Postman中的的 Authorization其实就是Header,只不过是有固定写法，可以在postman中的Header中查看到
                如 Authorization 选择 Bearer Token类型，那么实际在Header的固定写法是 Authorization:Bearer XXXXXXXX。注意有空格
                所以JWT是可以通过头部信息的Authorization中获取的，然后将字符串分割开来获取正确的值
            */
            String head = request.getHeader("Authorization");
            String token = head.substring(head.indexOf("bearer") + 7);
            //私钥一定要和授权服务器配置中的相同
            return Jwts.parser().setSigningKey("test_key".getBytes(StandardCharsets.UTF_8))
                    .parseClaimsJws(token).getBody();
        }
    }
    ~~~
* 使用Postman测试一下，获取到如下token
    ~~~json
    {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJhZG1pbiIsInNjb3BlIjpbImFsbCJdLCJleHAiOjE2NDU0MjYwNjksImF1dGhvcml0aWVzIjpbImFkbWluIl0sImp0aSI6ImIxNThhMmUyLTQwYmItNGJkMy05NWIwLWI2MjUxYzIxZGE0NyIsImNsaWVudF9pZCI6ImFkbWluIiwiZW5oYW5jZSI6ImVuaGFuY2UgaW5mbyJ9.YRd9bLoTxlAV7PL_lyWktU-8GNxek9Bqh0OQPe0wrG0",
        "token_type": "bearer",
        "expires_in": 3599,
        "scope": "all",
        "enhance": "enhance info",
        "jti": "b158a2e2-40bb-4bd3-95b0-b6251c21da47"
    }
    ~~~
* 在调用自定义的userController接口，当然要传递这个token,方法在上面已经讲述过了
    ~~~json
    {
        "user_name": "admin",
        "scope": [
            "all"
        ],
        "exp": 1645426069,
        "authorities": [
            "admin"
        ],
        "jti": "b158a2e2-40bb-4bd3-95b0-b6251c21da47",
        "client_id": "admin",
        "enhance": "enhance info"
    }
    ~~~

### 刷新令牌
* 在登录（认证）成功以后，token失效后，应该不需要再去做认证，而是直接去刷新token
* 在授权服务器中配置refresh_token类型即可
    ~~~java
    @Configuration
    @EnableAuthorizationServer
    public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

        @Resource
        private AuthenticationManager authenticationManager;
        @Resource
        private UserService userService;
    //    @Autowired
    //    @Qualifier("redisTokenStore")
    //    private TokenStore tokenStore;

        @Resource(name = "jwtTokenStore")
        private TokenStore tokenStore;
        @Resource
        private JwtAccessTokenConverter jwtAccessTokenConverter;
        @Resource
        private JwtTokenEnhancer jwtTokenEnhancer;

        @Override
        public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
            TokenEnhancerChain enhancerChain = new TokenEnhancerChain();
            List<TokenEnhancer> delegates = new ArrayList<>();
            delegates.add(jwtTokenEnhancer);
            delegates.add(jwtAccessTokenConverter);
            enhancerChain.setTokenEnhancers(delegates);


            endpoints.authenticationManager(authenticationManager)
                    .userDetailsService(userService)
                    .tokenStore(tokenStore)
                    .accessTokenConverter(jwtAccessTokenConverter)
                    .tokenEnhancer(enhancerChain);
        }

        @Resource
        private PasswordEncoder passwordEncoder;

        @Override
        public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
            clients.inMemory()
                    .withClient("admin")
                    .secret(passwordEncoder.encode("112233"))
                    .accessTokenValiditySeconds(3600)
                    .redirectUris("http://www.baidu.com")
                    .scopes("all")
                    //※※※※※※※※※   类型可以指定多个的，只要加上refresh_token即可   ※※※※※※※※※※
                    .authorizedGrantTypes("password","refresh_token");
        }
    }
    ~~~
* 那么此时通过postman获取token的时候将会返回一个refresh_token字段
    ~~~json
    {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJhZG1pbiIsInNjb3BlIjpbImFsbCJdLCJleHAiOjE2NDU0MjgzMjUsImF1dGhvcml0aWVzIjpbImFkbWluIl0sImp0aSI6IjhlZGMxMmNhLTViMTItNGE4Yy05MWI5LWVhZDQ1MmQzZGRjMyIsImNsaWVudF9pZCI6ImFkbWluIiwiZW5oYW5jZSI6ImVuaGFuY2UgaW5mbyJ9.0E54Jj1urq4nyWVxss9_uj2CckHU8l5Qz3atrESqcZY",
        "token_type": "bearer",
        "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJhZG1pbiIsInNjb3BlIjpbImFsbCJdLCJhdGkiOiI4ZWRjMTJjYS01YjEyLTRhOGMtOTFiOS1lYWQ0NTJkM2RkYzMiLCJleHAiOjE2NDgwMTY3MjUsImF1dGhvcml0aWVzIjpbImFkbWluIl0sImp0aSI6ImE0NTIyMjVlLTNhNTMtNDBmNC05ZDgyLTJhNjIwNjg4YmYzZiIsImNsaWVudF9pZCI6ImFkbWluIiwiZW5oYW5jZSI6ImVuaGFuY2UgaW5mbyJ9.nJKVGuGnzjVsZDiYsE4mbrZoLlLl4y3rW4WZ1ATOOjk",
        "expires_in": 3599,
        "scope": "all",
        "enhance": "enhance info",
        "jti": "8edc12ca-5b12-4a8c-91b9-ead452d3ddc3"
    }
    ~~~
* 如何去刷新令牌呢？同样使用postman，地址还是之前获取token的地址 http://localhost:8082/oauth/token，传递的参数就不同了，参看截图
* ![](postman刷新令牌.jpg)
* 返回参数如下
    ~~~json
    {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJhZG1pbiIsInNjb3BlIjpbImFsbCJdLCJleHAiOjE2NDU0Mjg2NzMsImF1dGhvcml0aWVzIjpbImFkbWluIl0sImp0aSI6IjNlMDdlMjhkLTI5ODMtNDBiNS1hZjFjLThhZDJjZGI4MWU1NiIsImNsaWVudF9pZCI6ImFkbWluIiwiZW5oYW5jZSI6ImVuaGFuY2UgaW5mbyJ9.IftV8krF1JIKMQwXZqxFCakiDleiWClhm9HwOUhRGlc",
        "token_type": "bearer",
        "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJhZG1pbiIsInNjb3BlIjpbImFsbCJdLCJhdGkiOiIzZTA3ZTI4ZC0yOTgzLTQwYjUtYWYxYy04YWQyY2RiODFlNTYiLCJleHAiOjE2NDgwMTY3MjUsImF1dGhvcml0aWVzIjpbImFkbWluIl0sImp0aSI6ImE0NTIyMjVlLTNhNTMtNDBmNC05ZDgyLTJhNjIwNjg4YmYzZiIsImNsaWVudF9pZCI6ImFkbWluIiwiZW5oYW5jZSI6ImVuaGFuY2UgaW5mbyJ9.WiAO2G76Jj7FRrHCjCPrLh8Cc6wmlGNqLNvlQn1uchI",
        "expires_in": 3599,
        "scope": "all",
        "enhance": "enhance info",
        "jti": "3e07e28d-2983-40b5-af1c-8ad2cdb81e56"
    }
    ~~~

### Security + Oauth2 + JWT 实现SSO（单点登录）
#### 项目结构
* 上面的项目 springsecurityoauth2demo，直接将它作为授权服务器
* 偷懒直接还是在springsecurityoauth2demo这个项目下新建一个模块，但是并不是父子关系，只是一个独立的项目放在下面方便调试，命名为:oauth2client01-demo,将它作为客户端
* 依赖直接使用之前的即可
* <hl>后文中oauth2client01-demo将被简称为client-01，springsecurityoauth2demo 简称为server</hl>

#### 项目
* 给client-01添加配置文件
    ~~~yaml
    server:
    port: 8083
    servlet:
        session:
        cookie:
            #防止cookie冲突，冲突会导致登录验证不通过
            name: OAUTH2-CLIENT-SESSIONID01
    # 授权服务器的地址，供下面的配置文件使用
    oauth2-server-url: http://localhost:8082
    # 与授权服务器对应的配置
    security:
    oauth2:
        client:
        client-id: admin
        client-secret: 112233
        # 授权URI
        user-authorization-uri: ${oauth2-server-url}/oauth/authorize
        # 获取token的URI
        access-token-uri: ${oauth2-server-url}/oauth/token
        resource:
        jwt:
            # 获取jwt的URI
            key-uri: ${oauth2-server-url}/oauth/token_key
    ~~~
* 在client-01的启动类上加上@EnableOAuth2Sso，表示开启单点登录功能
* 同样的，在client-01中新建一个用户测试类，UserController
    ~~~java
    @RestController
    @RequestMapping("/user")
    public class UserController {

        /**
        * 获取用户信息
        *
        * @param authentication
        * @return
        */
        @RequestMapping("/getCurrentUser")
        public Object getCurrentUser(Authentication authentication) {
            return authentication;
        }

    }

    ~~~
* 接下来需要修改server的授权服务配置，将认证成功后的跳转页面更改为client-01的登录页，也就是Security接管的登录界面
    ~~~java
    @Configuration
    @EnableAuthorizationServer
    public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

        @Resource
        private AuthenticationManager authenticationManager;
        @Resource
        private UserService userService;
    //    @Autowired
    //    @Qualifier("redisTokenStore")
    //    private TokenStore tokenStore;

        @Resource(name = "jwtTokenStore")
        private TokenStore tokenStore;
        @Resource
        private JwtAccessTokenConverter jwtAccessTokenConverter;
        @Resource
        private JwtTokenEnhancer jwtTokenEnhancer;

        @Override
        public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
            TokenEnhancerChain enhancerChain = new TokenEnhancerChain();
            List<TokenEnhancer> delegates = new ArrayList<>();
            delegates.add(jwtTokenEnhancer);
            delegates.add(jwtAccessTokenConverter);
            enhancerChain.setTokenEnhancers(delegates);


            endpoints.authenticationManager(authenticationManager)
                    .userDetailsService(userService)
                    .tokenStore(tokenStore)
                    .accessTokenConverter(jwtAccessTokenConverter)
                    .tokenEnhancer(enhancerChain);
        }

        @Resource
        private PasswordEncoder passwordEncoder;

        @Override
        public void configure(AuthorizationServerSecurityConfigurer security) throws Exception {
            //※※※※※※※※   获取密钥需要身份认证，使用单点登录时必须配置     ※※※※※※※※※
            security.tokenKeyAccess("isAuthenticated()");
        }

        @Override
        public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
            clients.inMemory()
                    .withClient("admin")
                    .secret(passwordEncoder.encode("112233"))
                    .accessTokenValiditySeconds(3600)
                    //※※※※※※※※※  还可以一下自动刷新令牌的有效时间    ※※※※※※※※※※
                    .refreshTokenValiditySeconds(864000)
                    //※※※※※※※※※  登录跳转成功后跳转到客户端的登录页   ※※※※※※※※※※
                    .redirectUris("http://localhost:8083/login")
                    //※※※※※※※※※  开启自动授权，就再也不需要认为去点接受授权了    ※※※※※※
                    .autoApprove(true)
                    .scopes("all")
                    //※※※※※※※※※  authorization_code好像必须得加，不加就会报错   ※※※※※※※※※
                    .authorizedGrantTypes("password", "refresh_token","authorization_code");
        }
    }
    ~~~
* 完成后即可，那么此时先要启动授权服务 server,然后启动 client-01
* 浏览器调用client-01的 getCurrentUser方法,地址：http://localhost:8083/user/getCurrentUser
* 由于没有登录，那么则会跳转到server的登录页：http://localhost:8082/login
* 此时输入账号密码，是在server中的自定义登录逻辑中配置的，即 UserService类，写死了admin,123456
* 输入完成后由于开启了自动授权，页面会立马跳回到刚才访问的地址：http://localhost:8083/user/getCurrentUser，并展示数据


## 动态权限控制
* 实际开发中，基本上都是将权限配置在数据库中，很少会写死
* 如下是一份简单的5表权限控制，<hl>sys_menu这个表暂时可以先不看，由于只是演示，这个表的设计有很大问题。正常来讲，角色对应权限，权限对应资源，这个sql中相当于跳开了角色和权限的关联，直接在Permissions表中填写了资源路径，所以只是demo</hl>
    ~~~sql
    /*
    Navicat Premium Data Transfer

    Source Server         : 本地
    Source Server Type    : MySQL
    Source Server Version : 50736
    Source Host           : localhost:3306
    Source Schema         : yz_demo

    Target Server Type    : MySQL
    Target Server Version : 50736
    File Encoding         : 65001

    Date: 23/02/2022 11:13:39
    */

    SET NAMES utf8mb4;
    SET FOREIGN_KEY_CHECKS = 0;

    -- ----------------------------
    -- Table structure for permissions
    -- ----------------------------
    DROP TABLE IF EXISTS `permissions`;
    CREATE TABLE `permissions`  (
    `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
    `resource` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
    `action` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
    UNIQUE INDEX `uk_role_permission`(`role`, `resource`, `action`) USING BTREE
    ) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

    -- ----------------------------
    -- Records of permissions
    -- ----------------------------
    INSERT INTO `permissions` VALUES ('1', '/demo/get', '1');
    INSERT INTO `permissions` VALUES ('2', '/demo/get', 'GET');

    -- ----------------------------
    -- Table structure for sys_menu
    -- ----------------------------
    DROP TABLE IF EXISTS `sys_menu`;
    CREATE TABLE `sys_menu`  (
    `menu_id` bigint(20) NOT NULL,
    `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
    `permission` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单权限标识',
    `path` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '前端URL',
    `parent_id` bigint(20) NULL DEFAULT NULL COMMENT '父菜单ID',
    `icon` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图标',
    `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序值',
    `keep_alive` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '0-开启，1- 关闭',
    `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单类型 （0菜单 1按钮）',
    `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '逻辑删除标记(0--正常 1--删除)',
    `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人',
    `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
    `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '修改人',
    `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
    PRIMARY KEY (`menu_id`) USING BTREE
    ) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

    -- ----------------------------
    -- Records of sys_menu
    -- ----------------------------
    INSERT INTO `sys_menu` VALUES (1000, '权限管理', NULL, '/admin', -1, 'icon-quanxianguanli', 1, '0', '0', '0', ' ', '2018-09-28 08:29:53', ' ', '2020-03-11 23:58:18');
    INSERT INTO `sys_menu` VALUES (1100, '用户管理', NULL, '/admin/user/index', 1000, 'icon-yonghuguanli', 0, '0', '0', '0', ' ', '2017-11-02 22:24:37', ' ', '2020-03-12 00:12:57');
    INSERT INTO `sys_menu` VALUES (1101, '用户新增', 'sys_user_add', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:52:09', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1102, '用户修改', 'sys_user_edit', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:52:48', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1103, '用户删除', 'sys_user_del', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:54:01', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1104, '导入导出', 'sys_user_import_export', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:54:01', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1200, '菜单管理', NULL, '/admin/menu/index', 1000, 'icon-caidanguanli', 0, '0', '0', '0', ' ', '2017-11-08 09:57:27', ' ', '2020-03-12 00:13:52');
    INSERT INTO `sys_menu` VALUES (1201, '菜单新增', 'sys_menu_add', NULL, 1200, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:15:53', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1202, '菜单修改', 'sys_menu_edit', NULL, 1200, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:16:23', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1203, '菜单删除', 'sys_menu_del', NULL, 1200, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:16:43', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1300, '角色管理', NULL, '/admin/role/index', 1000, 'icon-jiaoseguanli', 0, '0', '0', '0', ' ', '2017-11-08 10:13:37', ' ', '2020-03-12 00:15:40');
    INSERT INTO `sys_menu` VALUES (1301, '角色新增', 'sys_role_add', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:14:18', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1302, '角色修改', 'sys_role_edit', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:14:41', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1303, '角色删除', 'sys_role_del', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:14:59', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1304, '分配权限', 'sys_role_perm', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2018-04-20 07:22:55', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1400, '部门管理', NULL, '/admin/dept/index', 1000, 'icon-web-icon-', 0, '0', '0', '0', ' ', '2018-01-20 13:17:19', ' ', '2020-03-12 00:15:44');
    INSERT INTO `sys_menu` VALUES (1401, '部门新增', 'sys_dept_add', NULL, 1400, NULL, 0, '0', '1', '0', ' ', '2018-01-20 14:56:16', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1402, '部门修改', 'sys_dept_edit', NULL, 1400, NULL, 0, '0', '1', '0', ' ', '2018-01-20 14:56:59', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (1403, '部门删除', 'sys_dept_del', NULL, 1400, NULL, 0, '0', '1', '0', ' ', '2018-01-20 14:57:28', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2000, '系统管理', NULL, '/setting', -1, 'icon-xitongguanli', 2, '0', '0', '0', ' ', '2017-11-07 20:56:00', ' ', '2020-03-11 23:52:53');
    INSERT INTO `sys_menu` VALUES (2100, '日志管理', NULL, '/admin/log/index', 2000, 'icon-rizhiguanli', 0, '0', '0', '0', ' ', '2017-11-20 14:06:22', ' ', '2020-03-12 00:15:49');
    INSERT INTO `sys_menu` VALUES (2101, '日志删除', 'sys_log_del', NULL, 2100, NULL, 0, '0', '1', '0', ' ', '2017-11-20 20:37:37', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2102, '导入导出', 'sys_log_import_export', NULL, 2100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:54:01', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2200, '字典管理', NULL, '/admin/dict/index', 2000, 'icon-navicon-zdgl', 0, '0', '0', '0', ' ', '2017-11-29 11:30:52', ' ', '2020-03-12 00:15:58');
    INSERT INTO `sys_menu` VALUES (2201, '字典删除', 'sys_dict_del', NULL, 2200, NULL, 0, '0', '1', '0', ' ', '2017-11-29 11:30:11', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2202, '字典新增', 'sys_dict_add', NULL, 2200, NULL, 0, '0', '1', '0', ' ', '2018-05-11 22:34:55', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2203, '字典修改', 'sys_dict_edit', NULL, 2200, NULL, 0, '0', '1', '0', ' ', '2018-05-11 22:36:03', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2300, '令牌管理', NULL, '/admin/token/index', 2000, 'icon-denglvlingpai', 0, '0', '0', '0', ' ', '2018-09-04 05:58:41', ' ', '2020-03-13 12:57:25');
    INSERT INTO `sys_menu` VALUES (2301, '令牌删除', 'sys_token_del', NULL, 2300, NULL, 0, '0', '1', '0', ' ', '2018-09-04 05:59:50', ' ', '2020-03-13 12:57:34');
    INSERT INTO `sys_menu` VALUES (2400, '终端管理', '', '/admin/client/index', 2000, 'icon-shouji', 0, '0', '0', '0', ' ', '2018-01-20 13:17:19', ' ', '2020-03-12 00:15:54');
    INSERT INTO `sys_menu` VALUES (2401, '客户端新增', 'sys_client_add', NULL, 2400, '1', 0, '0', '1', '0', ' ', '2018-05-15 21:35:18', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2402, '客户端修改', 'sys_client_edit', NULL, 2400, NULL, 0, '0', '1', '0', ' ', '2018-05-15 21:37:06', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2403, '客户端删除', 'sys_client_del', NULL, 2400, NULL, 0, '0', '1', '0', ' ', '2018-05-15 21:39:16', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2500, '服务监控', NULL, 'http://localhost:5001', 2000, 'icon-server', 0, '0', '0', '0', ' ', '2018-06-26 10:50:32', ' ', '2019-02-01 20:41:30');
    INSERT INTO `sys_menu` VALUES (2600, '文件管理', NULL, '/admin/file/index', 2000, 'icon-wenjianguanli', 0, '0', '0', '0', ' ', '2018-06-26 10:50:32', ' ', '2019-02-01 20:41:30');
    INSERT INTO `sys_menu` VALUES (2601, '文件删除', 'sys_file_del', NULL, 2600, NULL, 0, '0', '1', '0', ' ', '2017-11-29 11:30:11', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2602, '文件新增', 'sys_file_add', NULL, 2600, NULL, 0, '0', '1', '0', ' ', '2018-05-11 22:34:55', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (2603, '文件修改', 'sys_file_edit', NULL, 2600, NULL, 0, '0', '1', '0', ' ', '2018-05-11 22:36:03', ' ', '2021-05-25 06:48:34');
    INSERT INTO `sys_menu` VALUES (3000, '开发平台', NULL, '/gen', -1, 'icon-shejiyukaifa-', 3, '1', '0', '0', ' ', '2020-03-11 22:15:40', ' ', '2020-03-11 23:52:54');
    INSERT INTO `sys_menu` VALUES (3100, '数据源管理', NULL, '/gen/datasource', 3000, 'icon-mysql', 0, '1', '0', '0', ' ', '2020-03-11 22:17:05', ' ', '2020-03-12 00:16:09');
    INSERT INTO `sys_menu` VALUES (3200, '代码生成', NULL, '/gen/index', 3000, 'icon-weibiaoti46', 0, '0', '0', '0', ' ', '2020-03-11 22:23:42', ' ', '2020-03-12 00:16:14');
    INSERT INTO `sys_menu` VALUES (3300, '表单管理', NULL, '/gen/form', 3000, 'icon-record', 0, '1', '0', '0', ' ', '2020-03-11 22:19:32', ' ', '2020-03-12 00:16:18');
    INSERT INTO `sys_menu` VALUES (3301, '表单新增', 'gen_form_add', NULL, 3300, '', 0, '0', '1', '0', ' ', '2018-05-15 21:35:18', ' ', '2020-03-11 22:39:08');
    INSERT INTO `sys_menu` VALUES (3302, '表单修改', 'gen_form_edit', NULL, 3300, '', 0, '0', '1', '0', ' ', '2018-05-15 21:35:18', ' ', '2020-03-11 22:39:09');
    INSERT INTO `sys_menu` VALUES (3303, '表单删除', 'gen_form_del', NULL, 3300, '', 0, '0', '1', '0', ' ', '2018-05-15 21:35:18', ' ', '2020-03-11 22:39:11');
    INSERT INTO `sys_menu` VALUES (3400, '表单设计', NULL, '/gen/design', 3000, 'icon-biaodanbiaoqian', 0, '1', '0', '0', ' ', '2020-03-11 22:18:05', ' ', '2020-03-12 00:16:25');
    INSERT INTO `sys_menu` VALUES (9999, '系统官网', NULL, 'https://pig4cloud.com/#/', -1, 'icon-guanwangfangwen', 999, '0', '0', '0', ' ', '2019-01-17 17:05:19', 'admin', '2020-03-11 23:52:57');
    INSERT INTO `sys_menu` VALUES (1644822612033, 'demo 表管理', '', '/demo/demo/index', -1, 'icon-bangzhushouji', 8, '0', '0', '0', NULL, '2018-01-20 13:17:19', NULL, '2018-07-29 13:38:19');
    INSERT INTO `sys_menu` VALUES (1644822612034, 'demo 表查看', 'demo_demo_get', '', 1644822612033, '1', 0, '0', '1', '0', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59');
    INSERT INTO `sys_menu` VALUES (1644822612035, 'demo 表新增', 'demo_demo_add', NULL, 1644822612033, '1', 1, '0', '1', '0', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59');
    INSERT INTO `sys_menu` VALUES (1644822612036, 'demo 表修改', 'demo_demo_edit', NULL, 1644822612033, '1', 2, '0', '1', '0', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59');
    INSERT INTO `sys_menu` VALUES (1644822612037, 'demo 表删除', 'demo_demo_del', NULL, 1644822612033, '1', 3, '0', '1', '0', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59');

    -- ----------------------------
    -- Table structure for sys_role
    -- ----------------------------
    DROP TABLE IF EXISTS `sys_role`;
    CREATE TABLE `sys_role`  (
    `role_id` bigint(20) NOT NULL,
    `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
    `role_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
    `role_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
    `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标识（0-正常,1-删除）',
    `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
    `update_time` datetime(0) NULL DEFAULT NULL COMMENT '修改时间',
    `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '修改人',
    `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
    PRIMARY KEY (`role_id`) USING BTREE,
    UNIQUE INDEX `role_idx1_role_code`(`role_code`) USING BTREE
    ) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统角色表' ROW_FORMAT = Dynamic;

    -- ----------------------------
    -- Records of sys_role
    -- ----------------------------
    INSERT INTO `sys_role` VALUES (1, '管理员', 'ROLE_ADMIN', '管理员', '0', '2017-10-29 15:45:51', '2018-12-26 14:09:11', NULL, NULL);

    -- ----------------------------
    -- Table structure for sys_role_menu
    -- ----------------------------
    DROP TABLE IF EXISTS `sys_role_menu`;
    CREATE TABLE `sys_role_menu`  (
    `role_id` bigint(20) NOT NULL,
    `menu_id` bigint(20) NOT NULL,
    PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
    ) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色菜单表' ROW_FORMAT = Dynamic;

    -- ----------------------------
    -- Records of sys_role_menu
    -- ----------------------------
    INSERT INTO `sys_role_menu` VALUES (1, 1000);
    INSERT INTO `sys_role_menu` VALUES (1, 1100);
    INSERT INTO `sys_role_menu` VALUES (1, 1101);
    INSERT INTO `sys_role_menu` VALUES (1, 1102);
    INSERT INTO `sys_role_menu` VALUES (1, 1103);
    INSERT INTO `sys_role_menu` VALUES (1, 1104);
    INSERT INTO `sys_role_menu` VALUES (1, 1200);
    INSERT INTO `sys_role_menu` VALUES (1, 1201);
    INSERT INTO `sys_role_menu` VALUES (1, 1202);
    INSERT INTO `sys_role_menu` VALUES (1, 1203);
    INSERT INTO `sys_role_menu` VALUES (1, 1300);
    INSERT INTO `sys_role_menu` VALUES (1, 1301);
    INSERT INTO `sys_role_menu` VALUES (1, 1302);
    INSERT INTO `sys_role_menu` VALUES (1, 1303);
    INSERT INTO `sys_role_menu` VALUES (1, 1304);
    INSERT INTO `sys_role_menu` VALUES (1, 1400);
    INSERT INTO `sys_role_menu` VALUES (1, 1401);
    INSERT INTO `sys_role_menu` VALUES (1, 1402);
    INSERT INTO `sys_role_menu` VALUES (1, 1403);
    INSERT INTO `sys_role_menu` VALUES (1, 2000);
    INSERT INTO `sys_role_menu` VALUES (1, 2100);
    INSERT INTO `sys_role_menu` VALUES (1, 2101);
    INSERT INTO `sys_role_menu` VALUES (1, 2102);
    INSERT INTO `sys_role_menu` VALUES (1, 2200);
    INSERT INTO `sys_role_menu` VALUES (1, 2201);
    INSERT INTO `sys_role_menu` VALUES (1, 2202);
    INSERT INTO `sys_role_menu` VALUES (1, 2203);
    INSERT INTO `sys_role_menu` VALUES (1, 2300);
    INSERT INTO `sys_role_menu` VALUES (1, 2301);
    INSERT INTO `sys_role_menu` VALUES (1, 2400);
    INSERT INTO `sys_role_menu` VALUES (1, 2401);
    INSERT INTO `sys_role_menu` VALUES (1, 2402);
    INSERT INTO `sys_role_menu` VALUES (1, 2403);
    INSERT INTO `sys_role_menu` VALUES (1, 2600);
    INSERT INTO `sys_role_menu` VALUES (1, 2601);
    INSERT INTO `sys_role_menu` VALUES (1, 2602);
    INSERT INTO `sys_role_menu` VALUES (1, 2603);
    INSERT INTO `sys_role_menu` VALUES (1, 3000);
    INSERT INTO `sys_role_menu` VALUES (1, 3100);
    INSERT INTO `sys_role_menu` VALUES (1, 3200);
    INSERT INTO `sys_role_menu` VALUES (1, 3300);
    INSERT INTO `sys_role_menu` VALUES (1, 3301);
    INSERT INTO `sys_role_menu` VALUES (1, 3302);
    INSERT INTO `sys_role_menu` VALUES (1, 3303);
    INSERT INTO `sys_role_menu` VALUES (1, 3400);
    INSERT INTO `sys_role_menu` VALUES (1, 9999);
    INSERT INTO `sys_role_menu` VALUES (1, 1644822612033);
    INSERT INTO `sys_role_menu` VALUES (1, 1644822612034);
    INSERT INTO `sys_role_menu` VALUES (1, 1644822612035);
    INSERT INTO `sys_role_menu` VALUES (1, 1644822612036);
    INSERT INTO `sys_role_menu` VALUES (1, 1644822612037);

    -- ----------------------------
    -- Table structure for sys_user
    -- ----------------------------
    DROP TABLE IF EXISTS `sys_user`;
    CREATE TABLE `sys_user`  (
    `user_id` bigint(20) NOT NULL,
    `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
    `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码',
    `salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '随机盐',
    `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '简介',
    `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
    `dept_id` bigint(20) NULL DEFAULT NULL COMMENT '部门ID',
    `lock_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '0-正常，9-锁定',
    `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '0-正常，1-删除',
    `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
    `update_time` datetime(0) NULL DEFAULT NULL COMMENT '修改时间',
    `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建者',
    `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
    PRIMARY KEY (`user_id`) USING BTREE,
    INDEX `user_idx1_username`(`username`) USING BTREE
    ) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

    -- ----------------------------
    -- Records of sys_user
    -- ----------------------------
    INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', NULL, '17034642999', '', 1, '0', '0', '2018-04-20 07:15:18', '2019-01-31 14:29:07', NULL, NULL);

    -- ----------------------------
    -- Table structure for sys_user_role
    -- ----------------------------
    DROP TABLE IF EXISTS `sys_user_role`;
    CREATE TABLE `sys_user_role`  (
    `user_id` bigint(20) NOT NULL,
    `role_id` bigint(20) NOT NULL,
    PRIMARY KEY (`user_id`, `role_id`) USING BTREE
    ) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户角色表' ROW_FORMAT = Dynamic;

    -- ----------------------------
    -- Records of sys_user_role
    -- ----------------------------
    INSERT INTO `sys_user_role` VALUES (1, 1);

    SET FOREIGN_KEY_CHECKS = 1;

    ~~~
* 我们需要先定义一个过滤器，来匹配路径所需要的角色信息
    ~~~java
    @Component
    @RequiredArgsConstructor(onConstructor = @__(@Autowired))
    public class MySecurityMetadataSource implements FilterInvocationSecurityMetadataSource {

        private final UserClient userClient;
        private final AntPathMatcher antPathMatcher = new AntPathMatcher();

        @Override
        public Collection<ConfigAttribute> getAttributes(Object o) throws IllegalArgumentException {
            //客户端请求的Url
            String requestUrl = ((FilterInvocation) o).getRequestUrl();
            //获取所有的资源路径，也就是表Permissions中的路径，将url和该路径匹配，来确定该路径需要XXX角色/XXX权限
            List<Permissions> permissions = userClient.queryAllPermissions();
            for (Permissions permission : permissions) {
                //如果路径匹配
                if (antPathMatcher.match(permission.getResource(), requestUrl)) {
                    //查询该路径所需要的角色信息
                    List<SysRole> rolePermissions = userClient.queryRoleByResource(permission.getResource());
                    //获取的是角色对象，验证的时候其实只需要角色编码
                    String[] roleNames = rolePermissions.stream().map(SysRole::getRoleCode).toArray(String[]::new);
                    //将该路径所需要的角色编码存储起来，SecurityConfig这个类是org.springframework.security.access包下的
                    return SecurityConfig.createList(roleNames);
                }
            }
            //这一段表示如果没有权限验证，也需要进行登录验证，很关键
            return SecurityConfig.createList("ROLE_USER");
        }

        @Override
        public Collection<ConfigAttribute> getAllConfigAttributes() {
            return null;
        }

        /**
        * 这个方法要先返回true
        *
        */
        @Override
        public boolean supports(Class<?> aClass) {
            return true;
        }
    }
    ~~~
* 然后再进行自定义的权限判定
    ~~~java
    @Component
    public class RoleAccessDecisionManager implements AccessDecisionManager {
        @Override
        public void decide(Authentication authentication, Object o, Collection<ConfigAttribute> collection) throws AccessDeniedException, InsufficientAuthenticationException {
            //获取用户所拥有的权限，该权限在登录的时候已经被放入了
            Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
            //接下来就是判定是否存在，如果存在，则return放行
            for (GrantedAuthority authority : authorities) {
                for (ConfigAttribute c : collection) {
                    if(c.getAttribute().equals(authority.getAuthority())){
                        return;
                    }
                }
            }
            //权限不通过则抛出异常
            throw new AccessDeniedException("当前访问没有权限");
        }

        /**
        * 返回值更改为true
        *
        */
        @Override
        public boolean supports(ConfigAttribute configAttribute) {
            return true;
        }

        /**
        * 返回值更改为true
        *
        */
        @Override
        public boolean supports(Class<?> aClass) {
            return true;
        }
    }
    ~~~
* 完成之后我们需要在Security的配置中配置这两个类
    ~~~java
    @Configuration
    @RequiredArgsConstructor(onConstructor = @__(@Autowired))
    @EnableWebSecurity
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        private final RoleAccessDecisionManager roleAccessDecisionManager;
        private final MySecurityMetadataSource mySecurityMetadataSource;

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http.csrf().disable().authorizeRequests()
                    .antMatchers("/login/**", "/logout/**").permitAll()
                    .anyRequest().authenticated()
                    //※※※※※※※※※      配置自定义的权限逻辑       ※※※※※※※※※※※※
                    .withObjectPostProcessor(new ObjectPostProcessor<FilterSecurityInterceptor>() {
                        @Override
                        public <O extends FilterSecurityInterceptor> O postProcess(O o) {
                            o.setAccessDecisionManager(roleAccessDecisionManager);
                            o.setSecurityMetadataSource(mySecurityMetadataSource);
                            return o;
                        }
                    })
                    .and()
                    .formLogin().permitAll()
                    .successForwardUrl("/toIndex");
        }
    }

    ~~~
* 当然如果想要验证的话，不要忘记自定义的认证逻辑里面的代码，认证完成后需要将权限信息放入，此处是写死的ROLE_ADMIN
    ~~~java
    @Service
    @RequiredArgsConstructor(onConstructor = @__(@Autowired))
    public class UserDetailsServiceImpl implements UserDetailsService {


        private final UserClient userClient;

        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            R<UserInfo> info = userClient.info(username);
            //跳开具体的验证逻辑，简写了
            UserInfo userInfo = info.getData();

            return new User(userInfo.getSysUser().getUsername(), userInfo.getSysUser().getPassword(), AuthorityUtils.commaSeparatedStringToAuthorityList("ROLE_ADMIN"));
        }
    }
    ~~~
## Security深入理解
### Security自带的过滤器
* 过滤器很重要，需要先查看下有哪些过滤器
* > https://blog.csdn.net/a807719447/article/details/108732660


## Security + JWT做token认证和授权（前后端分离）
### 直接上代码
* 编写一个jwt的工具类
    ~~~java
    @Data
    @ConfigurationProperties(prefix = "jwt")
    @Component
    public class JwtTokenUtil {

        private String secret;

        // 过期时间 毫秒
        private Long expiration;

        private String header;

        /**
        * 从数据声明生成令牌
        *
        * @param claims 数据声明
        * @return 令牌
        */
        private String generateToken(Map<String, Object> claims) {
            Date expirationDate = new Date(System.currentTimeMillis() + expiration);
            return Jwts.builder().setClaims(claims).setExpiration(expirationDate).signWith(SignatureAlgorithm.HS512, secret).compact();
        }

        /**
        * 从令牌中获取数据声明
        *
        * @param token 令牌
        * @return 数据声明
        */
        private Claims getClaimsFromToken(String token) {
            Claims claims;
            try {
                claims = Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
            } catch (Exception e) {
                claims = null;
            }
            return claims;
        }

        /**
        * 生成令牌
        *
        * @param userDetails 用户
        * @return 令牌
        */
        public String generateToken(UserDetails userDetails) {
            Map<String, Object> claims = new HashMap<>(2);
            claims.put(Claims.SUBJECT, userDetails.getUsername());
            claims.put(Claims.ISSUED_AT, new Date());
            return generateToken(claims);
        }

        /**
        * 从令牌中获取用户名
        *
        * @param token 令牌
        * @return 用户名
        */
        public String getUsernameFromToken(String token) {
            String username;
            try {
                Claims claims = getClaimsFromToken(token);
                username = claims.getSubject();
            } catch (Exception e) {
                username = null;
            }
            return username;
        }

        /**
        * 判断令牌是否过期
        *
        * @param token 令牌
        * @return 是否过期
        */
        public Boolean isTokenExpired(String token) {
            try {
                Claims claims = getClaimsFromToken(token);
                Date expiration = claims.getExpiration();
                return expiration.before(new Date());
            } catch (Exception e) {
                return true;
            }
        }

        /**
        * 刷新令牌
        *
        * @param token 原令牌
        * @return 新令牌
        */
        public String refreshToken(String token) {
            String refreshedToken;
            try {
                Claims claims = getClaimsFromToken(token);
                claims.put(Claims.ISSUED_AT, new Date());
                refreshedToken = generateToken(claims);
            } catch (Exception e) {
                refreshedToken = null;
            }
            return refreshedToken;
        }

        /**
        * 验证令牌
        *
        * @param token       令牌
        * @param userDetails 用户
        * @return 是否有效
        */
        public Boolean validateToken(String token, UserDetails userDetails) {
            JwtUser user = (JwtUser) userDetails;
            String username = getUsernameFromToken(token);
            return (username.equals(user.getUsername()) && !isTokenExpired(token));
        }
    }
    ~~~
* 由于工具类里面用了@ConfigurationProperties(prefix = "jwt")，所以在配置文件中需要一些配置一些参数
    ~~~yaml
    jwt:
        # 长度必须大于4，这边是随便写的
        secret: 4444
        # jwt的失效时间
        expiration: 600000
        # 头部key的名称
        header: Authorization
    ~~
* 编写一个核心的 jwt验证类
    ~~~java
    @Component
    @RequiredArgsConstructor
    public class JwtAuthenticationTokenFilter extends OncePerRequestFilter {
        private final UserDetailsService userDetailsService;
        private final JwtTokenUtil jwtTokenUtil;

        @Override
        protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws ServletException, IOException {
            //从头部获取token
            String token = request.getHeader(jwtTokenUtil.getHeader());
            if (!StringUtils.isEmpty(token)) {
                //解析token来获取用户名
                String username = jwtTokenUtil.getUsernameFromToken(token);
                //SecurityContextHolder.getContext()是表示Security，他内部是一个ThreadLocal
                if (username != null && SecurityContextHolder.getContext().getAuthentication() == null){
                    //执行自定义的登录逻辑，userDetailsService是注入进来的
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                    //这一段就是验证token中的用户和登录用户是否相同
                    if (jwtTokenUtil.validateToken(token, userDetails)){
                        // 将用户信息存入 authentication，方便后续校验
                        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                        authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                        // 将 authentication 存入 ThreadLocal，方便后续获取用户信息
                        SecurityContextHolder.getContext().setAuthentication(authentication);
                    }
                }
            }
            chain.doFilter(request, response);
        }
    }
    ~~~
* 自定义的登录逻辑代码还是贴出来一下,所拥有的权限直接写死了
    ~~~java
    @Service
    @RequiredArgsConstructor(onConstructor = @__(@Autowired))
    public class UserDetailsServiceImpl implements UserDetailsService {


        private final UserClient userClient;

        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            R<UserInfo> info = userClient.info(username);
            //跳开具体的验证逻辑，简写了
            UserInfo userInfo = info.getData();

            return new User(userInfo.getSysUser().getUsername(), userInfo.getSysUser().getPassword(), AuthorityUtils.commaSeparatedStringToAuthorityList("ROLE_ADMIN"));
        }
    }
    ~~~
* 接下来就是登录成功后将token写入返回的逻辑
    ~~~java
    @RequiredArgsConstructor
    @Component
    public class MyAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

        private final JwtTokenUtil jwtTokenUtil;

        @Override
        public void onAuthenticationSuccess(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Authentication authentication) throws IOException, ServletException {
            //获取登录的用户信息
            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            SecurityContextHolder.getContext().setAuthentication(authentication);
            //生成token
            String token = jwtTokenUtil.generateToken(userDetails);
            //登录成功后直接将token以json字符串的形式返回给前端了
            renderToken(httpServletResponse, token);
        }


        /**
        * 渲染返回 token 页面,因为前端页面接收的都是Result对象，故使用application/json返回
        *
        * @param response
        * @throws IOException
        */
        public void renderToken(HttpServletResponse response, String token) throws IOException {
            response.setContentType("application/json;charset=UTF-8");
            ServletOutputStream out = response.getOutputStream();
            String str = JSONObject.toJSONString(R.ok(token));
            out.write(str.getBytes(StandardCharsets.UTF_8));
            out.flush();
            out.close();
        }
    }
    ~~~
* 相应的编写一个 认证失败 的自定义处理
    ~~~java
    @Component
    public class MyAuthenticationFailureHandler implements AuthenticationFailureHandler {
        @Override
        public void onAuthenticationFailure(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, AuthenticationException e) throws IOException, ServletException {
            httpServletResponse.setContentType("application/json;charset=UTF-8");
            ServletOutputStream out = httpServletResponse.getOutputStream();
            String str = JSONObject.toJSONString(R.error(401, "登录失败"));
            out.write(str.getBytes(StandardCharsets.UTF_8));
            out.flush();
            out.close();
        }
    }
    ~~~
* 然后是编写一个 身份认证失败 的自定义处理，如果token不对将执行此段代码
    ~~~java
    @Component
    public class EntryPointUnauthorizedHandler implements AuthenticationEntryPoint {
        @Override
        public void commence(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, AuthenticationException e) throws IOException, ServletException {
            httpServletResponse.setContentType("application/json;charset=UTF-8");
            ServletOutputStream out = httpServletResponse.getOutputStream();
            String str = JSONObject.toJSONString(R.error(401,"身份验证失败"));
            out.write(str.getBytes(StandardCharsets.UTF_8));
            out.flush();
            out.close();
        }
    }
    ~~~
* 编写一个 授权失败 的自定义处理
    ~~~java
    @Component
    public class RestAccessDeniedHandler implements AccessDeniedHandler {
        @Override
        public void handle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, AccessDeniedException e) throws IOException, ServletException {
            httpServletResponse.setContentType("application/json;charset=UTF-8");
            ServletOutputStream out = httpServletResponse.getOutputStream();
            String str = JSONObject.toJSONString(R.error(403, "权限不足"));
            out.write(str.getBytes(StandardCharsets.UTF_8));
            out.flush();
            out.close();
        }
    }
    ~~~
* 然后就是Security的核心配置
    ~~~java
    @Configuration
    @RequiredArgsConstructor(onConstructor = @__(@Autowired))
    @EnableWebSecurity
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        private final MyAuthenticationSuccessHandler myAuthenticationSuccessHandler;
        private final UserDetailsService userDetailsService;
        private final JwtAuthenticationTokenFilter jwtAuthenticationTokenFilter;
        private final EntryPointUnauthorizedHandler entryPointUnauthorizedHandler;
        private final RestAccessDeniedHandler restAccessDeniedHandler;
        private final MyAuthenticationFailureHandler myAuthenticationFailureHandler;

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http.csrf().disable().authorizeRequests()
                    //允许所有的跨域请求
                    .requestMatchers(CorsUtils::isPreFlightRequest).permitAll()
                    .antMatchers("/toNoPermission", "/toLogin", "/login/**", "/logout/**", "/login.html").permitAll()
                    .anyRequest().authenticated()
                    .and()
                    .formLogin().permitAll()
                    //自定义的认证成功处理
                    .successHandler(myAuthenticationSuccessHandler)
                    //自定义的认证失败处理
                    .failureHandler(myAuthenticationFailureHandler)
                    .loginPage("/toLogin")
                    .loginProcessingUrl("/login")
                    .and()
                    //禁用Session，非常非常关键，如果少了这一段，即在客户端第一次登录完成后后续即使没有token也能继续访问，因为它的sessionId被记录了下来
                    .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                    .and()
                    //在UsernamePasswordAuthenticationFilter拦截器前面添加一个自定义的token拦截器
                    .addFilterBefore(jwtAuthenticationTokenFilter, UsernamePasswordAuthenticationFilter.class)
                    .exceptionHandling()
                    //自定义的身份验证失败处理
                    .authenticationEntryPoint(entryPointUnauthorizedHandler)
                    //自定义的权限失败处理
                    .accessDeniedHandler(restAccessDeniedHandler)
                    .and()
                    .headers().cacheControl();
        }


        @Bean
        public CorsFilter corsFilter(){
            UrlBasedCorsConfigurationSource configurationSource = new UrlBasedCorsConfigurationSource();
            CorsConfiguration cors = new CorsConfiguration();
            cors.setAllowCredentials(true);
            cors.addAllowedOrigin("*");
            cors.addAllowedHeader("*");
            cors.addAllowedMethod("*");
            configurationSource.registerCorsConfiguration("/**", cors);
            return new CorsFilter(configurationSource);
        }

    }
    ~~~
* 最后要在启动类上添加注解 ：@EnableGlobalMethodSecurity，将所有的注解功能开启
* 参看这一片文章 > https://www.jianshu.com/p/5b9f1f4de88d
* 最后进行验证，首先调用登录，成功后返回token,再调用任意需要权限的接口，将自定义的头部，此处是Authorization：token传递就可以访问了

## <hl>单点登录（必看）</hl>
* 以下是个人理解，也是踩过的坑
* 目前的主流肯定是前后端分离，所以登陆完成以后一定是会返回一个token。这一块内容就是上面  Security + JWT做token认证和授权（前后端分离）   所描述的，即通过自定义的token去鉴权,所以网上查的资料很多都是通过postman去访问/oauth/token去获取的，这种方式应该是没有加入自定义的token鉴权下是可用的。按之前的代码，加入了JwtAuthenticationTokenFilter这个类，实测下来应该是会替代它默认的token验证方法。也就是说，不再需要通过访问/oauth/token去获取，之前的代码中在登录完成以后直接会输出一个token,只要使用该token去访问其他服务即可。如果分布式环境，不确定JWT自己控制的token在分布式环境下是否会有问题，大概说一下目前能理解的流程
  * 前端访问A服务
  * 由于没有登录，后端跳转到统一登录页面
  * 客户输入账密，不通过则报错/继续跳转当页面并现实错误，都可以。如果认证通过则返回一串自定义的token,也就是上面前后端分离的代码
  * 前端再次发起请求，访问A服务，此时将token写入到header头中即可访问
* 具体的代码，看下面的实际案例
* 另外，基于Session会话完成的单点登录，也就是   Security + Oauth2 + JWT 实现SSO（单点登录）  这一章 ，无法确定在分布式场景下是否能使用，虽然配置起来非常简单，基本按照上面配置的就可以了（当然可以使用jdbc加载的形式），然后可以启动N个客户端，单点登录很方便也很简单


## 单点登录-实际案例
### 概述
* 在实际的场景中，不可能将客户的服务信息写死，Security也支持从数据库中读取
### 重点代码
* <hl></hl>
* 首先，肯定是需要一个授权服务
    ~~~java
    @Configuration
    @EnableAuthorizationServer
    @RequiredArgsConstructor
    public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {

        private final DataSource dataSource;
        private final UserDetailsService userService;
        private final AuthenticationManager authenticationManager;
        private final TokenStore tokenStore;
        private final JwtAccessTokenConverter jwtAccessTokenConverter;

        @Override
        public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
            clients.withClientDetails(clientDetails());
        }

        /**
        * 密码模式必须
        *
        */
        @Override
        public void configure(AuthorizationServerSecurityConfigurer security) throws Exception {
            security.tokenKeyAccess("isAuthenticated()");
        }



        @Bean
        public ClientDetailsService clientDetails() {
            //这一段是关键，Security提供了对JDBC的支持
            return new JdbcClientDetailsService(dataSource);
        }

        @Override
        public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
            endpoints.authenticationManager(authenticationManager)
                    //指定自定义的登录逻辑
                    .userDetailsService(userService)
                    //指定使用jwt
                    .tokenStore(tokenStore)
                    //jwt的转换
                    .accessTokenConverter(jwtAccessTokenConverter);
        }
    }
    ~~~
* 官方提供了相应的表结构
    ~~~sql
    DROP TABLE IF EXISTS `oauth_client_details`;
    CREATE TABLE `oauth_client_details` (
    `client_id` varchar(48) NOT NULL,
    `resource_ids` varchar(256) DEFAULT NULL,
    `client_secret` varchar(256) DEFAULT NULL,
    `scope` varchar(256) DEFAULT NULL,
    `authorized_grant_types` varchar(256) DEFAULT NULL,
    `web_server_redirect_uri` varchar(256) DEFAULT NULL,
    `authorities` varchar(256) DEFAULT NULL,
    `access_token_validity` int(11) DEFAULT NULL,
    `refresh_token_validity` int(11) DEFAULT NULL,
    `additional_information` varchar(4096) DEFAULT NULL,
    `autoapprove` varchar(256) DEFAULT NULL,
    PRIMARY KEY (`client_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ~~~
* 自己插入两条数据
    ~~~sql
    INSERT INTO `yz_demo`.`oauth_client_details`(`client_id`, `resource_ids`, `client_secret`, `scope`, `authorized_grant_types`, `web_server_redirect_uri`, `authorities`, `access_token_validity`, `refresh_token_validity`, `additional_information`, `autoapprove`) VALUES ('noname', NULL, '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', 'all', 'authorization_code', 'http://localhost:8083/login', 'ROLE_ADMIN', 3600, NULL, NULL, 'true');
    INSERT INTO `yz_demo`.`oauth_client_details`(`client_id`, `resource_ids`, `client_secret`, `scope`, `authorized_grant_types`, `web_server_redirect_uri`, `authorities`, `access_token_validity`, `refresh_token_validity`, `additional_information`, `autoapprove`) VALUES ('binbin', NULL, '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', 'all', 'password', 'http://localhost:8083/login', 'ROLE_ADMIN', 3600, NULL, NULL, 'true');
    ~~~
* <hl>此处有坑，client_secret是通过BCryptPasswordEncoder加密的结果，如果填写明文的话后台会报错。此处这一串乱码的明文是123456</hl>
* Security的配置还是使用的前后端分离的一套
    ~~~java
    @Configuration
    @RequiredArgsConstructor(onConstructor = @__(@Autowired))
    @EnableWebSecurity
    public class SecurityConfig extends WebSecurityConfigurerAdapter {

        private final MyAuthenticationSuccessHandler myAuthenticationSuccessHandler;
        private final UserDetailsService userDetailsService;
        private final JwtAuthenticationTokenFilter jwtAuthenticationTokenFilter;
        private final EntryPointUnauthorizedHandler entryPointUnauthorizedHandler;
        private final RestAccessDeniedHandler restAccessDeniedHandler;
        private final MyAuthenticationFailureHandler myAuthenticationFailureHandler;

        @Bean
        public PasswordEncoder getPw() {
            return new BCryptPasswordEncoder();
        }


        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http.csrf().disable().authorizeRequests()
                    //允许所有的跨域请求
                    .requestMatchers(CorsUtils::isPreFlightRequest).permitAll()
                    .antMatchers("/toNoPermission", "/toLogin", "/login/**", "/logout/**", "/login.html","/oauth/**").permitAll()
                    .anyRequest().authenticated()
                    .and()
                    .formLogin().permitAll()
                    //自定义的认证成功处理
                    .successHandler(myAuthenticationSuccessHandler)
                    //自定义的认证失败处理
                    .failureHandler(myAuthenticationFailureHandler)
                    .loginPage("/toLogin")
                    .loginProcessingUrl("/login")
                    .and()
                    //禁用Session，非常非常关键，如果少了这一段，即在客户端第一次登录完成后后续即使没有token也能继续访问，因为它的sessionId被记录了下来
                    .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                    .disable()
    //                .and()
                    //在UsernamePasswordAuthenticationFilter拦截器前面添加一个自定义的token拦截器
                    .addFilterBefore(jwtAuthenticationTokenFilter, UsernamePasswordAuthenticationFilter.class)
                    .exceptionHandling()
                    //自定义的身份验证失败处理
                    .authenticationEntryPoint(entryPointUnauthorizedHandler)
                    //自定义的权限失败处理
                    .accessDeniedHandler(restAccessDeniedHandler)
                    .and()
                    .headers().cacheControl();
        }


        @Bean
        public CorsFilter corsFilter(){
            UrlBasedCorsConfigurationSource configurationSource = new UrlBasedCorsConfigurationSource();
            CorsConfiguration cors = new CorsConfiguration();
            cors.setAllowCredentials(true);
            cors.addAllowedOrigin("*");
            cors.addAllowedHeader("*");
            cors.addAllowedMethod("*");
            configurationSource.registerCorsConfiguration("/**", cors);
            return new CorsFilter(configurationSource);
        }

        @Bean
        @Override
        public AuthenticationManager authenticationManagerBean() throws Exception {
            return super.authenticationManagerBean();
        }

    }
    ~~~
* 注意，上面的授权服务器的端口是9000，下面需要配置一个客户端，偷懒用的是 oauth2client01-demo 就改了下配置,此处是client-id和client-secret也就是数据库对应的一条记录，<hl>虽然指定了授权码模式，但一旦分离好像就无关紧要了</hl>
    ~~~yaml
    server:
    port: 8083
    servlet:
        session:
        cookie:
            #防止cookie冲突，冲突会导致登录验证不通过
            name: OAUTH2-CLIENT-SESSIONID01
    # 授权服务器的地址，供下面的配置文件使用
    oauth2-server-url: http://localhost:9000
    # 与授权服务器对应的配置
    security:
    oauth2:
        client:
        client-id: noname
        client-secret: 123456
        # 授权URI
        user-authorization-uri: ${oauth2-server-url}/oauth/authorize
        # 获取token的URI
        access-token-uri: ${oauth2-server-url}/oauth/token
        resource:
        jwt:
            # 获取jwt的URI
            key-uri: ${oauth2-server-url}/oauth/token_key
    ~~~
* 客户的访问类，保持原样
    ~~~java
    @RestController
    @RequestMapping("/user")
    public class UserController {

        /**
        * 获取用户信息
        *
        * @param authentication
        * @return
        */
        @RequestMapping("/getCurrentUser")
        public Object getCurrentUser(Authentication authentication) {
            return authentication;
        }

    }
    ~~~
* 启动类上添加@EnableOAuth2Sso注解
    ~~~java
    @SpringBootApplication
    @EnableOAuth2Sso
    public class Oauth2client01DemoApplication {

        public static void main(String[] args) {
            SpringApplication.run(Oauth2client01DemoApplication.class, args);
        }

    }
    ~~~
* 验证一下，需要浏览器和postman
* 首先访问 localhost:8083/user/getCurrentUser，由于没有登录，自然是跳转到登录页面，输入账号密码则返回一个token。这个token是自己实现的，也就上 前后端分离  那一章的代码
* 用postman再次访问 localhost:8083/user/getCurrentUser,将token放入到Header中，key的名称也是在 前后端分离  那一章指定了的，此处指定的是：Authorization，然后就可以访问。<hl>访问成功以后有个问题就是此时删除的header,postman再次放松也能成功，暂时不知道怎么解决，也不确定后续是否有问题</hl>