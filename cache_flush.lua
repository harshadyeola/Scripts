local sock = ngx.socket.tcp()
 
sock:settimeout(1000)   -- one second
 
local ok, err = sock:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end


local bytes, err = sock:send("flush_all\r\n")
if not bytes then
    ngx.say("failed to send query: ", err)
    return
end
 
local line, err = sock:receive()
if not line then
    ngx.say("failed to receive a line: ", err)
    return
end
 
ngx.say("result: ", line)


local ok, err = sock:setkeepalive(60000, 500)
if not ok then
    ngx.say("failed to put the connection into pool "
        .. "with pool capacity 500 "
        .. "and maximal idle time 60 sec")
    return
end