local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local playerGui = player:WaitForChild("PlayerGui")
local Personajeui = playerGui:WaitForChild("PersonajeUI")
local menu = Personajeui:WaitForChild('Menu')
local control = menu:WaitForChild("ControlButton")
local activarControl = control:WaitForChild("ActivarControl") -- <- aquí accedemos al BoolValue

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ordenMoverUnidad = remoteEvents:WaitForChild("OrdenMoverUnidad")
local ordenAtacarUnidad = remoteEvents:WaitForChild("OrdenAtacarUnidad")
local ordenMinarUnidad = remoteEvents:WaitForChild("OrdenMinarUnidad")

-- Crear la referencia de selección si no existe
if not player:FindFirstChild("UnidadSeleccionada") then
	local seleccionActual = Instance.new("ObjectValue")
	seleccionActual.Name = "UnidadSeleccionada"
	seleccionActual.Value = nil
	seleccionActual.Parent = player
end
local seleccionActual = player:WaitForChild("UnidadSeleccionada")

local TweenService = game:GetService("TweenService")

-- Variable para almacenar el highlight actual
local highlightActual = nil

local function aplicarBrilloTemporal(modelo)
	-- Eliminar highlight anterior si existe
	if highlightActual then
		highlightActual:Destroy()
		highlightActual = nil
	end

	if not modelo then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "SelectionEffect"
	highlight.FillColor = Color3.fromRGB(100, 150, 200)
	highlight.FillTransparency = 0.8
	highlight.OutlineColor = Color3.fromRGB(180, 180, 180)
	highlight.OutlineTransparency = 0.6
	highlight.Adornee = modelo
	highlight.Parent = game.Players.LocalPlayer.PlayerGui -- Mejor en PlayerGui para no interferir con scripts del modelo
	highlightActual = highlight

	-- Crear Tween para desvanecer
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local objetivo = {
		FillTransparency = 1,
		OutlineTransparency = 1
	}

	-- Esperar 2 segundos antes de comenzar a desvanecer
	task.delay(2, function()
		if highlight and highlight.Parent then
			local tween = TweenService:Create(highlight, tweenInfo, objetivo)
			tween:Play()
			tween.Completed:Connect(function()
				if highlight then
					highlight:Destroy()
					if highlight == highlightActual then
						highlightActual = nil
					end
				end
			end)
		end
	end)
end

-- Clic izquierdo para seleccionar
mouse.Button1Down:Connect(function()
	if not activarControl.Value then return end

	local objetivo = mouse.Target
	if not objetivo then return end
	
	local modelo = objetivo:FindFirstAncestorWhichIsA("Model")
	if not modelo then return end
	
	-- Verificar si es una unidad del jugador
	local owner = modelo:GetAttribute("Owner")
	if owner and owner == player.UserId then
		seleccionActual.Value = modelo
		print("Unidad seleccionada:", modelo.Name)
		aplicarBrilloTemporal(modelo)
		
		-- Mostrar UI de estadísticas si existe
		-- local estadisticasUI = Personajeui:FindFirstChild("EstadisticasUI")
		-- if estadisticasUI then
		-- 	estadisticasUI.Visible = true
		-- 	-- Actualizar valores (si tienes estos elementos)
		-- 	local vidaText = estadisticasUI:FindFirstChild("VidaText")
		-- 	local dañoText = estadisticasUI:FindFirstChild("DañoText")
		-- 	local velocidadText = estadisticasUI:FindFirstChild("VelocidadText")
			
		-- 	local humanoid = modelo:FindFirstChildOfClass("Humanoid")
		-- 	if humanoid and vidaText then
		-- 		vidaText.Text = "Vida: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
		-- 	end
			
		-- 	if dañoText then
		-- 		dañoText.Text = "Daño: " .. (modelo:GetAttribute("DamageAtaque") or 10)
		-- 	end
			
		-- 	if velocidadText then
		-- 		velocidadText.Text = "Vel. Ataque: " .. (modelo:GetAttribute("VelocidadAtaque") or 1) .. "s"
		-- 	end
		-- end
	end
end)

-- Clic derecho para dar órdenes
mouse.Button2Down:Connect(function()
	print("Clic derecho detectado")
	
	if not seleccionActual.Value then
		print("No hay unidad seleccionada")
		return
	end
	
	local unidad = seleccionActual.Value
	print("Unidad seleccionada:", unidad.Name)
	
	local objetivo = mouse.Target
	if not objetivo then
		print("No hay objetivo (clic en el aire)")
		return
	end
	
	print("Objetivo clickeado:", objetivo.Name, objetivo:GetFullName())
	
	-- Buscar el modelo del objetivo
	local modelo = objetivo:FindFirstAncestorWhichIsA("Model")
	if not modelo then
		-- Clic en el suelo - mover
		local pos = mouse.Hit.Position
		ordenMoverUnidad:FireServer(unidad, pos)
		print("Orden de mover a:", pos)
		return
	end
	
	print("Modelo objetivo:", modelo.Name)
	
	-- Determinar qué tipo de orden dar
	-- 1. Si es enemigo (no del mismo jugador y tiene humanoid)
	local esDelJugador = modelo:GetAttribute("Owner") == player.UserId
	local tieneHumanoid = modelo:FindFirstChildOfClass("Humanoid")
	
	if not esDelJugador and tieneHumanoid then
		-- Es enemigo - atacar
		print("Es enemigo - Ordenando ataque")
		ordenAtacarUnidad:FireServer(unidad, modelo)
		return
	end
	
	-- 2. Si es mineral y la unidad puede minar
	local esMineral = modelo:GetAttribute("EsMineral")
	local puedeMinar = unidad:GetAttribute("PuedeMinar")
	
	if esMineral and puedeMinar then
		print("Es mineral - Ordenando minar")
		ordenMinarUnidad:FireServer(unidad, modelo)
		return
	end
	
	-- 3. Si es aliado o algo sin interacción - mover hacia él
	local pos = mouse.Hit.Position
	ordenMoverUnidad:FireServer(unidad, pos)
	print("Orden de mover a:", pos)
end)

-- Sistema para detectar qué hay bajo el cursor (feedback visual)
local function actualizarCursor()
	if not activarControl.Value then return end
	
	local target = mouse.Target
	if not target then
		mouse.Icon = "rbxasset://SystemCursors/Arrow"
		return
	end
	
	local modelo = target:FindFirstAncestorWhichIsA("Model")
	if not modelo then
		mouse.Icon = "rbxasset://SystemCursors/Arrow"
		return
	end
	
	-- Verificar si es unidad del jugador
	local owner = modelo:GetAttribute("Owner")
	if owner and owner == player.UserId then
		mouse.Icon = "rbxasset://SystemCursors/PointingHand"
		return
	end
	
	-- Verificar si es enemigo (tiene humanoid y no es del jugador)
	local tieneHumanoid = modelo:FindFirstChildOfClass("Humanoid")
	if tieneHumanoid and owner ~= player.UserId then
		mouse.Icon = "rbxasset://textures/Cursor/AttackCursor.png"
		return
	end
	
	-- Verificar si es mineral
	if modelo:GetAttribute("EsMineral") then
		mouse.Icon = "rbxasset://SystemCursors/Cross"
		return
	end
	
	-- Por defecto
	mouse.Icon = "rbxasset://SystemCursors/Arrow"
end

-- Actualizar cursor cuando se mueve el mouse
mouse.Move:Connect(actualizarCursor)

-- Actualizar cuando cambia el estado de control
activarControl:GetPropertyChangedSignal("Value"):Connect(function()
	if activarControl.Value then
		actualizarCursor()
	else
		mouse.Icon = "rbxasset://SystemCursors/Arrow"
	end
end)

-- Conectar para deseleccionar cuando la unidad muere
game:GetService("RunService").Heartbeat:Connect(function()
	if seleccionActual.Value and not seleccionActual.Value.Parent then
		seleccionActual.Value = nil
		if highlightActual then
			highlightActual:Destroy()
			highlightActual = nil
		end
	end
end)