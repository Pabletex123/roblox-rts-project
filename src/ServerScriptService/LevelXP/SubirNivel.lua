local ServerScriptService = game:GetService("ServerScriptService")
local NivelesUnidades = ServerScriptService:WaitForChild("NivelesUnidades")

local SubirNivel = {}--Crear tabla SubirNivel

function SubirNivel.SubirNivel(unidad)--Referirse a la tabla SubirNivel con SubirNivel.SubirNivel
	if not unidad or not unidad:IsA("Model") then return end

	local nivel = unidad:GetAttribute("Nivel") or 0
	local xp = unidad:GetAttribute("XP") or 0
	local xpParaSubir = unidad:GetAttribute("XPParaSubir") or 100

	local moduloUnidad = NivelesUnidades:FindFirstChild(unidad.Name)
	if not moduloUnidad then
		warn("No existe módulo de niveles para:", unidad.Name)
		return
	end

	moduloUnidad = require(moduloUnidad)

	-- 🔁 Permite subir varios niveles si tiene mucha XP
	while xp >= xpParaSubir and nivel < moduloUnidad.NivelMaximo do
		xp -= xpParaSubir
		nivel += 1

		unidad:SetAttribute("XP", xp)
		unidad:SetAttribute("Nivel", nivel)

		local data = moduloUnidad.Niveles[nivel]--Pide la tabla de datos del nivel actual
		if data then-- Si hay datos en el nivel actual, se aplican los cambios
			for key, value in pairs(data) do--Recorre los datos de la una tabla en NivelesUnidades
				if typeof(value) == "number" then --Si el valor es un número 
					local actual = unidad:GetAttribute(key) or 0 --obtener el valor actual del atributo (ej: Fuerza actual)
					unidad:SetAttribute(key, actual + value) --sumar el valor nuevo al existente (ej: Fuerza + 5)
				elseif typeof(value) == "boolean" then--si el valor es verdadero/falso
					unidad:SetAttribute(key, value)--asignar directamente el valor booleano (ej: HabilidadDesbloqueada = true)
				end
			end
		end
	end
end

return SubirNivel
