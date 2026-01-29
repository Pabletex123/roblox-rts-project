--Script para que las unidades lanzen los proyectiles (dependiendo de cual sea cada una(falta hacer))
local RunService = game:GetService("RunService")--obtener el servicio de ejecución
local projectilesFolder = game.ServerStorage.Projectiles --Acceder a la cartpeta de proyectiles

local ProjectileService = {} -- Crear la tabla

function ProjectileService.Launch(origin, targetPos, projectileName, stats)
	local template = projectilesFolder:FindFirstChild(projectileName)--Obtener la platilla del proyectil (flecha,boladefuego,etc)
	if not template then return end

	local direction = (targetPos - origin).Unit
	local gravity = Vector3.new(0, -workspace.Gravity * (stats.gravity or 0), 0)

	local projectile = template:Clone() -- clonar la plantilla del proyectil
	projectile.Anchored = true
	projectile.CFrame = CFrame.new(origin, origin + direction)
	projectile.Parent = workspace

	local velocity = direction * stats.speed
	local position = origin
	local traveled = 0

	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		local displacement =
			velocity * dt + 0.5 * gravity * (dt ^ 2)

		velocity += gravity * dt
		position += displacement

		projectile.CFrame = CFrame.new(position, position + velocity.Unit)
		traveled += displacement.Magnitude

		if traveled >= stats.range then
			projectile:Destroy()
			connection:Disconnect()
		end
	end)
end

return ProjectileService
