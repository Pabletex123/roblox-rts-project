--Localscript para animar a una araña funciona  en StarterCharacterScripts para usarlo en el propio jugador
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local walkAnim = script:WaitForChild("Walk")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
local walkAnimTrack = animator:LoadAnimation(walkAnim)

walkAnimTrack.Looped = true -- 🌀 Muy importante: se repetirá mientras esté activa

humanoid.Running:Connect(function(speed)--conecta la funcion de movimiento y inicia la animacion
	if speed > 0 then --si la velocidad es mayor a 0 inicia la animacion
		if not walkAnimTrack.IsPlaying then
			walkAnimTrack:Play()
		end-- inicia la animacion si se cumple la condicion
	else
		if walkAnimTrack.IsPlaying then--se detiene si la velocidad es 0
			walkAnimTrack:Stop()
		end
		--hay un error que la animacion sigue despues del salto ya que el salto cuanta como movimiento
		--ya que al terminar el salto tiene un pequeño rebote y al terminar no deja de correr la animacion
		--al moverte un poco y dejar de moverte ya para la animacion(esto podria ser alguna posible solucion)
		--otra solucion seria quitar el salto y hacer una animacion de escalada o algo adecuado a una araña
	end
end)
