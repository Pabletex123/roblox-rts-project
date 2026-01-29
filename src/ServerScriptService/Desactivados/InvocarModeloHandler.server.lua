local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteInvocar = ReplicatedStorage:WaitForChild("InvocarModelo") -- RemoteEvent que el cliente dispara para invocar
local remoteUI = ReplicatedStorage:WaitForChild("AgregarPersonajeUI") -- RemoteEvent para mandar datos a cliente

local PersonajesDB = require(ReplicatedStorage:WaitForChild("PersonajesDB"))

remoteInvocar.OnServerEvent:Connect(function(player, personajeID)
	-- Validar personaje
	local datos = PersonajesDB[personajeID]
	if not datos then
		warn("Personaje no encontrado:", personajeID)
		return
	end

	-- Clonar modelo en workspace
	local modeloOriginal = ReplicatedStorage:FindFirstChild(datos.Nombre) -- El modelo debe llamarse igual que datos.Nombre (ej: "Arana")
	if not modeloOriginal then
		warn("Modelo no encontrado en ReplicatedStorage:", datos.Nombre)
		return
	end

	local modelo = modeloOriginal:Clone()
	modelo.Parent = workspace
	modelo:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)) -- Aparece frente al jugador

	-- Aquí puedes poner la animación si quieres (como en tu script anterior)...

	-- Mandar datos al cliente para mostrar UI
	remoteUI:FireClient(player, datos)
end)
