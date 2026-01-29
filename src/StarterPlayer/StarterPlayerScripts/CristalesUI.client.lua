local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local cristales = player:FindFirstChild("Cristales")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local actualizarCristales = remoteEvents:WaitForChild("ActualizarCristales")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CristalesUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

--Fondo
local fondoCristal = Instance.new("ImageLabel")
fondoCristal.Name = "CristalFondo"
fondoCristal.Size = UDim2.new(0, 130, 0, 40)
fondoCristal.Position = UDim2.new(0, 10, 0, 70)
fondoCristal.Image = "rbxassetid://129005529078153" -- tu ID de imagen
fondoCristal.BackgroundTransparency = 1
fondoCristal.Parent = screenGui

--Texto encima del fondo
local textoCristales = Instance.new("TextLabel")
textoCristales.Name = "CristalDisplay"
textoCristales.Text = "Cristales: 0"
textoCristales.Size = UDim2.new(1, 0, 1, 0)
textoCristales.Position = UDim2.new(0, 0, 0, 0)
textoCristales.BackgroundTransparency = 1
textoCristales.TextColor3 = Color3.new(1, 1, 1)
textoCristales.Font = Enum.Font.SourceSansBold
textoCristales.TextScaled = true
textoCristales.Parent = fondoCristal

-- 🔄 Escuchar cambios de valor
actualizarCristales.OnClientEvent:Connect(function(nuevoValor)
	textoCristales.Text = "Cristales: " .. nuevoValor
end)
