TOOL.Category = "GFactory"
TOOL.Name = "Device Connector"

if CLIENT then
    language.Add("tool.deviceconnector.name", "Device Connector")
    language.Add("tool.deviceconnector.desc", "Connect electrical devices togheter.\nHold shift for multi connection")
    language.Add("tool.deviceconnector.0", "Primary: Select energy source.")
    language.Add("tool.deviceconnector.1", "Primary: Select target device.")
end
local function MessagePlayer( Ply, Msg )
	Ply:SendLua( "GAMEMODE:AddNotify('" .. Msg .. "',NOTIFY_GENERIC,7);" )
end
function TOOL:LeftClick(trace)
    local entity = trace.Entity
    local owner = self:GetOwner()
    if not entity:HasElectricalSystem() then return end
    if self:GetStage() == 0 and not entity.hasOutputs then
        MessagePlayer(owner, "Please select a device with an output.")
        return false
    end
    if self:GetStage() == 1 and not entity.hasInputs then
        self:SetStage(0)
        MessagePlayer(owner, "Please select a device with an input.")
        return false
    end


    if self:GetStage() == 0 and entity.hasOutputs then
        self.Source = entity
        self.SourceHitpos = trace.HitPos
        self:SetStage(1)
    elseif self:GetStage() == 1 and entity.hasInputs then
        local Source, Target = self.Source, entity
        print(Source, Target)
        local success = Source:connectDevice(Target)
        if success  then
            constraint.Rope(Target, Source, 0, 0, Target.InputPosition or Vector(), Source.OutputPosition or Vector(), 256, 0, 0, 4, "arrowire/arrowire2", false, Color(255, 255, 255))
            MessagePlayer(owner, "Devices connected successfully.")
            if not owner:KeyDown(IN_SPEED) then
                self:SetStage(0)
            end
        else
            MessagePlayer(owner, "Devices connection unsuccessful.")
            self:SetStage(0)
            return false
        end
    else
        self:SetStage(0)
        MessagePlayer(owner, "Devices connection unsuccessful.")
        return false
    end
    return true
end