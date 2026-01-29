--Unidad Archer
local Unidad = {}

Unidad.Nombre = "Archer"
Unidad.NivelMaximo = 5

Unidad.Niveles = {
	[0] = {
        AttackType = "Rango",--Los tipos de ataque son Rango o melee
	    Projectile = "Arrow",
		ImpactDamage = 15, --Daño al impactar
	--	ProjectilePenetration = 0.05, -- +5%  Daño completo
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
