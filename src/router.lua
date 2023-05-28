---@author: Áron Demeter 2023-05-28 18:30:20
---@version: 1.0.0
---@description: The router class

-- Path: src/router.lua

---------------------------------------------
--imports

local serial = require("serialization")
local thread = require("thread")
local interface = require("router_interface")
local np = require("node_payload")
local Payload = np.Payload
local Field = np.Field
local Body = np.Body

local computer = require("computer")
local component = require("component")
local modem = component.modem

local router = {
    clients = {}, ---@type table<string, table> The clients connected to the router
}