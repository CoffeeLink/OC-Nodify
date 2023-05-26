---@author: Áron Demeter 2023-05-26 12:52:47
---@version: 1.0.0
---@description: a module for the node class

-- Path src/node.lua

---------------------------------------------
--imports
local serial = require("serialization")
local thread = require("thread")

local nodeInterface = require("node_interface")
local np = require("node_payload")
local Payload = np.Payload
local Field = np.Field
local Body = np.Body


---Node class
local Node = {
    name = "", ---@type string The name of the node
    id = "", ---@type string The id of the node
    interface = {}, ---@type NodeInterface The node interface
    eventListeners = {}, ---@type table<string, function[]> The event listeners
}
Node.__index = Node

--- Creates a new Node object
--- @param name string the name of the node
--- @param nodeInterface NodeInterface The interface the node will use
--- @return table : Node
function Node.new(name, nodeInterface)
    local self = setmetatable({}, Node)
    self.name = name
    self.id = ""
    self.interface = nodeInterface
    self.eventListeners = {}
    
    self.interface:setNode(self)

    return self
end

function Node:listen()
    while true do
        local payload = self.interface:recv()
        if payload == nil then
            goto continue
        end
        if self.eventListeners[payload.body.msg_type.value] == nil then
            goto continue
        end
        if #self.eventListeners[payload.body.msg_type.value] == 0 then
            goto continue
        end

        for _, event_callback in pairs(self.eventListeners[payload.body.msg_type.value]) do
            event_callback(payload) 
        end

        :: continue ::
    end
end

---Adds an event listener
---@param name string The name of the event
---@param callback function<Payload> The callback function
function Node:addEvent(name, callback)
    if self.eventListeners[name] == nil then
        self.eventListeners[name] = {}
    end
    table.insert(self.eventListeners[name], callback)
end

---Removes an event listener
---@param name string the name of the event
---@param callback function<Payload> the event listener to remove
function Node:removeEvent(name, callback)
    if self.eventListeners[name] == nil then
        return
    end
    for i, event_callback in pairs(self.eventListeners[name]) do
        if event_callback == callback then
            table.remove(self.eventListeners[name], i)
        end
    end
end

--- Sends a body to the destination
--- @param destination string the ID of the destination Node
function Node:send(destination, body)
    local payload = Payload.new(self.id, destination, body)
    self.interface:send(payload)
end

---Starts the node, this blocks exec
function Node:start()
    self.interface:start()
    self:listen()
    self:on_start()
end

function Node:on_init(payload)
    self.id = payload.body.fields["node_id"].value
end

function Node:on_start()
    return
end

--- an Overide for sending Payloads
---@param payload Payload The pyload that will be setNode
---@return Payload Payload The overwritten payload
function Node:on_send(payload)
    return payload
end

return Node