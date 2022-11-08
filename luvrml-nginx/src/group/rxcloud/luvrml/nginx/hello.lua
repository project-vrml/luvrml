--启用cjson处理json
gcjson = require("cjson");

--获取请求参数值
local requestmap = ngx.req.get_uri_args();

--为了解决不同请求见参数重名的问题，通过唯一key记录每个请求param-value
local req_a = "/api/a.json";
if requestmap["akey"] and requestmap["akey"] ~= "" then
    req_a = req_a .. "?" .. requestmap["akey"];
    ngx.say("akey:" .. requestmap["akey"])
end
local req_b = "/api/b.json";
if requestmap["bkey"] and requestmap["bkey"] ~= "" then
    req_a = req_a .. "?" .. requestmap["bkey"];
    ngx.say("bkey:" .. requestmap["bkey"])
end
local req_c = "/api/c.json";
if requestmap["ckey"] and requestmap["ckey"] ~= "" then
    req_a = req_a .. "?" .. requestmap["ckey"];
    ngx.say("ckey:" .. requestmap["ckey"])
end

--location.capture_multi发送请求到后端服务器
--如果存在跳转，则返回0
--否则，拼装json报文并返回客户端
local requestArray = { { req_a }, { req_b }, { req_c } };
local res_a, res_b, res_c = ngx.location.capture_multi(requestArray);
if res_a and res_a.status == ngx.HTTP_MOVED_TEMPORARILY then
    ngx.say("0");
    do
        return
    end ;
end
if res_b and res_b.status == ngx.HTTP_MOVED_TEMPORARILY then
    ngx.say("0");
    do
        return
    end ;
end
if res_c and res_c.status == ngx.HTTP_MOVED_TEMPORARILY then
    ngx.say("0");
    do
        return
    end ;
end

local data = {};

if res_a and res_a.status == ngx.HTTP_OK then
    data["akey"] = res_a.body;
end ;
if res_b and res_b.status == ngx.HTTP_OK then
    data["bkey"] = res_b.body;
end ;
if res_c and res_c.status == ngx.HTTP_OK then
    data["ckey"] = res_c.body;
end ;

ngx.say(gcjson.encode(data));