# luvrml

## 一、Lua 简介

Lua是一个小巧的脚本语言。作者是巴西人。该语言的设计目的是为了嵌入应用程序中，从而为应用程序提供灵活的扩展和定制功能。

Lua 的优点就是小巧，核心代码不过一万几多行。高效，弱类型，可以调用 C 的共享库，就是抓来 C 代码，用 lua api 的命名改改，就可以直接使用 C 代码写的函数了。

Lua 脚本也可以很容易的被 C/C++ 代码调用，这使得 Lua 在应用程序中可以被广泛应用。不仅仅作为扩展脚本，也可以作为普通的配置文件，代替 XML,Ini 等文件格式，并且更容易理解和维护。

Lua由标准 C 编写而成，代码简洁优美，几乎在所有操作系统和平台上都可以编译，运行。

**一个完整的 Lua 解释器不过200k，在目前所有脚本引擎中，Lua 的速度是最快的。这一切都决定了 Lua 是作为嵌入式脚本的最佳选择。**

### Lua特性：

+ 轻量级：它用标准C语言编写并以源代码形式开放，编译后仅仅一百余K，可以很方便的嵌入别的程序里。
+ 可扩展：Lua提供了非常易于使用的扩展接口和机制：由宿主语言(通常是C或C++)提供这些功能，Lua可以使用它们，就像是本来就内置的功能一样。

#### 其它特性：

+ 支持面向过程(procedure-oriented)编程和函数式编程(functional programming)；
+ 自动内存管理；只提供了一种通用类型的表（table），用它可以实现数组，哈希表，集合，对象； 
+ 语言内置模式匹配；闭包(closure)；函数也可以看做一个值；提供多线程（协同进程，并非操作系统所支持的线程）支持； 
+ 通过闭包和table可以很方便地支持面向对象编程所需要的一些关键机制，比如数据抽象，虚函数，继承和重载等。

### Lua 应用场景：

+ 游戏开发
+ 独立应用脚本
+ Web应用脚本
+ 扩展和数据库插件如：MySQL Proxy 和 MySQL WorkBench
+ 安全系统，如入侵检测系统

## Lua与Go对比：

Apache APISIX 是一个动态、实时、高性能的开源 API 网关，提供负载均衡、动态上游、灰度发布、服务熔断、身份认证、可观测性等丰富的流量管理功能。Apache APISIX 可以快速、安全地处理 API 和微服务流量，包括网关、Kubernetes Ingress和服务网格等。

+ Apache APISIX GitHub：github.com/apache/apis…
+ Apache APISIX 官网：apisix.apache.org
+ Apache APISIX 文档：apisix.apache.org/zh/docs/api…

事实上，Apache APISIX 采用的技术栈并不是纯粹的 Lua，准确来说，应该是 Nginx + Lua。Apache APISIX 以底下的 Nginx 为根基，以上层的 Lua 代码为枝叶。

严谨认真的朋友会指出，Apache APISIX 并非基于 Nginx + Lua 的技术栈，而是 Nginx + LuaJIT （又称 OpenResty，以下为了避免混乱，会仅仅采用 Nginx + Lua 这样的称呼）。

LuaJIT 是 Lua 的一个 JIT 实现，性能比 Lua 好很多，而且额外添加了 FFI 的功能，能方便高效地调用 C 代码。

由于现行的主流 API 网关，如果不是基于 OpenResty 实现，就是使用 Go 编写，所以时不时会看到各种 Go 和 Lua 谁的性能更好的比较。脱离场景比较语言的性能，是没有意义的。

首先明确一点，Apache APISIX 是基于 Nginx + Lua 的技术栈，只是外层代码用的是 Lua。所以如果要论证哪种网关性能更好，正确的比较对象是 C + LuaJIT 跟 Go 的比较。网关的性能的大头，在于代理 HTTP 请求和响应，这一块的工作主要是 Nginx 在做。所以倘若要比试比试性能，不妨比较 Nginx 和 Go 标准库的 HTTP 实现。

众所周知，Nginx 是一个 bytes matter 的高性能服务器实现，对内存使用非常抠门。随便举两个例子：

+ Nginx 里面的 request header 在大多数时候都只是指向原始的 HTTP 请求数据的一个指针，只有在修改的时候才会创建副本。
+ Nginx 代理上游响应时对 buffer 的复用逻辑非常复杂，是我读过的最为烧脑的代码之一。
+ 
凭借这种抠门，Nginx 得以屹立在高性能服务器之巅。

相反的，Go 标准库的 HTTP 实现，是一个滥用内存的典型反例。这可不是我的一面之辞，Fasthttp，一个重新实现 Go 标准库里面的 HTTP 包的项目，就举了两个例子：

+ 标准库的 HTTP Request 结构体没法复用
+ headers 总是被提前解析好，存储成 map[string][]string，即使没有用到（原文见：github.com/valyala/fas…）

Fasthttp文档里面还提到一些 bytes matter 的优化技巧，建议大家可以阅读下。

事实上，即使不去比较作为网关核心的代理功能，用 LuaJIT 写的代码不一定比 Go 差多少。

原因有二：

其一，拜 Lua 跟 C 良好的亲和力所赐，许多 Lua 的库核心其实是用 C 写的。

其二，LuaJIT 的 JIT 优化无出其右。

讨论动态语言的性能，可以把动态语言分成两类，带 JIT 和不带 JIT 的。JIT 优化能够把动态语言的代码在运行时编译成机器码，进而把原来的代码的性能提升一个数量级。

带 JIT 的语言还可以分成两类，能充分 JIT 的和只支持部分 JIT 的。而 LuaJIT 属于前者。

人所皆知，Lua 是一门非常简单的语言。

相对鲜为人知的是，LuaJIT 的作者 Mike Pall 是一个非常厉害的程序员。

这两者的结合，诞生了 LuaJIT 这种能跟 V8 比肩的作品。（关于 LuaJIT 和 V8 到底谁更快，一直是长盛不衰的争论话题。）

展开讲 LuaJIT 的 JIT 已经超过了本文想要讨论的范畴。简单来说，JIT 加持的 LuaJIT 跟预先编译好的 Go 性能差别并不大。

至于谁比谁慢，慢多少，那就是个见仁见智的问题了。