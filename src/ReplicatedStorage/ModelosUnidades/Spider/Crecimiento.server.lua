--Desactivado de momento
local unidad = script.Parent
local OriginalSize = {}

-- Guardar tamaño original al iniciar
for _, part in ipairs(unidad:GetDescendants()) do
	if part:IsA("BasePart") then
		OriginalSize[part] = part.Size
	end
end

-- Función que ajusta el tamaño
local function aplicarCambiosVisuales()
	local fuerza = unidad:GetAttribute("Fuerza") or 0
	local agilidad = unidad:GetAttribute("Agilidad") or 0

	local escalaCuerpo = 1 + (fuerza / 100)
	local alargamientoPiernas = agilidad / 20

	for _, part in ipairs(unidad:GetDescendants()) do
		if part:IsA("BasePart") and OriginalSize[part] then
			if part.Name:lower():match("pata") then
				local original = OriginalSize[part]
				part.Size = Vector3.new(
					original.X,
					original.Y + alargamientoPiernas,
					original.Z
				)
			else
				part.Size = OriginalSize[part] * escalaCuerpo
			end
		end
	end
end

-- Aplicarlo al iniciar (cuando se invoca)
aplicarCambiosVisuales()

-- Reaplicarlo automáticamente si suben los atributos
unidad:GetAttributeChangedSignal("Fuerza"):Connect(aplicarCambiosVisuales)
unidad:GetAttributeChangedSignal("Agilidad"):Connect(aplicarCambiosVisuales)
