--Script para que el jugador aparezca con el atributo Owner con su UserId
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        char:SetAttribute("Owner", player.UserId)
    end)
end)
