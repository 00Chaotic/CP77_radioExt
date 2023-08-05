local config = require("modules/utils/config")
local Cron = require("modules/utils/Cron")

local radioManager = {}

function radioManager:new(radioMod)
	local o = {}

    o.rm = radioMod
    o.radios = {}
    o.initialized = false

    o.isMounted = false

	self.__index = self
   	return setmetatable(o, self)
end

function radioManager:getSongLengths(radioName)
    local songs = {}

    for _, file in pairs(dir("radios/" .. radioName .. "/")) do
        local extension = file.name:match("^.+(%..+)$")
        if extension == ".flac" or extension == ".mp2" or extension == ".mp3" or extension == ".ogg" or extension == ".wav" or extension == ".wax" or extension == ".wma" then
            local length = RadioExt.GetSongLength("plugins\\cyber_engine_tweaks\\mods\\radioExt\\radios\\" .. radioName .. "\\" .. file.name)
            if length ~= 0 then
                songs[radioName .. "\\" .. file.name] = length / 1000
            end
        end
    end

    return songs
end

function radioManager:backwardsCompatibility(metadata)
    if metadata.customIcon == nil then
        metadata.customIcon = {
            ["useCustom"] = false,
            ["inkAtlasPath"] = "",
            ["inkAtlasPart"] = ""
        }

        config.saveFile("radios/" .. path .. "/metadata.json", metadata)
    end

    if metadata.streamInfo == nil then
        metadata.streamInfo = {
            isStream = false,
            streamURL = ""
        }

        config.saveFile("radios/" .. path .. "/metadata.json", metadata)
    end

    if metadata.order == nil then
        metadata.order = {}

        config.saveFile("radios/" .. path .. "/metadata.json", metadata)
    end
end

function radioManager:loadRadios() -- Loads radios
    self.initialized = false

    local radios = RadioExt.GetFolders("plugins\\cyber_engine_tweaks\\mods\\radioExt\\radios")
    if not radios then return end

    for _, path in pairs(radios) do
        if not config.fileExists("radios/" .. path .. "/metadata.json") then
            print("[RadioMod] Could not find metadata.json file in \"radios/" .. path .. "\"")
        else
            local songs = self:getSongLengths(path)
            local metadata
            local success = pcall(function ()
                metadata = config.loadFile("radios/" .. path .. "/metadata.json")
            end)

            if success then
                self:backwardsCompatibility(metadata)

                local r = require("modules/radioStation"):new(self.rm)
                r:load(metadata, songs, path)
                self.radios[#self.radios + 1] = r
            else
                print("[RadioMod] Error: Failed to load the metadata.json file for \"" .. path .. "\". Make sure the file is valid.")
            end
        end
    end

    self.initialized = true

    return true
end

function radioManager:getRadioByName(name)
    for _, radio in pairs(self.radios) do
        if name == radio.name then
            return radio
        end
    end

    return nil
end

function radioManager:switchToRadio(radio)
    if radio.active then return end
    self:disableCustomRadio()
    Cron.After(0.1, function()
        if GetMountedVehicle(GetPlayer()) then
            GetMountedVehicle(GetPlayer()):GetBlackboard():SetBool(GetAllBlackboardDefs().Vehicle.VehRadioState, true)
            GetMountedVehicle(GetPlayer()):GetBlackboard():SetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, radio.name)
        end
        radio:activate()
    end)
end

function radioManager:disableCustomRadio() -- Disables all custom radios, vehicle and physical
    for _, radio in pairs(self.radios) do
        radio:deactivate()
    end
end

function radioManager:update()
    local veh = GetMountedVehicle(GetPlayer())
    if veh then
        self.isMounted = true
        if veh:IsEngineTurnedOn() then
            local name = veh:GetBlackboard():GetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName)
            local radio = self:getRadioByName(name.value)

            if radio and not radio.active then
                radio:activate()
            end
        end
    elseif self.isMounted then
        self.isMounted = false
        self:disableCustomRadio()
    end
end

function radioManager:handleMenu()
    local veh = GetMountedVehicle(GetPlayer())
    if not veh then return end

    local name = veh:GetBlackboard():GetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName)
    local radio = self:getRadioByName(name.value)

    if radio then
        if radio.active then
            radio:deactivate()
        end
    end
end

function radioManager:handleTS() -- trainSystem comp
    if self.rm.runtimeData.ts then
        if not self.rm.runtimeData.ts.stationSys then return end
        local train = self.rm.runtimeData.ts.stationSys.activeTrain
        if train and train.playerMounted then
            for _, radio in pairs(self.radios) do
                if radio.active then
                    GetMountedVehicle(GetPlayer()):ToggleRadioReceiver(false)
                end
            end
        end
    end
end

return radioManager