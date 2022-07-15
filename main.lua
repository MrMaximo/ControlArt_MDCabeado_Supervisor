-- Including LuaSQL sqlite3 library
local driver = require('luasql.sqlite3')

-- TODO: First page selecting the database *.ca file

-- Read the entire database to discover all the modules
local env = driver.sqlite3()
local db = env:connect('./Alexandre.ca')        -- Esqpecificando o arquivo assim por não fazer a primeira parte ainda

-- Getting data from "module" table

local module = {}
local nModules = 0

-- DB MODULE
-- Selecting id, hdw_addr and serial_number from module
local mod_req = db:execute[[SELECT id, hdw_addr, serial_number FROM module;]]

local mod_id, mod_hdw_addr, serial_number = mod_req:fetch()
while mod_id do

    module[nModules] = {}
    module[nModules][0] = mod_id
    module[nModules][1] = mod_hdw_addr
    module[nModules][2] = serial_number
    
    -- DEBUG print('ID = ' .. module[nModules][0] .. ' | MAC = ' .. module[nModules][1] .. ' | Serial = ' .. module[nModules][2])
    mod_id, mod_hdw_addr, serial_number = mod_req:fetch()
    
    -- Incrementing number of modules
    nModules = nModules + 1
end

-- Getting data from "input" table

local input = {}

-- DB INPUT
-- Selecting name, module_id, idx from input

local inp_req = db:execute[[SELECT name, module_id, idx FROM input;]]

local inputName, inputModuleID, inputIDX = inp_req:fetch()
while inputName do

    input[inputModuleID] = {}
    input[inputModuleID][inputIDX] = inputName
    --print(  'NAME = ' .. input[inputModuleID][inputIDX] ..' | MODULE ID = ' .. inputModuleID ..' | IDX = ' .. inputIDX)
    inputName, inputModuleID, inputIDX = inp_req:fetch()
end

inp_req:close()

-- Getting data from "output" table

local output = {}

-- DB OUTPUT
-- Selecting name, module_id, idx from ouput

local out_req = db:execute[[SELECT name, module_id, idx FROM output;]]

local outputName, outputModuleID, outputIDX = out_req:fetch()
while outputName do

    input[outputModuleID] = {}
    input[outputModuleID][outputIDX] = outputName
    print(  'NAME = ' .. input[outputModuleID][outputIDX] .. ' | MODULE ID = ' .. outputModuleID .. ' | IDX = ' .. outputIDX)
    outputName, outputModuleID, outputIDX = out_req:fetch()
end

out_req:close()