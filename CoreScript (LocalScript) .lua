local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remote")
local Players = game:GetService("Players")


local CoreEvent = remotes.CoreEvent
local Player = game.Players.LocalPlayer

task.wait(2)

if Player.Configuration.Base.Value then
	print("locking base")
	CoreEvent:FireServer("LockBase")
	
	local base = Player.Configuration.Base.Value
	local Doors = base.Floors.Floor1.Doors
	local Floor1 = base.Floors.Floor1
	
	--local lock = Floor1.Build.Platforms.Lock
	--lock.Touched:Connect(function(hit)

	--	if hit.Parent == Player.Character then
	--		print("locking base")
	--		CoreEvent:FireServer("LockBase")
	--	end
	--end)
	
end

