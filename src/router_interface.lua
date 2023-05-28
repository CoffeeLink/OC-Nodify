---@author: Áron Demeter 2023-05-28 18:21:15
---@version: 1.0.0
---@description: The router interface class

-- Path: src/router_interface.lua

---------------------------------------------

--imports

local computer = require("computer")
local thread = require("thread")

local np = require("node_payload")
local Payload = np.Payload  ---for typing reasons 
local Field = np.Field  ---for typing reasons
local Body = np.Body  ---for typing reasons

local components = require("component")
local modem = components.modem

local serial = require("serialization")


-- The router interface classes

local RouterInterface = {
    address = "",
    port = 0,
    recvThread = nil, ---@type thread The thread that recives data
    recived = {}, ---@type Payload[] The recived messages
    recivedLimit = 45, ---@type number The max ammount of recived payload cached 
}

--- Creates a new RouterInterface object
--- @param port number The port of the Router Modem
--- @return table RouterInterface
function RouterInterface.new(port)
    local self = setmetatable({}, RouterInterface)
    self.port = port

    return self
end

function RouterInterface:start()
    modem.open(self.port)
    self.recvThread = thread.create(self.recv_thread_func, self)
end

function RouterInterface:stop()
    modem.close(self.port)
    self.recvThread:kill()
end

function RouterInterface:recv_thread_func()
    while true do
        local _, _, from, port, _, message = computer.pullSignal("modem_message")
        if port == self.port then
            local payload = message
            table.insert(self.recived, payload)
            if #self.recived > self.recivedLimit then
                table.remove(self.recived, 1)
            end
        end
    end
end

function RouterInterface:send(addr, port, payload)
    modem.send(addr, port, serial.serialize(payload))
end

function RouterInterface:recv()
    while true do
        if #self.recived > 0 then
            local data = self.recived[1]
            table.remove(self.recived, 1)
            return data
        end
        computer.pullSignal(0.01)
    end
end

return RouterInterface