local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")

local playerGui = player:WaitForChild("PlayerGui")
local Personajeui = playerGui:WaitForChild("PersonajeUI")
local menu = Personajeui:WaitForChild('Menu')
local control = menu:WaitForChild("ControlButton")
local activarControl = control:WaitForChild("ActivarControl")

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

-- 🔥 DECLARAR TODAS LAS VARIABLES
local highlightActual = nil
local selectionBox = nil  -- Frame del cuadro de selección
local startMousePos = nil
local selectedUnits = {}  -- Tabla para almacenar unidades seleccionadas
local highlights = {}     -- Tabla para almacenar highlights
local isDragging = false  -- Si está arrastrando para selección múltiple

-- 🔥 CREAR UN SCREENGUI DEDICADO PARA EL CUADRO DE SELECCIÓN
local selectionScreenGui = Instance.new("ScreenGui")
selectionScreenGui.Name = "SelectionScreenGui"
selectionScreenGui.DisplayOrder = 999  -- Lo más alto posible
selectionScreenGui.ResetOnSpawn = false
selectionScreenGui.Parent = playerGui

-- Función para limpiar selección múltiple
local function limpiarSeleccionMultiple()
    for unit, highlight in pairs(highlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    highlights = {}
    selectedUnits = {}
    
    -- Limpiar selección simple también
    seleccionActual.Value = nil
    if highlightActual then
        highlightActual:Destroy()
        highlightActual = nil
    end
end

-- Función para aplicar highlight a una unidad
local function aplicarHighlight(unidad, color)
    if not unidad then return nil end
    
    -- Remover highlight anterior si existe
    if highlights[unidad] then
        highlights[unidad]:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color or Color3.fromRGB(100, 150, 200)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(50, 100, 255)
    highlight.OutlineTransparency = 0.3
    highlight.Adornee = unidad
    highlight.Parent = playerGui
    highlight.Name = "SelectionHighlight"
    
    highlights[unidad] = highlight
    return highlight
end

-- Creacion del Frame de seleccion multiple de unidades
local function createSelectionBox(startPos)
    if selectionBox then
        selectionBox:Destroy()
        selectionBox = nil
    end

    -- Crear el Frame principal
    selectionBox = Instance.new("Frame")
    selectionBox.Name = "SelectionBox"
    selectionBox.BackgroundColor3 = Color3.fromRGB(18, 142, 195)
    selectionBox.BackgroundTransparency = 0.5  -- 50% transparente
    selectionBox.BorderSizePixel = 1
    selectionBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
    selectionBox.Position = UDim2.new(0, startPos.X, 0, startPos.Y)
    selectionBox.Size = UDim2.new(0, 0, 0, 0)
    selectionBox.Visible = true
    selectionBox.Parent = selectionScreenGui
    
    print("✅ Cuadro de selección creado en:", startPos.X, startPos.Y)
    return selectionBox
end

-- 🔥 FUNCIÓN PARA ACTUALIZAR EL CUADRO DE SELECCIÓN
local function updateSelectionBox(endPos)
    if not selectionBox or not startMousePos then 
        return 
    end

    local minX = math.min(startMousePos.X, endPos.X)
    local minY = math.min(startMousePos.Y, endPos.Y)
    local maxX = math.max(startMousePos.X, endPos.X)
    local maxY = math.max(startMousePos.Y, endPos.Y)

    selectionBox.Position = UDim2.new(0, minX, 0, minY)
    selectionBox.Size = UDim2.new(0, maxX - minX, 0, maxY - minY)
    
    print("📐 Cuadro actualizado:", minX, minY, maxX - minX, maxY - minY)
end

-- 🔥 FUNCIÓN PRINCIPAL: DETECTAR UNIDADES DENTRO DEL CUADRO
local function detectarUnidadesEnCuadro()
    if not startMousePos or not selectionBox then return end
    
    local currentPos = Vector2.new(mouse.X, mouse.Y)
    local minX = math.min(startMousePos.X, currentPos.X)
    local minY = math.min(startMousePos.Y, currentPos.Y)
    local maxX = math.max(startMousePos.X, currentPos.X)
    local maxY = math.max(startMousePos.Y, currentPos.Y)
    
    -- Verificar si Shift está presionado (para añadir a selección)
    local teclaShiftPresionada = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
                                 UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    
    -- Si no está presionando Shift, limpiar selección anterior
    if not teclaShiftPresionada and not isDragging then
        limpiarSeleccionMultiple()
        isDragging = true
    end
    
    -- Temporalmente guardar las unidades dentro del cuadro
    local unidadesEnCuadro = {}
    
    -- Buscar todas las unidades del jugador en el workspace
    for _, unit in ipairs(workspace:GetChildren()) do
        if unit:IsA("Model") and unit:GetAttribute("Owner") == player.UserId then
            -- 🔥 EXCLUIR AL JUGADOR: no seleccionar el personaje del jugador
            if unit == player.Character then
                continue
            end
            
            local humanoidRootPart = unit:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                -- Convertir posición 3D a posición 2D en pantalla
                local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                if visible and 
                   screenPos.X >= minX and screenPos.X <= maxX and
                   screenPos.Y >= minY and screenPos.Y <= maxY then
                   
                    -- Agregar unidad a la lista temporal
                    unidadesEnCuadro[unit] = true
                    
                    -- Si la unidad no está ya seleccionada, agregarla
                    if not selectedUnits[unit] then
                        selectedUnits[unit] = true
                        aplicarHighlight(unit, Color3.fromRGB(100, 150, 200))
                        print("➕ Unidad añadida:", unit.Name)
                    end
                end
            end
        end
    end
    
    -- 🔥 LIMPIAR UNIDADES QUE YA NO ESTÁN EN EL CUADRO (solo si no estamos añadiendo con Shift)
    if not teclaShiftPresionada then
        for unit, _ in pairs(selectedUnits) do
            if not unidadesEnCuadro[unit] then
                selectedUnits[unit] = nil
                if highlights[unit] then
                    highlights[unit]:Destroy()
                    highlights[unit] = nil
                    print("➖ Unidad removida:", unit.Name)
                end
            end
        end
    end
end

-- 🔥 FUNCIÓN PARA DESTRUIR EL CUADRO DE SELECCIÓN
local function destroySelectionBox()
    if selectionBox then
        selectionBox:Destroy()
        selectionBox = nil
    end
    isDragging = false
    print("🗑️ Cuadro de selección destruido")
end

-- Clic izquierdo: Selección simple o múltiple
mouse.Button1Down:Connect(function()
    if not activarControl.Value then 
        print("❌ Control desactivado")
        return 
    end
    
    local teclaShiftPresionada = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
                                 UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    
    print("🖱️ Click izquierdo. Shift:", teclaShiftPresionada)
    
    if teclaShiftPresionada then
        -- 🔥 Modo selección múltiple (con cuadro visual)
        startMousePos = Vector2.new(mouse.X, mouse.Y)
        createSelectionBox(startMousePos)
    else
        -- 🔥 Selección simple (click sin Shift)
        local objetivo = mouse.Target
        if not objetivo then 
            -- Click en el aire: deseleccionar todo
            limpiarSeleccionMultiple()
            print("🌌 Click en el aire - Deseleccionar todo")
            return 
        end
        
        local modelo = objetivo:FindFirstAncestorWhichIsA("Model")
        if not modelo then 
            limpiarSeleccionMultiple()
            print("❓ No es un modelo")
            return 
        end
        
        -- Verificar si es una unidad del jugador
        local owner = modelo:GetAttribute("Owner")
        if owner and owner == player.UserId then
            -- Seleccionar esta unidad individualmente
            limpiarSeleccionMultiple()
            seleccionActual.Value = modelo
            selectedUnits[modelo] = true
            aplicarHighlight(modelo, Color3.fromRGB(0, 200, 255))
            print("👤 Unidad seleccionada:", modelo.Name)
        else
            -- Click en algo que no es nuestra unidad: deseleccionar
            limpiarSeleccionMultiple()
            print("🚫 No es tu unidad")
        end
    end
end)

-- 🔥 ACTUALIZAR MIENTRAS SE ARRASTRA EL MOUSE
mouse.Move:Connect(function()
    if startMousePos and selectionBox then
        local currentPos = Vector2.new(mouse.X, mouse.Y)
        updateSelectionBox(currentPos)
        detectarUnidadesEnCuadro()
    end
end)

-- 🔥 SOLTAR CLICK: FINALIZAR SELECCIÓN
mouse.Button1Up:Connect(function()
    if startMousePos and selectionBox then
        -- Finalizar detección de unidades
        detectarUnidadesEnCuadro()
        
        -- Destruir el cuadro visual
        destroySelectionBox()
        
        -- Contar unidades seleccionadas
        local count = 0
        for _ in pairs(selectedUnits) do
            count = count + 1
        end
        
        if count > 0 then
            print("✅ " .. count .. " unidades seleccionadas")
            
            -- Si solo hay una, actualizar selección simple
            if count == 1 then
                for unit, _ in pairs(selectedUnits) do
                    seleccionActual.Value = unit
                    break
                end
            else
                seleccionActual.Value = nil
            end
        else
            -- Si no se seleccionó nada, limpiar todo
            limpiarSeleccionMultiple()
            print("📭 No se seleccionaron unidades")
        end
        
        startMousePos = nil
    end
end)

-- Clic derecho: Dar órdenes (se mantiene igual)
mouse.Button2Down:Connect(function()
    if not activarControl.Value then 
        print("❌ Control desactivado")
        return 
    end
    
    -- Determinar a qué unidades dar órdenes
    local unidades = {}
    
    -- Si hay selección múltiple, usarlas
    local tieneSeleccionMultiple = false
    for unit, _ in pairs(selectedUnits) do
        table.insert(unidades, unit)
        tieneSeleccionMultiple = true
    end
    
    -- Si no hay selección múltiple, usar selección simple
    if not tieneSeleccionMultiple and seleccionActual.Value then
        table.insert(unidades, seleccionActual.Value)
    end
    
    if #unidades == 0 then
        print("🚫 No hay unidades seleccionadas")
        return
    end
    
    print("🎯 Dando órdenes a " .. #unidades .. " unidades")
    
    local objetivo = mouse.Target
    if not objetivo then
        -- Mover al suelo
        local pos = mouse.Hit.Position
        for i, unidad in ipairs(unidades) do
            local spacing = 4
            local offset = Vector3.new(
                ((i-1) % 5) * spacing - 8,  -- Formación de 5 columnas
                0,
                math.floor((i-1) / 5) * spacing
            )
            ordenMoverUnidad:FireServer(unidad, pos + offset)
        end
        print("🚶 Moviendo " .. #unidades .. " unidades a:", pos)
        return
    end
    
    -- Determinar tipo de orden
    if objetivo:FindFirstAncestorWhichIsA("Model") then
        local modelo = objetivo:FindFirstAncestorWhichIsA("Model")
        
        -- ATAQUE MÚLTIPLE
        local owner = modelo:GetAttribute("Owner")
        local tieneHumanoid = modelo:FindFirstChildOfClass("Humanoid")
        
        if tieneHumanoid and owner ~= player.UserId then
            -- Es enemigo
            for _, unidad in ipairs(unidades) do
                ordenAtacarUnidad:FireServer(unidad, modelo)
            end
            print("⚔️ Atacando enemigo:", modelo.Name)
            return
        end
        
        -- MINADO MÚLTIPLE
        if modelo:GetAttribute("EsMineral") then
            for _, unidad in ipairs(unidades) do
                if unidad:GetAttribute("PuedeMinar") then
                    ordenMinarUnidad:FireServer(unidad, modelo)
                end
            end
            print("⛏️ Minando mineral:", modelo.Name)
            return
        end
    end
    
    -- MOVIMIENTO MÚLTIPLE (click en objeto no interactivo)
    local pos = mouse.Hit.Position
    for i, unidad in ipairs(unidades) do
        local spacing = 4
        local offset = Vector3.new(
            ((i-1) % 5) * spacing - 8,
            0,
            math.floor((i-1) / 5) * spacing
        )
        ordenMoverUnidad:FireServer(unidad, pos + offset)
    end
    print("🚶 Moviendo " .. #unidades .. " unidades (objeto no interactivo)")
end)

-- Sistema para deseleccionar cuando unidades mueren
game:GetService("RunService").Heartbeat:Connect(function()
    -- Verificar si las unidades seleccionadas aún existen
    local unidadesAEliminar = {}
    
    for unit, _ in pairs(selectedUnits) do
        if not unit.Parent then
            table.insert(unidadesAEliminar, unit)
        end
    end
    
    for _, unit in ipairs(unidadesAEliminar) do
        selectedUnits[unit] = nil
        if highlights[unit] then
            highlights[unit]:Destroy()
            highlights[unit] = nil
            print("💀 Unidad muerta removida de selección:", unit.Name)
        end
    end
    
    -- Si no quedan unidades seleccionadas múltiples, limpiar
    local count = 0
    for _ in pairs(selectedUnits) do
        count = count + 1
    end
    
    if count == 0 then
        selectedUnits = {}
        if seleccionActual.Value and not seleccionActual.Value.Parent then
            seleccionActual.Value = nil
        end
    end
end)

-- Función para seleccionar todas las unidades visibles
local function seleccionarTodasUnidades()
    limpiarSeleccionMultiple()
    
    for _, unit in ipairs(workspace:GetChildren()) do
        if unit:IsA("Model") and unit:GetAttribute("Owner") == player.UserId then
            if unit:FindFirstChildOfClass("Humanoid") then
                selectedUnits[unit] = true
                aplicarHighlight(unit, Color3.fromRGB(100, 150, 200))
            end
        end
    end
    
    local count = 0
    for _ in pairs(selectedUnits) do
        count = count + 1
    end
    
    if count > 1 then
        print("✅ " .. count .. " unidades seleccionadas (Ctrl+A)")
        seleccionActual.Value = nil
    elseif count == 1 then
        for unit, _ in pairs(selectedUnits) do
            seleccionActual.Value = unit
            break
        end
    else
        print("📭 No hay unidades para seleccionar")
    end
end

-- Atajo de teclado: Ctrl+A para seleccionar todas las unidades
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.A and 
       (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or 
        UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        seleccionarTodasUnidades()
    end
end)

print("✅ Script de selección múltiple cargado correctamente")
print("📌 Instrucciones:")
print("   • Shift + arrastre = Seleccionar múltiples unidades (aparecerá un cuadro azul)")
print("   • Click sin Shift = Seleccionar una unidad")
print("   • Ctrl + A = Seleccionar todas las unidades")
print("   • Click derecho = Dar órdenes")