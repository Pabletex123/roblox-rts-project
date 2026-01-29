--Esta ui esta reciclada de la de cartas por eso los nombres son asi menos los visibles en el juego

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a que se cargue el GUI que creaste antes
local screenGui = playerGui:WaitForChild("PersonajeUI")
local cardMenu = screenGui:WaitForChild("Menu")

-- Crear botón para abrir/cerrar
local openButton = Instance.new("TextButton")
openButton.Name = "OpenCardMenuButton"
openButton.Text = "Unidades"
openButton.Size = UDim2.new(0, 100, 0, 40)
openButton.Position = UDim2.new(0, 20, 0, 20)
openButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
openButton.TextColor3 = Color3.new(1,1,1)
openButton.Font = Enum.Font.SourceSansBold
openButton.TextSize = 20
openButton.Parent = screenGui

-- Acción al hacer clic
openButton.MouseButton1Click:Connect(function()
	cardMenu.Visible = not cardMenu.Visible
end)