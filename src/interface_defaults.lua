---@author: Áron Demeter 2023-05-28 17:36:08
---@version: 1.0.0
---@description: Provides some built in interface options

-- Path: src/interface_defaults.lua

---------------------------------------------
--imports

local interface = require("node_interface")
local np = require("node_payload")
local Payload = np.Payload
local Field = np.Field
local Body = np.Body

local components = require("component")
local modem = components.modem

local computer = require("computer")
local thread = require("thread")
local serial = require("serialization")

-- The node interface classes

local ModemInterface = {
    address = "",
    port = 0,
    node = {},
    recvThread = {},
    recived = {}, ---@type Payload[] The recived messages
    recivedLimit = 45, ---@type number The max ammount of recived payload cached
}

--- Creates a new ModemInterface object
--- @param address string The address of the Router Modem
--- @param port number The port of the Router Modem
--- @return table ModemInterface
function ModemInterface.new(address, port)
    local self = setmetatable(ModemInterface, interface)
    self.address = address
    self.port = port

    return self
end

function ModemInterface:start()
    modem.open(self.port)
    self.recvThread = thread.create(self.recv_thread_func, self)
    -- connets
    self:send("NC")
end

function ModemInterface:stop()
    self:send("DC")
    modem.close(self.port)
    self.recvThread:kill()
end

function ModemInterface:recv_thread_func()
    while true do
        local _, _, from, port, _, message = computer.pullSignal("modem_message")
        if port == self.port and self.address == from then  -- if the message is from the router address and port
            if message == nil then
                goto continue
            end
            if not pcall(function() message = Payload.fromTable(message) end) then
                goto continue
            end

            local msg = Payload.fromTable(message)
            table.insert(self.recived, msg)
        end

        :: continue ::  -- continue statement
    end
end

function ModemInterface:send(data)
    modem.send(self.address, self.port, data)
end

return ModemInterface