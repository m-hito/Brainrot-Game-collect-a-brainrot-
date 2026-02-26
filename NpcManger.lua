local ReplicatedStorage = game.ReplicatedStorage
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local SpawnAreas = workspace:WaitForChild("SpawnArea")
local NPCFolder = ReplicatedStorage:WaitForChild("NPCs") -- your NPC models here

local ActiveNPCs = {}

local MaxNPCsPerArea = {Area1 = 8, Area2 = 6} -- per-area limits

local Rarities = {
	{Rarity = "Common", 
		timer = 45, weight = 70, NPCname = {"noob", "Haunter"}, Color = Color3.fromRGB(58, 91, 131)},
	{Rarity = "Uncommon", 
		timer = 40, weight = 30, NPCname = {"hell nah"}, Color = Color3.fromRGB(100, 255, 100)}
}

local NPCData = {
	noob = {name = "noob", Value = 200, CashPerSec = 5, nameColor = Color3.fromRGB(13, 73, 80), Rarity = "Common"},
	Haunter = {name = "Haunter", Value = 500, CashPerSec = 10, nameColor = Color3.fromRGB(63, 0, 94), Rarity = "Common"},
	["hell nah"] = {name = "hell nah", Value = 1000, CashPerSec = 25, nameColor = Color3.fromRGB(117, 27, 28), Rarity = "Uncommon"}
}

local function rollRarity()
	local totalWeight = 0
	for _, r in ipairs(Rarities) do
		totalWeight += r.weight
	end

	local roll = math.random(1, totalWeight)
	local sum = 0

	for _, r in ipairs(Rarities) do
		sum += r.weight
		if roll <= sum then
			return r
		end
	end
	
end

local function tweenTextColor(label, targetColor)
	if not (label and label.Parent) then return end
	
	if label.TextColor3 == targetColor then return end

	local tween = TweenService:Create(
		label,
		TweenInfo.new(15, Enum.EasingStyle.Quad),
		{TextColor3 = targetColor}
	)
	print("tween Called")
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

local function GenrateMoney()
	
end 	
	
local function spawnNPC(areaName)
	local areaFolder = SpawnAreas:FindFirstChild(areaName)
	if not areaFolder then return end

	local spawnPlate = areaFolder:FindFirstChild("SpawnPlate")
	if not spawnPlate then return end

	-- Count existing NPCs in this area
	local npcCount = 0
	for npc, data in pairs(ActiveNPCs) do
		if data.areaName == areaName then
			npcCount += 1
		end
	end

	local maxNPCs = MaxNPCsPerArea[areaName] or 5	
	local spawnNpc = math.random(1, maxNPCs)
	
	if npcCount >= maxNPCs then return end
	
	for i = 1, spawnNpc do
		local rarityData = rollRarity()
		if not rarityData then return end
		
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
		npc.Parent = workspace

		-- Random spawn position
		local spawnPos = getRandomSpawnPos(spawnPlate)
		npc.PrimaryPart.CFrame = CFrame.new(spawnPos) * CFrame.new(0, 3, 0)

		-- Track this NPC
		ActiveNPCs[npc] = {
			areaName = areaName,
			spawnPlate = spawnPlate,
			spawnTime = tick()
		}

		print("Spawned NPC in", areaName, "Total:", npcCount + 1)
		
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
		
		-- Timer countdown
		task.spawn(function()
			local lastRange = nil

			while timer.Value > 0 and npc.Parent do
				task.wait(1)
				timer.Value -= 1

				local range
				if timer.Value > 30 then
					range = "high"
				elseif timer.Value > 15 then
					range = "mid"
				else
					range = "low"
				end

				if range ~= lastRange then
					if range == "high" then
						tweenTextColor(timeText, Color3.fromRGB(0, 255, 0))
					elseif range == "mid" then
						tweenTextColor(timeText, Color3.fromRGB(255, 255, 0))
					else
						tweenTextColor(timeText, Color3.fromRGB(255, 0, 0))
					end
					lastRange = range
				end

				if timerGui and timerGui.Parent and timeText and timeText.Parent then
					timeText.Text = timer.Value
				end
			end

			-- CLEANUP FIRST
			valueGui.Enabled = false
			cashPerSec.Enabled = false
			NameGui.Enabled = false
			rarityGui.Enabled = false
			timerGui.Enabled = false
			
			if npc.Parent then
				ActiveNPCs[npc] = nil
				Debris:AddItem(npc, 0.1)
			end
			
		end)
		
	end
	
end

-- Auto-spawn loop for each area
spawn(function()
	while true do
		for _, areaFolder in pairs(SpawnAreas:GetChildren()) do
			if areaFolder.Name:match("Area%d+") then
				print(areaFolder, "found area")
				spawnNPC(areaFolder.Name)
			end
		end
		
		task.wait(math.random(5, 15)) -- spawn every 5-15 seconds
		print(ActiveNPCs)
	end
end)




