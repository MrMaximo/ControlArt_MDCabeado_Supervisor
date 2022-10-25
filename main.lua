-- Including LuaSQL sqlite3 library
local driver = require('luasql.sqlite3')

-- Including Lua Socket library
local socket = require('socket')

-- Including FLTK library
local gui = require('fltk4lua')

-- TODO: First page selecting the database *.ca file

-- Read the entire database to discover all the modules
local env = driver.sqlite3()
local db = env:connect('./Alexandre.ca')        -- Esqpecificando o arquivo assim por não fazer a primeira parte ainda
--local db = env:connect('./MD_Teste.ca')        -- Esqpecificando o arquivo assim por não fazer a primeira parte ainda

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
    -- DEBUG print(  'NAME = ' .. input[outputModuleID][outputIDX] .. ' | MODULE ID = ' .. outputModuleID .. ' | IDX = ' .. outputIDX)
    outputName, outputModuleID, outputIDX = out_req:fetch()
end

out_req:close()

-- Creating GUI based on previous database

-- Window Settings
local conf_wind = {
    label = "ControlArt - MDimmer Supervisório",
    xywh = {1385, 73, 770, 320}
}

-- Tab Settings
local conf_tab = {
    xywh = {10, 10, 750, 300}
}

-- Gruops Settings
local conf_group =  {
    label = "M ",
    xywh = {10, 40, 750, 300}
}

-- Buttons Settings
local conf_botoes = {
    label = "LIGAR TODAS",
    xywh = {590, 200, 150, 35},
    box = "FL_PLASTIC_UP_BOX",
    down_box = "FL_PLASTIC_DOWN_BOX"
}

-- Input Settings
local conf_indic = {
    label = "IN ",
    xywh = {35, 120, 26, 26},
    box = "FL_PLASTIC_ROUND_UP_BOX",
    color = 1,
    labeltype = "FL_NORMAL_LABEL",
    align = "FL_ALIGN_BOTTOM"
}

-- Output Settings
local conf_lamps = {
    xywh = {35, 220, 32, 32},
    label = "OUT ",
    box = "FL_PLASTIC_ROUND_UP_BOX",
    labeltype = "FL_NORMAL_LABEL",
    align = "FL_ALIGN_BOTTOM",
    color = 2,
}


-- Creating window
local janela = gui.Window(conf_wind.xywh[3], conf_wind.xywh[4], conf_wind.label)

-- Creating tab
local tab = gui.Tabs(conf_tab.xywh[1], conf_tab.xywh[2], conf_tab.xywh[3], conf_tab.xywh[4])

-- Creating array of groups
local grupo = {} 

-- Creating array of indicators
local indicators = {}

-- Creating array of lamps
local lamps = {}

for i = 0, nModules-1 do

    grupo[i] = {}
    grupo[i] = gui.Group(conf_group.xywh[1],
                            conf_group.xywh[2],
                            conf_group.xywh[3],
                            conf_group.xywh[4],
                            conf_group.label .. modules[i][0])

    local text1 = gui.Box(80, 60, 240, 30, "MAC: " .. modules[i][1])
    text1.labelfont = 1
    text1.labelsize = 20

    indicators[i] = {}
    for j = 0, 11 do
       local newIndic = gui.Button(conf_indic.xywh[1] + j*60,
                              conf_indic.xywh[2],
                              conf_indic.xywh[3],
                              conf_indic.xywh[4],
                              conf_indic.label .. j+1)
       newIndic.box = conf_indic.box
       newIndic.color = conf_indic.color
       newIndic.labeltype = conf_indic.labeltype
       newIndic.align = conf_indic.align
       newIndic.tooltip = input[modules[i][0]][j]
       indicators[i][j] = newIndic
    end

    lamps[i] = {}

    for j = 0, 8, 1 do
        
        local newButton = gui.Button(conf_lamps.xywh[1] + j*60,
                                    conf_lamps.xywh[2],
                                    conf_lamps.xywh[3],
                                    conf_lamps.xywh[4],
                                    conf_lamps.label .. j+1)
        newButton.box = conf_lamps.box
        newButton.color = conf_lamps.color
        newButton.labeltype = conf_lamps.labeltype
        newButton.align = conf_lamps.align
        newButton.tooltip = output[modules[i][0]][j]
        lamps[i][j] = newButton
    end

    -- Criando os Botões
    local botoes = {}
    botoes[i] = {}

    botoes[i][0] = gui.Button(conf_botoes.xywh[1], conf_botoes.xywh[2], conf_botoes.xywh[3], conf_botoes.xywh[4], conf_botoes.label)
    botoes[i][0].box = conf_botoes.box
    botoes[i][0].down_box = conf_botoes.down_box

    -- TOOLTIPS PODEM SER ADCIONADAS DESTA MANEIRA

    botoes[i][1] = gui.Button(conf_botoes.xywh[1], conf_botoes.xywh[2]+40, conf_botoes.xywh[3], conf_botoes.xywh[4], "DES" .. conf_botoes.label)
    botoes[i][1].box = conf_botoes.box
    botoes[i][1].down_box = conf_botoes.down_box

    grupo[i]:end_group()
end
-- Make resizable
-- janela.resizable = janela

-- Fechando Aba
tab:end_group()
-- Fechando Janela
janela:end_group()

-- Exibindo Janela
janela:show()
gui:redraw()
gui.wait(1)
gui.run()

-- --janela:show()

-- -- Making connection
-- local ip_addr = '192.168.15.100'
-- local port = 4998

-- -- Connecting to client
-- local client = socket.connect(ip_addr, port)

-- if client then
--     print('Connected')
--     --client:send('mdcmd_sendrele,0x65,0x5B,0x7C,0,0\r\n')
-- else 
--     print('Offline')
-- end

-- repeat
--     -- Find MAC Address
--     local r = client:receive()
--     local rec_mac = string.sub(r,9,16)

--     -- Find Inputs
--     local rec_inp = {}
--     local r_i = string.gsub(string.sub(r,18,40), ",", "")
--     for i = 0, 12 do rec_inp[i] = tonumber(string.sub(r_i,i+1,i+1)) end

--     -- DEBUG print(rec_inp[0].. " " .. rec_inp[1].. " "..rec_inp[2].. " "..rec_inp[3].. " "..rec_inp[4].. " "..rec_inp[5].. " ")

--     -- Find Outputs
--     local rec_out = {}
--     local r_o = string.sub(r,42)
--     for i = 0, 8 do
--         local index = string.find(r_o,",")
--         rec_out[i] = tonumber(string.sub(r_o,1, (index-1)))
--         if (i < 7) then r_o = string.sub(r_o, index+1) end
--     end

--     -- DEBUG print(rec_out[0].. " " .. rec_out[1].. " "..rec_out[2].. " "..rec_out[3].. " "..rec_out[4].. " "..rec_out[5].. " ")

--     -- Find module
--     local isMod = -1
--     for i = 0, nModules do       
--         if(modules[i][1] == rec_mac) then
--             isMod = i
--             break
--         end
--     end
--     -- print("mod: ".. isMod+1)

--     for i = 0, 11 do
--         -- RED = 1 and GREEN = 2
--         indicators[isMod][i].color = (rec_inp[i]+1)
--     end

--     gui:redraw()
--     gui.wait(1)
-- until not client