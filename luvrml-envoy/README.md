## Lua 过滤器

在这个例子中，我们会展示 Lua 过滤器在 Envoy 代理中是如何使用的。 
Envoy 代理配置包括一个 Lua 过滤器，此过滤器包含了在 这个 文档中记录的两个函数，即：

+ envoy_on_request(request_handle)
+ envoy_on_response(response_handle)