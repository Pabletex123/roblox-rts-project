local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local walkAnim = script:WaitForChild("Walk")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
local walkAnimTrack = animator:LoadAnimation(walkAnim)
walkAnimTrack.Looped = true

humanoid.Running:Connect(function(speed)
	if speed > 0 then
		if not walkAnimTrack.IsPlaying then
			walkAnimTrack:Play()
		end
	else
		if walkAnimTrack.IsPlaying then
			walkAnimTrack:Stop()
		end
	end
end)
