--Unidad Archer
local Unidad = {}

Unidad.Nombre = "Archer"
Unidad.NivelMaximo = 5

Unidad.Niveles = {
	[0] = { --Las estadisticas del arquero sirven para un multiplicador de daño min y max en su arco ejemplo arco T1 1.0x mult base min 1.8x mult max
        TipoAtaque = "Rango",--Los tipos de ataque son Rango o melee
	    Projectile = "Arrow",
		RangoAtaque = 25, -- Alcance de ataque en studs
	--El daño al impactar dependera de el tipo de arco y el tipo de fuerza necesaria para tensarlo al min-max + el tipo de flecha
	--	ProjectilePenetration = 0.05, -- +5%  Daño completo
	},
	[1] = {
		ProjectileSpeed = 0.10, -- +10%
		--	ProjectilePenetration = 0.05, -- +5%  Daño completo
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
