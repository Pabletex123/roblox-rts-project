--Unidad Archer
local Unidad = {}

Unidad.Nombre = "Archer"
Unidad.NivelMaximo = 5

Unidad.Niveles = {
	[0] = {
        AttackType = "Rango",--Los tipos de ataque son Rango o melee
	    Projectile = "FireBall",
		CastTime = 1.5, --Tiempo de lanzamiento de la bola de fuego
		Cooldown = 5, --Tiempo de recarga entre lanzamientos
		ImpactDamage = 10, --Daño al impactar
		BurnDuration = 3,
		BurnDamagePerSecond = 0.5, --50% del daño de la bola de fuego por segundo
		--Hacer mecanica de mana despues para un limite a la cantidad de lanzamientos cuando se acabe y un tiempo de regenracion de mana en descanso
		--Que tambien mejorable por niveles(que sera algo diferente de los demas)
	},
	[1] = {
		ProjectileSpeed = 0.10, -- +10%
		Fuerza = 0.15,
		Agilidad = 0.25,
	},
	[2] = {
		ProjectileSpeed = 0.10, -- +10%
	--	ProjectilePenetration = 0.05, -- +5%  Daño completo
		Fuerza = 0.15,
		Agilidad = 0.25,
	},
	[3] = {
		Fuerza = 0.15,
		Agilidad = 0.25,
	},
	[4] = {
		Fuerza = 0.15,
		Agilidad = 0.25,
	},
	[5] = {
		Fuerza = 0.15,
		Agilidad = 0.25,
	},
}

return Unidad
