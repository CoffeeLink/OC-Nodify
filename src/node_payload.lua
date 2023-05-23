---@author: Áron Demeter 2023-05-22 14:38:26
---@version: 1.0.0
---@description: The node payload classes

-- Path: src/node_payload.lua

---------------------------------------------
--imports
local serial = require("serialization")

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

--- Adds a field to the body
--- @param field Field The field to add
--- @return table The body with the field added
function Body:addField(field)
  checkVar(1, field, "table")
  table.insert(self.fields, field)
  return self
end

--- Sets the value of a field
--- @param fieldName string The name of the field
--- @param value any The value of the field
function Body:setField(fieldName, value)
  checkVar(1, fieldName, "string")
  checkVar(2, value, "any")
  -- loops through the fields table and sets the value of the field with a matching name, if it doesnt exist it creates a new field
  for _, field in ipairs(self.fields) do
    if field.name == fieldName then
      field.value = value
      return
    end
  end
  self:addField(Field.new(fieldName, value))
end

--- Gets the value of a field
--- @param fieldName string The name of the field
--- @return any value The value of the field nil if it doesnt exist
function Body:getField(fieldName)
  checkVar(1, fieldName, "string")
  -- loops through the fields table and returns the value of the field with a matching name, if it doesnt exist it returns nil
  for _, field in ipairs(self.fields) do
    if field.name == fieldName then
      return field.value
    end
  end
  return nil
end

--- Deletes a field from the body
--- @param fieldName string The name of the field
function Body:delField(fieldName)
  checkVar(1, fieldName, "string")
  -- loops through the fields table and deletes the field with a matching name, if it doesnt exist it does nothing
  for i, field in ipairs(self.fields) do
    if field.name == fieldName then
      table.remove(self.fields, i)
      return
    end
  end
end

--- Adds the body to a table
--- @return table The table with the body added
function Body:toTable()
  local table = {} -- output
  self.msg_type:addToTable(table)

  -- check if msg_id, msg_reply_to isnt empty, if it is dont add it to the table
  if self.msg_id.value ~= nil then
    self.msg_id:addToTable(table)
  end
  if self.msg_reply_to.value ~= nil then
    self.msg_reply_to:addToTable(table)
  end
  -- loop through the fields table and add them to the output table
  for _, field in ipairs(self.fields) do
    field:addToTable(table)
  end
  return table
end

--- Creates a new Body object from a table
--- @param table table The table to create the body from
--- @return table Body
function Body.fromTable(table)
  local body = Body.new(table.msg_type, table.msg_id, table.msg_reply_to)
  for key, value in pairs(table) do
    if key ~= "msg_type" and key ~= "msg_id" and key ~= "msg_reply_to" then
      body:addField(Field.new(key, value))
    end
  end
  return body
end

--Payload Class

---@class Payload : table The Message Payload class
---@field src string The source of the message
---@field dest string The destination of the message
---@field body Body The body of the message
---@field __index Payload
local Payload = {
  src = "",
  dest = "",
  body = Body,
}
Payload.__index = Payload

--- Creates a new Payload object
--- @param src string The source of the message
--- @param dest string The destination of the message
--- @param body Body The body of the message
--- @return table Payload
function Payload.new(src, dest, body)
  local self = setmetatable({}, Payload)
  checkVar(1, src, "string")
  checkVar(2, dest, "string")
  checkVar(3, body, "table")

  self.src = src
  self.dest = dest
  self.body = body
  return self
end

--- Creates a table from all fields like a json object
--- @return table The table with all fields
function Payload:toTable()
  local table = {} -- output
  table.src = self.src
  table.dest = self.dest
  table.body = self.body:toTable()
  return table
end

--- Creates a json string from all fields
--- @return string The json string
function Payload:serialize()
  return serial.serialize(self:toTable())
end

--- Creates a new Payload object from a table
--- @param table table The table to create the payload from
--- @return table Payload
function Payload.fromTable(table)
  return Payload.new(table.src, table.dest, Body.fromTable(table.body))
end

--- Module Class

---@class Node_Payloads : table The Node Payloads class
---@field Payload Payload The Payload class
---@field Body Body The Body class
---@field Field Field The Field class
---@field __index Node_Payloads
local Node_Payloads = {
  Payload = Payload,
  Body = Body,
  Field = Field,
}
Node_Payloads.__index = Node_Payloads

return Node_Payloads