local enemigo = script.Parent
local humanoid = enemigo:FindFirstChildOfClass("Humanoid")
local guardiaCentro = enemigo:GetPivot().Position
local radioPatrulla = 20
local objetivo = nil

local rangoVisionJugador = 20
local rangoPerseguirUnidad = 30
local rangoRegreso = 35
local velocidadAtaque = enemigo:GetAttribute("VelocidadAtaque") or 1
local damage = enemigo:GetAttribute("DamageAtaque") or 5
local rangoAtaque = enemigo:GetAttribute("RangoAtaque") or 6
local distanciaMinimaSeguir = rangoAtaque - 1

-- Buscar objetivo válido
local function buscarObjetivo()
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= enemigo then
			local root = obj:FindFirstChild("HumanoidRootPart")
			if root and (root.Position - enemigo:GetPivot().Position).Magnitude <= rangoVisionJugador then
				if not obj:GetAttribute("EsEnemigo") and obj:GetAttribute("Owner") then
					return obj
				end
			end
		end
	end
	return nil
end

-- Ataque con cooldown
local puedeAtacar = true
task.spawn(function()
	while enemigo and enemigo.Parent do
		if objetivo and objetivo:FindFirstChild("Humanoid") and puedeAtacar then
			local dist = (enemigo:GetPivot().Position - objetivo:GetPivot().Position).Magnitude
			if dist <= rangoAtaque then
				puedeAtacar = false
				objetivo:FindFirstChild("Humanoid"):TakeDamage(damage)
				task.wait(velocidadAtaque)
				puedeAtacar = true
			end
		end
		task.wait(0.1)
	end
end)

-- Patrullaje básico (se ejecuta solo cuando no hay objetivo)
task.spawn(function()
	while humanoid and humanoid.Health > 0 do
		if not objetivo then
			local punto = guardiaCentro + Vector3.new(
				math.random(-radioPatrulla, radioPatrulla),
				0,
				math.random(-radioPatrulla, radioPatrulla)
			)
			humanoid:MoveTo(punto)
			wait(4 + math.random())
		end
		wait(0.5)
	end
end)

-- Detección y seguimiento constantes
game:GetService("RunService").Heartbeat:Connect(function()
	if not objetivo then
		objetivo = buscarObjetivo()
	elseif objetivo and objetivo:FindFirstChild("Humanoid") then
		local dist = (objetivo:GetPivot().Position - enemigo:GetPivot().Position).Magnitude
		if dist <= rangoPerseguirUnidad then
			if dist > distanciaMinimaSeguir then
				humanoid:MoveTo(objetivo:GetPivot().Position)
			else
				humanoid:MoveTo(enemigo:GetPivot().Position) -- Detiene al acercarse
			end
		elseif dist > rangoRegreso then
			objetivo = nil
			humanoid:MoveTo(guardiaCentro)
		end
	end
end)
