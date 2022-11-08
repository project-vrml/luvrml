local mylibrary = require("group.rxcloud.luvrml.envoy.internal.foobar")

function envoy_on_request(request_handle)
    request_handle:headers():add("foo", mylibrary.foobar())
end

function envoy_on_response(response_handle)
    body_size = response_handle:body():length()
    response_handle:headers():add("foo", mylibrary.foobar())
    response_handle:headers():add("response-body-size", tostring(body_size))
end