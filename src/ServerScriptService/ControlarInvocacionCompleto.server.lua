local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ordenMoverUnidad = remoteEvents:WaitForChild("OrdenMoverUnidad")
local ordenAtacarUnidad = remoteEvents:WaitForChild("OrdenAtacarUnidad")

local AtaquesActivos = {}
local UltimoAtaque = {} -- 🕓 Para controlar cooldown
local MinadosActivos = {} -- 🔨 Para controlar minados en progreso
local ObjetivosUnidades = {} -- Nueva tabla
local MineralesActivos = {} -- Tabla para guardar referencias a minerales
local MineralesPorId = {}
local MineralesUnidades = {} -- 🔥 NUEVA TABLA para almacenar minerales

-- 🔍 Función para encontrar unidad por identificador
local function encontrarUnidadPorId(unidadId)
    for _, unidad in ipairs(workspace:GetChildren()) do
        if unidad:IsA("Model") and unidad:FindFirstChildOfClass("Humanoid") then
            if unidad:GetAttribute("UnidadId") == unidadId then
                return unidad
            end
        end
    end
    return nil
end
-- 🔍 Función para encontrar mineral por identificador
local function encontrarMineralPorId(mineralId)
    for _, mineral in ipairs(workspace:GetChildren()) do
        if mineral:IsA("Model") and mineral:GetAttribute("EsMineral") then
            if mineral:GetAttribute("MineralId") == mineralId then
                return mineral
            end
        end
    end
    return nil
end

-- 🔁 Función reutilizable para atacar
local function atacarUnidad(unidad, objetivo, dt)
    if not unidad or not objetivo or not unidad.Parent or not objetivo.Parent then
        return false -- Terminar ataque
    end
    
    local humanoid = unidad:FindFirstChildOfClass("Humanoid")
    local objetivoHumanoid = objetivo:FindFirstChildOfClass("Humanoid")
    local root = unidad:FindFirstChild("HumanoidRootPart")
    local objetivoRoot = objetivo:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not objetivoHumanoid or not root or not objetivoRoot then
        return false
    end
    
    if objetivoHumanoid.Health <= 0 then
        return false -- Objetivo muerto
    end
    
    local velocidadAtaque = unidad:GetAttribute("VelocidadAtaque") or 1
    local damage = unidad:GetAttribute("DamageAtaque") or 10
    local rango = unidad:GetAttribute("RangoAtaque") or 10
    local tipoAtaque = unidad:GetAttribute("TipoAtaque") or "Melee"
    
    -- Calcular distancia
    local distancia = (root.Position - objetivoRoot.Position).Magnitude
    
    -- Si está fuera de rango, acercarse
    if distancia > rango then
        if tipoAtaque == "Rango" then
            -- Para unidades de rango, mantenerse a distancia
            local direccion = (objetivoRoot.Position - root.Position).Unit
            local posicionIdeal = objetivoRoot.Position - (direccion * (rango * 0.8))
            humanoid:MoveTo(posicionIdeal)
        else
            -- Para melee, acercarse directamente
            humanoid:MoveTo(objetivoRoot.Position)
        end
        return true -- Aún atacando
    end
    
    -- Está en rango, detenerse
    humanoid:MoveTo(root.Position)
    
    -- Verificar cooldown y atacar
    local tiempoActual = tick()
    local ultimoAtaque = UltimoAtaque[unidad] or 0
    
    if tiempoActual - ultimoAtaque >= velocidadAtaque then
        UltimoAtaque[unidad] = tiempoActual
        
        if tipoAtaque == "Rango" then
            -- Lanzar proyectil
            local success, ProjectileService = pcall(require, game.ServerScriptService.Services.ProjectileService)
            local success2, ProjectileStats = pcall(require, game.ServerScriptService.Data.ProjectileStats)
            
            if success and success2 then
                local projectileName = unidad:GetAttribute("Projectile")
                if ProjectileStats and projectileName and ProjectileStats[projectileName] then
                    ProjectileService.Launch(
                        root.Position,
                        objetivoRoot.Position,
                        projectileName,
                        ProjectileStats[projectileName],
                        unidad
                    )
                end
            else
                -- Fallback: daño directo si no hay sistema de proyectiles
                objetivoHumanoid:TakeDamage(damage)
            end
        else
            -- Ataque cuerpo a cuerpo
            objetivoHumanoid:TakeDamage(damage)
        end
        
        -- Animación de ataque
        local animFolder = unidad:FindFirstChild("Animate")
        if animFolder then
            local animAttack = animFolder:FindFirstChild("Attack")
            if animAttack then
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    local track = animator:LoadAnimation(animAttack)
                    track:Play()
                end
            end
        end
        
        print("✅ " .. unidad.Name .. " atacó a " .. objetivo.Name)
    end
    
    return true -- Aún atacando
end

-- ✅ Movimiento con cancelación de ataque
ordenMoverUnidad.OnServerEvent:Connect(function(jugador, unidad, destino)
    if not unidad or not unidad:IsDescendantOf(workspace) then return end
    if unidad:GetAttribute("Owner") ~= jugador.UserId then return end

    -- Cambiar estado y guardar destino
	unidad:SetAttribute("Estado", "Moving")
	unidad:SetAttribute("Destino", destino)
	unidad:SetAttribute("Objetivo", nil)
	unidad:SetAttribute("Mineral", nil)


    -- Cancelar acciones previas
    if MinadosActivos[unidad] then
        MinadosActivos[unidad] = false
        unidad:SetAttribute("Minando", false)
		unidad:SetAttribute("MineralId", nil)
    end

    local humanoid = unidad:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    
end)

ordenAtacarUnidad.OnServerEvent:Connect(function(jugador, unidad, enemigo)
    if not unidad or not enemigo then return end
    if unidad:GetAttribute("Owner") ~= jugador.UserId then return end

    -- Validaciones básicas
    if enemigo == unidad then return end
    if enemigo == jugador.Character then return end
    if enemigo:GetAttribute("Owner") == jugador.UserId then return end
    
    -- Verificar que el enemigo tiene Humanoid
    if not enemigo:FindFirstChildOfClass("Humanoid") then return end

    -- Cancelar otras acciones
    if MinadosActivos[unidad] then
        MinadosActivos[unidad] = false
        unidad:SetAttribute("Minando", false)
    end
    
    -- Limpiar movimiento previo
    local humanoid = unidad:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:MoveTo(unidad:GetPivot().Position)
    end

        -- Establecer nuevo estado
    unidad:SetAttribute("Estado", "Attacking")
    unidad:SetAttribute("Destino", nil)
    unidad:SetAttribute("Mineral", nil)
    ObjetivosUnidades[unidad] = enemigo  -- Guardar en tabla
    
    print("🎯 " .. unidad.Name .. " atacando a " .. enemigo.Name)
end)
	--if enemigo:GetAttribute("EsEnemigo") == false then return end eliminado de ordenatacarunidad}

--Bucle de minados
local function iniciarMinado(unidad, mineralId, tiempoMinado, jugador)
    local mineral = MineralesUnidades[unidad] or encontrarMineralPorId(mineralId)
    if not mineral then
        print("Mineral no encontrado para minar")
        return
    end
    
    unidad:SetAttribute("Estado", "Mining")
    unidad:SetAttribute("MineralId", mineralId)

    if not unidad or not mineral or not unidad:FindFirstChild("HumanoidRootPart") then 
        return 
    end

    -- Prevenir múltiples minas al mismo tiempo
    if unidad:GetAttribute("Minando") then 
        return 
    end
    unidad:SetAttribute("Minando", true)

    -- Mostrar barra de minado
    local barraGui = game.ReplicatedStorage:FindFirstChild("BarraMinado"):Clone()
    barraGui.Adornee = mineral
    barraGui.Parent = mineral
    barraGui.Enabled = true
    
    local fondoBarra = barraGui:FindFirstChild("FondoBarra")
    local barraProgreso = fondoBarra and fondoBarra:FindFirstChild("BarraProgreso")
    local textoMinado = barraGui:FindFirstChild("TextoMinado")
    
    if not barraProgreso then
        warn("No se encontró BarraProgreso en la GUI de minado")
        barraGui:Destroy()
        return
    end
    
    barraProgreso.Size = UDim2.new(0, 0, 1, 0)

    -- Iniciar tiempo de minado
    local tInicio = tick()
    local minando = true

    while minando and unidad:GetAttribute("Minando") and unidad.Parent and mineral.Parent do
        local tiempoTranscurrido = tick() - tInicio
        local progreso = math.clamp(tiempoTranscurrido / tiempoMinado, 0, 1)
        local tiempoRestante = tiempoMinado - tiempoTranscurrido

        -- Actualizar barra de progreso
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
        local peso = mineral:GetAttribute("Peso") 
        local cristales = jugador:FindFirstChild("Cristales")
        if cristales then
            cristales.Value += peso
        end
        mineral:Destroy()
        MineralesUnidades[unidad] = nil
        print("✅ " .. unidad.Name .. " ha completado el minado de " .. mineral.Name)
    else
        print("❌ " .. unidad.Name .. " ha cancelado el minado")
    end
end

local DISTANCIA_MINADO = 10 -- Distancia mínima para iniciar minado

local function acercarseYMinear(unidad, mineralId, tiempoMinado, jugador)
    local mineral = MineralesUnidades[unidad] or encontrarMineralPorId(mineralId)
    if not mineral then
        print("Mineral no encontrado para acercarse")
        return
    end
    
    unidad:SetAttribute("Estado", "Mining")
    unidad:SetAttribute("MineralId", mineralId)

    if not unidad or not mineral then return end

    local humanoid = unidad:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local rootPart = unidad:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    if unidad:GetAttribute("PuedeMinar") ~= true then
        warn("Unidad no puede minar:", unidad.Name)
        return
    end
    
    -- Mover unidad al mineral
    local targetPosition = mineral:GetPivot().Position
    humanoid:MoveTo(targetPosition)
    print(unidad.Name .. " Acercandose al mineral " .. mineral.Name)

    local conexion
    local timeout = 30
    local tiempoInicio = os.time()
    local intentos = 0
    local maxIntentos = 5

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
        if intentos % 100 == 0 then
            humanoid:MoveTo(targetPosition)
        end
        
        -- 4. Calcular distancia
        local distancia = (rootPart.Position - targetPosition).Magnitude
        print("Distancia al mineral: " .. math.floor(distancia) .. " studs")

        -- 5. Verificar si está lo suficientemente cerca
        if distancia <= DISTANCIA_MINADO then
            if conexion then conexion:Disconnect() end

            print(unidad.Name .. " alcanzó el mineral a " .. math.floor(distancia) .. " studs")

            -- Iniciar minado
            local MinarRemoteEvent = remoteEvents:WaitForChild("MinarRemoteEvent")
            MinarRemoteEvent:FireClient(jugador, unidad, tiempoMinado)
            print(unidad.Name .. " ha comenzado a minar " .. mineral.Name)
            iniciarMinado(unidad, mineralId, tiempoMinado, jugador)
        end
    end)
end

local ordenMinarUnidad = remoteEvents:WaitForChild("OrdenMinarUnidad")

ordenMinarUnidad.OnServerEvent:Connect(function(jugador, unidad, mineral)
    if not unidad or not mineral then return end
    if not unidad:GetAttribute("PuedeMinar") then return end
    if not mineral:GetAttribute("EsMineral") then return end

    -- Asignar ID único al mineral si no lo tiene
    if not mineral:GetAttribute("MineralId") then
        mineral:SetAttribute("MineralId", "mineral_" .. tick() .. "_" .. mineral.Name)
    end

    local tiempoMinado = mineral:GetAttribute("TiempoMinado")
    local peso = mineral:GetAttribute("Peso") or 1
    local cristales = jugador:FindFirstChild("Cristales")

    -- Iniciar proceso de minado
    task.wait(0.1)
    MinadosActivos[unidad] = true
    
    -- 🔥 Guardar en tabla en lugar de Attribute
    unidad:SetAttribute("Estado", "Mining")
    unidad:SetAttribute("MineralId", mineral:GetAttribute("MineralId"))
    unidad:SetAttribute("Destino", nil)
    unidad:SetAttribute("ObjetivoId", nil)
    
    MineralesUnidades[unidad] = mineral
    ObjetivosUnidades[unidad] = nil -- Limpiar ataque si había
    
    acercarseYMinear(unidad, mineral:GetAttribute("MineralId"), tiempoMinado, jugador)
end)



RunService.Heartbeat:Connect(function(dt)
    for _, unidad in ipairs(workspace:GetChildren()) do
        if unidad:IsA("Model") and unidad:FindFirstChildOfClass("Humanoid") then
            local estado = unidad:GetAttribute("Estado")
            
            if estado == "Moving" then
                local destino = unidad:GetAttribute("Destino")
                if destino then
                    local humanoid = unidad:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:MoveTo(destino)
                        local distancia = (unidad:GetPivot().Position - destino).Magnitude
                        if distancia <= 5 then
                            unidad:SetAttribute("Estado", "Idle")
                        end
                    end
                end
                
            elseif estado == "Attacking" then
            	local objetivo = ObjetivosUnidades[unidad]
            if objetivo and objetivo.Parent then
                local continuarAtaque = atacarUnidad(unidad, objetivo, dt)
                if not continuarAtaque then
                    -- Terminar ataque
                    unidad:SetAttribute("Estado", "Idle")
                    ObjetivosUnidades[unidad] = nil
                    print("⚡ " .. unidad.Name .. " terminó ataque")
                end
            else
                -- Objetivo desapareció
                unidad:SetAttribute("Estado", "Idle")
                ObjetivosUnidades[unidad] = nil
            end
                
            elseif estado == "Mining" then
                -- Tu código de minado existente
                local cristal = unidad:GetAttribute("Mineral")
                if cristal and not unidad:GetAttribute("Minando") then
                    local jugador = unidad:GetAttribute("Owner") and game.Players:GetPlayerByUserId(unidad:GetAttribute("Owner"))
                    if jugador then
                        iniciarMinado(unidad, cristal, cristal:GetAttribute("TiempoMinado"), jugador)
                    end
					else
            	-- Si el mineral no existe, cancelar minado
            	unidad:SetAttribute("Estado", "Idle")
            	unidad:SetAttribute("MineralId", nil)
        	
                end
            end
        end
    end
end)
-- 🔥 Función para limpiar tabla cuando una unidad es destruida
game:GetService("Workspace").DescendantRemoving:Connect(function(descendant)
    if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") then
        -- Limpiar si esta unidad era objetivo de alguien
        for unidad, objetivo in pairs(ObjetivosUnidades) do
            if objetivo == descendant then
                ObjetivosUnidades[unidad] = nil
                if unidad:GetAttribute("Estado") == "Attacking" then
                    unidad:SetAttribute("Estado", "Idle")
                    unidad:SetAttribute("ObjetivoId", nil)
                end
            end
        end
        
        -- Limpiar si esta unidad tenía un objetivo
        if ObjetivosUnidades[descendant] then
            ObjetivosUnidades[descendant] = nil
        end
    end
end)

