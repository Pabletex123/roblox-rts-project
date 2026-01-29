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

local seleccionActual = player:FindFirstChild("UnidadSeleccionada")
if not seleccionActual then
	seleccionActual = Instance.new("ObjectValue")
	seleccionActual.Name = "UnidadSeleccionada"
	seleccionActual.Value = nil
	seleccionActual.Parent = player
end



local TweenService = game:GetService("TweenService")

local function aplicarBrilloTemporal(modelo)
	-- Eliminar highlight anterior si ya existe
	local anterior = modelo:FindFirstChild("SelectionEffect")
	if anterior then anterior:Destroy() end

	local highlight = Instance.new("Highlight")
	highlight.Name = "SelectionEffect"
	highlight.FillColor = Color3.fromRGB(100, 150, 200)
	highlight.FillTransparency = 0.8
	highlight.OutlineColor = Color3.fromRGB(180, 180, 180)
	highlight.OutlineTransparency = 0.6
	highlight.Adornee = modelo
	highlight.Parent = modelo

	-- Crear Tween para desvanecer (0.8 → 1, 0.6 → 1)
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local objetivo = {
		FillTransparency = 1,
		OutlineTransparency = 1
	}

	-- Esperar 3 segundos antes de comenzar a desvanecer
	task.delay(2, function()
		local tween = TweenService:Create(highlight, tweenInfo, objetivo)
		tween:Play()
		tween.Completed:Connect(function()
			highlight:Destroy()
		end)
	end)
end




mouse.Button1Down:Connect(function()
	if not activarControl.Value then return end -- <- usamos el valor real del BoolValue

	local objetivo = mouse.Target
	if objetivo and objetivo:FindFirstAncestorWhichIsA("Model") then
		local modelo = objetivo:FindFirstAncestorWhichIsA("Model")
		if modelo:GetAttribute("Owner") == player.UserId then

			seleccionActual.Value = modelo -- Guardamos la selección compartida

			print("Unidad seleccionada:", modelo.Name)
			
			if seleccionActual and seleccionActual:FindFirstChild("SelectionEffect") then
				seleccionActual.SelectionEffect:Destroy()  --Elimina un efecto de seleccion si existia
			end

			aplicarBrilloTemporal(seleccionActual.Value)--aplica la funcion a la unidad seleccionada.Value (.Value ya que es el nuevo valor que se le da en la funcion que seria el modelo al que se le da click)


		end
	end
end)

mouse.Button2Down:Connect(function()
	print("Clic derecho detectado")
	if seleccionActual and seleccionActual.Value then
		print("Unidad seleccionada:", seleccionActual.Value.Name)
		local objetivo = mouse.Target
		if seleccionActual and seleccionActual.Value then
			print("Unidad seleccionada:", seleccionActual.Value.Name)
		end
		if objetivo then
			print("Objetivo clickeado:", objetivo.Name, objetivo:GetFullName())

			if objetivo:FindFirstAncestorWhichIsA("Model") then
				local modelo = objetivo:FindFirstAncestorWhichIsA("Model")
				print("Modelo objetivo:", modelo.Name)
				print("Es mineral?", modelo:GetAttribute("EsMineral"))
			end
		end

		if objetivo and objetivo:FindFirstAncestorWhichIsA("Model") then
			local modelo = objetivo:FindFirstAncestorWhichIsA("Model")

			-- 🔥 Si haces clic sobre un enemigo, se ordena ataque
			if modelo:GetAttribute("EsEnemigo") then
				local eventoAtacar = remoteEvents:WaitForChild("OrdenAtacarUnidad")
				eventoAtacar:FireServer(seleccionActual.Value, modelo)
				return -- salimos para que no siga con el movimiento
			end
		end
		-- Verificamos si el objetivo es minable y la unidad puede minar
		if objetivo and objetivo:FindFirstAncestorWhichIsA("Model") then
			local modeloObjetivo = objetivo:FindFirstAncestorWhichIsA("Model")
			if modeloObjetivo:GetAttribute("EsMineral") and seleccionActual.Value:GetAttribute("PuedeMinar") then
				
				local eventoMinar = remoteEvents:WaitForChild("OrdenMinarUnidad")
				eventoMinar:FireServer(seleccionActual.Value, modeloObjetivo)
				return
			end
		end


		-- Si no fue enemigo, simplemente se mueve al punto clickeado
		local pos = mouse.Hit.Position
		ordenMoverUnidad:FireServer(seleccionActual.Value, pos)
	end
end)

