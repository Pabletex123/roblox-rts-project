local ServerScriptService = game:GetService("ServerScriptService")
local XPManager = require(script.Parent.XPManager)
local XPdata = require(ServerScriptService.XPdata.Acciones)

workspace.Enemigos.ChildAdded:Connect(function(enemigo)
	local humanoid = enemigo:FindFirstChild("Humanoid")
	if not humanoid then return end

	humanoid.Died:Connect(function()
		local killer = enemigo:GetAttribute("UnidadAsesina")
		if not killer then return end

		local xp = XPdata.MatarEnemigo[enemigo.Name] or 0
		XPManager.GanarXP(killer, xp)
	end)
end)
