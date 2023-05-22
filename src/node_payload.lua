---@author: Áron Demeter 2023-05-22 14:38:26
---@version: 1.0.0
---@description: The node payload classes

-- Path: src/node_payload.lua

---------------------------------------------
-- The node payload classes

---@class Field : table The Message Field class
---@field name string The name of the field
---@field value any The value of the field
local Field = {
  name = "",
  value = ""
}
Field.__index = Field


--- Creates a new Field object
--- @param name string The name of the field
--- @param value? any The value of the field
--- @return table Field
function Field.new(name, value)
  local self = setmetatable({}, Field)
  self.name = name
  self.value = value
  return self
end

--- Adds the field to a table
--- @param table table The table to add the field to
--- @return table The table with the field added
function Field:addToTable(table)
  table[self.name] = self.value
  return table
end

--Body Class

---@class Body : table The Message Body class
---@field msg_type Field The message type
---@field msg_id Field The message id
---@field msg_reply_to Field The message reply id
---@field __index Body
local Body = {
  msg_type = Field.new("msg_type", ""),
  msg_id = Field.new("msg_id", ""),
  msg_reply_to = Field.new("msg_reply_to", ""),

  fields = {} ---@type table<Field>
}
Body.__index = Body

--- Creates a new Body object
--- @param msg_type string The message type
--- @param msg_id? string The message id
--- @param msg_reply_id? string The message reply id
--- @return table Body
function Body.new(msg_type, msg_id, msg_reply_id)
  local self = setmetatable({}, Body)
  checkVar(1, msg_type, "string")
  
  self.msg_type.value = msg_type
  self.msg_id.value = msg_id
  self.msg_reply_to.value = msg_reply_id
  return self
end
