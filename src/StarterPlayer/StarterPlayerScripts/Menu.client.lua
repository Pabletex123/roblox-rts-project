local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PersonajeUI"--nombre del screengui de los personajes
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui


local menu = Instance.new("Frame")--Frame del menu
menu.Name = "Menu"
menu.Size = UDim2.new(0.6, 0, 0.6, 0)
menu.Position = UDim2.new(0.2 ,0 ,0.2 ,0)
menu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
menu.Visible = true
menu.Parent = screenGui
menu.Visible = false




local ControlButton = Instance.new("TextButton")
ControlButton.Name = "ControlButton"
ControlButton.Size = UDim2.new(0.35, 0, 0.15, 0)
ControlButton.Position = UDim2.new(0.35, 0, 0.85, 0)
ControlButton.Text = "Activar Control"
ControlButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ControlButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ControlButton.TextScaled = true
ControlButton.ZIndex = 4
ControlButton.Parent = menu

-- Crear el BoolValue que almacenará el estado
local activarControl = Instance.new("BoolValue")
activarControl.Name = "ActivarControl"
activarControl.Value = false
activarControl.Parent = ControlButton



local seleccion = player:FindFirstChild("UnidadSeleccionada")
if not seleccion then
	seleccion = Instance.new("ObjectValue")
	seleccion.Name = "UnidadSeleccionada"
	seleccion.Parent = player
end
local seleccion = player:FindFirstChild("UnidadSeleccionada")
if seleccion and seleccion.Value then
	local unidadSeleccionada = seleccion.Value
	print("La unidad seleccionada es:", unidadSeleccionada.Name)
end



-- Al hacer clic, se alterna el valor entre activado y desactivado
ControlButton.MouseButton1Click:Connect(function()
	activarControl.Value = not activarControl.Value

	if activarControl.Value then
		ControlButton.Text = "Modo Control ON"
		print("✅ Modo control activado")
	else
		ControlButton.Text = "Modo Control OFF"
		print("⛔ Modo control desactivado")
		seleccion.Value = nil
		--aqui
	end
end)



-- Crear Frame de detalles de carta (oculto)
local detalleCarta = Instance.new("Frame")
detalleCarta.Name = "DetalleUnidad"
detalleCarta.Size = UDim2.new(0, 0, 0, 0)
detalleCarta.Position = UDim2.new(0.5, -150, 0.5, -100)
detalleCarta.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
detalleCarta.Visible = false
detalleCarta.ZIndex = 2
detalleCarta.Parent = screenGui

local cornerDetalle = Instance.new("UICorner")
cornerDetalle.CornerRadius = UDim.new(0, 12)
cornerDetalle.Parent = detalleCarta

local imagen = Instance.new("ImageLabel")
imagen.Name = "Imagen"
imagen.Size = UDim2.new(0, 100, 0, 100)
imagen.Position = UDim2.new(0, 10, 0, 10)
imagen.BackgroundTransparency = 1
imagen.Parent = detalleCarta

local nombre = Instance.new("TextLabel")
nombre.Name = "Nombre"
nombre.Size = UDim2.new(0, 150, 0, 30)
nombre.Position = UDim2.new(0, 120, 0, 10)
nombre.TextColor3 = Color3.new(1, 1, 1)
nombre.BackgroundTransparency = 1
nombre.Font = Enum.Font.SourceSansBold
nombre.TextSize = 20
nombre.Parent = detalleCarta

local descripcion = Instance.new("TextLabel")
descripcion.Name = "Descripcion"
descripcion.Size = UDim2.new(0, 250, 0, 60)
descripcion.Position = UDim2.new(0, 120, 0, 50)
descripcion.TextColor3 = Color3.new(1, 1, 1)
descripcion.BackgroundTransparency = 1
descripcion.Font = Enum.Font.SourceSans
descripcion.TextSize = 16
descripcion.TextWrapped = true
descripcion.TextXAlignment = Enum.TextXAlignment.Left
descripcion.TextYAlignment = Enum.TextYAlignment.Top
descripcion.Parent = detalleCarta

local closeBtndetalle = Instance.new("TextButton")
closeBtndetalle.Name = "CerrarDetalle"
closeBtndetalle.Text = "X"
closeBtndetalle.Size = UDim2.new(0, 30, 0, 30)
closeBtndetalle.Position = UDim2.new(1, -35, 0, 5) -- Arriba a la derecha del Frame
closeBtndetalle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtndetalle.TextColor3 = Color3.new(1,1,1)
closeBtndetalle.ZIndex = 12
closeBtndetalle.Parent = detalleCarta

closeBtndetalle.MouseButton1Click:Connect(function()
	detalleCarta.Visible = false
end)



-- Decoración opcional
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = menu

-- Contenedor de unidades
local container = Instance.new("Frame")
container.Name = "UnidadesContainer"
container.Size = UDim2.new(1, -20, 1, -40)
container.Position = UDim2.new(0, 10, 0, 10)
container.BackgroundTransparency = 1
container.Parent = menu

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 100, 0, 140)
grid.CellPadding = UDim2.new(0, 10, 0, 10)
grid.Parent = container

-- Botón de cerrar
local closeBtnCard = Instance.new("TextButton")
closeBtnCard.Text = "X"
closeBtnCard.Size = UDim2.new(0, 30, 0, 30)
closeBtnCard.Position = UDim2.new(1, -35, 0, 5)
closeBtnCard.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtnCard.TextColor3 = Color3.new(1,1,1)
closeBtnCard.Parent = menu

closeBtnCard.MouseButton1Click:Connect(function()
	menu.Visible = false
end)

-- Aquí puedes agregar la generación de cartas como se explicó antes
local TweenService = game:GetService("TweenService")

-- Tabla de cartas disponibles
local unidades = {
	{
		Nombre = "Carta Rayo",
		Descripcion = "Invoca un rayo del cielo.",
		Imagen = "rbxassetid://138276118567450", -- Cambia esto por una ID real
		ToolId = "Rayo"
	},
	{
		Nombre = "Carta Fuego",
		Descripcion = "Lanza una bola de fuego ardiente.",
		Imagen = "rbxassetid://76514917824450",
		ToolId = "Fuego"
	}
}

-- Crear cada carta en el menú
for _, unidad in ipairs(unidades) do
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 100, 0, 140)
	frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	frame.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local img = Instance.new("ImageButton")
	img.Name = "Carta"
	img.Image = unidad.Imagen
	img.Size = UDim2.new(1, 0, 0, 100)
	img.BackgroundTransparency = 1
	img.Parent = frame

	local label = Instance.new("TextLabel")
	label.Text = unidad.Nombre
	label.Size = UDim2.new(1, 0, 0, 40)
	label.Position = UDim2.new(0, 0, 1, -40)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.TextWrapped = true
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14
	label.Parent = frame

	img.MouseButton1Click:Connect(function()
		local estaCartaFrame = frame -- ← Guarda la carta que fue clickeada

		-- Mostrar detalles
		detalleCarta.Parent = nil
		detalleCarta.Parent = screenGui

		detalleCarta.ZIndex = 10
		nombre.ZIndex = 11
		descripcion.ZIndex = 11

		detalleCarta.Visible = true
		detalleCarta.Size = UDim2.new(0, 0, 0, 0)

		nombre.Text = unidad.Nombre
		descripcion.Text = unidad.Descripcion
		imagen.Image = unidad.Imagen

		local tween = TweenService:Create(detalleCarta, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 380, 0, 160)
		})
		tween:Play()

	end)



end


local invocarUnidadEvento = remoteEvents:WaitForChild("InvocarUnidad") --recibe unidad data


invocarUnidadEvento.OnClientEvent:Connect(function(unidadData)
	
	print("Unidad recibida:", unidadData.Nombre)
	-- Misma lógica de generación que ya tienes
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 100, 0, 140)
	frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	frame.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local img = Instance.new("ImageButton") --Imagen del menu de las unidades?
	img.Name = "UnidadImagen"
	img.Image = unidadData.Imagen
	img.Size = UDim2.new(1, 0, 0, 100)
	img.ZIndex = 3    -- imagen de la unidad en unidades
	img.Parent = frame

	local label = Instance.new("TextLabel")
	label.Text = unidadData.Nombre  --Nombre de la unidad en unidades
	label.Size = UDim2.new(1, 0, 0, 40)
	label.Position = UDim2.new(0, 0, 1, -40)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.TextWrapped = true
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14
	label.ZIndex = 3
	label.Parent = frame
	
	-- Crear Frame de detalles de carta (oculto)
	local detalleUnidad = Instance.new("Frame")
	detalleUnidad.Name = "DetalleUnidad"
	detalleUnidad.Size = UDim2.new(0, 0, 0, 0)
	detalleUnidad.Position = UDim2.new(0.5, -150, 0.5, -100)
	detalleUnidad.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	detalleUnidad.Visible = false
	detalleUnidad.ZIndex = 4
	detalleUnidad.Parent = screenGui
	
	local cornerDetalle = Instance.new("UICorner")
	cornerDetalle.CornerRadius = UDim.new(0, 12)
	cornerDetalle.Parent = detalleUnidad

	local imagen = Instance.new("ImageLabel")
	imagen.Name = "ImagenUnidadDescripcion"
	imagen.Image = unidadData.Imagen
	imagen.Size = UDim2.new(0, 100, 0, 100)
	imagen.Position = UDim2.new(0, 10, 0, 10)
	imagen.BackgroundTransparency = 1
	imagen.ZIndex = 4
	imagen.Parent = detalleUnidad

	local nombre = Instance.new("TextLabel")
	nombre.Name = "NombreUnidad"
	nombre.Text  = unidadData.Nombre
	nombre.Size = UDim2.new(0, 150, 0, 30)
	nombre.Position = UDim2.new(0, 120, 0, 10)
	nombre.TextColor3 = Color3.new(1, 1, 1)
	nombre.BackgroundTransparency = 1
	nombre.Font = Enum.Font.SourceSansBold
	nombre.TextSize = 20
	nombre.ZIndex = 4
	nombre.Parent = detalleUnidad

	local descripcion = Instance.new("TextLabel")
	descripcion.Name = "Descripcion"
	descripcion.Text  = unidadData.Descripcion
	descripcion.Size = UDim2.new(0, 250, 0, 60)
	descripcion.Position = UDim2.new(0, 120, 0, 50)
	descripcion.TextColor3 = Color3.new(1, 1, 1)
	descripcion.BackgroundTransparency = 1
	descripcion.Font = Enum.Font.SourceSans
	descripcion.TextSize = 16
	descripcion.TextWrapped = true
	descripcion.ZIndex = 4
	descripcion.Parent = detalleUnidad

	local closeBtndetalle = Instance.new("TextButton")
	closeBtndetalle.Name = "CerrarDetalle"
	closeBtndetalle.Text = "X"
	closeBtndetalle.Size = UDim2.new(0, 30, 0, 30)
	closeBtndetalle.Position = UDim2.new(1, -35, 0, 5) -- Arriba a la derecha del Frame
	closeBtndetalle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtndetalle.TextColor3 = Color3.new(1,1,1)
	closeBtndetalle.ZIndex = 4
	closeBtndetalle.Parent = detalleUnidad

	closeBtndetalle.MouseButton1Click:Connect(function()
		detalleUnidad.Visible = false
	end)
	


	img.MouseButton1Click:Connect(function()
		-- Buscar los elementos dentro de su propio Frame
		local nombreLabel = detalleUnidad:FindFirstChild("Nombre")
		local descripcionLabel = detalleUnidad:FindFirstChild("Descripcion")
		local imagenLabel = detalleUnidad:FindFirstChild("Imagen")

		if nombreLabel and descripcionLabel and imagenLabel then
			nombreLabel.Text = unidadData.Nombre
			descripcionLabel.Text = unidadData.Descripcion
			imagenLabel.Image = unidadData.Imagen
		end

		detalleUnidad.Visible = true
		detalleUnidad.Size = UDim2.new(0, 0, 0, 0)

		local tween = TweenService:Create(detalleUnidad, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 380, 0, 160)
		})
		tween:Play()
	end)
end)


