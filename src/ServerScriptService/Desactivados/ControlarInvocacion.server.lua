local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ordenMoverUnidad = ReplicatedStorage:WaitForChild("OrdenMoverUnidad")



	--Detectar llegada al destino.
	--Buscar enemigos dentro de un radio.
	--Decidir si atacar.


ordenMoverUnidad.OnServerEvent:Connect(function(jugador, unidad, destino)
	if not unidad or not unidad:IsDescendantOf(workspace) then return end
	if unidad:GetAttribute("Owner") ~= jugador.UserId then return end

	local humanoid = unidad:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Mover a la posición solicitada
	humanoid:MoveTo(destino)

	-- Monitorear hasta que llegue al destino o detecte enemigos
	local arrived = false
	local distanciaMinima = 5
	local radioDeteccion = 12
	local enemigoDetectado = nil

	-- Verificamos cada frame si se acerca al destino
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not unidad or not unidad.Parent then
			connection:Disconnect()
			return
		end

		local posActual = unidad:GetPivot().Position
		if (posActual - destino).Magnitude <= distanciaMinima then
			arrived = true --llegada Confirmada
		end

		if arrived then-- Si llego entonces
			-- Buscar enemigos cercanos en un radio de 12 unidades
			for _, obj in ipairs(workspace:GetChildren()) do
				if obj:IsA("Model") and obj:GetAttribute("EsEnemigo") then
					local root = obj:FindFirstChild("HumanoidRootPart")
					if root and (root.Position - destino).Magnitude <= radioDeteccion then
						enemigoDetectado = obj
						break
					end
				end
			end

			if enemigoDetectado then
				print("¡Enemigo detectado cerca del destino!", enemigoDetectado.Name)
				humanoid:MoveTo(enemigoDetectado:GetPivot().Position)
			end







			if enemigoDetectado then
				print("¡Enemigo detectado cerca del destino!", enemigoDetectado.Name)

				local function atacarEnemigo()
					if not enemigoDetectado or not enemigoDetectado.Parent then return end
					local enemigoHumanoid = enemigoDetectado:FindFirstChildOfClass("Humanoid")
					if not enemigoHumanoid or enemigoHumanoid.Health <= 0 then return end

					local velocidadAtaque = unidad:GetAttribute("VelocidadAtaque")
					local damage = unidad:GetAttribute("DañoAtaque")
					local rangoAtaque = unidad:GetAttribute("RangoAtaque") 

					-- Seguir atacando mientras el enemigo esté vivo y dentro de rango
					while enemigoHumanoid and enemigoHumanoid.Health > 0 do
						local distancia = (unidad:GetPivot().Position - enemigoDetectado:GetPivot().Position).Magnitude
						if distancia > rangoAtaque then
							humanoid:MoveTo(enemigoDetectado:GetPivot().Position)
						else
							enemigoHumanoid:TakeDamage(damage)
						end
						task.wait(velocidadAtaque)
					end
				end

				-- Llama al bucle de ataque en segundo plano para seguir atacando esperando la velocidad de ataque
				task.spawn(atacarEnemigo)
				connection:Disconnect() -- 🔥 MUY IMPORTANTE
			else
				connection:Disconnect() -- También desconecta si no hay enemigo
			end

		end
	end)
end)

