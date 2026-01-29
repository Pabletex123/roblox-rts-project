local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ordenMoverUnidad = remoteEvents:WaitForChild("OrdenMoverUnidad")
local ordenAtacarUnidad = remoteEvents:WaitForChild("OrdenAtacarUnidad")

local AtaquesActivos = {}
local UltimoAtaque = {} -- 🕓 Para controlar cooldown
local MinadosActivos = {} -- 🔨 Para controlar minados en progreso



-- 🔁 Función reutilizable para atacar
local function atacarUnidad(unidad, objetivo)
	if not unidad or not objetivo then return end
	-- Cancelar 🗡️ataque🗡️ anterior si estaba activo
	if AtaquesActivos[unidad] then
		AtaquesActivos[unidad] = false
		task.wait(0.05) -- Espera breve para que el bucle anterior se cierre bien
	end

	local humanoid = unidad:FindFirstChildOfClass("Humanoid")
	local objetivoHumanoid = objetivo:FindFirstChildOfClass("Humanoid")
	if not humanoid or not objetivoHumanoid then return end

	local velocidadAtaque = unidad:GetAttribute("VelocidadAtaque")
	local damage = unidad:GetAttribute("DamageAtaque")
	local rango = unidad:GetAttribute("RangoAtaque")

	local seguirAtacando = true
	AtaquesActivos[unidad] = seguirAtacando

	-- Solo inicializa el tiempo si no existe
	if UltimoAtaque[unidad] == nil then
		UltimoAtaque[unidad] = 0
	end
	local ProjectileService = require(game.ServerScriptService.Services.ProjectileService)
	local ProjectileStats = require(game.ServerScriptService.Data.ProjectileStats)
	local root = unidad:FindFirstChild("HumanoidRootPart")
	local objetivoRoot = objetivo:FindFirstChild("HumanoidRootPart")
	if not root or not objetivoRoot then return end

	task.spawn(function()
		while seguirAtacando and objetivoHumanoid.Health > 0 and unidad and unidad.Parent do
			if not AtaquesActivos[unidad] then break end

			local distancia = (unidad:GetPivot().Position - objetivo:GetPivot().Position).Magnitude

			if distancia > rango then
				humanoid:MoveTo(objetivo:GetPivot().Position)
			else
				local tiempoActual = tick()
				local ultimo = UltimoAtaque[unidad] or 0
				if tiempoActual - ultimo >= velocidadAtaque then
		local tipoAtaque = unidad:GetAttribute("TipoAtaque")

        if tipoAtaque == "Rango" then
			local projectileName = unidad:GetAttribute("ProjectileName")
			local projectileBaseStats = ProjectileStats[projectileName]
    		if not projectileBaseStats then return end

    		ProjectileService.Launch(
        		root.Position,
        		objetivoRoot.Position,
        		projectileName,
        		projectileBaseStats
    		)
		else
			--melee attack
			objetivoHumanoid:TakeDamage(damage)
		end

					print("✅ 👊Golpe👊 válido para", unidad.Name)
					UltimoAtaque[unidad] = tiempoActual
					
				
					-- 🟢 Reproducir animación de ataque
					local animFolder = unidad:FindFirstChild("Animate")
					if animFolder then
						local animAttack = animFolder:FindFirstChild("Attack")
						if animAttack then
							local humanoid = unidad:FindFirstChildOfClass("Humanoid")
							if humanoid then
								local animator = humanoid:FindFirstChildOfClass("Animator")
								if animator then
									local track = animator:LoadAnimation(animAttack)
									track:Play()
								end
							end
						end
					end
					
				else
					print("⛔ Cooldown activo para", unidad.Name)
				end
			end

			task.wait(0.1) -- Permite comprobaciones más fluidas sin spamear daño
		end

		-- Limpiar si se detuvo el ataque
		if AtaquesActivos[unidad] == seguirAtacando then
			AtaquesActivos[unidad] = nil
		end
	end)
end


-- ✅ Movimiento con cancelación de ataque
ordenMoverUnidad.OnServerEvent:Connect(function(jugador, unidad, destino)
	if not unidad or not unidad:IsDescendantOf(workspace) then return end
	if unidad:GetAttribute("Owner") ~= jugador.UserId then return end
	-- Cancelar ⛏️minado⛏️ activo si existe
	if MinadosActivos[unidad] then
		MinadosActivos[unidad] = false
		unidad:SetAttribute("Minando", false)
	end
	-- Cancelar 🗡️ataque🗡️ activo
	if AtaquesActivos[unidad] then
		AtaquesActivos[unidad] = false
	end

	local humanoid = unidad:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid:MoveTo(destino)

	local distanciaMinima = 5
	local radioDeteccion = 12
	local connection

	connection = RunService.Heartbeat:Connect(function()
		if not unidad or not unidad.Parent then
			connection:Disconnect()
			return
		end

		local posActual = unidad:GetPivot().Position
		if (posActual - destino).Magnitude <= distanciaMinima then
			connection:Disconnect()

			for _, obj in ipairs(workspace:GetChildren()) do
				if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
					if obj:GetAttribute("Owner") == jugador.UserId then continue end
					if obj == unidad then continue end
					if obj == jugador.Character then continue end
					
					local root = obj:FindFirstChild("HumanoidRootPart")
					if root and (root.Position - destino).Magnitude <= radioDeteccion then
						atacarUnidad(unidad, obj)
						break
					end
				end
			end
		end
	end)
end)

ordenAtacarUnidad.OnServerEvent:Connect(function(jugador, unidad, enemigo)
	-- Cancelar ⛏️minado⛏️ activo si existe
	if MinadosActivos[unidad] then
		MinadosActivos[unidad] = false
		unidad:SetAttribute("Minando", false)
	end
	
	if not unidad or not enemigo then return end
	if unidad:GetAttribute("Owner") ~= jugador.UserId then return end
	-- 🚫 No atacar a sí mismo, a unidades propias ni al personaje del jugador
	if enemigo:GetAttribute("Owner") == jugador.UserId then return end --unidades
	if enemigo == unidad then return end --la misma unidad
	if enemigo == jugador.Character then return end --jugador

	if not enemigo:IsDescendantOf(workspace) then return end

	local enemigoHumanoid = enemigo:FindFirstChildOfClass("Humanoid")
	if not enemigoHumanoid then return end
	if enemigo:GetAttribute("EsEnemigo") == false then return end

	atacarUnidad(unidad, enemigo)
end)



--Bucle de minados
local function iniciarMinado(unidad, cristal, tiempoMinado, jugador)
	if not unidad or not cristal or not unidad:FindFirstChild("HumanoidRootPart") then 
		return 
	end

	-- Prevenir múltiples minas al mismo tiempo
	if unidad:GetAttribute("Minando") then 
		return 
	end
	unidad:SetAttribute("Minando", true)


	--    Barra de Progreso
	-- Mostrar barra de minado encima del cristal
	local barraGui = game.ReplicatedStorage:FindFirstChild("BarraMinado"):Clone()
	barraGui.Adornee = cristal
	barraGui.Parent = cristal
	barraGui.Enabled = true  -- Asegurar que está habilitada
	-- Referencias a los componentes
	local fondoBarra = barraGui:FindFirstChild("FondoBarra")
	local barraProgreso = fondoBarra and fondoBarra:FindFirstChild("BarraProgreso")
	local textoMinado = barraGui:FindFirstChild("TextoMinado")
	if not barraProgreso then
		warn("No se encontró BarraProgreso en la GUI de minado")
		barraGui:Destroy()
		return
	end
	-- Configuración inicial de la barra (vacía)
	barraProgreso.Size = UDim2.new(0, 0, 1, 0)
	--    Barra de Progreso

	-- Iniciar tiempo de minado
	local tInicio = tick()
	local minando = true

	while minando and unidad:GetAttribute("Minando") and unidad.Parent and cristal.Parent do
		local tiempoTranscurrido = tick() - tInicio
		local progreso = math.clamp(tiempoTranscurrido / tiempoMinado, 0, 1)
		local tiempoRestante = tiempoMinado - tiempoTranscurrido

		-- Actualizar barra de progreso (llenándola progresivamente)
		barraProgreso.Size = UDim2.new(progreso, 0, 1, 0)

		-- Actualizar texto con tiempo restante
		if textoMinado then
			textoMinado.Text = string.format("%.1f", tiempoRestante) .. "s"
		end

		-- Verificar si se completó el minado
		if tiempoTranscurrido >= tiempoMinado then
			minando = false
			break
		end

		task.wait(0.05)
	end

	-- Limpiar GUI
	if barraGui then 
		barraGui:Destroy() 
	end

	unidad:SetAttribute("Minando", false)

	if not minando then  -- Minado completado
		local peso = cristal:GetAttribute("Peso") 
		local cristales = jugador:FindFirstChild("Cristales")
		if cristales then
			cristales.Value += peso
		end
		cristal:Destroy()
		print("✅ " .. unidad.Name .. " ha completado el minado de " .. cristal.Name)
	else
		print("❌ " .. unidad.Name .. " ha cancelado el minado")
	end
end

local DISTANCIA_MINADO = 5 -- Distancia mínima para iniciar minado

local function acercarseYMinear(unidad, mineral, tiempoMinado, jugador)
	if not unidad or not mineral then return end

	local humanoid = unidad:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local rootPart = unidad:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
    --2da validacion si la unidad tiene el atributo para minar(solo las unidades mineras)
	if unidad:GetAttribute("PuedeMinar") ~= true then
		warn("Unidad no puede minar:", unidad.Name)
		return
	end
	
	-- Mover unidad al mineral
	local targetPosition = mineral:GetPivot().Position -- obtener la posicion del mineral
	humanoid:MoveTo(targetPosition)--mover la unidad minera a la posicion del mineral
	print(unidad.Name .. " Acercandose al mineral " .. mineral.Name)

	local conexion
	local timeout = 30  -- Segundos máximos
	local tiempoInicio = os.time()
	local intentos = 0
	local maxIntentos = 5  -- Máximo de intentos para encontrar camino

	conexion = RunService.Heartbeat:Connect(function()
		-- 1. Verificar timeout
		if os.time() - tiempoInicio > timeout then
			print("TIMEOUT: La unidad no pudo alcanzar el mineral")
			if conexion then conexion:Disconnect() end
			return
		end

		-- 2. Verificar si se debe cancelar
		if not MinadosActivos[unidad] or not unidad.Parent or not mineral.Parent then
			if conexion then conexion:Disconnect() end
			return
		end
		-- 3. Reintentar movimiento si está atascado
		intentos = intentos + 1
		if intentos % 100 == 0 then  -- Cada 100 frames (~1.6 segundos)
			humanoid:MoveTo(targetPosition)
		end
		
		-- 3. Calcular distancia usando la posición ACTUAL del mineral
		local distancia = (rootPart.Position - targetPosition).Magnitude
		print("Distancia al mineral: " .. math.floor(distancia) .. " studs")

		-- 4. Verificar si está lo suficientemente cerca
		if distancia <= DISTANCIA_MINADO then
			if conexion then conexion:Disconnect() end

			print(unidad.Name .. " alcanzó el mineral a " .. math.floor(distancia) .. " studs")

			-- Iniciar minado
		local MinarRemoteEvent = remoteEvents:WaitForChild("MinarRemoteEvent")
			MinarRemoteEvent:FireClient(jugador, unidad, tiempoMinado)
			print(unidad.Name .. " ha comenzado a minar " .. mineral.Name)
			iniciarMinado(unidad, mineral, tiempoMinado, jugador)
		end
	end)
end

local ordenMinarUnidad = remoteEvents:WaitForChild("OrdenMinarUnidad")

ordenMinarUnidad.OnServerEvent:Connect(function(jugador, unidad, mineral)
	if not unidad or not mineral then return end
	if not unidad:GetAttribute("PuedeMinar")  then return end
	if not mineral:GetAttribute("EsMineral") then return end

	local tiempoMinado = mineral:GetAttribute("TiempoMinado")
	local peso = mineral:GetAttribute("Peso") or 1
	local cristales = jugador:FindFirstChild("Cristales")

	-- Iniciar proceso de minado
-- Agregar un pequeño delay para evitar que se cancele inmediatamente
    task.wait(0.1)
    MinadosActivos[unidad] = true
	acercarseYMinear(unidad, mineral, tiempoMinado, jugador)--Cuando el jugador da click en un mineral se le manda a esta funcion para que se acerque
	--y a cierta distancia se activara la funcion iniciarminado que empezara la barra de carga de minado y el tiempo que tarda en minarse

   --Agregar Que cuando el jugador mande a la unidad a moverse a otro lado se cancele el minado y quede guardado el progreso de minado -1 segundo al salirse pero no exceda del tiempo maximo del mineral

end)

