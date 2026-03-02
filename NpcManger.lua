local ReplicatedStorage = game.ReplicatedStorage
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Bases = workspace.Bases
local PhysicsService = game:GetService("PhysicsService")

local SpawnAreas = workspace:WaitForChild("SpawnArea")
local NPCFolder = ReplicatedStorage:WaitForChild("NPCs") -- your NPC models here

local ActiveNPCs = {}

--local MaxNPCsPerArea = {Common = 8, Uncommon = 7, Rare = 5} -- per-area limits

local Rarities = {
	{Rarity = "Common", 
		timer = 45, weight = 70, NPCname = {"noob", "Haunter"}, Color = Color3.fromRGB(58, 91, 131)},
	{Rarity = "Uncommon", 
		timer = 40, weight = 30, NPCname = {"Destroyer"}, Color = Color3.fromRGB(100, 255, 100)},
	{Rarity = "Rare", 
		timer = 35, weight = 30, NPCname = {"TungTung"}, Color = Color3.fromRGB(255, 85, 0)},
}

local NPCData = {
	noob = {name = "noob", Value = 200, CashPerSec = 5, nameColor = Color3.fromRGB(13, 73, 80), Rarity = "Common"},
	Haunter = {name = "Haunter", Value = 500, CashPerSec = 10, nameColor = Color3.fromRGB(63, 0, 94), Rarity = "Common"},
	["Destroyer"] = {name = "Destroyer", Value = 1000, CashPerSec = 25, nameColor = Color3.fromRGB(117, 27, 28), Rarity = "Uncommon"},
	TungTung = {name = "TungTung", Value = 30000, CashPerSec = 3000, nameColor = Color3.fromRGB(255, 170, 0), Rarity = "Uncommon"}
}


local ZoneData = {
	Common = {spawnFolder = "Common", Rarity = {"Common"} ,maxNpcs = 12, 
		spawnChance = {Common = 100}},
	["Stage1.5"] = {spawnFolder = "Stage1.5", Rarity = {"Common", "Uncommon"} ,maxNpcs = 11, 
		spawnChance = {Common = 70, Uncommon = 30}},
	Uncommon = {spawnFolder = "Uncommon", Rarity = {"Uncommon"} ,maxNpcs = 10, 
		spawnChance = {Uncommon = 30}},
	["Stage2.5"] = {spawnFolder = "Stage2.5", Rarity = {"Uncommon" , "Rare"} ,maxNpcs = 9, 
		spawnChance = {Uncommon = 60, Rare = 40}},
	Rare = {spawnFolder = "Rare", Rarity = {"Rare"} ,maxNpcs = 8, 
		spawnChance = {Rare = 100}},
}

PhysicsService:RegisterCollisionGroup("Players")
PhysicsService:RegisterCollisionGroup("NPCs")
PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)  -- no player-player collision
PhysicsService:CollisionGroupSetCollidable("NPCs", "NPCs", false)       -- NPCs pass through each other

local function rollRarityForZone(areaName)
	local zone = ZoneData[areaName]
	if not zone then warn("Invalid area "..areaName) return nil end

	local chances = zone.spawnChance
	local total = 0
	for rarity, chance in pairs(chances) do
		total += chance
	end

	local roll = math.random(1, total)
	local sum = 0

	for rarity, chance in pairs(chances) do
		sum += chance
		if roll <= sum then
			return rarity  -- "Common", "Uncommon", etc.
		end
	end
end

local function tweenTextColor(label, targetColor)
	if not (label and label.Parent) then return end
	
	if label.TextColor3 == targetColor then return end

	local tween = TweenService:Create(
		label,
		TweenInfo.new(15, Enum.EasingStyle.Linear),
		{TextColor3 = targetColor}
	)
	--print("tween Called")
	tween:Play()
end


local function getRandomSpawnPos(spawnPlate)
	local size = spawnPlate.Size
	local pos = spawnPlate.Position

	-- Random X/Z within spawn plate bounds (keep Y same)
	return Vector3.new(
		pos.X + math.random(-size.X/2 + 2, size.X/2 - 2), -- +2 padding from edges
		pos.Y,
		pos.Z + math.random(-size.Z/2 + 2, size.Z/2 - 2)
	)
	
end

-- BaseManager addition
local function GenrateMoney(SpecificNPCFolder, npc, assignedPlatform)
	local base = assignedPlatform.Parent.Parent.Parent.Parent.Parent.Parent
	local config = base.Configuration
	local CashPerSec = npc.Configuration.CashPerSec
	
	assignedPlatform.Collect.Text.TextFrame.Enabled = true
	npc.Humanoid.Money.Changed:Connect(function()
		assignedPlatform.Collect.Text.TextFrame.Amount.Text = npc.Humanoid.Money.Value.."$"
	end)
	
	assignedPlatform.Collect.Touched:Connect(function(hit)
		if hit.Parent == config.Player.Value.Name then
			local Player = game.Players:FindFirstChild(config.Player.Value.Name)
			if Player then
				Player.leaderstats.Coins.Value += npc.Humanoid.Money.Value
				npc.Humanoid.Money.Value = 0
			end
			
		end
		
	end)
	
	while npc.Humanoid.Status.Value == "Active" do
		npc.Humanoid.Money.Value += CashPerSec.Value
		task.wait(1)
	end
	
end



local function BuyNpc(npc, player)
	local npcName = npc.Configuration:FindFirstChild("Name")
	if not npcName then
		warn("NPC has no Configuration.Name", npc)
		return
	end
	
	if npc:GetAttribute("Placed") then
		return
	end
	
	local npcInfo = NPCData[npcName.Value]
	if not npcInfo then
		warn("NPCData missing for", npcName.Value)
		return
	end

	if player.leaderstats.Coins.Value < npcInfo.Value then
		return 
	end

	player.leaderstats.Coins.Value -= npcInfo.Value

	local base = player.Configuration.Base.Value
	if not base then
		warn("base not found for player", player.Name)
		return
	end

	local assignedPlatform = nil
	for _, stand in ipairs(base.Floors.Floor1.Build.Platforms.Left:GetChildren()) do
		local important = stand:FindFirstChild("Important")
		
		if assignedPlatform == stand then break end
		if important and not important.Equipped.Value then
			assignedPlatform = stand
			break
		end
	end
	
	for _, stand in ipairs(base.Floors.Floor1.Build.Platforms.Right:GetChildren()) do
		local important = stand:FindFirstChild("Important")
		if assignedPlatform == stand then break end
		if important and not important.Equipped.Value then
			assignedPlatform = stand
			break
		end
	end
	
	if not assignedPlatform then return end 
	
	local important = assignedPlatform.Important 
	important.Equipped.Value = true
	important.NPCName.Value = npcName.Value

	npc.Parent = assignedPlatform.PlaceHolder.NPCPlatform

	local carryweld = npc:FindFirstChild("CarryWeld")
	if not carryweld then return end
	carryweld:Destroy()
	print("Destroyed carry weld for.."..npc.Name)
	
	npc:PivotTo(assignedPlatform.PlaceHolder.CFrame)
	npc.HumanoidRootPart.PickUpPrompt.Enabled = false
	npc.HumanoidRootPart.Anchored = true
	
	npc.Humanoid.Status.Value = "Active"
	npc:SetAttribute("Placed", true)
	--npc:SetAttribute("CarriedBy", nil)
	
	return assignedPlatform
	--GenrateMoney(nil, npc, assignedPlatform)
end



local function onTouchedSafeZone(hit, npc)
	local char = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(char)
	if not player then return end
	
	-- Now player is a proper Player object
	local platForm = BuyNpc(npc, player)

	local carriedName = npc:GetAttribute("CarriedBy")
	if carriedName ~= player.Name then return end

	local NameGui = npc.Head.NameGui
	local PerSecondGui = npc.Head.PerSecond

	if not npc:GetAttribute("InInventory") then
		npc:SetAttribute("CarriedBy", nil)
		npc:SetAttribute("InInventory", true)
		npc:SetAttribute("Owner", player.Name)

		npc.Configuration.Timer.Value = 0 
		NameGui.Enabled = true
		PerSecondGui.Enabled = true
	end
	GenrateMoney(nil, npc, platForm)
	
	return true
end

local function connectSafeZones(npc)
	local safeZone = workspace.Map.SafeZone
	if not safeZone then return end

	safeZone.Touched:Connect(function(hit)
		onTouchedSafeZone(hit, npc)
	end)
	
	ActiveNPCs[npc] = nil
end

local function addToBackPack(npc, player)
	local Tool = Instance.new("Tool")
	Tool.Name = npc.Name
	Tool.CanBeDropped = false
	--T
	
end



local function spawnNPC(areaName)
	local areaFolder = SpawnAreas:FindFirstChild(areaName)
	if not areaFolder then return end
	
	local spawnPlate = areaFolder:FindFirstChild("SpawnPlate")
	if not spawnPlate then return end
	
	-- Count existing NPCs in this area
	local npcCount = 0
	
	for npc, data in pairs(ActiveNPCs) do -- count npcs here in active npc of this area 
		if data.areaName == areaName then
			npcCount += 1
		end
		
	end
	
	local maxNPCs = ZoneData[areaName].maxNPCs or 5	
	local spawnNpc = math.random(1, maxNPCs)
	
	if npcCount >= maxNPCs then return end
	
	for i = 1, spawnNpc do
		
		local rolledRarityName = rollRarityForZone(areaName)
		
		if not rolledRarityName then warn("rarityName Not found") return end

		-- find matching rarity data from Rarities table
		local rarityData
		for _, r in ipairs(Rarities) do
			if r.Rarity == rolledRarityName then
				rarityData = r
				break
			end
		end
		
		if not rarityData then warn("Rarity data not found") return end

		
		-- Pick random NPC from rarity pool
		local npcNames = rarityData.NPCname
		local npcName = npcNames[math.random(1, #npcNames)]
		local npcTemplate = NPCFolder:FindFirstChild(npcName)
		
		local npcData = NPCData[npcName]
		
		if not npcTemplate then 
			warn("Missing NPC model:", npcName)
			continue 
		end

		local npc = npcTemplate:Clone()
		npc.Name = rarityData.Rarity .. "_" .. npcName .. "_" .. tick()
		npc.Parent = workspace.World.Live
		
		
		
		for _, part in pairs(npc:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
				part.Anchored = false
				part.CanCollide = false
				part.Massless = true
				part.CollisionGroup = "NPCs"
			end
		end
		
		-- Random spawn position
		local spawnPos = getRandomSpawnPos(spawnPlate)
		npc.PrimaryPart.CFrame = CFrame.new(spawnPos) * CFrame.new(0, 4.5, 0)

		-- Track this NPC
		ActiveNPCs[npc] = {
			areaName = areaName,
			spawnPlate = spawnPlate,
			spawnTime = tick()
		}

		--print("Spawned NPC in", areaName, "Total:", npcCount + 1)
		
		local config = npc:FindFirstChild("Configuration") or Instance.new("Folder")
		config.Name = "Configuration"
		config.Parent = npc
		
		local timer = Instance.new("NumberValue")
		timer.Name = "Timer"
		timer.Value = rarityData.timer or 20
		timer.Parent = config
		
		local rarityValue = Instance.new("StringValue")
		rarityValue.Name = "Rarity"
		rarityValue.Value = rarityData.Rarity
		rarityValue.Parent = config
		
		local value = Instance.new("NumberValue")
		value.Name = "Value"
		value.Value = npcData.Value
		value.Parent = config
		
		local cashPerSec = Instance.new("NumberValue")
		cashPerSec.Name = "CashPerSec"
		cashPerSec.Value = npcData.CashPerSec
		cashPerSec.Parent = config
		
		local name = Instance.new("StringValue")
		name.Name = "Name"
		name.Value = npcData.name
		name.Parent = config
		
		local timerGui = npc.Head.TimerGui
		local timeText = timerGui.Time
		local rarityGui = npc.Head.RarityGui
		local rarityText = rarityGui.Rarity
		local NameGui = npc.Head.NameGui
		local NameText = NameGui.NpcName
		local cashPerSec = npc.Head.PerSecond
		local cashPerSecText = cashPerSec.CashPerSecond
		local valueGui = npc.Head.Value
		local valueText = valueGui.TextLabel
		
		valueGui.Enabled = true
		cashPerSec.Enabled = true
		NameGui.Enabled = true
		rarityGui.Enabled = true
		timerGui.Enabled = true
		
		valueText.Text = npcData.Value.."$/s-"
		NameText.Text = npcData.name
		timeText.Text = timer.Value
		rarityText.Text = rarityData.Rarity
		rarityText.TextColor3 = rarityData.Color
		NameText.TextColor3 = npcData.nameColor
		cashPerSecText.Text = npcData.CashPerSec.."$/s-"
		
		-- Inside spawnNPC(), after GUI setup:
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "PickUpPrompt"
		prompt.ActionText = "Pick Up"
		prompt.ObjectText = npcData.name
		prompt.Parent = npc.HumanoidRootPart  -- or Head
		prompt.RequiresLineOfSight = false
		prompt.HoldDuration = 0.5
		prompt.MaxActivationDistance = 5
		
		task.spawn(function()
			prompt.Triggered:Connect(function(player)
				local char = player.Character
				if not char then return end

				-- Mark as "carried"
				npc:SetAttribute("CarriedBy", player.Name)
				npc:SetAttribute("InInventory", false)
				local weld = Instance.new("Weld")
				weld.Name = "CarryWeld"
				weld.Parent = npc
				weld.Part0 = npc.PrimaryPart
				weld.Part1 = char.PrimaryPart
				weld.Enabled = true

				weld.C1 = CFrame.new(0, 9, 0)

				connectSafeZones(npc, player)
			
				
				
				
				--npc:PivotTo(char.Head.CFrame * CFrame.new(0, 10, 0))

				-- Disable wild timer while carried
				--timer.Value = 0  -- stops despawn
			end)
		end)
		
		-- Timer countdown
		task.spawn(function()
			local lastRange = nil
			local ranges = {low = "low", mid = "mid", high = "high"}
			
			while timer.Value > 0 and npc.Parent do
				-- If secured, break out of timer logic completely
				if npc:GetAttribute("InInventory") then
					break
				end
				
				task.wait(1)
				timer.Value -= 1
				
				
				local range
				if timer.Value > 30 then
					range = ranges.high
				elseif timer.Value > 15 then
					range = ranges.mid
				else
					range = ranges.low
				end
				
				if range ~= lastRange then
					if range == "high" then
						tweenTextColor(timeText, Color3.fromRGB(0, 255, 0))
					elseif range == "mid" then
						tweenTextColor(timeText, Color3.fromRGB(255, 255, 0))
					else
						tweenTextColor(timeText, Color3.fromRGB(255, 0, 0)) -- red
					end
					lastRange = range
				end
				
				if timerGui and timerGui.Parent and timeText and timeText.Parent then
					timeText.Text = timer.Value
				end
			end

			-- Only despawn if NOT secured
			if not npc:GetAttribute("InInventory") then
				valueGui.Enabled = false
				cashPerSec.Enabled = false
				NameGui.Enabled = false
				rarityGui.Enabled = false
				timerGui.Enabled = false

				if npc.Parent then
					ActiveNPCs[npc] = nil
					Debris:AddItem(npc, 0.1)
				end
			else
				-- Optional: hide wild GUIs when secured
				valueGui.Enabled = true
				cashPerSec.Enabled = true
				NameGui.Enabled = true
				rarityGui.Enabled = true
				timerGui.Enabled = false
			end
			
		end)
		
	end
	print(ActiveNPCs)
end

-- Auto-spawn loop for each area
spawn(function()
	while true do
		for _, areaFolder in pairs(SpawnAreas:GetChildren()) do
			spawnNPC(areaFolder.Name)
			task.wait(1)
		end
		
		task.wait(math.random(5, 15)) -- spawn every 5-15 seconds
		--print(ActiveNPCs)
	end
end)
