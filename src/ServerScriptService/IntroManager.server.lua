local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
						
Players.PlayerAdded:Connect(function(player)--Al momento de que el jugador entre al juego
	player.CharacterAdded:Connect(function(char)--Cuando el jugador aparece o reaparece
		local zona = RS.IntroZona:Clone()--Clonamos el modelo de la intro de el ReplicatedStorage
		--falta crear la intro en replicatedstorage
		zona.Name = "Intro_" .. player.UserId
		zona.Parent = workspace--Queda dentro del workspace

		zona:SetPrimaryPartCFrame(
			CFrame.new(player.UserId * 500, 0, 0)
		)

		char:WaitForChild("HumanoidRootPart").CFrame =
			zona.SpawnJugador.CFrame + Vector3.new(0,3,0)
	end)
end)
