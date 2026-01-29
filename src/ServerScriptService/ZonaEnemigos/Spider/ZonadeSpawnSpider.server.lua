local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModelosEnemigos = ReplicatedStorage:WaitForChild("ModelosEnemigos")
local SpiderModel = ModelosEnemigos:WaitForChild("Spider") -- asegúrate que esté allí

local zonaSpawns = workspace:WaitForChild("ZonasSpawnSpider")

for _, punto in pairs(zonaSpawns:GetChildren()) do
	if punto.Name:match("^SpawnAraña") then -- Coincide con nombres como "SpawnAraña", "SpawnAraña1", etc.
		if math.random() < 0.1 then -- 10% de probabilidad
			
			local copia = SpiderModel:Clone()
			-- Asignar estadísticas aleatorias
			local fuerza = math.random(7, 14) --Basandote en la peligrosidad de la zona y el mismo enemigo depende la fuerza maxima de los enemigos  Zona facil = mas debiles que la mayoria de jugadores
			local agilidad = math.random(7, 14)-- Por eso no usan las estadisticas aleatorias de StatsUnidades
			-- Cálculos basados en agilidad y fuerza
			local velocidad = agilidad + 3
			local velocidadAtaque = math.max(0.2, 2 - (agilidad / 100)) -- Nunca menos de 0.2
			local Ataque = fuerza * (velocidad / 100) --daño de ataque
			local rangoAtaque = 6 -- Puedes ajustarlo por tipo de unidad

			copia:SetAttribute("Fuerza", fuerza)
			copia:SetAttribute("Agilidad", agilidad)
			copia:SetAttribute("Velocidad", velocidad)
			copia:SetAttribute("VelocidadAtaque", velocidadAtaque)
			copia:SetAttribute("DamageAtaque", Ataque)
			copia:SetAttribute("RangoAtaque", rangoAtaque)

			-- También marcamos que es enemigo
			copia:SetAttribute("EsEnemigo", true)

			copia:PivotTo(CFrame.new(punto.Position))--Nueva forma sin primarypart
			copia.Parent = workspace
			--if not copia.PrimaryPart then
			--	copia.PrimaryPart = copia:FindFirstChild("HumanoidRootPart") or copia:FindFirstChildWhichIsA("BasePart")
			--end
			--if copia.PrimaryPart then
			--	copia:SetPrimaryPartCFrame(CFrame.new(punto.Position))
			--	copia.Parent = workspace
			--else
			--	warn("La araña no tiene PrimaryPart configurada")
			--end
		end
	end
end
