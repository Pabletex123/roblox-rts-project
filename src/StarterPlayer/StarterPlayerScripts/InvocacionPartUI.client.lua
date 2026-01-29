
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local invocarUnidadEvento = remoteEvents:WaitForChild("InvocarUnidad")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnitUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui


local menu = Instance.new("Frame")--Frame del menu
menu.Name = "SummonFrame"
menu.Size = UDim2.new(0.6, 0, 0.6, 0)
menu.Position = UDim2.new(0.2 ,0 ,0.2 ,0)
menu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
menu.Visible = false
menu.Parent = screenGui


-- Función para animar botón de invocar
local function animateButton(button)
	local originalSize = button.Size
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local shrinkTween = TweenService:Create(button, tweenInfo, {Size = originalSize - UDim2.new(0, 10, 0, 10)})
	local growTween = TweenService:Create(button, tweenInfo, {Size = originalSize})

	shrinkTween:Play()
	shrinkTween.Completed:Connect(function()
		growTween:Play()
	end)
end





-- Contenedor de unidades
local container = Instance.new("Frame")
container.Name = "UnidadContainer"
container.Size = UDim2.new(1, -20, 1, -40)
container.Position = UDim2.new(0, 10, 0, 10)
container.BackgroundTransparency = 1
container.Parent = menu

-- Obtener StatsUnidades una sola vez al inicio
local function obtenerStatsUnidades()
	-- Intentar obtener de ReplicatedStorage primero (si existe una copia)
	local rs = game:GetService("ReplicatedStorage")
	if rs:FindFirstChild("StatsUnidades") then
		return require(rs:WaitForChild("StatsUnidades"))
	end
	-- Si no existe, retornar tabla vacía y usar valores por defecto
	return {}
end

local StatsUnidades = obtenerStatsUnidades()

local unidades = {
	{
		Nombre = "Ant",
		Descripcion = "hormiga.",
		Imagen = "rbxassetid://121644002622464", --id de hormiga imagen falta
		--Posicion 0, 0, 0, 0 por defecto
	},
	{
		Nombre = "Spider",
		Descripcion = "una arana.",
		Imagen = "rbxassetid://121644002622464", --id de arana imagen falta
		Posicion = UDim2.new(0, 120, 0, 0), -- posición personalizada + 120 por cada unidad

	},
	{
		Nombre = "NagaMinero",
		Descripcion = "Un naga Util para minar cristales o hacer diferentes tareas de no combate.",
		Imagen = "rbxassetid://138276118567451", --id de arana imagen falta
		Posicion = UDim2.new(0, 240, 0, 0), -- posición personalizada

	},
	{
		Nombre = "nagaUnidad",
		Descripcion = "algo.",
		Imagen = "rbxassetid://138276118567452", --id de arana imagen falta
		Posicion = UDim2.new(0, 360, 0, 0), -- posición personalizada
	},
	{
		Nombre = "Archer",
		Descripcion = "Un arquero veloz y preciso.",
		Imagen = "rbxassetid://138276118567452", --id de archer imagen falta
		Posicion = UDim2.new(0, 480, 0, 0), -- posición personalizada + 120 por cada unidad
	},
}
local mostrandoDetalle = false
local botonesUnidad = {} -- Guardamos todos los botones
for _, unidad in ipairs(unidades) do
	local frame = Instance.new("Frame") -- Frame para cada unidad
	frame.Name = "FrameUnidad"
	frame.Size = UDim2.new(0, 100, 0, 140)
	frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	frame.ZIndex = 2
	
	frame.Position = unidad.Posicion or UDim2.new(0, 0, 0, 0) -- posición personalizada o default PERMITE PONER UDIM2 COMO DATOS
	
	frame.Parent = container
	
	local img = Instance.new("ImageButton")
	img.Name = "ImagenUnidad"
	img.Image = unidad.Imagen  --llamando el nombre de la imagen a enviar data
	img.Size = UDim2.new(1, 0, 0, 100)
	img.BackgroundTransparency = 1
	img.ZIndex = 2
	img.Parent = frame

	local label = Instance.new("TextLabel")
	label.Text = unidad.Nombre--llamando el nombre de la unidad a enviar data
	label.Size = UDim2.new(1, 0, 0, 40)
	label.Position = UDim2.new(0, 0, 1, -40)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.TextWrapped = true
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14
	label.ZIndex = 2
	label.Parent = frame
	
	
	
	-- Crear Frame de detalles de carta (oculto)
	local detalleUnidad = Instance.new("Frame")
	detalleUnidad.Name = "DetalleUnidad"
	detalleUnidad.Size = UDim2.new(0, 0, 0, 0)
	detalleUnidad.Position = UDim2.new(0.5, -150, 0.5, -100)
	detalleUnidad.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	detalleUnidad.Visible = false
	detalleUnidad.ZIndex = 3
	detalleUnidad.Parent = frame

	local SummonButton = Instance.new("TextButton")--Boton de invocar 
	SummonButton.Name = "SummonButton"
	SummonButton.Size = UDim2.new(0.50, 0, 0.25, 0)
	SummonButton.Position = UDim2.new(0, 130, 0, 100)
	SummonButton.Text = "Invocar"
	SummonButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	SummonButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SummonButton.TextScaled = true
	SummonButton.ZIndex = 4
	SummonButton.Parent = detalleUnidad
	
	local precioUnidad = StatsUnidades[unidad.Nombre] and StatsUnidades[unidad.Nombre].Price or "?"

	local precioLabel = Instance.new("TextLabel")
	precioLabel.Name = "PrecioLabel"
	precioLabel.Size = UDim2.new(0, -20, 0, 5)
	precioLabel.Position = UDim2.new(1, -70, 0, 120)
	precioLabel.Text = tostring(precioUnidad) .. "💠"
	precioLabel.BackgroundTransparency = 1
	precioLabel.TextColor3 = Color3.new(1, 1, 1)
	precioLabel.Font = Enum.Font.SourceSans
	precioLabel.TextSize = 16
	precioLabel.ZIndex = 4
	precioLabel.Parent = detalleUnidad
	
	SummonButton.MouseButton1Click:Connect(function()
		animateButton(SummonButton)

		print("Invocando unidad:", unidad.Nombre)

		invocarUnidadEvento:FireServer({
			Nombre = unidad.Nombre,
			Descripcion = unidad.Descripcion,
			Imagen = unidad.Imagen
		})
		
	end)

	

	local imagen = Instance.new("ImageLabel")
	imagen.Name = "Imagen"
	imagen.Size = UDim2.new(0, 100, 0, 100)
	imagen.Position = UDim2.new(0, 10, 0, 10)
	imagen.BackgroundTransparency = 1
	imagen.Parent = detalleUnidad
	imagen.ZIndex = 3
	
	
	local nombre = Instance.new("TextLabel")
	nombre.Name = "Nombre"
	nombre.Size = UDim2.new(0, 150, 0, 30)
	nombre.Position = UDim2.new(0, 120, 0, 10)
	nombre.TextColor3 = Color3.new(1, 1, 1)
	nombre.BackgroundTransparency = 1
	nombre.Font = Enum.Font.SourceSansBold
	nombre.TextSize = 20
	nombre.Parent = detalleUnidad
	nombre.ZIndex = 3
	
	local descripcion = Instance.new("TextLabel")
	descripcion.Name = "Descripcion"
	descripcion.Text = unidad.Descripcion -- llamando a descripcion desde unidadData
	descripcion.Size = UDim2.new(0, 250, 0, 60)
	descripcion.Position = UDim2.new(0, 120, 0, 50)
	descripcion.TextColor3 = Color3.new(1, 1, 1)
	descripcion.BackgroundTransparency = 1
	descripcion.Font = Enum.Font.SourceSans
	descripcion.TextSize = 16
	descripcion.TextWrapped = true
	descripcion.TextXAlignment = Enum.TextXAlignment.Left
	descripcion.TextYAlignment = Enum.TextYAlignment.Top
	descripcion.Parent = detalleUnidad
	descripcion.ZIndex = 3
	
	--Crear el boton de cerrado del menu y se cierren juntos al cerrar el menu 
	--Estan juntos con el menu para evitar problemas para el jugador
	local closeBtnmenu = Instance.new("TextButton")
	closeBtnmenu.Name = "CerrarMenu"
	closeBtnmenu.Text = "X"
	closeBtnmenu.Size = UDim2.new(0, 30, 0, 30)
	closeBtnmenu.Position = UDim2.new(1, -35, 0, 5) -- Arriba a la derecha del Frame
	closeBtnmenu.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtnmenu.TextColor3 = Color3.new(1,1,1)
	closeBtnmenu.ZIndex = 12
	closeBtnmenu.Parent = menu

	closeBtnmenu.MouseButton1Click:Connect(function()
		menu.Visible = false
		detalleUnidad.Visible = false
		mostrandoDetalle = false
		for _, boton in ipairs(botonesUnidad) do
			boton.Active = true
			boton.AutoButtonColor = true
		end
	end)


	local closeBtnDescripcion = Instance.new("TextButton")--Boton de cerrar solo la descripcion
	closeBtnDescripcion.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtnDescripcion.TextColor3 = Color3.new(1,1,1)
	closeBtnDescripcion.Size = UDim2.new(0, 30, 0, 30)
	closeBtnDescripcion.Position = UDim2.new(0, 350, 0, 0)
	closeBtnDescripcion.Text = "X"
	closeBtnDescripcion.ZIndex = 12
	closeBtnDescripcion.Parent = detalleUnidad
	
	closeBtnDescripcion.MouseButton1Click:Connect(function()
		detalleUnidad.Visible = false
		mostrandoDetalle = false
		for _, boton in ipairs(botonesUnidad) do
			boton.Active = true
			boton.AutoButtonColor = true
		end
	end)
	
	
	img.MouseButton1Click:Connect(function()
		if mostrandoDetalle then return end -- 💥 evita abrir otra ventana

		mostrandoDetalle = true
		
		-- Desactivar los botones
		for _, boton in ipairs(botonesUnidad) do
			boton.Active = false
			boton.AutoButtonColor = false
		end
		local estaUnidadFrame = frame -- ← Guarda la unidad que fue clickeada(el Frame de la unidad)


		detalleUnidad.Visible = true
		detalleUnidad.Size = UDim2.new(0, 0, 0, 0)

		nombre.Text = unidad.Nombre
		descripcion.Text = unidad.Descripcion
		imagen.Image = unidad.Imagen

		local tween = TweenService:Create(detalleUnidad, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 380, 0, 160)
		})
		tween:Play()

	end)
	table.insert(botonesUnidad, img) -- Guardamos el botón
end

	
---- Acción al invocar araña
--summonButton.MouseButton1Click:Connect(function()
--	animateButton(summonButton)
--	print("Araña invocada (visual más adelante)")
--end)
--falta hacer el summon

