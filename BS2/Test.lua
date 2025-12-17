local player = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlrName = Players.LocalPlayer.Name
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RunService = game:GetService("RunService")

-- Important: str is SIZE, not actual strength
local str = game:GetService("Players").LocalPlayer.leaderstats.Strength -- This is SIZE
local Strength = game:GetService("ReplicatedStorage").Data[PlrName].Strength -- This is actual STRENGTH

-- Load ZayHub Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Criptism/ZayHub/refs/heads/main/library.lua"))()

-- Initialize Window
local Window = Library:Init({
	Name = "Doggy Hub V3 | Private Farm"
})

-- Global variables
_G.Equip = false
_G.Farm = false
_G.dupeRunning = false
_G.dupeTarget = 777
_G.AutoFarmEnabled = false
_G.WeightThreshold = 777
_G.MaxPing = 25000
_G.ResumePing = 1000
_G.FarmingActive = false

-- Utility Functions
local function getPing()
	local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	return math.floor(ping)
end

local function getTotalInventoryCount()
	local total = 0
	for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			total = total + 1
		end
	end
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("Tool") then
			total = total + 1
		end
	end
	return total
end

local function getDoubleWeightCount()
	local num = 0
	for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
		if v.Name == "Double Weight" then
			num = num + 1
		end
	end
	for i, v in pairs(character:GetChildren()) do
		if v.Name == "Double Weight" then
			num = num + 1
		end
	end
	return num
end

-- Farming Tab
local FarmingTab = Window:CreateTab("Farming")

FarmingTab:AddLabel("--- Farming Options ---")

FarmingTab:AddToggle("Equip Weight", false, function(state)
	_G.Equip = state
	if state then
		print("✅ Equipping Weight...")
		spawn(function()
			while _G.Equip do
				wait()
				for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
					if v.Name == "Double Weight" then
						v.Parent = game.Players.LocalPlayer.Character
					end
				end
			end
		end)
	else
		print("❌ Stopped Equipping Weight")
	end
end)

FarmingTab:AddToggle("Farm Weight", false, function(state)
	_G.Farm = state
	if state then
		print("✅ Farming Weight...")
		spawn(function()
			while _G.Farm do
				wait(0.5)
				for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
					if v.Name == "Double Weight" then
						v:Activate()
					end
				end
			end
		end)
	else
		print("❌ Stopped Farming Weight")
	end
end)

FarmingTab:AddToggle("Lock Player", false, function(state)
	if state then
		for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
			if v:IsA('MeshPart') then
				v.Anchored = true
			end
		end
		print("🔒 Player Locked")
	else
		for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
			if v:IsA('MeshPart') then
				v.Anchored = false
			end
		end
		print("🔓 Player Unlocked")
	end
end)

FarmingTab:AddLabel("--- Extra Options ---")

FarmingTab:AddButton("Delete HUD", function()
	pcall(function()
		game:GetService("Players").LocalPlayer.PlayerGui.HUD:Destroy()
	end)
	print("🗑️ HUD Deleted")
end)

FarmingTab:AddButton("Delete Rumble", function()
	pcall(function()
		game.ReplicatedFirst.TourneyQ:Destroy()
	end)
	print("🗑️ Rumble Deleted")
end)

FarmingTab:AddButton("Delete Clouds", function()
	pcall(function()
		game:GetService("Workspace").Clouds:Destroy()
		for i, v in pairs(player.PlayerScripts:GetChildren()) do
			if v.Name == "LocalScript" then
				v:Destroy()
			end
		end
	end)
	print("🗑️ Clouds Deleted")
end)

FarmingTab:AddButton("Delete All Workspace", function()
	print("🗑️ Deleting workspace objects...")
	
	local keepObjects = {
		["Terrain"] = true,
		["Camera"] = true,
		[character.Name] = true
	}
	
	-- Keep all player characters
	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr.Character then
			keepObjects[plr.Character.Name] = true
		end
	end
	
	-- Delete everything except essentials
	local deletedCount = 0
	for _, obj in pairs(game.Workspace:GetChildren()) do
		if not keepObjects[obj.Name] and obj ~= character then
			pcall(function()
				obj:Destroy()
				deletedCount = deletedCount + 1
			end)
		end
	end
	
	print("✅ Deleted " .. deletedCount .. " objects")
	print("✅ Kept: Terrain, Camera, and all Players")
end)

FarmingTab:AddButton("Teleport to Safe Zone", function()
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1938, 146, -5296)
	print("🚀 Teleported to Safe Zone")
end)

FarmingTab:AddButton("Hide Inventory", function()
	loadstring(game:HttpGet("https://pastebin.com/raw/8W1draqT", true))()
	print("👻 Inventory Hidden")
end)

FarmingTab:AddButton("Low Ping (FPS Boost)", function()
	local decalsyeeted = true
	local g = game
	local w = g.Workspace
	local l = g.Lighting
	local t = w.Terrain
	t.WaterWaveSize = 0
	t.WaterWaveSpeed = 0
	t.WaterReflectance = 0
	t.WaterTransparency = 0
	l.GlobalShadows = false
	l.FogEnd = 9e9
	l.Brightness = 0
	settings().Rendering.QualityLevel = "Level01"
	for i, v in pairs(g:GetDescendants()) do
		if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
			v.Material = "Plastic"
			v.Reflectance = 0
		elseif v:IsA("Decal") and decalsyeeted then
			v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		elseif v:IsA("Explosion") then
			v.BlastPressure = 1
			v.BlastRadius = 1
		end
	end
	for i, e in pairs(l:GetChildren()) do
		if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
			e.Enabled = false
		end
	end
	print("⚡ FPS Boost Applied")
end)

FarmingTab:AddButton("Anti AFK", function()
	local vu = game:GetService("VirtualUser")
	game:GetService("Players").LocalPlayer.Idled:connect(function()
		vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		wait(1)
		vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	end)
	print("🕐 Anti AFK Enabled")
end)

-- Duping Tab
local DupingTab = Window:CreateTab("Duping")

DupingTab:AddLabel("--- Duping System ---")

-- Weight counter label
local DupeWeightLabel = DupingTab:AddLabel("Weights: Loading...")

-- Update weight label
spawn(function()
	while wait(1) do
		pcall(function()
			local doubleWeights = getDoubleWeightCount()
			DupeWeightLabel:Set("Weights: " .. doubleWeights)
		end)
	end
end)

local function runDupeLoop()
	while _G.dupeRunning do
		local currentWeights = getDoubleWeightCount()
		
		if currentWeights >= _G.dupeTarget then
			_G.dupeRunning = false
			print("✅ Target reached! (" .. currentWeights .. "/" .. _G.dupeTarget .. ")")
			break
		end
		
		local MarketplaceService = game:GetService("MarketplaceService")
		local localPlayer = game.Players.LocalPlayer
		
		local function simulatePurchase(gamePassId)
			MarketplaceService:SignalPromptGamePassPurchaseFinished(localPlayer, gamePassId, true)
		end

		simulatePurchase(5949054)
		wait(0.65)
	end
end

DupingTab:AddButton("Auto Dupe 777 DW", function()
	if not _G.dupeRunning then
		_G.dupeTarget = 777
		_G.dupeRunning = true
		print("🔄 Auto Dupe Started - Target: 777 Weights")
		spawn(runDupeLoop)
	else
		print("⚠️ Dupe already running!")
	end
end)

DupingTab:AddButton("Auto Dupe 85 DW", function()
	if not _G.dupeRunning then
		_G.dupeTarget = 85
		_G.dupeRunning = true
		print("🔄 Auto Dupe Started - Target: 85 Weights")
		spawn(runDupeLoop)
	else
		print("⚠️ Dupe already running!")
	end
end)

DupingTab:AddButton("Stop Auto Dupe", function()
	_G.dupeRunning = false
	print("❌ Dupe Stopped")
end)

DupingTab:AddLabel("--- Auto Farm ---")

DupingTab:AddToggle("Auto Farm", false, function(state)
	_G.AutoFarmEnabled = state
	if state then
		print("🚀 Smart Auto Farm Started!")
		print("⏳ Waiting for 777+ items in inventory...")
		spawn(function()
			while _G.AutoFarmEnabled do
				wait(0.5)
				
				local totalItems = getTotalInventoryCount()
				local doubleWeights = getDoubleWeightCount()
				local currentPing = getPing()
				
				local shouldFarm = (totalItems >= _G.WeightThreshold or doubleWeights >= _G.WeightThreshold) and currentPing < _G.MaxPing
				
				if currentPing >= _G.MaxPing then
					if _G.FarmingActive then
						print("🔴 PING TOO HIGH! (" .. currentPing .. "ms) - Pausing farm...")
						_G.FarmingActive = false
					end
					
					repeat
						wait(2)
						currentPing = getPing()
						if currentPing < _G.ResumePing and _G.AutoFarmEnabled then
							print("🟢 Ping restored (" .. currentPing .. "ms)")
						end
					until currentPing < _G.ResumePing or not _G.AutoFarmEnabled
				end
				
				if shouldFarm and not _G.FarmingActive and _G.AutoFarmEnabled then
					print("✅ Conditions met!")
					print("   Total Items: " .. totalItems)
					print("   Double Weights: " .. doubleWeights)
					print("   Ping: " .. currentPing .. "ms")
					print("🚀 Starting farm...")
					
					_G.FarmingActive = true
					
					spawn(function()
						while _G.AutoFarmEnabled and _G.FarmingActive do
							wait()
							for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
								if v.Name == "Double Weight" then
									v.Parent = LocalPlayer.Character
									break
								end
							end
						end
					end)
					
					spawn(function()
						while _G.AutoFarmEnabled and _G.FarmingActive do
							wait(0.5)
							for i, v in pairs(LocalPlayer.Character:GetChildren()) do
								if v.Name == "Double Weight" then
									v:Activate()
								end
							end
						end
					end)
				
				elseif not shouldFarm and _G.FarmingActive then
					if totalItems < _G.WeightThreshold and doubleWeights < _G.WeightThreshold then
						print("⏸️ Items below threshold - Pausing farm")
						print("   Total: " .. totalItems .. "/" .. _G.WeightThreshold)
					end
					_G.FarmingActive = false
				end
			end
			
			print("❌ Auto Farm Disabled")
			_G.FarmingActive = false
		end)
	else
		print("❌ Auto Farm Stopped")
		_G.FarmingActive = false
	end
end)

-- Information Tab
local InfoTab = Window:CreateTab("Info")

InfoTab:AddLabel("--- Statistics ---")

local StrengthLabel = InfoTab:AddLabel("Strength: Loading...")
local GainedLabel = InfoTab:AddLabel("Gained: Loading...")
local WeightLabel = InfoTab:AddLabel("Weight: Loading...")
local SizeLabel = InfoTab:AddLabel("Size: Loading...")
local PingLabel = InfoTab:AddLabel("Ping: Loading...")

InfoTab:AddLabel("More stats coming soon!")

-- Track strength gains
local lastStrength = 0
local totalGained = 0

-- Update Strength & Gained (Real-time with Heartbeat)
RunService.Heartbeat:Connect(function()
	pcall(function()
		-- Use actual strength from ReplicatedStorage
		local currentStrength = Strength.Value
		
		-- Initialize last strength on first run
		if lastStrength == 0 then
			lastStrength = currentStrength
		end
		
		-- Calculate gained
		if currentStrength > lastStrength then
			local gained = currentStrength - lastStrength
			totalGained = totalGained + gained
			lastStrength = currentStrength
		end
		
		StrengthLabel:Set("Strength: " .. tostring(currentStrength))
		GainedLabel:Set("Gained: " .. tostring(totalGained))
	end)
end)

-- Update Weight (every second is fine)
spawn(function()
	while wait(1) do
		pcall(function()
			local totalItems = getTotalInventoryCount()
			local doubleWeights = getDoubleWeightCount()
			WeightLabel:Set("Items: " .. totalItems .. " | Weights: " .. doubleWeights)
		end)
	end
end)

-- Update Size (Real-time with Heartbeat)
RunService.Heartbeat:Connect(function()
	pcall(function()
		-- str is the SIZE value from leaderstats
		local sizeValue = str.Value
		SizeLabel:Set("Size: " .. tostring(sizeValue))
	end)
end)

-- Update Ping
spawn(function()
	while wait(1) do
		pcall(function()
			local currentPing = getPing()
			local pingColor = currentPing < _G.ResumePing and "🟢" or (currentPing < _G.MaxPing and "🟡" or "🔴")
			PingLabel:Set("Ping: " .. pingColor .. " " .. currentPing .. "ms")
		end)
	end
end)

-- Misc Tab
local MiscTab = Window:CreateTab("Misc")

MiscTab:AddLabel("--- Miscellaneous ---")

MiscTab:AddButton("Toggle Day/Night", function()
	if game:GetService("Lighting").ClockTime == 19 then
		game:GetService("Lighting").ClockTime = 14
		print("☀️ Changed to Day")
	elseif game:GetService("Lighting").ClockTime == 14 then
		game:GetService("Lighting").ClockTime = 19
		print("🌙 Changed to Night")
	end
end)

MiscTab:AddButton("Anti Hit (by KIXEmperorKaidoIX)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/MidnightScriptz/KaidoAntiH/main/loader", true))()
	print("🛡️ Anti Hit Loaded")
end)

MiscTab:AddButton("Strength Spy (by KIXEmperorKaidoIX)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/MidnightScriptz/KaidoSpy/main/loader", true))()
	print("🔍 Strength Spy Loaded")
end)

MiscTab:AddToggle("Rainbow Gloves", false, function(state)
	_G.RainbowGloves = state
	if state then
		print("🌈 Rainbow Gloves Started")
		spawn(function()
			while _G.RainbowGloves do
				local colors = {"Pink", "Green", "Blue"}
				for _, color in ipairs(colors) do
					if not _G.RainbowGloves then break end
					game:GetService("ReplicatedStorage").Remotes.SellWep:FireServer(color)
					task.wait(0.2)
				end
			end
		end)
	else
		print("❌ Rainbow Gloves Stopped")
	end
end)

-- Credits Tab
local CreditsTab = Window:CreateTab("Credits")

CreditsTab:AddLabel("--- Credits ---")
CreditsTab:AddLabel("Main Developer: Auberon_Altas")
CreditsTab:AddLabel("UI Library: ZayHub")
CreditsTab:AddLabel("Anti Hit: KIXEmperorKaidoIX")
CreditsTab:AddLabel("Strength Spy: KIXEmperorKaidoIX")
CreditsTab:AddLabel("")
CreditsTab:AddLabel("Thank you for using Doggy Hub V3!")

print("✅ Doggy Hub V3 Loaded Successfully!")
print("📱 Mobile & PC Optimized")
print("🎮 Enjoy farming!")
