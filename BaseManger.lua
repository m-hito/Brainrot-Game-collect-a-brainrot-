local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remote")
local CoreEvent = remotes.CoreEvent
local Bases = game.Workspace.Bases:GetChildren()
local Players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

local function SetProperty(Player)
	local configuration = Instance.new("Folder")  -- better than Configuration object
	configuration.Name = "Configuration"
	configuration.Parent = Player

	local baseValue = Instance.new("ObjectValue")
	baseValue.Name = "Base"
	baseValue.Parent = configuration
	
end

local function SetBase(player)
	if not player then return end 
	local char = player.Character or player.CharacterAdded:Wait()
	
	local available = {}
	
	for i, Base in pairs(Bases) do
		if not Base.Configuration.Player.Value then
			table.insert(available, Base)
		end
	end
	
	if #available == 0 then return end

	local base = available[math.random(1, #available)]
	local Sign = base.Floors.Floor1.Build.Signs.SignsPart
	local Text = Sign.PlayerNameBase.Owner.OwnerText
	
	base.Configuration.Player.Value = player
	player.Configuration.Base.Value = base
	Text.Text = player.Name.." 's Base"
	print("assigning "..player.Name.." to "..base.Name)
	
	char:PivotTo(base.Spawn.CFrame)
	return base
end

local function SetLock(player, time)
	
	local base = player.Configuration.Base.Value
	local Doors = base.Floors.Floor1.Doors
	local Floor1 = base.Floors.Floor1
	local lock = Floor1.Build.Platforms.Lock
	local locking = lock.Value
	
	local Config = base.Configuration
	
	locking.Value = true
	
	Doors.Door1.Hitbox.CanCollide = true
	for i, v in pairs(Doors.Door1.Lasers:GetChildren()) do
		local Tween = tweenService:Create(v, TweenInfo.new(0.5), {Transparency = 0, Size = Vector3.new(1, 18.41, 1)})
		Tween:Play()

		--v.Transparency = 1
		v.CanCollide = false
	end
	
	for i = time, 0, -1 do
		local lockText = Floor1.Build.Platforms.Lock.LockGui.LockTextLabel
		lockText.Text = i.."second(s) left" 
		task.wait(1)
	end
	
	if Config.Player.Value == player then
		print("unlocking base")
		Floor1.Build.Platforms.Lock.LockGui.LockTextLabel.Text = "Unlocked"
		Doors.Door1.Hitbox.CanCollide = false
		locking.Value = false
		for i, v in pairs(Doors.Door1.Lasers:GetChildren()) do
			local Tween = tweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(0, 0, 0)})
			Tween:Play()
			
			--v.Transparency = 1
			v.CanCollide = false
			
		end
	end
	
end


Players.PlayerAdded:Connect(function(player)
	SetProperty(player)
	
	-- 2) Now that config exists, assign base
	SetBase(player)
end)

Players.PlayerRemoving:Connect(function(player)
	local base = player.Configuration:FindFirstChild("Base") and player.Configuration.Base.Value
	
	if base and base.Parent then
		-- Clear base ownership
		if base:FindFirstChild("Configuration") and base.Configuration:FindFirstChild("Player") then
			base.Configuration.Player.Value = nil
			base.Floors.Floor1.Build.Signs.SignsPart.PlayerNameBase.Owner.OwnerText.Text = "Empty base"
		end
		-- Clear player reference (optional, gets GC'd anyway)
		if player.Configuration:FindFirstChild("Base") then
			player.Configuration.Base.Value = nil
		end
		print("Freed base", base.Name, "from", player.Name)
	end
end)

CoreEvent.OnServerEvent:Connect(function(Player, eventType)
	local Base = Player.Configuration.Base.Value
	local Floors = Base.Floors
	local Doors = Floors.Floor1.Doors
	local Config = Base.Configuration
	
	if eventType == "LockBase" and Config.Player.Value == Player then
		if Floors.Floor1.Build.Platforms.Lock.Value.Value == true then
			return
		end
		
		print(Player.Name, Player)

		if Config.Player.Value ~= Player then
			print("inside ")
			Doors.Door1.Hitbox.CanCollide = false
		end

		for i, v in pairs(Doors.Door1.Lasers:GetChildren()) do
			v.Transparency = 0.5
			print(v.Transparency)
		end
		
		SetLock(Player, 10)
		
	end

end)
