local Cron   = require("modules/utils/Cron")

local managerV = {}

function managerV:new(manager, radioMod)
	local o = {}

    o.manager = manager
    o.radios = {}
    o.isMounted = false
    o.rm = radioMod

	self.__index = self
   	return setmetatable(o, self)
end

function managerV:getRadioByName(name)
    return self.manager:getRadioByName(name)
end

function managerV:switchToRadio(radio) -- Set avtiveRadio var to the radio object
    if radio.channels[-1] then return end
    self:disableCustomRadio()
    Cron.After(0.1, function()
        if GetMountedVehicle(GetPlayer()) then
            GetMountedVehicle(GetPlayer()):GetBlackboard():SetBool(GetAllBlackboardDefs().Vehicle.VehRadioState, true)
            GetMountedVehicle(GetPlayer()):GetBlackboard():SetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, radio.name)
        end
        radio:activate(-1)
    end)
end

function managerV:disableCustomRadio() -- Just stop playback
    for _, radio in pairs(self.manager.radios) do
        radio:deactivate(-1)
    end
end

function managerV:update()
    local veh = GetMountedVehicle(GetPlayer())
    if veh then
        self.isMounted = true
        if veh:IsEngineTurnedOn() then
            local name = veh:GetBlackboard():GetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName)
            local radio = self:getRadioByName(name.value)

            if radio and not radio.channels[-1] then
                radio:activate(-1)
            end
        end
    elseif self.isMounted then
        self.isMounted = false
        self:disableCustomRadio()
    end
end

function managerV:handleMenu()
    local veh = GetMountedVehicle(GetPlayer())
    if not veh then return end

    local name = veh:GetBlackboard():GetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName)
    local radio = self:getRadioByName(name.value)

    if radio then
        if radio.channels[-1] then
            radio:deactivate(-1)
        end
    end
end

function managerV:handleTS() -- trainSystem comp
    if self.rm.runtimeData.ts then
        if not self.rm.runtimeData.ts.stationSys then return end
        local train = self.rm.runtimeData.ts.stationSys.activeTrain
        if train and train.playerMounted then
            for _, radio in pairs(self.manager.radios) do
                if radio.channels[-1] then
                    GetMountedVehicle(GetPlayer()):ToggleRadioReceiver(false)
                end
            end
        end
    end
end

return managerV