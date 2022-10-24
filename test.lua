-- Including LuaSQL sqlite3 library
local driver = require('luasql.sqlite3')

-- Including Lua Socket library
local socket = require('socket')

-- Read the entire database to discover all the modules
local env = driver.sqlite3()
--local db = env:connect('./Alexandre.ca')        -- Esqpecificando o arquivo assim por não fazer a primeira parte ainda
local db = env:connect('./MD_Teste.ca')        -- Esqpecificando o arquivo assim por não fazer a primeira parte ainda

-- Getting data from "module" table

local modules = {}
local nModules = 0

-- DB MODULE
-- Selecting id, hdw_addr and serial_number from module
local mod_req = db:execute[[SELECT id, hdw_addr, serial_number FROM module;]]

local mod_id, mod_hdw_addr, serial_number = mod_req:fetch()
while mod_id do

    modules[nModules] = {}
    modules[nModules][0] = mod_id
    modules[nModules][1] = mod_hdw_addr
    modules[nModules][2] = serial_number
    
    -- DEBUG print('ID = ' .. module[nModules][0] .. ' | MAC = ' .. module[nModules][1] .. ' | Serial = ' .. module[nModules][2])
    mod_id, mod_hdw_addr, serial_number = mod_req:fetch()
    
    -- Incrementing number of modules
    nModules = nModules + 1
end

mod_req:close()
-- Getting data from "input" table

local input = {}

-- DB INPUT
-- Selecting name, module_id, idx from input

local inp_req = db:execute[[SELECT id, name, module_id, idx FROM input;]]

local id, inputName, inputModuleID, inputIDX = inp_req:fetch()

local sameID = 0
while id do

    if (sameID ~= inputModuleID) then
        sameID = inputModuleID
        input[inputModuleID] = {}
    end
    input[inputModuleID][inputIDX] = inputName
    -- DEBUG print(  'NAME = ' .. input[1][0] ..' | MODULE ID = ' .. inputModuleID ..' | IDX = ' .. inputIDX)
    id, inputName, inputModuleID, inputIDX = inp_req:fetch()
end

inp_req:close()

-- Getting data from "output" table

local output = {}

-- DB OUTPUT
-- Selecting name, module_id, idx from ouput

local out_req = db:execute[[SELECT name, module_id, idx FROM output;]]

local outputName, outputModuleID, outputIDX = out_req:fetch()
sameID = 0
while outputName do

    if (sameID ~= outputModuleID) then
        sameID = outputModuleID
        output[outputModuleID] = {}
    end
    output[outputModuleID][outputIDX] = outputName
    --print(  'NAME = ' .. input[outputModuleID][outputIDX] .. ' | MODULE ID = ' .. outputModuleID .. ' | IDX = ' .. outputIDX)
    outputName, outputModuleID, outputIDX = out_req:fetch()
end

out_req:close()



local ip_addr = '192.168.15.100'
local port = 4998

-- Connecting to client
local client = socket.connect(ip_addr, port)

if client then
    print('Connected')
    client:send('mdcmd_sendrele,0x65,0x5B,0x7C,0,0\r\n')
else 
    print('Offline')
end

repeat
    -- Find MAC Address
    local r = client:receive()
    local rec_mac = string.sub(r,9,16)

    -- Find Inputs
    local rec_inp = {}
    local r_i = string.gsub(string.sub(r,18,40), ",", "")
    for i = 0, 12 do
        -- if (string.sub(r_i,i+1,i+1) == "0") then
        --     rec_inp[i] = 0
        -- else
        --     rec_inp[i] = 1
        -- end
        rec_inp[i] = tonumber(string.sub(r_i,i+1,i+1))
    end

    -- DEBUG print(rec_inp[0].. " " .. rec_inp[1].. " "..rec_inp[2].. " "..rec_inp[3].. " "..rec_inp[4].. " "..rec_inp[5].. " ")

    -- Find Outputs
    local rec_out = {}
    local r_o = string.sub(r,42)
    for i = 0, 8 do
        local index = string.find(r_o,",")
        rec_out[i] = tonumber(string.sub(r_o,1, (index-1)))
        if (i < 7) then r_o = string.sub(r_o, index+1) end
    end

    -- DEBUG print(rec_out[0].. " " .. rec_out[1].. " "..rec_out[2].. " "..rec_out[3].. " "..rec_out[4].. " "..rec_out[5].. " ")

    -- Find module
    local isMod = -1
    for i = 0, nModules do
        
        if(modules[i][1] == rec_mac) then
            isMod = i
            break
        end
    end
    print("mod: ".. isMod)

until not client


-- COMPARAR AS ENTRADAS E AS SAIDAS
 
