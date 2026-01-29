-- Rango de atributos base iniciales por tipo de unidad
local StatsUnidades = {
	["Spider"] = {
		Fuerza = { min = 17, max = 22 },
		Agilidad = { min = 15, max = 20 },
		Vitalidad = { min = 4, max = 8  },	
		Price = 10,
	},
	["Ant"] = {
		Fuerza = { min = 15, max = 30 },
		Agilidad = { min = 10, max = 15 },
		Vitalidad = { min = 4, max = 8  },	
		Price = 10,
	},
	["Thing"] = {
		Fuerza = { min = 5, max = 10 },
		Agilidad = { min = 5, max = 10 },
		Vitalidad = { min = 4, max = 8  },	
		Price = 10,
	},
	["NagaMinero"] = {
		Fuerza = { min = 2, max = 10 },
		Agilidad = { min = 4, max = 10 },
		Vitalidad = { min = 4, max = 8  },
		Price = 10,
	},
	["Archer"] = {
		Fuerza = { min = 12, max = 18 },
		Agilidad = { min = 20, max = 25 },
		Vitalidad = { min = 5, max = 10  },
		Price = 10,
	},
	-- Puedes agregar más unidades aquí
}
return StatsUnidades 
