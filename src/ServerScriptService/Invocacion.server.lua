-- Script de invocación de unidades
-- Para agregar nuevas unidades:
-- 1. Crear el modelo en ReplicatedStorage/ModelosUnidades/{NombreUnidad}
-- 2. Crear el módulo de niveles en ServerScriptService/NivelesUnidades/{NombreUnidad}.lua
-- 3. Agregar las estadísticas en ServerScriptService/NivelesUnidades/StatsUnidades.lua
-- 4. Agregar la unidad a la lista en StarterPlayer/StarterPlayerScripts/InvocacionPartUI.client.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ModelosUnidades = ReplicatedStorage:WaitForChild("ModelosUnidades")
local NivelesUnidades = ServerScriptService:WaitForChild("NivelesUnidades")
local StatsUnidades = require(NivelesUnidades:WaitForChild("StatsUnidades"))

local invocarUnidadEvento = remoteEvents:WaitForChild("InvocarUnidad")

local function aplicarAtributosPorNivel(unidad, moduloUnidad)
	local nivelActual = unidad:GetAttribute("Nivel") or 0

	if not moduloUnidad or not moduloUnidad.Niveles then return end

	for nivel = 0, nivelActual do
		local data = moduloUnidad.Niveles[nivel]
		if data then
			for key, value in pairs(data) do
				if typeof(value) == "boolean" then
					unidad:SetAttribute(key, value)
				end
			end
		end
	end
end

invocarUnidadEvento.OnServerEvent:Connect(function(jugador, unidadData)
	local modeloNombre = unidadData.Nombre
	local modeloOriginal = ModelosUnidades:FindFirstChild(modeloNombre)

	invocarUnidadEvento:FireClient(jugador, unidadData)
	if modeloOriginal then
		local precio = StatsUnidades[modeloNombre] and StatsUnidades[modeloNombre].Price or 0
		local cristales = jugador:FindFirstChild("Cristales")

		if not cristales or cristales.Value < precio then
			warn(jugador.Name .. " no tiene suficientes cristales para invocar " .. modeloNombre)
			return
		end

		local copia = modeloOriginal:Clone()

		if not copia.PrimaryPart then
			copia.PrimaryPart = copia:FindFirstChild("HumanoidRootPart") or copia:FindFirstChildWhichIsA("BasePart")
		end
		cristales.Value -= precio
		
		--PRUEBA DE FISICAS
		-- Función para configurar física con densidad base + crecimiento visual
		local function configurarFisicaDelModelo(modelo, crecimiento)
			local densidadBase = 1
			local friccion = 0.5
			local densidadFinal = densidadBase + (crecimiento * 0.25) -- puedes ajustar este factor

			for _, part in pairs(modelo:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CustomPhysicalProperties = PhysicalProperties.new(densidadFinal, friccion, 0)
				end
			end
			local unidadesConCrecimiento = {
				["Spider"] = true,
				["Ant"] = true,
				["Thing"] = true,
				-- No incluir a "NagaMinero"
			}
		end
		--PRUEBA DE FISICAS EN PRUEBA!!!!
		
		if copia.PrimaryPart then
			local personaje = jugador.Character
			if personaje and personaje:FindFirstChild("HumanoidRootPart") then
				local posJugador = personaje.HumanoidRootPart.Position
				copia:SetPrimaryPartCFrame(CFrame.new(posJugador + Vector3.new(5, 0, 0)))
				copia.Parent = workspace

				-- ✅ Asignar atributos aleatorios
				local rango = StatsUnidades[modeloNombre]
				if rango then
					local fuerza = math.random(rango.Fuerza.min, rango.Fuerza.max)
					local agilidad = math.random(rango.Agilidad.min, rango.Agilidad.max)
					local vitalidad = math.random(rango.Vitalidad.min, rango.Vitalidad.max)
					
					-- Cálculos basados en agilidad y fuerza
					local velocidad = agilidad + 3
					local velocidadAtaque = math.max(0.2, 2 - (agilidad / 100)) -- Nunca menos de 0.2
					local Ataque = fuerza * (velocidad / 100) --daño de ataque
					local rangoAtaque = 6 -- Puedes ajustarlo por tipo de unidad
					-- requerir cada modulescript dentro de NivelesUnidades 
				local moduloUnidad = require(NivelesUnidades:FindFirstChild(modeloNombre))--Buscar las estadisticas y habilidades especiales en los niveles dependiendo la unidad
					copia:SetAttribute("TipoAtaque", moduloUnidad.Niveles[0].TipoAtaque or "Melee") -- debe ser "Rango" para proyectil
					copia:SetAttribute("Projectile", moduloUnidad.Niveles[0].Projectile or "None")

					copia:SetAttribute("Vitalidad", vitalidad)
					
					copia:SetAttribute("Fuerza", fuerza)
					copia:SetAttribute("Agilidad", agilidad)
					copia:SetAttribute("Velocidad", velocidad)
					copia:SetAttribute("VelocidadAtaque", velocidadAtaque)
					copia:SetAttribute("DamageAtaque", Ataque)
					copia:SetAttribute("RangoAtaque", moduloUnidad.Niveles[0].RangoAtaque or 6)

					copia:SetAttribute("VidaMaxima", vidaTotal)
					-- Al crear una unidad:
					--copia:SetAttribute("UnidadId", tick() .. "_" .. nuevaUnidad.Name)--


					copia:SetAttribute("Nivel", 0)--Asigna el nivel inicial 0
					copia:SetAttribute("XP", 0)          -- Experiencia inicial
					copia:SetAttribute("XPParaSubir", 100) -- Experiencia necesaria para subir al siguiente nivel
					
					local nivelActual = copia:GetAttribute("Nivel") -- Obtener el nivel actual
					aplicarAtributosPorNivel(copia, moduloUnidad)
					
					print(modeloNombre .. "Invocacion exitosa Inicia en el nivel 0 Fuerza:", fuerza, "Agilidad:", agilidad, "Velocidad:", velocidad, "Daño:", Ataque)
					copia:SetAttribute("setEstado", "Idle") -- Estado inicial

					-- Cálculo y aplicación del crecimiento base
					--local crecimientoBase = 1 + (fuerza + agilidad) / 300 --Recalcular un crecimiento estable ademas junto con la nivelacion
				-- tamaño = vitalidad(tamaño actual del modelo entre masmas vida mas grande el modelo)
				--	copia:SetAttribute("Vida",) Vida del modelo(falta hacer)

				end

				copia:SetAttribute("Owner", jugador.UserId)
			end
		end
	else
		warn("No se encontró el modelo de unidad:", modeloNombre)
	end
end)




