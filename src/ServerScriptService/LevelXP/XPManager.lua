local ServerScriptService = game:GetService("ServerScriptService")
local levelXP = ServerScriptService:WaitForChild("LevelXP")
local subirNivel = require(levelXP:WaitForChild("SubirNivel"))


local XPManager = {}

-- Función principal para ganar XP
function XPManager.GanarXP(unidad, cantidad)
	if not unidad or not unidad:IsA("Model") then return end

	local xpActual = unidad:GetAttribute("XP") or 0
	unidad:SetAttribute("XP", xpActual + cantidad)
	print(unidad.Name, "ganó", cantidad, "XP. Total:", unidad:GetAttribute("XP"))

	-- Llamar a subir de nivel
	subirNivel.SubirNivel(unidad)
end

return XPManager

