include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

function ENT:DrawStored()
    local scrncrd = (self:WorldSpaceCenter() + Vector(0, 0, 16)):ToScreen()
    local stored = self:GetNWStored()
    draw.SimpleTextOutlined("" .. stored, "GF_interactable3", scrncrd.x, scrncrd.y, Color(255, 255, 255), 1, 1, 1, Color(0, 0, 0))
end