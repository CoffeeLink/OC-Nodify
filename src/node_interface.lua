---@author: Áron Demeter 2023-05-24 14:49:33
---@version: 1.0.0
---@description: The node interface class

-- Path: src/node_interface.lua

---------------------------------------------
local computer = require("computer")
local thread = require("thread")

local np = require("node_payload")
local Payload = np.Payload  ---for typing reasons 
local Field = np.Field  ---for typing reasons
local Body = np.Body  ---for typing reasons

---Interface Master class

---@class NodeInterface : table The Node Interface class responsible for communication between nodes
---@field node table The node object
---@field recvThread table The thread that recives data
---@field __index NodeInterface
local NodeInterface = {
    node = {},
    recvThread = {},
    recived = {}, ---@type Payload[] The recived messages
    recivedLimit = 45, ---@type number The max ammount of recived payload cached
}
NodeInterface.__index = NodeInterface

--- Sets the node object
--- @param node table The node object
function NodeInterface:setNode(node)
    self.node = node
end

--- Sends a payload to the node
--- @param payload Payload The payload to send
function NodeInterface:send(payload)
    -- something that sends data i guess
end

--- Recives a payload from the node
--- @return Payload Payload The recived payload
function NodeInterface:recv()
    while true do
        if #self.recived > 0 then
            local data = self.recived[1]
            table.remove(self.recived, 1)
            return data
        end
        computer.pullSignal(0.01)
    end
end

function NodeInterface:recv_thread_func()
    while true do
        -- something that recives data i guess
        -- table.insert(self.recived, your data)
    end
end

--- Starts the NodeInterface's threads, gets called when the node starts
function NodeInterface:start()
    self.recvThread = thread.create(self.recv_thread_func, self)
end

--- Stops the NodeInterface's threads, gets called when the node stops
function NodeInterface:stop()
    self.recvThread:kill()
end

--- returning func
return NodeInterface