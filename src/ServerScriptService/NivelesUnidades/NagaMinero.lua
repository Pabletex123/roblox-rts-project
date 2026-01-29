--Unidad Naga
local Unidad = {}

Unidad.Nombre = "NagaMinero"
Unidad.NivelMaximo = 5

Unidad.Niveles = {
	[0] = {
		PuedeMinar = true  --atributo especial para minar
		-- Solo la unidad minera tendrá esto
	},
	[1] = {
		Fuerza = 0.2,
		Agilidad = 0.2,
	},
	[2] = {
		Fuerza = 0.2,
		Agilidad = 0.2,
	},
	-- y así sucesivamente puede desblear atributos o habilidades especiales dependiendo de la unidad
}

return Unidad
