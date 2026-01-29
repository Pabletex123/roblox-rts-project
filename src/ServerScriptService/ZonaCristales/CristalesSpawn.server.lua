local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ZonaCristalesSpawn = workspace:WaitForChild("ZonasCristalSpawn")
local CristalesFolder = ReplicatedStorage:WaitForChild("ModelosCristales")

local TIEMPO_ROTACION_MINUTOS = 10
local PROBABILIDAD_SPAWN = 0.05
print("📦 Modelos de cristales encontrados:", CristalesFolder:GetChildren())

local rarezas = {
	Bajo = {
		prob = 0.95,
		pesoMin = 5, pesoMax = 80, --5 min 80 max
		carpeta = CristalesFolder:WaitForChild("Bajo"),
	},
	Medio = {
		prob = 0.04,
		pesoMin = 2, pesoMax = 20,
		carpeta = CristalesFolder:WaitForChild("Medio"),

	},
	Alto = {
		prob = 0.01,
		pesoMin = 0.1, pesoMax = 3,
		carpeta = CristalesFolder:WaitForChild("Alto"),

	},
	--Especial = {
	--	prob = 0.001,
	--	--peso = peso definido para cada gema  y entre ellos deben tener probabilidades propias ya que seran de habilidades especiales estadisticas permantentes hasta otras habilidades
	--	carpeta = CristalesFolder:WaitForChild("Especiales"),
		
	--}, --todavia no existen
}

-- Elegir rareza
local function elegirRareza()
	local roll = math.random()
	local acumulado = 0
	for nombre, data in pairs(rarezas) do
		acumulado += data.prob
		if roll <= acumulado then
			return nombre, data
		end
	end
	return "Bajo", rarezas.Bajo
end


-- Verifica si hay cristales ya colocados en el mapa
local function hayCristalesEnMapa()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:GetAttribute("Rareza") then
			return true
		end
	end
	return false
end

-- Genera cristales en puntos con chance del 5%
local function generarCristales()
	for _, punto in ipairs(ZonaCristalesSpawn:GetChildren()) do
		if punto:IsA("BasePart") and math.random() < PROBABILIDAD_SPAWN then
			local nombreRareza, rarezaData = elegirRareza()
			local modelos = rarezaData.carpeta:GetChildren()

			if #modelos > 0 then
				local modeloAleatorio = modelos[math.random(1, #modelos)]
				local copia = modeloAleatorio:Clone()

				if not copia.PrimaryPart then
					copia.PrimaryPart = copia:FindFirstChildWhichIsA("BasePart")
				end

				if copia.PrimaryPart then
					local peso = math.random(rarezaData.pesoMin * 10, rarezaData.pesoMax * 10) / 10
					copia:SetAttribute("Peso", peso)
					copia:SetAttribute("Rareza", nombreRareza)
					copia:SetAttribute("EsMineral", true) -- ✅ Esto lo diferencia de otras unidades
				
					-- Calcular tiempo de minado modificar segun se sienta mejor la dificultad de rareza
					local calidad = nombreRareza -- asumimos que la rareza representa la calidad
					local tiempoMinado

					if calidad == "Bajo" then
						tiempoMinado = peso / 2 -- 1s por cada 2 de peso
					elseif calidad == "Medio" then
						tiempoMinado = peso / 1.5
					elseif calidad == "Alto" then
						tiempoMinado = peso / 1 -- 1s por cada 1 de peso
					--elseif calidad == "Especial" then
					--	tiempoMinado = peso / 0.01 -- 100s por cada 1 de peso  Todavia no existen de momento
					else
						tiempoMinado = peso / 1 -- valor por defecto
					end

					copia:SetAttribute("TiempoMinado", tiempoMinado)


					-- Escalar según peso
					local escala = 0.5 + (peso / 80)
					for _, parte in ipairs(copia:GetDescendants()) do
						if parte:IsA("BasePart") then
							parte.Size *= escala
						end
					end

					copia:SetPrimaryPartCFrame(CFrame.new(punto.Position))
					copia.Parent = workspace
				end
			end
		end
	end
end

-- Genera cristales forzadamente (sin 5% de chance), solo si no hay ningún cristal en el mapa
local function forzarGeneracionSiNoHayCristales()
	if not hayCristalesEnMapa() then
		print("💠 No hay cristales en el mapa. Forzando generación...")
		generarCristales()
	end
end

-- 🟢 Generación inicial al arrancar el servidor
generarCristales()

-- 🔁 Cada 10 minutos, intenta generar donde se pueda
while true do
	task.wait(TIEMPO_ROTACION_MINUTOS * 60)
	print("⌛ Rotación de cristales...")

	if hayCristalesEnMapa() then
		-- solo intenta generar en puntos con el 5%
		generarCristales()
	else
		-- si no hay ninguno, forzar generación
		forzarGeneracionSiNoHayCristales()
	end
end