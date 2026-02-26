game.Players.PlayerAdded:Connect(function(plr)
	local leaderStats = Instance.new("Folder")
	leaderStats.Name = "leaderstats"
	leaderStats.Parent = plr
	
	local coins = Instance.new("NumberValue")
	coins.Name = "Coins"
	coins.Parent = leaderStats

    
end)