include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

function ENT:InteractDraw()
    local selfScreenCoord = (self:WorldSpaceCenter() + Vector(0, 0, 16)):ToScreen()
    surface.SetDrawColor(255, 255, 255)
    --surface.DrawRect(selfScreenCoord.x - 2, selfScreenCoord.y - 2, 4, 4)
    local Flsh = math.Remap(math.sin(SysTime() * 128), -1, 1, 0.8, 1)
    local Quantity = self:GetCL_Quantity()
    draw.SimpleTextOutlined(self.PrintName .. " (" .. Quantity .. "x)", "GF_interactable3", selfScreenCoord.x, selfScreenCoord.y, Color(255 * Flsh, 255 * Flsh, 128 * Flsh), 1, 1, 1, Color(0, 0, 0))
end
