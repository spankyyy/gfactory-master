include("autorun/sh_gfactory.lua")
surface.CreateFont( "GF_interactable", {
	font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 24 * 2,
	weight = 1,
	blursize = 1,
	scanlines = 2,
	shadow = true,
} )
surface.CreateFont( "GF_interactable2", {
	font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 16,
	weight = 1,
	blursize = 1,
	scanlines = 1,
	shadow = true,
} )
surface.CreateFont( "GF_interactable3", {
	font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 24,
	weight = 1,
	blursize = 1,
	scanlines = 2,
	shadow = true,
} )

hook.Add("PreDrawHalos", "GF_AddPropHalos", function()
    -- Halo around interactables
    do
        local Interactable = LocalPlayer():GetEyeTrace().Entity
        local closeEnough = LocalPlayer():GetEyeTrace().Fraction * (2 ^ 15) < 96
        if Interactable.isInteractable and closeEnough then
            halo.Add({Interactable}, Color(255, 255, 255), 2, 2, 2)
        end
    end
    do--[[
        local NearbyInteractables = ents.FindInSphere(EyePos(), 256)
        local New = {}
        for k, Interactable in pairs(NearbyInteractables) do
            if Interactable.isInteractable then 
                New[#New+1] = Interactable
            end
        end
        halo.Add(New, Color(255, 255, 255, 0), 4, 4, 1)
    ]]end
end )
hook.Add("HUDPaint", "GF_HUDPaint", function()
    local entity = LocalPlayer():GetEyeTrace().Entity
    local closeEnough = LocalPlayer():GetEyeTrace().Fraction * (2 ^ 15) < 96
    if entity.isInteractable and closeEnough then
	    Interactable:InteractDraw()
        if entity.isPickupable then
            draw.SimpleTextOutlined("Press USE (" .. string.upper(input.LookupBinding("+use")) .. ") to pickup", "GF_interactable2", 1920 * 0.5, (1080 * 0.5) + 64, Color(255, 255, 255), 1, 1, 1, Color(0, 0, 0))
        end
        if entity.isOpenable then
            draw.SimpleTextOutlined("Press USE (" .. string.upper(input.LookupBinding("+use")) .. ") to open", "GF_interactable2", 1920 * 0.5, (1080 * 0.5) + 64, Color(255, 255, 255), 1, 1, 1, Color(0, 0, 0))
        end
    end
    if entity.DrawStored then
        entity:DrawStored()
    end
end)
hook.Add("PostRenderVGUI", "GF_PostVGUI", function()
    local item = LocalPlayer()._CursorItem
	if item and GFACTORY.GUI.Inventory.Frame then
        local text = item.ID .. "\n(" .. item.quantity .. "x)"
        local cx, cy = input.GetCursorPos()
        surface.SetFont("DermaDefault")
        local tx, ty = surface.GetTextSize(text)
        --draw.SimpleTextOutlined(item.ID .. "\n(" .. item.quantity .. ")", "DebugFixed", cx, cy, Color(255, 255, 255), 1, 1, 1, Color(0, 0, 0))
        draw.DrawText(text, "SlotFont", cx - (tx * 0.5), cy - ty, Color(192, 192, 192), TEXT_ALIGN_CENTER)
    end
end )

