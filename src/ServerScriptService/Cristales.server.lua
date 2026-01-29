local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local actualizarCristales = remoteEvents:WaitForChild("ActualizarCristales")

game.Players.PlayerAdded:Connect(function(player)
	local cristales = Instance.new("IntValue")
	cristales.Name = "Cristales"
	cristales.Value = 50
	cristales.Parent = player

	-- Enviar valor inicial al cliente
	actualizarCristales:FireClient(player, cristales.Value)

	-- Siempre que cambie, también se actualiza la UI del jugador
	cristales:GetPropertyChangedSignal("Value"):Connect(function()
		actualizarCristales:FireClient(player, cristales.Value)
	end)
end)

