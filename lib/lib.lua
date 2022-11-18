local Util = {
	ChestSettings = {
		["Skip"] = false,
		["Auto"] = false,
		["TripleChest"] = true
	},

	AutoDelete = {
		["Epic"] = false,
		["Common"] = false,
		["Rare"] = false,
		["Uncommon"] = false
	},

	AutoDeleteMinions = {},

	ChestsToOpen = {},
}

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Game Folders
local Loaded = game:GetService('Workspace'):WaitForChild('Loaded')
local Breakables = Loaded:FindFirstChild('Breakables')
local Drops = Loaded:FindFirstChild('Drops')

local Events = ReplicatedStorage:WaitForChild('RemoteEvents')
local Functions = ReplicatedStorage:WaitForChild('RemoteFunctions')

-- Game Events
local BreakableEvent = Events:WaitForChild('BreakableClickEvent')
local OpenSettingsUpdateEvent = Events:WaitForChild('OpenSettingsUpdateEvent')

-- Game Functions
local ChestOpenFunction = Functions:WaitForChild('ChestOpenFunction')
local PickaxeBreakableFunction = Functions:WaitForChild('PickaxeBreakableFunction')

function Util:GetClosestBreakable()
		local closest = nil

		local closestDistance = math.huge
		for _, breakable in pairs(Breakables:GetChildren()) do
				if breakable:IsA('Model') then
					local distance = (LocalPlayer.Character.HumanoidRootPart.Position - breakable.PrimaryPart.Position).Magnitude
					if distance < closestDistance then
							if breakable:FindFirstChild('Center') then
								closest = breakable
								break
							end

							local Variants = breakable:GetChildren()
							local isVisible = false

							for _, variant in pairs(Variants) do
									if variant:IsA('Folder') then
											if variant:GetChildren()[1].Transparency == 0 then
													isVisible = true
											end
									end
							end

							if isVisible then
									closest = breakable
									closestDistance = distance
							end
					end
				end
		end

		return closest
end

function Util:BreakClosest()
		local closest = Util:GetClosestBreakable()

		if closest then
				BreakableEvent:FireServer(closest.Name, false)
		end
end

function Util:SwingPickaxe()
		local closest = Util:GetClosestBreakable()
		if closest then
				PickaxeBreakableFunction:InvokeServer(closest.Name)
		end
end

function Util:CollectAllDrops()
		for _, folder in pairs(Drops:GetChildren()) do
				for _, drop in pairs(folder:GetChildren()) do
						if drop:IsA('BasePart') then
								drop.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
						end
				end
		end
end

function Util:UpdateChestSettings(option, key, value)
		Util[option][key] = value

		OpenSettingsUpdateEvent:FireServer({
			["ChestSettings"] = Util.ChestSettings,
			["AutoDelete"] = Util.AutoDelete,
			["AutoDeleteMinions"] = Util.AutoDeleteMinions
		})
end

function Util:OpenChests()
	for _, chest in pairs(Util.ChestsToOpen) do
		if chest then
			ChestOpenFunction:InvokeServer({["Name"] = chest})
			
			if Util.ChestSettings.TripleChest then
				task.wait(2)
			else
				task.wait(0.8)
			end
		end
	end
end

function Util:GetChestNames()
	local chests = Loaded.Chests:GetChildren()
	local chestNames = {}

	for _, chest in pairs(chests) do
		table.insert(chestNames, chest.Name)
	end

	return chestNames
end

function Util:UpdateChestsToOpen(chests)
	Util.ChestsToOpen = chests
end

function Util:Log(...)
		local args = {...}
		local message = ''
		for _, arg in pairs(args) do
				message = message .. tostring(arg) .. ' '
		end
		warn('[Banana] ' .. message)
end

return Util
