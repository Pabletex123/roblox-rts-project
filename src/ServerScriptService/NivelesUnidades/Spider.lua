--Unidad Naga
local Unidad = {}

Unidad.Nombre = "Spider"
Unidad.NivelMaximo = 5

Unidad.Niveles = {
	[0] = {
		--Habilidades = { "Pegajoso"--Habilidad Pasiva de ralentizacion al atacar } 
	},
	[1] = {
		Fuerza = 0.2,
		Agilidad = 0.2,
-- sin crecimiento
	},
	[2] = {
		Fuerza = 0.2,
		Agilidad = 0.2,
--sin crecimiento
	},
	-- y así sucesivamente
}

return Unidad
