local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ordenAtacarUnidad = ReplicatedStorage:WaitForChild("OrdenAtacarUnidad")

ordenAtacarUnidad.OnServerEvent:Connect(function(jugador, unidad, enemigo)
	if not unidad or not enemigo then return end
	if unidad:GetAttribute("Owner") ~= jugador.UserId then return end
	if not enemigo:IsDescendantOf(workspace) or not enemigo:GetAttribute("EsEnemigo") then return end

	local humanoid = unidad:FindFirstChildOfClass("Humanoid")
	local enemigoHumanoid = enemigo:FindFirstChildOfClass("Humanoid")
	if not humanoid or not enemigoHumanoid then return end

	local velocidadAtaque = unidad:GetAttribute("VelocidadAtaque")
	local damage = unidad:GetAttribute("DañoAtaque")
	local rango = unidad:GetAttribute("RangoAtaque")

	print("Velocidad de ataque:", velocidadAtaque)
	print("Daño de ataque:", damage)
	print("Rango de ataque:", rango)

	local function atacar()
		while enemigoHumanoid and enemigoHumanoid.Health > 0 and unidad and unidad.Parent do
			local distancia = (unidad:GetPivot().Position - enemigo:GetPivot().Position).Magnitude
			print("Distancia:", distancia)

			if distancia <= rango then
				enemigoHumanoid:TakeDamage(damage)
			else
				humanoid:MoveTo(enemigo:GetPivot().Position)
			end
			task.wait(velocidadAtaque)
		end
	end

	task.spawn(atacar)
end)
