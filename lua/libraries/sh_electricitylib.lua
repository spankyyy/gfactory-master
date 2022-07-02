if CLIENT then return end
print("loaded electricitylib")

local entityMeta = FindMetaTable("Entity")

function entityMeta:InitElectricitySystem(hasInputs, hasOutputs)
    self.electricalSystem = true
    self.eBuffer = {
        capacity = 0,
        stored = 0
    }
    self.hasInputs = hasInputs or false
    self.hasOutputs = hasOutputs or false
    if self.hasInputs then
        self.inputs = {}
        self.inputInfo = {
            maxTransfer = 0
        }
    end
    if self.hasOutputs then
        self.outputs = {}
        self.outputInfo = {
            maxTransfer = 0
        }
    end
end

function entityMeta:HasElectricalSystem()
    return self.electricalSystem or false
end
function entityMeta:connectDevice(device)
    if not self.hasOutputs then return false end
    if not self:HasElectricalSystem() then return false end
    if not device.hasInputs then return false end
    if not device:HasElectricalSystem() then return false end
    if table.HasValue(self.outputs, device) then return false end
    if table.HasValue(device.inputs, self) then return false end
    
    self.outputs[#self.outputs+1] = device
    device.inputs[#device.inputs+1] = self
    return true
end
function entityMeta:disconnectDevice(device)
    if not self.hasOutputs then return false end
    if not self:HasElectricalSystem() then return false end
    if not device.hasInputs then return false end
    if not device:HasElectricalSystem() then return false end
    if not table.HasValue(self.outputs, device) then return false end
    if not table.HasValue(device.inputs, self) then return false end

    table.RemoveByValue(self.outputs, device)
    table.RemoveByValue(device.inputs, self)
    return true
end
function entityMeta:SetInput(maxTransfer)
    if not self.hasInputs then print("ERROR, This entity has no inputs setup!") return false end
    self.inputInfo.maxTransfer = maxTransfer
end
function entityMeta:SetOutput(maxTransfer)
    if not self.hasOutputs then print("ERROR, This entity has no outputs setup!") return false end
    self.outputInfo.maxTransfer = maxTransfer
end
function entityMeta:SetBuffer(capacity, stored)
    self.eBuffer.capacity = capacity or 0
    self.eBuffer.stored = stored or 0
end
function sanitizeDevices(devices)
    removeInvalidDevices(devices)
    local temp = {}
    for k,v in pairs(devices) do
        if v.eBuffer.stored ~= v.eBuffer.capacity and v then
            temp[#temp+1] = v
        end
    end
    return temp
end
function removeInvalidDevices(devices)
    for k,v in pairs(devices) do
        if not v or not v:IsValid() then
            devices[k] = nil
        end
    end
end
function entityMeta:PushEnergyTo(devices, amount)
    if self.eBuffer.stored == 0 then return end
    --if amount == 0 then amount = self.outputInfo.maxTransfer end
    local amount = math.Clamp(amount or self.outputInfo.maxTransfer, 0, self.outputInfo.maxTransfer)

    local inputMaxes = {}
    local sumOfInputMaxes = 0
    for k,v in pairs(devices) do
        local max = math.Clamp(v.eBuffer.capacity - v.eBuffer.stored, 0, v.inputInfo.maxTransfer)
        inputMaxes[k] = max
        sumOfInputMaxes = sumOfInputMaxes + max
    end
    local amount = math.Clamp(amount, 0, sumOfInputMaxes)
    
    local max = math.min(self.eBuffer.stored, amount)
    local tempMax = max
    local tempOut = {}
        
    while tempMax ~= 0 do
        for k,v in pairs(devices) do
            local dMax = inputMaxes[k]
            if (tempOut[k] or 0) >= dMax then
                continue
            end
            tempOut[k] = (tempOut[k] or 0) + 1
            tempMax = tempMax - 1
            if tempMax == 0 then break end
        end
    end
    self.eBuffer.stored = self.eBuffer.stored - max
    for k,v in pairs(devices) do
        v.eBuffer.stored = v.eBuffer.stored + (tempOut[k] or 0)
    end
end
function entityMeta:PushEnergyToConnectedDevices()
    if not self:HasElectricalSystem() then return end
    --PrintTable(self.outputs)
    self:PushEnergyTo(sanitizeDevices(self.outputs))
end
function entityMeta:ElectricityThink()
    if not self:HasElectricalSystem() then return end
    if self.hasOutputs then
        self:PushEnergyToConnectedDevices()
    end
end