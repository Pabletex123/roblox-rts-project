
local replicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
local openSummonUI = remoteEvents:WaitForChild("OpenSummonUI")
--local invocarUnidadEvento = remoteEvents:WaitForChild("InvocarUnidad") -- Evento para invocar la unidad a la ui  falta hacer a el mundo

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local unitUI = playerGui:WaitForChild("UnitUI")
local summonFrame = unitUI:WaitForChild("SummonFrame")

local container = summonFrame:WaitForChild("UnidadContainer")
local frame = container:WaitForChild("FrameUnidad")

-- Mostrar el Frame cuando el server lo diga
openSummonUI.OnClientEvent:Connect(function()
	summonFrame.Visible = true
	local containerUnidad = frame:FindFirstChild("ImagenUnidad")
	if not containerUnidad then
		containerUnidad = frame:WaitForChild("DetalleUnidad")
	end



	local detalleUnidad = frame:FindFirstChild("DetalleUnidad")
	if not detalleUnidad then
		detalleUnidad = frame:WaitForChild("DetalleUnidad")
	end

	-- Esperar a que exista el botón
	local summonButton = detalleUnidad:FindFirstChild("SummonButton")
	if not summonButton then
		summonButton = detalleUnidad:WaitForChild("SummonButton")
	end
	

	-- Evitar conectar dos veces
	if not summonButton:GetAttribute("Connected") then
		summonButton.MouseButton1Click:Connect(function()
			print("¡Invocación completada!")

			print("Contenido de DetalleUnidad:")
			for _, child in ipairs(detalleUnidad:GetChildren()) do
				print(child.Name)
			end

			-- Aquí va la lógica de invocar la unidad
			local unidadData = {
				Nombre = detalleUnidad:WaitForChild("Nombre").Text,
				Descripcion = detalleUnidad:WaitForChild("Descripcion").Text,
				Imagen = detalleUnidad:WaitForChild("Imagen").Image
			}

			-- nada
			
		end)
		summonButton:SetAttribute("Connected", true)
	end
end)-- Esperar a que exista DetalleUnidad
	
-- Aquí puedes agregar el código para:
-- - Invocar la araña
-- - Mostrarla en tu UI de unidades
--summonFrame.Visible = false  --nose si cerrar el frame cuando se hace corretamente la invocacion amenos que
-- haya una animacion

