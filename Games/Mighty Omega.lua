--// Main Debug Version \\ -- jobs bugged

Debug = true
function Debug(...)
    if Debug then
        print(...)
    end
end

local HttpService = game:GetService('HttpService');
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local statusEvent = getgenv().ah_statusEvent;

local CurrentThread = nil
local CurrentLog = {}
local GameName = "Mighty Omega"

local Utility = {};

local function setStatus(...)
    if (not statusEvent) then return end;
    statusEvent:Fire(...);
end;

if (not game:IsLoaded()) then
    setStatus('Waiting for game to load');
    game.Loaded:Wait();
end;

local LocalPlayer = game:GetService('Players').LocalPlayer;
local sharedRequires = {};
local gameId = game.GameId;
local jobId, placeId = game.JobId, game.PlaceId;
local userId = LocalPlayer.UserId;
local Services = {}
local plrGUI = LocalPlayer.PlayerGui;
local mouse = LocalPlayer:GetMouse()
local camera = workspace.CurrentCamera;
local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
local Character = LocalPlayer.Character
local HWID = gethwid()
local getFpsCap = getfpscap()
local Pass = false

function Services:Get(...)
	local allServices = {};

	for _, service in next, {...} do
		table.insert(allServices, self[service]);
	end

	return unpack(allServices);
end;

local ReplicatedStorage = game.ReplicatedStorage
local Players = game.Players
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local MemStorageService = game:GetService("MemStorageService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local NetworkClient = game:GetService("NetworkClient")
local GuiService = game:GetService("GuiService")
local PathfindingService = game:GetService("PathfindingService")

local isA = game.IsA;
local ffc = game.FindFirstChild;
local ffcwia = game.FindFirstChildWhichIsA;
local kick = game.Players.LocalPlayer.Kick;

repeat task.wait() until Character;
repeat task.wait() until ffc(LocalPlayer,"Backpack");
repeat task.wait() until ffc(LocalPlayer.Backpack,"LocalS");

local banRemote;
local remoteKey;

local foodTool,lastFood;
local hungerBar;
local calorieBar;
local staminaBar;
local fatigueNum;
local utility;
local visualFrame;
local beds = {};
local LivingThings;
local updateStat;
local tryingToSleep = false;
local eating = false
local sprinting = false
local PlayerMod = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
local Controls = PlayerMod:GetControls()
local CurrentlyPathing = false
local TweenI = TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
local VisualFolder = Instance.new("Folder",workspace)
local CurrentWaypoint = nil
local Pass = false
CurrentPath = nil

local function find(t, c)
    for i, v in next, t do
        if (c(v, i)) then
            return v, i;
        end;
    end;

    return nil;
end;

local function parseKey(str)
    return find({str:byte(1,9999)}, function(v) return v > 128 end);
end

local function getKey(script)
    if not script:IsA("LocalScript") then error("Expected a localscript got "..script.ClassName) end
    local key;

    local ran,env = pcall(getsenv,script);
    if not ran then return; end

    for _,v in next, env do
        if typeof(v) ~= 'function' then continue; end

        for _,k in next, getupvalues(v) do
            if typeof(k) ~= 'string' or not parseKey(k) then continue; end

            key = k;
            break;
        end
    end

    if key then return key; end

    for _,v in next, script.Parent:GetDescendants() do
        local con = string.match(v.ClassName,"Button") and getconnections(v.MouseButton1Click)[1] or getconnections(v.Changed)[1];
        if not con or not con.Function then continue; end

        for _,k in next, getupvalues(con.Function) do
            if typeof(k) ~= 'string' or not parseKey(k) then continue; end

            key = k;
            break;
        end

        if key then break; end
    end
    return key;
end

getgenv().getKey = getKey;

local function round(n, decimals)
	decimals = decimals or 0
	return math.floor(n * 10^decimals) / 10^decimals
end

local function loaded()
    if not Character then
        return false;
	elseif not ffc(Character,"HumanoidRootPart") then
        return false;
    elseif not ffc(Character,"Humanoid") then
        return false;
	elseif not ffc(Character,"DB") then
        return false;
    end
    return true;
end

local function grabUIObjects()
    pcall(function()
        if (plrGUI:FindFirstChild('MainGui') and plrGUI.MainGui:FindFirstChild('Utility')) then
            utility = plrGUI.MainGui.Utility;
            hungerBar = utility.StomachBar.BarF.Bar;
            calorieBar = utility.StomachBar.Calories.Bar;
            staminaBar = utility.StamBar.BarF.Bar;
            fatigueNum = utility.BodyFatigue;
            visualFrame = utility.VisualFrame;
        end
    end);
end;

grabUIObjects();

local function getStyle()
    if not loaded() then return; end
    if not ffc(LocalPlayer,"Backpack") then return; end
    if ffc(LocalPlayer.Backpack,"Style",true) then
        return ffc(LocalPlayer.Backpack,"Style",true).Parent;
    elseif ffc(Character,"Style",true) then
        return ffc(Character,"Style",true).Parent;
    end
    return nil
end

--Simple table search function
local function search(tbl,str)
    for t,k in next, tbl do
        if string.match(t,str) then
            return k;
        end
    end
    return nil;
end

--Legit move to function uses pathfind
local function legitMove(Position)
    if not loaded() then return; end
    local path = PathfindingService:CreatePath();
    path:ComputeAsync(Character.HumanoidRootPart.Position, Position);
    local waypoints = path:GetWaypoints();
    for _, waypoint in pairs(waypoints) do
    	Character.Humanoid:MoveTo(waypoint.Position);
    	Character.Humanoid.MoveToFinished:Wait();
    end
	print("uwu")
end

local Foods = {
    ["BCAA: $75"] = 75;
    ["Fat Burner: $70"] = 70;
    ["Protein Shake: $60"] = 60;
    ["Ramen: $55"] = 55;
    ["Hamburger: $55"] = 55;
    ["Tofu Beef Soup: $45"] = 45;
    ["Pancakes: $35"] = 35;
    ["Pie: $35"] = 35;
    ["Donut: $35"] = 35;
    ["EZ Taco: $25"] = 25;
    ["Hotdog: $25"] = 25;
    ["Chicken Fries: $20"] = 20;
    ["Omelette: $20"] = 20;
}

local foodButtons = {};
for i,v in next, workspace:GetDescendants() do
    if Foods[v.Name] then
        table.insert(foodButtons,v);
    end
end

local Teleports = {
    ["Protein CEO Bed"] = Vector3.new(-287.970764, 65.4588547, -256.528046);
    ["Gym CEO Bed"] = Vector3.new(-605.105347, 72.4071121, -158.616302);
    ["HOMRA CEO Bed"] = Vector3.new(-426, 84, -141);
    ["Bank CEO Bed1"] = Vector3.new(-429.838226, 139.137741, -521.047363);
    ["Bank CEO Bed2"] = Vector3.new(-400.048737, 138.245346, -519.46936);
    ["Space BunkBed"] = Vector3.new(-293.323395, 50.5205154, -522.796326);
    ["Mart CEO Bed"] = Vector3.new(-326.314911, 51.4444199, -514.276367);
    ["Boxing CEO Bed"] = Vector3.new(845.754395, 50.2253838, -102.881683);
    ["Ramen CEO Bed"] = Vector3.new(-1172.79968, 49.8107491, -309.082245);
    ["PRIME CEO Bed"] = Vector3.new(-1127.57178, 13.5423203, -829.319519);
    ["Police CEO Bed"] = Vector3.new(-791.490967, 49.4704971, 36.7121468);
    ["AOKI Gym"] = Vector3.new(-423.82809448242, -8.1605911254883, -492.89834594727);
}

local Events = game.ReplicatedStorage.Events;
local StatT = {};
local staminaP = 10;
local updateStat;
local autoTrain;
local stupidWait = false;

LivingThings = ffc(workspace,"Live") or Instance.new("Model");

setStatus('All done', true)
warn("Step 0")

sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'] = (function()
	
	local Services = {};
	local vim = getvirtualinputmanager and getvirtualinputmanager();
	
	function Services:Get(...)
	    local allServices = {};
	
	    for _, service in next, {...} do
	        table.insert(allServices, self[service]);
	    end
	
	    return unpack(allServices);
	end;
	
	setmetatable(Services, {
	    __index = function(self, p)
	        if (p == 'VirtualInputManager' and vim) then
	            return vim;
	        end;
	
	        local service = game:GetService(p);
	        if (p == 'VirtualInputManager') then
	            service.Name = "VirtualInputManager ";
	        end;
	
	        rawset(self, p, service);
	        return rawget(self, p);
	    end,
	});
	
	return Services;
end)();

sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'] = (function()
	
	--- Lua-side duplication of the API of events on Roblox objects.
	-- Signals are needed for to ensure that for local events objects are passed by
	-- reference rather than by value where possible, as the BindableEvent objects
	-- always pass signal arguments by value, meaning tables will be deep copied.
	-- Roblox's deep copy method parses to a non-lua table compatable format.
	-- @classmod Signal
	
	local Signal = {}
	Signal.__index = Signal
	Signal.ClassName = "Signal"
	
	--- Constructs a new signal.
	-- @constructor Signal.new()
	-- @treturn Signal
	function Signal.new()
		local self = setmetatable({}, Signal)
	
		self._bindableEvent = Instance.new("BindableEvent")
		self._argData = nil
		self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil
	
		return self
	end
	
	function Signal.isSignal(object)
		return typeof(object) == 'table' and getmetatable(object) == Signal;
	end;
	
	--- Fire the event with the given arguments. All handlers will be invoked. Handlers follow
	-- Roblox signal conventions.
	-- @param ... Variable arguments to pass to handler
	-- @treturn nil
	function Signal:Fire(...)
		self._argData = {...}
		self._argCount = select("#", ...)
		self._bindableEvent:Fire()
		self._argData = nil
		self._argCount = nil
	end
	
	--- Connect a new handler to the event. Returns a connection object that can be disconnected.
	-- @tparam function handler Function handler called with arguments passed when `:Fire(...)` is called
	-- @treturn Connection Connection object that can be disconnected
	function Signal:Connect(handler)
		if not self._bindableEvent then return error("Signal has been destroyed"); end --Fixes an error while respawning with the UI injected
	
		if not (type(handler) == "function") then
			error(("connect(%s)"):format(typeof(handler)), 2)
		end
	
		return self._bindableEvent.Event:Connect(function()
			handler(unpack(self._argData, 1, self._argCount))
		end)
	end
	
	--- Wait for fire to be called, and return the arguments it was given.
	-- @treturn ... Variable arguments from connection
	function Signal:Wait()
		self._bindableEvent.Event:Wait()
		assert(self._argData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
		return unpack(self._argData, 1, self._argCount)
	end
	
	--- Disconnects all connected events to the signal. Voids the signal as unusable.
	-- @treturn nil
	function Signal:Destroy()
		if self._bindableEvent then
			self._bindableEvent:Destroy()
			self._bindableEvent = nil
		end
	
		self._argData = nil
		self._argCount = nil
	end
	
	return Signal
end)();

sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2fFXSRAEWegfdhertyhwefasdacvzx422'] = (function()
	
	---	Manages the cleaning of events and other things.
	-- Useful for encapsulating state and make deconstructors easy
	-- @classmod Maid
	-- @see Signal
	
	local Signal = sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'];
	local tableStr = "table";
	local classNameStr = "Maid";
	local funcStr = "function";
	local threadStr = "thread";
	
	local Maid = {}
	Maid.ClassName = "Maid"
	
	--- Returns a new Maid object
	-- @constructor Maid.new()
	-- @treturn Maid
	function Maid.new()
		return setmetatable({
			_tasks = {}
		}, Maid)
	end
	
	function Maid.isMaid(value)
		return type(value) == tableStr and value.ClassName == classNameStr
	end
	
	--- Returns Maid[key] if not part of Maid metatable
	-- @return Maid[key] value
	function Maid.__index(self, index)
		if Maid[index] then
			return Maid[index]
		else
			return self._tasks[index]
		end
	end
	
	--- Add a task to clean up. Tasks given to a maid will be cleaned when
	--  maid[index] is set to a different value.
	-- @usage
	-- Maid[key] = (function)         Adds a task to perform
	-- Maid[key] = (event connection) Manages an event connection
	-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
	-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
	-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
	--                                it is destroyed.
	function Maid:__newindex(index, newTask)
		if Maid[index] ~= nil then
			error(("'%s' is reserved"):format(tostring(index)), 2)
		end
	
		local tasks = self._tasks
		local oldTask = tasks[index]
	
		if oldTask == newTask then
			return
		end
	
		tasks[index] = newTask
	
		if oldTask then
			if type(oldTask) == "function" then
				oldTask()
			elseif typeof(oldTask) == "RBXScriptConnection" then
				oldTask:Disconnect();
			elseif typeof(oldTask) == 'table' then
				oldTask:Remove();
			elseif (Signal.isSignal(oldTask)) then
				oldTask:Destroy();
			elseif (typeof(oldTask) == 'thread') then
				task.cancel(oldTask);
			elseif oldTask.Destroy then
				oldTask:Destroy();
			end
		end
	end
	
	--- Same as indexing, but uses an incremented number as a key.
	-- @param task An item to clean
	-- @treturn number taskId
	function Maid:GiveTask(task)
		if not task then
			error("Task cannot be false or nil", 2)
		end
	
		local taskId = #self._tasks+1
		self[taskId] = task
	
		return taskId
	end
	
	--- Cleans up all tasks.
	-- @alias Destroy
	function Maid:DoCleaning()
		local tasks = self._tasks
	
		-- Disconnect all events first as we know this is safe
		for index, task in pairs(tasks) do
			if typeof(task) == "RBXScriptConnection" then
				tasks[index] = nil
				task:Disconnect()
			end
		end
	
		-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
		local index, taskData = next(tasks)
		while taskData ~= nil do
			tasks[index] = nil
			if type(taskData) == funcStr then
				taskData()
			elseif typeof(taskData) == "RBXScriptConnection" then
				taskData:Disconnect()
			elseif (Signal.isSignal(taskData)) then
				taskData:Destroy();
			elseif typeof(taskData) == tableStr then
				taskData:Remove();
			elseif (typeof(taskData) == threadStr) then
				task.cancel(taskData);
			elseif taskData.Destroy then
				taskData:Destroy()
			end
			index, taskData = next(tasks)
		end
	end
	
	--- Alias for DoCleaning()
	-- @function Destroy
	Maid.Destroy = Maid.DoCleaning
	
	return Maid;
end)();

sharedRequires['440091b7051afb5de04e8074836c386e2e5cd7fa634c32d8daf533b6353c69fc'] = (function()
	
	local stringPattern = "%s(.)";
	return function (text)
	    return string.lower(text):gsub(stringPattern, string.upper);
	end;
end)();

sharedRequires['a5aab7a81f59849e7c2e50d0ecd43092d80b0aaa025889a2d0219df4023d863d'] = (function()
	local ContextActionService = game:GetService("ContextActionService")
    local HttpService = game:GetService("HttpService")
	
	local ControlModule = {};
	
	do
	    ControlModule.__index = ControlModule
	
	    function ControlModule.new()
	        local self = {
	            forwardValue = 0,
	            backwardValue = 0,
	            leftValue = 0,
	            rightValue = 0
	        }
	
	        setmetatable(self, ControlModule)
	        self:init()
	        return self
	    end
	
	    function ControlModule:init()
	        local handleMoveForward = function(actionName, inputState, inputObject)
	            self.forwardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
	            return Enum.ContextActionResult.Pass
	        end
	
	        local handleMoveBackward = function(actionName, inputState, inputObject)
	            self.backwardValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
	            return Enum.ContextActionResult.Pass
	        end
	
	        local handleMoveLeft = function(actionName, inputState, inputObject)
	            self.leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
	            return Enum.ContextActionResult.Pass
	        end
	
	        local handleMoveRight = function(actionName, inputState, inputObject)
	            self.rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
	            return Enum.ContextActionResult.Pass
	        end
	
	        ContextActionService:BindAction(HttpService:GenerateGUID(false), handleMoveForward, false, Enum.KeyCode.W);
	        ContextActionService:BindAction(HttpService:GenerateGUID(false), handleMoveBackward, false, Enum.KeyCode.S);
	        ContextActionService:BindAction(HttpService:GenerateGUID(false), handleMoveLeft, false, Enum.KeyCode.A);
	        ContextActionService:BindAction(HttpService:GenerateGUID(false), handleMoveRight, false, Enum.KeyCode.D);
	    end
	
	    function ControlModule:GetMoveVector()
	        return Vector3.new(self.leftValue + self.rightValue, 0, self.forwardValue + self.backwardValue)
	    end
	end
	
	return ControlModule.new();
end)();

local function EventConnect(Function)
	if not self.RobloxEvent then
		return
	end

	if self.Connection then
		self:Disconnect()
	end

	-- Connect
	self.Connection = self.RobloxEvent and self.RobloxEvent:Connect(Function) or nil
end

local function EventGet()
	return self.Connection
end

local function EventDisconnect()
	if not self.Connection then
		return
	end

	-- Disconnect connection
	self.Connection:Disconnect()
end

local function EventNew(RobloxEvent)
	-- Create Event object with data
	local EventObject = {
		RobloxEvent = RobloxEvent,
		Connection = nil,
	}

	-- Set the metatable of the Event object
	setmetatable(EventObject, self)

	-- Return back Event object
	return EventObject
end

function LoggerPrint(String, ...)
	-- Format string
	local FormatString = string.format(String, ...)

        rconsoleprint(FormatString .. "\n") 

	-- Add to current log, our current string...
	table.insert(CurrentLog, FormatString)
end


local function HelperTryAndCatch(Try, Catch)
	return xpcall(Try, Catch)
end

local function ThreadStart(...)
	if not CurrentThread then
		return
	end

	coroutine.resume(CurrentThread, ...)
end

local function ThreadStop()
	if not CurrentThread then
		return
	end

	-- Stop execution and close thread
	coroutine.yield(CurrentThread)
	coroutine.close(CurrentThread)

	-- Set current thread to nil
	CurrentThread = nil
end

local function ThreadCreate(Function)
	if not CurrentThread then
		ThreadStop()
	end

	CurrentThread = coroutine.create(Function)
end

local function ThreadNew(Object)
	-- Create Thread object with data
	local ThreadObject = { CurrentThread = nil }

	-- Set the metatable of the Thread object
	setmetatable(ThreadObject, self)
	CurrentThread = Object
	

	-- Return back Thread object
	return ThreadObject
end
	
warn("Loaded Requires")
local RenderEventObject = EventNew(RunService.RenderStepped)
local OnTeleportEventObject = EventNew(game.Players.LocalPlayer.OnTeleport)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/urmom1313/project-elysian/main/menulib.lua"))()

warn("Step 1")

local function MainThreadFn()
	HelperTryAndCatch(
		function()
		        warn("Injected")

				sharedRequires['1703a89252a94a3cb5cd02ad3d6ea64fffsd4744ee588da3340de8ca770740cc981NAzcgretsa'] = (function()
					local Signal = sharedRequires['1131354b3faa476e8cf67a829e7e64a41ecd461a3859adfe16af08354df80d2b'];
					local Services = sharedRequires['994cce94d8c7c390545164e0f4f18747359a151bc8bbe449db36b0efa3f0f4e6'];
				
					local CoreGui, Players, RunService, TextService, UserInputService, ContentProvider, HttpService, TweenService, GuiService, TeleportService = Services:Get('CoreGui', 'Players', 'RunService', 'TextService', 'UserInputService', 'ContentProvider', 'HttpService', 'TweenService', 'GuiService', 'TeleportService');
					
					local toCamelCase = sharedRequires['440091b7051afb5de04e8074836c386e2e5cd7fa634c32d8daf533b6353c69fc'];
					local Maid = sharedRequires['4d7f148d62e823289507e5c67c750b9ae0f8b93e49fbe590feb421847617de2fFXSRAEWegfdhertyhwefasdacvzx422'];
                    local ControlModule = sharedRequires['a5aab7a81f59849e7c2e50d0ecd43092d80b0aaa025889a2d0219df4023d863d'];
                    
					local visualizer;
					local doingAction = false

					local maid = Maid.new();
					local gMaid = Maid.new();

					-- Esp library Configeration 
					EspConfigeration = {
						whitelist = {}, -- When this table contains at least 1 user id, it will only show esp for those players.
						sharedSettings = {
							textSize = 13,
							textFont = 2,
							limitDistance = true, -- Set a maximum render distance
							maxDistance = 150,
							useTeamColor = false -- Change all colors to the players team color
						},
						teamSettings = {
							enemy = {
								enabled = false,
								box = false,
								boxColor = { Color3.new(1,0,0), 1 },
								--boxColor = { "Team Color", 1 }, -- Do this to change a single color to the team color
								boxOutline = true,
								boxOutlineColor = { Color3.new(), 1 },
								boxFill = false,
								boxFillColor = { Color3.new(1,0,0), 0.5 },
								healthBar = false,
								healthyColor = Color3.new(0,1,0),
								dyingColor = Color3.new(1,0,0),
								healthBarOutline = true,
								healthBarOutlineColor = { Color3.new(), 0.5 },
								healthText = false,
								healthTextColor = { Color3.new(1,1,1), 1 },
								healthTextOutline = true,
								healthTextOutlineColor = Color3.new(),
								box3d = false,
								box3dColor = { Color3.new(1,0,0), 1 },
								name = false,
								nameColor = { Color3.new(1,1,1), 1 },
								nameOutline = true,
								nameOutlineColor = Color3.new(),
								weapon = false,
								weaponColor = { Color3.new(1,1,1), 1 },
								weaponOutline = true,
								weaponOutlineColor = Color3.new(),
								distance = false,
								distanceColor = { Color3.new(1,1,1), 1 },
								distanceOutline = true,
								distanceOutlineColor = Color3.new(),
								tracer = false,
								tracerOrigin = "Bottom",
								tracerColor = { Color3.new(1,0,0), 1 },
								tracerOutline = true,
								tracerOutlineColor = { Color3.new(), 1 },
								offScreenArrow = false,
								offScreenArrowColor = { Color3.new(1,1,1), 1 },
								offScreenArrowSize = 15,
								offScreenArrowRadius = 150,
								offScreenArrowOutline = true,
								offScreenArrowOutlineColor = { Color3.new(), 1 },
								chams = false,
								chamsVisibleOnly = false,
								chamsFillColor = { Color3.new(0.2, 0.2, 0.2), 0.5 },
								chamsOutlineColor = { Color3.new(1,0,0), 0 },
							},
							friendly = {
								enabled = false,
								box = false,
								boxColor = { Color3.new(0,1,0), 1 },
								boxOutline = true,
								boxOutlineColor = { Color3.new(), 1 },
								boxFill = false,
								boxFillColor = { Color3.new(0,1,0), 0.5 },
								healthBar = false,
								healthyColor = Color3.new(0,1,0),
								dyingColor = Color3.new(1,0,0),
								healthBarOutline = true,
								healthBarOutlineColor = { Color3.new(), 0.5 },
								healthText = false,
								healthTextColor = { Color3.new(1,1,1), 1 },
								healthTextOutline = true,
								healthTextOutlineColor = Color3.new(),
								box3d = false,
								box3dColor = { Color3.new(0,1,0), 1 },
								name = false,
								nameColor = { Color3.new(1,1,1), 1 },
								nameOutline = true,
								nameOutlineColor = Color3.new(),
								weapon = false,
								weaponColor = { Color3.new(1,1,1), 1 },
								weaponOutline = true,
								weaponOutlineColor = Color3.new(),
								distance = false,
								distanceColor = { Color3.new(1,1,1), 1 },
								distanceOutline = true,
								distanceOutlineColor = Color3.new(),
								tracer = false,
								tracerOrigin = "Bottom",
								tracerColor = { Color3.new(0,1,0), 1 },
								tracerOutline = true,
								tracerOutlineColor = { Color3.new(), 1 },
								offScreenArrow = false,
								offScreenArrowColor = { Color3.new(1,1,1), 1 },
								offScreenArrowSize = 15,
								offScreenArrowRadius = 150,
								offScreenArrowOutline = true,
								offScreenArrowOutlineColor = { Color3.new(), 1 },
								chams = false,
								chamsVisibleOnly = false,
								chamsFillColor = { Color3.new(0.2, 0.2, 0.2), 0.5 },
								chamsOutlineColor = { Color3.new(0,1,0), 0 }
							}
						}
				    }

					function getHealth(player)
						local character = player.Character
						local humanoid = character and findFirstChildOfClass(character, "Humanoid");
						if humanoid then
							return humanoid.Health, humanoid.MaxHealth;
						end
					end

					if (not isfile('ProjectElysian')) then
						makefolder('EchoHub');
					end;
				
					if (not isfile('ProjectElysian/configs')) then
						makefolder('ProjectElysian/configs');
					end;
					
					if (not isfile('ProjectElysian/configs/globalConf.bin')) then
						-- By default global config is turned on
						writefile('ProjectElysian/configs/globalConf.bin', 'true');
					end;
					
					local globalConfFilePath = 'ProjectElysian/configs/globalConf.bin';
					local isGlobalConfigOn = readfile(globalConfFilePath) == 'true';
					local trainMove = "Push up"
					local librarySetting = {
						unloadMaid = Maid.new(),
						tabs = {},
						draggable = true,
						flags = {},
						title = string.format('ProjectElysian | v%s', 'DEBUG'),
						open = false,
						popup = nil,
						instances = {},
						connections = {},
						options = {},
						notifications = {},
						configVars = {},
						tabSize = 0,
						theme = {},
						foldername =  isGlobalConfigOn and 'ProjectElysian/configs/global' or string.format('ProjectElysian/configs/%s', tostring(LocalPlayer.UserId)),
						fileext = ".json",
						chromaColor = Color3.new(),
						attachToBackKey = nil,
						speedHackValue = 40,
                        flyHackValue = 40,
						fly = false,
                        infiniteJump = true,
                        infiniteJumpHeight = 40,
                        infRhythm = true,
                        runningSpeed = 1,
						infStamina = false,
						infDashes = false,
						streetFighterNotifier = false,
						eggNotifier = false,
						oneShot = true,
						oneShotPercent = 100,
						oneShotDelay = 1,
						useMouseClick = false,
						autoEat = false,
						["autoEatAt%"] = 50,
						["eatTo%"] = 90,
						legitAutoMachine = false,
						riskyAutoMachine = false,
						autoDura = false,
						autoProtein = false,
						autoFatBurner = false,
						autoScalar = false,
						["minimumStamina%"] = 10,
						["maximumStamina%"] = 100,
						minimumStamina = 10,
						maximumStamina = 100,
						autoReuse = false,
						treadmillType = "Stamina",
						keypressDelay = 0.25,
						treadmillPower = 1,
						reuseWait = 0.5,
						["lift/squatPower"] = 1,
						autoPunch = false,
						autoRhythm = false,
						autoSleep = false,
						training = "Push Up",
						autoTrain = true,
						trainingType = "Slow",
						minTrainingStam = 10,
						maxTrainingStam = 100,
						autoStrikespeed = true,
						autoWalk = false,
					}

					local functions = {};
					local globalMaid = Maid.new();
					local legitMachineMaid = Maid.new();
					local strikeMaid = Maid.new();
	
					function Utility.listenToChildAdded(folder, listener, options)
						options = options or {listenToDestroying = false};
					
						local createListener = typeof(listener) == 'table' and listener.new or listener;
					
						assert(typeof(folder) == 'Instance', 'listenToChildAdded folder #1 listener has to be an instance');
						assert(typeof(createListener) == 'function', 'listenToChildAdded #2 listener has to be a function');
					
						local function onChildAdded(child)
							local listenerObject = createListener(child);
					
							if (options.listenToDestroying) then
								child.Destroying:Connect(function()
									local removeListener = typeof(listener) == 'table' and (function() local a = (listener.Destroy or listener.Remove); a(listenerObject) end) or listenerObject;
					
									if (typeof(removeListener) ~= 'function') then
										warn('[Utility] removeListener is not definded possible memory leak for', folder);
									else
										removeListener(child);
									end;
								end);
							end;
						end
					
						debug.profilebegin(string.format('Utility.listenToChildAdded(%s)', folder:GetFullName()));
					
						for _, child in next, folder:GetChildren() do
							task.spawn(onChildAdded, child);
						end;
					
						debug.profileend();
					
						return folder.ChildAdded:Connect(createListener);
					end;

					local function getToolByName(toolName)
						if not loaded() then return; end
					
						return ffc(LocalPlayer.Backpack,toolName) or ffc(Character,toolName);
					end

					local function getStyle()
						if not loaded() then return; end
						if not ffc(LocalPlayer,"Backpack") then return; end
						if ffc(LocalPlayer.Backpack,"Style",true) then
							return ffc(LocalPlayer.Backpack,"Style",true).Parent;
						elseif ffc(Character,"Style",true) then
							return ffc(Character,"Style",true).Parent;
						end
						return nil
					end
					
					local Stats = setmetatable({},{ --Creates a metatable that returns values in %
						__index = function(t,k)
							if not hungerBar or hungerBar.Parent == nil then
								grabUIObjects();
							end;
					
							if k == "Hunger" then
								if hungerBar then
									return hungerBar.Size.X.Scale*100;
								end
							elseif k == "Calories" then
								if calorieBar then
									return calorieBar.Size.X.Scale*100;
								end
							elseif k == "Stamina" then
								if staminaBar then
									return staminaBar.Size.X.Scale*100;
								end
							elseif k == "Fatigue" then
								if fatigueNum then
									return tonumber(string.match(fatigueNum.Text,"[%d%.]+"));
								end
							elseif k == "isEating" then
								if ffc(Character,"DB") then
									return Character.DB.Value;
								end
							elseif k == "Rhythm" then
								if ffc(Character,"Rhythm") then
									return Character.Rhythm.Value;
								end
							elseif k == "isKnocked" then
								if ffc(Character,"Ragdolled") then
									return Character.Ragdolled.Value;
								end
							elseif k == "Sleeping" then
								if not loaded() then return false; end
					
								for i,v in next, Character.HumanoidRootPart:GetConnectedParts() do
									if v.Name == "Matress" then
										return true;
									end
								end
								return false;
							elseif k == "isRunning" then
								if not loaded() then return false; end
					
								local foundAnim = false;
								for i,v in next, Character.Humanoid.Animator:GetPlayingAnimationTracks() do
									local curId = v.Animation.AnimationId;
									if curId == "rbxassetid://5087736730" or curId == "rbxassetid://4889489948" then
										foundAnim = true;
									end
								end
								return foundAnim;
							elseif k == "isSquatting" then
								if not loaded() then return false; end
					
								local foundAnim = false;
								for i,v in next, Character.Humanoid.Animator:GetPlayingAnimationTracks() do
									local curId = v.Animation.AnimationId;
									if curId == "rbxassetid://4934239228" then
										foundAnim = true;
									end
								end
								return foundAnim;
							elseif k == "isPushuping" then
								if not loaded() then return false; end
					
								local foundAnim = false;
								for i,v in next, Character.Humanoid.Animator:GetPlayingAnimationTracks() do
									local curId = v.Animation.AnimationId;
									if curId == "rbxassetid://4931281501" then
										foundAnim = true;
									end
								end
								return foundAnim;
							elseif k == "ProteinShake" then
								if visualFrame then
									return ffc(visualFrame,"Protein Shake");
								end
							elseif k == "BCAA" then
								if visualFrame then
									return ffc(visualFrame,"BCAA");
								end
							elseif k == "FatBurner" then
								if visualFrame then
									return ffc(visualFrame,"Fat Burner");
								end
							elseif k == "Scalar" then
								if visualFrame then
									return ffc(visualFrame,"Scalar");
								end
							end
						end
					});
					getfenv().Stats = Stats; --Sets to script env

					local function getFood(foodName)
						if not foodName then foodName = ""; end
						if not loaded() then return; end
					
						local food;
						if foodName ~= "" then
							food = ffc(LocalPlayer.Backpack,foodName) or ffc(Character,foodName);
						else
							food = ffc(LocalPlayer.Backpack,"FoodScript",true) or ffc(Character,"FoodScript",true);
						end
					
						if not food then return; end
						if isA(food,"Tool") then
							return {food, food.Name};
						else
							return {food.Parent, food.Parent.Name};
						end
					end

					local function isBusy()
						if librarySetting.autoEat and Stats.Hunger <= librarySetting["autoEatAt%"] then
							repeat task.wait(); until Stats.Hunger >= librarySetting["eatTo%"] or (not librarySetting.legitAutoMachine and not librarySetting.riskyAutoMachine and not librarySetting.autoDura)
						end
						if librarySetting.autoProtein and getFood('Protein Shake') then
							repeat task.wait(); until Stats.ProteinShake or (not librarySetting.legitAutoMachine and not librarySetting.riskyAutoMachine and not librarySetting.autoDura)
						end
					
						if librarySetting.autoBcaa and getFood('BCAA') then
							repeat task.wait(); until Stats.BCAA or (not librarySetting.legitAutoMachine and not librarySetting.riskyAutoMachine and not librarySetting.autoDura)
						end
					
						if librarySetting.autoFatBurner and getFood('Fat Burner') then
							repeat task.wait(); until Stats.FatBurner or (not librarySetting.legitAutoMachine and not librarySetting.riskyAutoMachine and not librarySetting.autoDura)
						end
					
						if librarySetting.autoScalar and getFood('Scalar') then
							repeat task.wait(); until Stats.Scalar or (not librarySetting.legitAutoMachine and not librarySetting.riskyAutoMachine and not librarySetting.autoDura)
						end
						return;
					end

					local trainButtons = {
						["Strike"] = {};
						["Dura"] = {};
						["Road"] = {};
					};
					local BadModels = {};
					--Puts all the buttons in appropriate tables
					for i,v in next, workspace:GetDescendants() do
						if v.Name == "Weight2" and v.Parent.Name == "Model" and not BadModels[v.Parent] then
							BadModels[v.Parent] = true;
						end
						if v.Name == "Roadwork: $110" then
							table.insert(trainButtons["Road"],v);
						elseif v.Name == "Strike Speed Training: $180" then
							table.insert(trainButtons["Strike"],v);
						elseif v.Name == "Durability Training: $140" then
							table.insert(trainButtons["Dura"],v);
						end
					end
					
					--Simple table search function
					local function search(tbl,str)
						for t,k in next, tbl do
							if string.match(t,str) then
								return k;
							end
						end
						return nil;
					end
					
					--Gives closest button in specified range
					local function getButton(Type,Range)
						if not loaded() then return; end
						local closest;
						for i,v in next, trainButtons[Type] do
							if (v.Head.Position-Character.HumanoidRootPart.Position).magnitude < Range then
								Range = (v.Head.Position-Character.HumanoidRootPart.Position).magnitude;
								closest = v;
							end
						end
						return closest;
					end
					
					local punchingBags = {};
					for i,v in next, workspace:GetDescendants() do
						if v.Name == "PunchingBag" then
							table.insert(punchingBags,v.bag);
						end
					end
					
					local function getBag()
						if not loaded() then return; end
						local closest;
						for i,v in next, punchingBags do
							if ((v.Position * Vector3.new(1, 0, 1))-(Character.HumanoidRootPart.Position*Vector3.new(1,0,1))).magnitude < 6.5 then
								closest = v;
								break;
							end
						end
						return closest;
					end
					local AbleToSprint = false

					local env = getsenv(LocalPlayer.Backpack.LocalS)

					--Get closest bed returns bed model that is closest to you.
					local function closestBed()
						if not loaded() then return; end
						local last = 15; --Must be within 15 studs to click a bed aka ontop of it
						local closest;
						for i = 1,#beds do
							if ffc(beds[i],"Matress") and (beds[i].Matress.Position - Character.HumanoidRootPart.Position).magnitude < last then
								closest = beds[i];
								last = (closest.Matress.Position - Character.HumanoidRootPart.Position).magnitude;
							end
						end
						return closest;
					end


					--toggleSleep function that sleeps on bed and unsleep if in bed.
					local function toggleSleep()
						if not loaded() then return; end
					
						local bed = closestBed();
						if not bed then return; end
					
						if not Stats.Sleeping then
							tryingToSleep = true;
							repeat
								task.wait(0.2);
								Character.Humanoid:UnequipTools();
								safeClick(bed.Matress);
							until Stats.Sleeping or not librarySetting.autoSleep;
							tryingToSleep = false;
					
						elseif Stats.Sleeping and bed then
							Character.Humanoid:UnequipTools();
							safeClick(bed.Matress);
							task.wait(0.5);
							for i,v in next, Character:GetChildren() do
								if v.Name == "Safe" then
									v:Destroy();
								end
							end
					
						end
					end
					local function isPointInsidePart(part, point)
						-- Get the part's size and position
						local size = part.Size
						local position = part.Position
					  
						-- Calculate the part's minimum and maximum x, y, and z values
						local minX = position.X - size.X / 2
						local maxX = position.X + size.X / 2
						local minY = position.Y - size.Y / 2
						local maxY = position.Y + size.Y / 2
						local minZ = position.Z - size.Z / 2
						local maxZ = position.Z + size.Z / 2
					  
						-- Check if the point is inside the part's x, y, and z bounds
						if point.X > minX and point.X < maxX and point.Y > minY and point.Y < maxY and point.Z > minZ and point.Z < maxZ then
						  return true
						end
					  
						return false
					  end
					  
					
					local function TTP(Position : CFrame)
					
						if not Pass then
							if typeof(Position) == "Instance" then
								Position = Position.CFrame
							end
						
							if typeof(Position) == "Vector3" then
								Position = CFrame.new(Position)
							end
						
							if typeof(Position) ~= "CFrame" then
								warn("[!] Invalid Argument Passed to TTP()")
							else
								local OP = LocalPlayer.Character.HumanoidRootPart.Position
								local TTW = (OP - Position.Position).Magnitude / 5
							
								local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,TweenInfo.new(TTW),{CFrame = Position})
								Tween:Play()
								Tween.Completed:Wait()
							end
						end
						
						
					end;
					
					local function UpdateVisualPoint(Point,Remove,Color)
						task.spawn(function()
							if Remove == true then
								TweenService:Create(Point,TweenI,{Color3 = Color3.new(0.454902, 0.454902, 0.454902)}):Play()
								TweenService:Create(Point,TweenI,{Transparency = 1}):Play()
								wait(1)
								if Point.Parent then
									Point.Parent:Destroy()
								end
							else
								TweenService:Create(Point,TweenI,{Color3 = Color}):Play()
							end end)
					end
					
					
					local function CreateVisualPoint(Position)
						local A = Instance.new("Part")
						local B = Instance.new("SelectionSphere")
						A.Anchored = true
						A.CanCollide = false
						A.Size = Vector3.new(0.001,0.001,0.001)
						A.Position = Position + Vector3.new(0,2,0)
						A.Transparency = 1
						A.Parent = VisualFolder
						A.Name = tostring(Position)
						B.Transparency = 1
						B.Parent = A
						B.Adornee = A
						B.Color3 = Color3.new(1, 0, 0.0156863)
						TweenService:Create(B,TweenI,{Transparency = 0}):Play()
					end
					
					local function checkVisibility()
						for _, player in pairs(game.Players:GetPlayers()) do
							if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
								local raycastParams = RaycastParams.new()
								raycastParams.FilterDescendantsInstances = {player.Character}
								raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
								raycastParams.IgnoreWater = true
								local result = workspace:Raycast(player.Character.Head.Position, (LocalPlayer.Character.PrimaryPart.Position - player.Character.Head.Position).Unit * 70)
								if result and result.Instance:IsDescendantOf(LocalPlayer.Character) then
									return true
								end
							end
						end
						return false
					end
					
					local function CanPathTo(Position)
						local path = PathfindingService:CreatePath({
							AgentRadius = 2,
							AgentHeight = 4,
							AgentCanJump = true,
							AgentCanClimb = true
						})
					
						local success, errorMessage = pcall(function()
							path:ComputeAsync(Character.HumanoidRootPart.Position,Position)
						end)
					
						--CurrentPath = PathfindService:FindPathAsync(Character.HumanoidRootPart.Position,CoordinateFrame.Position)
						if success and path.Status == Enum.PathStatus.Success then
							for i,v in pairs(path:GetWaypoints()) do
								CreateVisualPoint(v.Position)
							end
							return true
						end
						return false
					end
					
					local function isPositionInsidePart(position)
						local params = OverlapParams.new()
						params.FilterType = Enum.RaycastFilterType.Whitelist
						params.FilterDescendantsInstances = { workspace }
					
						local parts = workspace:GetPartBoundsInRadius(position, 20, params)
					
						for i = 1, #parts do
						  local part = parts[i]
						  
						  if part:IsA("Part") and part.CanCollide == true and isPointInsidePart(part, position) then
							return true
						  end
						end
					  
						return false
					end
					
					local function Path2CFrame(CoordinateFrame,SafeValue)
						
						CurrentlyPathing = false
						
						for i,v in pairs(VisualFolder:GetChildren()) do
							UpdateVisualPoint(v.SelectionSphere,true)
						end
					
						local Humanoid = Character:FindFirstChild("Humanoid")
						Controls:Disable()
						-- Method 1 - Roblox pathfinding service
					
						local path = PathfindingService:CreatePath({
							AgentRadius = 2,
							AgentHeight = 4,
							AgentCanJump = true,
							AgentCanClimb = true
						})
					
						local success, errorMessage = pcall(function()
							path:ComputeAsync(Character.HumanoidRootPart.Position,CoordinateFrame.Position)
						end)
					
						--CurrentPath = PathfindService:FindPathAsync(Character.HumanoidRootPart.Position,CoordinateFrame.Position)
						if success and path.Status == Enum.PathStatus.Success then
							CurrentPath = path
					
							CurrentlyPathing = true
							
							for i,v in pairs(CurrentPath:GetWaypoints()) do
								CreateVisualPoint(Vector3.new(v.Position.X,v.Position.Y+5,v.Position.Z))
							end
							
							

							task.spawn(function()
								local TimesFailed = 0
								local TotalTimesFailed = 0
								
								while task.wait(0.5) and CurrentlyPathing == true do
									if TimesFailed == 2 then
										repeat wait() until not checkVisibility()
									    Debug("[!] Attempt to get unstuck failed, teleporting to next waypoint.")
										--Character:PivotTo(CFrame.new(CurrentWaypoint.Position + Vector3.new(0.1,0.1,0.1)))
										env.stopSprint();
										Humanoid.Jump = true
										Humanoid.WalkToPoint = CurrentWaypoint.Position
										TimesFailed = 0
									end
									
									if (Character.HumanoidRootPart.Velocity).Magnitude < 0.1 then
										Humanoid.WalkToPoint = CurrentWaypoint.Position
										task.wait(0.2)
										if (Character.HumanoidRootPart.Velocity).Magnitude < 0.1 then -- Double check
											local targetPosition = CurrentWaypoint.Position
											local characterPosition = game.Players.LocalPlayer.Character.PrimaryPart.Position
											local dx = targetPosition.X - characterPosition.X
											local dz = targetPosition.Z - characterPosition.Z
											local distance = math.sqrt(dx*dx + dz*dz)
											if distance < 3 and not checkVisibility() then
												Debug("[!] Stuck, Teleporting to next waypoint.")
												--Character:PivotTo(CFrame.new(CurrentWaypoint.Position + Vector3.new(0,4,0)))
												env.stopSprint();
												Humanoid.Jump = true
												Humanoid.WalkToPoint = CurrentWaypoint.Position
												TimesFailed = 0
											else
												TimesFailed = TimesFailed + 1
												TotalTimesFailed = TotalTimesFailed + 1
												Debug("[!] Stuck, attempting to jump.")
												env.stopSprint();
												Humanoid.Jump = true
												VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game);
												wait()
												Humanoid.WalkToPoint = CurrentWaypoint.Position
												env.runPrompt();
											end
										end
									else

										env.runPrompt();
										TimesFailed = 0
									end
									
								end
							end) -- should be seperate thread but keeps yielding next loop? (SOLVED, jumping cancels moveto)
							
							Pass = false
							local SkipNext = false
					
							for i,v in pairs(CurrentPath:GetWaypoints()) do
					
							 
					
								UpdateVisualPoint(VisualFolder[tostring(Vector3.new(v.Position.X,v.Position.Y+5,v.Position.Z))].SelectionSphere,false,Color3.new(0.0980392, 1, 0))
								
								if not Pass and not SkipNext then
									
									CurrentWaypoint = v
									Humanoid.WalkToPoint = Vector3.new(v.Position.X,v.Position.Y+5,v.Position.Z)
					
									Debug("[Debug] WalkToPoint set to ",Vector3.new(v.Position.X,v.Position.Y+5,v.Position.Z))
					
									repeat task.wait() until (Character.HumanoidRootPart.Position - Vector3.new(v.Position.X,v.Position.Y+5,v.Position.Z)).Magnitude < 3.8
					
									if CurrentPath:GetWaypoints()[i+1] ~= nil and isPositionInsidePart(CurrentPath:GetWaypoints()[i+1].Position + Vector3.new(0,2,0)) then
										SkipNext = true
									end
									
									if CurrentPath:GetWaypoints()[i+1] ~= nil and CurrentPath:GetWaypoints()[i+1].Action == Enum.PathWaypointAction.Jump then
										task.spawn(function()
											env.stopSprint();
											task.wait(0.1)
											Humanoid.Jump = true
											task.wait(1)
											env.runPrompt();
										end)
									end
					
								elseif SkipNext == true then
									print("Skipped [1] Invalid waypoint.")
									SkipNext = false
								end
					
								UpdateVisualPoint(VisualFolder[tostring(Vector3.new(v.Position.X,v.Position.Y+5,v.Position.Z))].SelectionSphere,true)
					
							end
							CurrentlyPathing = false
							Controls:Enable()
							print("Done")
							Pass = true
							return true
						else
							Pass = true
							CurrentlyPathing = false
							wait(1)
							print("Done2")
							-- Method 2 - Custom pathfinding (Slow)
							-- did not actually implement this lol, might add A* later.
							return false
						end
					end
					
					-- click to move basically ^
					
					local function checkRaycastObstruction(startPos, endPos)
						
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
						raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
						raycastParams.IgnoreWater = true
						local result = workspace:Raycast(startPos, endPos - startPos, raycastParams)
					
						-- Check if the raycast hit anything
						if result then
							-- Return the hit object and the hit position
							return result.Instance, result.Position
						else
							-- Return nil if the raycast did not hit anything
							return nil
						end
					end
					
					local function GetClosest(instances, origin)
						-- Initialize variables for the closest instance and distance
						local closestInstance = nil
						local closestDistance = math.huge
					  
						-- Iterate through all the instances in the table
						for _, instance in pairs(instances) do
						  -- Calculate the distance between the origin and the current instance
						  local distance = (origin.Position - instance.PosPart.Position).magnitude
					  
						  -- If the distance is smaller than the current closest distance,
						  -- update the closest instance and distance
						  if distance < closestDistance then
							closestInstance = instance
							closestDistance = distance
						  end
						end
					  
						-- Return the closest instance
						return closestInstance
					end
					

					do -- // hooks
                        local oldNamecall;
                        oldNamecall = hookmetamethod(game, "__namecall",function(self, ...)

                            local ncMethod = getnamecallmethod();
                            if ncMethod == "FireServer" and ncMethod == "fireServer" then
                                return;
                            end;

                            if librarySetting.infRhythm then

                            end

                            return oldNamecall(self,...);
                        end);
                        
                        local oldFireServer;
                        oldFireServer = hookfunction(Instance.new("RemoteEvent").FireServer,function(self, ...)
                            
                        
                            if self == banRemote then
                                return;
                            end;
                        
                            return oldFireServer(self,...);
                        end);
                        
					
						warn("LOADED HOOKS")
					end;

					do -- // Functions
						function functions.speedHack(toggle)
							if (not toggle) then
								maid.speedHack = nil;
								maid.speedHackBv = nil;
					
								return;
							end;
					
							maid.speedHack = RunService.Heartbeat:Connect(function()
								local playerData = {
									humanoid = Character.Humanoid,
									primaryPart = Character.HumanoidRootPart
								}
								local humanoid, rootPart = playerData.humanoid, playerData.primaryPart;
								if (not humanoid or not rootPart) then return end;
					
								if (librarySetting.fly) then
									maid.speedHackBv = nil;
									return;
								end;
					
								maid.speedHackBv = maid.speedHackBv or Instance.new('BodyVelocity');
								maid.speedHackBv.MaxForce = Vector3.new(100000, 0, 100000);
					
								if (not CollectionService:HasTag(maid.speedHackBv, 'AllowedBM')) then
									CollectionService:AddTag(maid.speedHackBv, 'AllowedBM');
								end;
					
								maid.speedHackBv.Parent = not librarySetting.fly and rootPart or nil;
								maid.speedHackBv.Velocity = (humanoid.MoveDirection.Magnitude ~= 0 and humanoid.MoveDirection or gethiddenproperty(humanoid, 'WalkDirection')) * librarySetting.speedHackValue;
							end);
						end;
					
						function functions.fly(toggle)
							local playerData = {
								humanoid = Character.Humanoid,
								primaryPart = Character.HumanoidRootPart
							}
							local RunService = game:GetService("RunService")
							if (not toggle) then
								maid.flyHack = nil;
								maid.flyBv = nil;
					
								return;
							end;
					
							maid.flyBv = Instance.new('BodyVelocity');
							maid.flyBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge);
					
							maid.flyHack = RunService.Heartbeat:Connect(function()
								local rootPart = Character.HumanoidRootPart
								local camera = workspace.CurrentCamera
	
								if (not rootPart or not camera) then return end;
					
								if (librarySetting.speed) then
									maid.flyBv = nil;
									return;
								end;

								if (not CollectionService:HasTag(maid.flyBv, 'AllowedBM')) then
									CollectionService:AddTag(maid.flyBv, 'AllowedBM');
								end;
					
								maid.flyBv.Parent = rootPart;
								maid.flyBv.Velocity = camera.CFrame:VectorToWorldSpace(ControlModule:GetMoveVector() * librarySetting.flyHackValue);

							end);
						end;

                        function functions.infiniteJump(toggle)
                            if(not toggle) then return end;
                    
                            repeat
                                local rootPart = LocalPlayer.Character:FindFirstChild('HumanoidRootPart');
                                if(rootPart and UserInputService:IsKeyDown(Enum.KeyCode.Space)) then
                                    rootPart.Velocity = Vector3.new(rootPart.Velocity.X, librarySetting.infiniteJumpHeight, rootPart.Velocity.Z);
                                end;
                                task.wait(0.1);
                            until not librarySetting.infiniteJump;
                        end;

						-- // esp functions
						function functions.PlayerEsp(toggle)
							Sense.teamSettings.enemy.enabled = toggle
                            Sense.teamSettings.enemy.name = toggle
							Sense.sharedSettings.limitDistance = toggle
						end;

						function safeClick(part) --Part should have a vector3 and contain ClickDetector

							fireclickdetector(part.Parent:FindFirstChildWhichIsA("ClickDetector"));
						end
						
						function safeButton(button)
							local size = button.AbsoluteSize;
							local pos = button.AbsolutePosition;
							local inset = GuiService:GetGuiInset();
							local center = {
								x = (pos.X+inset.X)+(size.X/2);
								y = (pos.Y+inset.Y)+(size.Y/2);
							}
							VirtualInputManager:SendMouseButtonEvent(center.x,center.y,0,true,game,0);
							task.wait(0.1);
							VirtualInputManager:SendMouseButtonEvent(center.x,center.y,0,false,game,0);
						end

						function ChangeRunningSpeed(toggleVal)
							local func;
							for i,v in next, getconnections(Events.UpdateStats.OnClientEvent) do
								if v.Function and not isexecutorclosure(v.Function) then
									func = v.Function;
								end
							end
							local tab = getupvalue(func,1);
							oldSpeed = rawget(tab,"RunningSpeed") or oldSpeed;
							print(oldSpeed)
							if not toggleVal then
								setmetatable(tab,nil);
								rawset(tab,"RunningSpeed",oldSpeed);
								return;
							end
							setmetatable(tab,{
								__newindex = function(t,k,v)
									if k == 'RunningSpeed' then
										return;
									end
									return rawset(t,k,v);
								end;
								__index = function(t,k)
									if k == 'RunningSpeed' then
										return librarySetting.runningSpeed;
									end
								end
							})
							rawset(tab,"RunningSpeed",nil);
						end
						local constantNum = table.find(getconstants(env.Dash),"FireServer");
						function InfStam(toggleVal)
							if not toggleVal then return; end
							if not loaded() then return; end
							print("Getting Key...")
							local key = getKey(LocalPlayer.Backpack.LocalS);
							
							if key then
								local action = LocalPlayer.Backpack.Action;
								print("Got Ket")
								repeat
									action:FireServer(key,"RunToggle",{[1] = true,[2] = false});
									task.wait();
									action:FireServer(key,"RunToggle",{false});
									task.wait(0.3)
								until not librarySetting.infStamina;
							end
						end
						function InfDashStam(toggleVal)
							if not toggleVal then setconstant(getsenv(LocalPlayer.Backpack.LocalS).Dash,constantNum,"FireServer") return; end
	
							setconstant(getsenv(LocalPlayer.Backpack.LocalS).Dash,constantNum,"GetChildren");
						end
	
						function InfDashes(toggleVal)
							if not toggleVal then return; end
							if not loaded() then return; end
							local env = getsenv(LocalPlayer.Backpack.LocalS);
							repeat
								task.wait(0.1)
								setupvalue(env.Dash,2,3);
								setupvalue(env.Dash,3,"");
							until not librarySetting.infDashes;
						end
					
						function AutoJob(value) 
							local JobBoard
							local JobClickDetector
							local RestockCheckpoint1
							local RestockCheckpoint2
							local DoingJob = false
							local Step = 0
							local GotJob

							JobBoard = game.Workspace["JobBoardModel"].Board
							JobClickDetector = JobBoard.Parent.ClickDetector

							if not DoingJob then
								DoingJob = true
								legitMove(JobBoard.Position)
								print("Finished walk")
								safeClick(JobBoard)
								task.wait(1.25)
								GotJob = game:GetService("Players")["Bobbey13131"].PlayerGui.JobGUI.Frame.Title.Text
								local function RepeatGetJob()
									wait(0.1)
									local args = {
										[1] = "Close",
									}
									
									game:GetService("Players")["Bobbey13131"].PlayerGui.JobGUI.RemoteEvent:FireServer(unpack(args))
									wait(0.35)
									safeClick(JobBoard)
									wait(1.25)
									GotJob = game:GetService("Players")["Bobbey13131"].PlayerGui.JobGUI.Frame.Title.Text
								end
								repeat RepeatGetJob() until GotJob == "Restock Job"

								RestockCheckpoint1 = game.Workspace.Jobs.SupplyDelivery.Convenience.Part1
								RestockCheckpoint2 = game.Workspace.Jobs.SupplyDelivery.Convenience.Part2

								legitMove(RestockCheckpoint1.Position)

								legitMove(RestockCheckpoint2.Position)

								wait(0.5)

								DoingJob = false
								GotJob = nil
								RestockCheckpoint2 = nil
								RestockCheckpoint1 = nil

							end
							--legitMove(game.Workspace["Metal Bat: $110000"].Head.Position)
						end
                     
						--AutoJob(true)
						function eat(item,ignore,keepEating)
							if getgenv().debug_auto_eat then
								print(item, Stats.Hunger, ignore, Stats.isEating, Stats.isRunning, doingAction, Stats.isKnocked, Stats.Sleeping, tryingToSleep, librarySetting.autoEat);
							end
							if typeof(item) == 'table' then item = unpack(item); end --If we pass a table to it handle it properly
							if Stats.Hunger >= librarySetting["autoEatAt%"] and not ignore then return; end
							if eating then return; end
							if Stats.isEating then return; end
							if Stats.isRunning then return false; end
							if doingAction then return false; end
							if Stats.isKnocked then return false; end
							if Stats.Sleeping then return false; end
							if tryingToSleep then return false; end
							if not item then return false; end
							if not librarySetting.autoEat then return false; end
							warn("PASSED ALL")
						
							if item.Parent == nil then
						
								if librarySetting.autoSleep and getFood() == nil then --If no more food and they using auto sleep, make them go to sleep.
									Character.Humanoid:UnequipTools();
									toggleSleep();
									return false;
								end
						
								return false;
							end
						
							eating = true;
							sprinting = false;
						
							warn(item.Parent);
							if item.Parent ~= Character then
								Character.Humanoid:UnequipTools();
							end
						
							if doingAction then Character.Humanoid:UnequipTools(); return false; end --We want to make sure we NEVER have food on treadmill
						
							item.Parent = Character;
							item:Activate();
						
							repeat task.wait(0.5); item:Activate(); if item.Parent == nil then break; end if item.Parent ~= Character then if doingAction then break; end item.Parent = Character; end until Stats.isEating or not librarySetting.autoEat; --If item is in nil or they are on the treadmill then break, otherwise equip
							repeat task.wait(0.5); until not Stats.isEating or not librarySetting.autoEat;
						
							if item.Parent ~= Character then
								Character.Humanoid:UnequipTools();
							end
							eating = false;
						
							if Stats.Hunger <= librarySetting["eatTo%"] and keepEating then
								local foodTab = getFood(lastFood) or getFood() or {};
								foodTool,lastFood = unpack(foodTab);
								eat(foodTool,true,true);
							end
							Character.Humanoid:UnequipTools();
						end
					end;


					

					local Window = Library:CreateWindow("Project Elysian".." - "..GameName.." ".."-".." Debug" ,true)

					Library:Notify("Loaded script",4)
                    
					do -- // Spectate
						local function spectatefunc(Object)
							if curSpectate == Object.Name then --Unspectate player
								curSpectate = "";
								Object.User.Txt.TextColor3 = Color3.new(255,255,255);
								camera.CameraSubject = Character.Humanoid;
								return;
							end
						
							if not ffc(LivingThings,Object.Name) then return; end --If they dont have a player model
						
							if oldObject and oldObject.Parent then
								oldObject.User.Txt.TextColor3 = Color3.new(255,255,255); --Reset the color when they spectate someone new
							end
						
							oldObject = Object;
							curSpectate = Object.Name;
						
							Object.User.Txt.TextColor3 = Color3.new(255,0,0);
							camera.CameraSubject = LivingThings[Object.Name].Humanoid;
						end
	
						-- // Spectate
	
						for i,v in next, plrGUI.PlayerList.Frame.ScrollF:GetChildren() do
							if not Players:FindFirstChild(v.Name) then continue; end
						
							v.User.MouseButton1Click:Connect(function()
								spectatefunc(v);
							end);
						end
	
						plrGUI.PlayerList.Frame.ScrollF.ChildAdded:Connect(function(v)
							v.User.MouseButton1Click:Connect(function()
								spectatefunc(v);
							end);
						end);
	
						
	
						plrGUI.ChildAdded:Connect(function(c)
							if c.Name ~= "PlayerList" then return; end
							if not c:WaitForChild("Frame",2) then return; end
							if not c.Frame:WaitForChild("ScrollF",2) then return; end
							repeat task.wait(); until ffc(c.Frame.ScrollF,plr.Name);
							task.wait(0.1)
							for i,v in next, c.Frame.ScrollF:GetChildren() do
								if not Players:FindFirstChild(v.Name) then continue; end
						
								v.User.MouseButton1Click:Connect(function()
									spectatefunc(v);
								end);
							end
						end);
					end

					local Tab1 = Window:AddTab("Main")
					local Tab2 = Window:AddTab("Esp")
					local Tab3 = Window:AddTab("Settings")

					local Esp = Tab2:AddLeftGroupbox("Players")
					local Settingsbox1 = Tab3:AddLeftGroupbox("Settings")
					local LeftGroupBox1 = Tab1:AddLeftGroupbox("Player")
					local LeftGroupBox2 = Tab1:AddLeftGroupbox("Risky")
					local RightGroupBox1 = Tab1:AddRightGroupbox("Misc")
					local FarmGroupBox1 = Tab1:AddLeftGroupbox("Autofarms")
					local Trainings = Tab1:AddLeftGroupbox("Trainings")
                    local StatV = Tab1:AddRightGroupbox("Stat Viewer")
                    local oldSpeed; --This function can get detected technically
					local env = getsenv(LocalPlayer.Backpack.LocalS)

					local stopOld = env.stopSprint;
					local runOld = env.runPrompt;
					env.runPrompt = function()
						local remote = LocalPlayer:FindFirstChild("Action",true);
						if remote then
							print("Found remote")
							local actionCon = getupvalues(getconnections(remote.OnClientEvent)[1].Function);
					
							local toolInfo = actionCon[13];
							print(toolInfo)
							if toolInfo then
								--print("Told it to stop playing..")
							end
						end
						sprinting = true;
						return runOld();
					end
					
					env.stopSprint = function()
						sprinting = false;
						return stopOld();
					end
                    
					do -- // Stats
						local whiteStats = {
							["BodyFatigue"] = true;
							["PrimaryStyle"] = true;
							["Calories"] = true;
							["Reputation"] = true;
							["Trait"] = true;
							["LowerBodyMuscle"] = true;
							["UpperBodyMuscle"] = true;
							["Karma"] = true;
							["MightyCoins"] = true;
							["BankMoney"] = true;
							["Money"] = true;
							["Stamina"] = true;
							["BodyHeat"] = true;
							["Rhythm"] = true;
							["Stomach"] = true;
							["Height"] = true;
							["RunningSpeed"] = true;
							["Fat"] = true;
							["SkillPoints"] = true;
							["Logged"] = true;
							["Banned"] = true;
							["Durability"] = true;
							["StrikingPower"] = true;
							["StrikingSpeed"] = true;
						};
						local function statfunction(p5,p6)
							if not whiteStats[p5] then return; end
							if p5 == "UpperBodyMuscle" then
								p5 = "UpperMuscle";
							elseif p5 == "LowerBodyMuscle" then
								p5 = "LowerMuscle";
							elseif p5 == "RunningSpeed" then
								p5 = "RunSpeed";
							end
							
							local val;
							if tonumber(p6) ~= nil then
								val = tostring(round(p6,3));
							elseif typeof(p6) == "table" then
								val = tostring(round(p6[1],3));
							else
								if typeof(p6) == 'function' then return; end
						
								val = tostring(p6);
							end
						
							if not StatT[p5] then
								StatT[p5] = StatV:AddLabel(string.format("%s: %s",p5,val),false);
							else
								StatT[p5].Text = string.format("%s: %s",p5,val);
							end
						 
						end
	
						for i,v in next, getconnections(Events.UpdateStats.OnClientEvent) do
							if not v.Function then
								return;
							end
							if string.match(debug.getinfo(v.Function,'s').short_src,"LocalS") then
								updateStat = v.Function;
							end
							
						end
	
						for i,v in next, getupvalues(updateStat) do
							if typeof(v) == 'table' then
								for t,k in next, v do
									statfunction(t,k);
								end
								break;
							end
						end
	
						Events.UpdateStats.OnClientEvent:Connect(statfunction)
						task.spawn(function()
							while task.wait(1) do
								if not loaded() then return; end
								if not ffc(Character,"MaxStamina") then return; end
								statfunction("Stamina",Character.MaxStamina.Value-100);
								statfunction("BodyHeat",Character.BodyHeat.Value);
								statfunction("Rhythm",Character.Rhythm.Value);
							end
						end);
					end


					do -- // moneyfarm
						function CashFarm()
							local JobBoard
							local JobClickDetector
							local RestockCheckpoint1
							local RestockCheckpoint2
							local DoingJob = false
							local Step = 0
							local GotJob
						
							JobBoard = game.Workspace["JobBoardModel"].Board
							JobClickDetector = JobBoard.Parent.ClickDetector
							Path2CFrame(JobBoard.CFrame * CFrame.new(Vector3.new(0,0,-2)),false)
							print("finished pathfind")
							env.stopSprint();
							wait()
							safeClick(JobBoard)
							local function RepeatGetJob()
								wait(0.1)
								repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("JobGUI")
								local args = {
									[1] = "Close",
								}
								
								game:GetService("Players").LocalPlayer.PlayerGui.JobGUI.RemoteEvent:FireServer(unpack(args))
								wait(0.35)
								safeClick(JobBoard)
								wait(1.25)
								GotJob = game:GetService("Players").LocalPlayer.PlayerGui.JobGUI.Frame.Title.Text
							end
							repeat RepeatGetJob() until GotJob == "Restock Job"
							
							
							RestockCheckpoint1 = game.Workspace.Jobs.SupplyDelivery.Convenience.Part1
							RestockCheckpoint2 = game.Workspace.Jobs.SupplyDelivery.Convenience.Part2    
							
							Path2CFrame(RestockCheckpoint1.CFrame * CFrame.new(Vector3.new(0,0,0)),false)
							env.stopSprint();
							wait(0.5)
						
							print("Done2")
						
							wait(0.5)
							
							Path2CFrame(RestockCheckpoint2.CFrame * CFrame.new(Vector3.new(0,0,5)),false)
							env.stopSprint();
						    
							wait(1.5)
						end
					end

					do -- // One shot
						local mobs = {};
                        local networkOneShot = {};
                        networkOneShot.__index = networkOneShot;

						function networkOneShot.new(mob)
							local self = setmetatable({},networkOneShot);
							mobs[mob] = self;
						
							self._maid = Maid.new();
						
							self.char = mob;
							self.humanoid = mob.Humanoid;
							self.hrp = mob.HumanoidRootPart;
						
							self._maid:GiveTask(mob.Destroying:Connect(function()
								self:Destroy();
							end))
							print("Made Connection!", mob);
							self._maid:GiveTask(RunService.RenderStepped:Connect(function()

								--if librarySetting.oneShotPercent < self.humanoid.Health/self.humanoid.MaxHealth*100 then return; end
								--wait(librarySetting.oneShotDelay)
							    --if not isnetworkowner(self.hrp) then return end;
								print("doing PivotTo on npc: "..self.char.Name)
								self.char:PivotTo(CFrame.new(self.hrp.Position.X,workspace.FallenPartsDestroyHeight-1000,self.hrp.Position.Z))
							end))

						end

						function networkOneShot:Destroy()
							self._maid:DoCleaning();
							for i,v in next, mobs do
								if v ~= self then continue; end
						
								mobs[i] = nil;
							end
						end

						function networkOneShot:ClearAll()
							for _,v in next, mobs do
								v:Destroy();
							end
						end


						-- // got rid because of buggynesss
					end

					do --Street Fighter ESP/Notifier

						local function onStreetFighterAdded(streetFighter)
							if not streetFighter:WaitForChild("HumanoidRootPart",10) then return; end
							local streetFighterName = streetFighter:WaitForChild("Attached",1) and streetFighter.Attached:WaitForChild("FakeH",1) and streetFighter.Attached.FakeH:FindFirstChildWhichIsA("Model") and streetFighter.Attached.FakeH:FindFirstChildWhichIsA("Model").Name or "Street Fighter";
					
							local sfESP = Sense.AddInstance(streetFighter.HumanoidRootPart, {
								enabled = true,
								text = "{Street Fighter}", -- Placeholders: {name}, {distance}, {position}
								textColor = { Color3.new(1,1,1), 1 },
								textOutline = true,
								textOutlineColor = Color3.new(),
								textSize = 13,
								textFont = 2,
								limitDistance = false,
								maxDistance = 150
							})
					
							local connection;
							connection = streetFighter.AncestryChanged:Connect(function()
								if streetFighter:IsDescendantOf(game) then return; end
					
								sfESP:Destroy();
								connection:Disconnect();
							end);
						end
					
						local function sfDescendantAdded(instance)
							if not instance or instance.Name ~= "NPCModel" then return; end
					
							local streetFighter;
					
							while true do
								streetFighter = instance.Value;
								if streetFighter then break; end
								task.wait();
							end
					
							local streetFighterName = streetFighter:WaitForChild("Attached",1) and streetFighter.Attached:WaitForChild("FakeH",1) and streetFighter.Attached.FakeH:FindFirstChildWhichIsA("Model") and streetFighter.Attached.FakeH:FindFirstChildWhichIsA("Model").Name or "Street Fighter";
							onStreetFighterAdded(streetFighter);
					
							if not librarySetting.streetFighterNotifier then return; end
					
							Library:Notify("A street fighter has spawned:"..streetFighterName,4)

							--if library.flags.webhookNotify then notifyWebhook("@everyone A Street Fighter has spawned: "..streetFighterName); end
						end

						RightGroupBox1:AddToggle("Street Fighter Notifier", {
							Text = "Street Fighter Notifier",
							Value = true, -- Default value (true / false)
							Callback = function(Value)
								librarySetting.streetFighterNotifier = Value
								if not Value then return; end
					
								sfDescendantAdded(ffc(workspace,"NPCModel",true))
							end,
						})
					
						workspace.DescendantAdded:Connect(sfDescendantAdded);
					end
					
					do -- // Egg Notifier/ESP

						local function onEggAdded(egg)

							for i,v in pairs(egg:GetChildren()) do
								if v:FindFirstChild("ClickDetector") and v:FindFirstChild("HumanoidRootPart") then
									
									local eggESP = Sense.AddInstance(v.HumanoidRootPart, {
										enabled = true,
										text = "{Anniversery Egg}", -- Placeholders: {name}, {distance}, {position}
										textColor = { Color3.new(1,1,1), 1 },
										textOutline = true,
										textOutlineColor = Color3.new(),
										textSize = 13,
										textFont = 2,
										limitDistance = false,
										maxDistance = 150
									})
							
									local connection;
									connection = egg.AncestryChanged:Connect(function()
										if egg:IsDescendantOf(game) then return; end
							
										eggESP:Destroy();
										connection:Disconnect();
									end);
								else
									local eggESP = Sense.AddInstance(egg.Cube, {
										enabled = true,
										text = "{Anniversery Egg}", -- Placeholders: {name}, {distance}, {position}
										textColor = { Color3.new(1,1,1), 1 },
										textOutline = true,
										textOutlineColor = Color3.new(),
										textSize = 13,
										textFont = 2,
										limitDistance = false,
										maxDistance = 150
									})
							
									local connection;
									connection = egg.AncestryChanged:Connect(function()
										if egg:IsDescendantOf(game) then return; end
							
										eggESP:Destroy();
										connection:Disconnect();
									end);
								end
							end

							
						end
					
						local function EggDescended(instance)

							if not instance then return; end
					
							local egg;
					
							while true do
								egg = instance;
								if egg then break; end
								task.wait();
							end
					
							onEggAdded(egg);
					
							if not librarySetting.eggNotifier then return; end
					
							Library:Notify("A egg has spawned!",4)

							--if library.flags.webhookNotify then notifyWebhook("@everyone A Street Fighter has spawned: "..streetFighterName); end
						end

						RightGroupBox1:AddToggle("Egg Notifier", {
							Text = "Egg Notifier",
							Value = true, -- Default value (true / false)
							Callback = function(Value)
								librarySetting.eggNotifier = Value
								if not Value then return; end

								for i,v in pairs(game.Workspace.Event:GetChildren()) do
									if v then
										EggDescended(v)
									end
								end

							end,
						})
					
						workspace.Event.DescendantAdded:Connect(EggDescended);
					end

					do -- // macro machine
						local legitAutoMachine = Tab1:AddLeftGroupbox("Legit Auto Machine");

						legitAutoMachine:AddToggle("LEGIT Auto Machine", {
							Text = "LEGIT Auto Machine",
							Value = false, -- Default value (true / false)
							Callback = function(toggle)
								librarySetting.legitAutoMachine = toggle
								if not toggle then legitMachineMaid:DoCleaning(); doingAction = false; return; end
							doingAction = false;
						
							local lastMachine = nil;
							legitMachineMaid:GiveTask(plrGUI.ChildAdded:Connect(function(v)
								task.wait()
								if ffc(v,"Machine") then lastMachine = v.Machine.Value; end
						
								if v.Name == "BarbellMachineGUI" or v.Name == "SquatMachineGUI" then
									if not v:WaitForChild("Frame2") then return; end
									if not v.Frame2:WaitForChild("LiftingF") then return; end
									doingAction = true;
						
									legitMachineMaid:GiveTask(v.Frame2.LiftingF.ChildAdded:Connect(function(z)
										if stupidWait then return; end
										if z.Name ~= "LiftIcon" then return; end
										if Stats.Stamina <= librarySetting["minimumStamina%"] then stupidWait = true; repeat task.wait() until Stats.Stamina >= librarySetting["maximumStamina%"] or (not librarySetting.legitAutoMachine); stupidWait = false; end --Wait for stamina to reach 100%
						
										task.wait(librarySetting.keypressDelay);
										repeat
											safeButton(z);
											task.wait(0.1);
										until (not z or not z.Parent)
									end))
						
									if not librarySetting.autoReuse then return; end
									if not v:WaitForChild("Frame") then return; end
									if not v.Frame:WaitForChild("ListF") then return; end
						
									local powerButton = v.Frame.ListF:WaitForChild(string.format("Barbell %s Weight",librarySetting["lift/squatPower"]));
									if not powerButton then return; end
						
									repeat
										safeButton(powerButton);
										task.wait();
									until (v.Frame2.Visible) or (not librarySetting.legitAutoMachine or not librarySetting.autoReuse)
						
									if (not librarySetting.legitAutoMachine) then return; end
						
									repeat task.wait() until (Stats.Stamina >= 100) or (not librarySetting.legitAutoMachine);
						
									repeat
										safeButton(v.Frame2.Start);
										task.wait();
									until not v.Frame2.Start.Visible or (not librarySetting.legitAutoMachine or not librarySetting.autoReuse)
									return;
								end
						
								--Treadmill Part
								if v.Name ~= "TreadmillMachineGUI" then return; end
								if not v:WaitForChild("Frame3") then return; end
								if not v.Frame3:WaitForChild("TrainingF") then return; end
						
								doingAction = true;
								task.wait();
								legitMachineMaid:GiveTask(v.Frame3.TrainingF.ButtonTemplate:GetPropertyChangedSignal("Position"):Connect(function()
									if stupidWait then return; end
									if Stats.Stamina <= librarySetting["minimumStamina%"] then stupidWait = true; repeat task.wait() until Stats.Stamina >= librarySetting["maximumStamina%"] or (not librarySetting.legitAutoMachine); stupidWait = false; end --Wait for stamina to reach 100%
						
									task.wait(librarySetting.keypressDelay);
						
									local key = v.Frame3.TrainingF.ButtonTemplate.Input.Text;
									VirtualInputManager:SendKeyEvent(true,key,false,game);
									task.wait(0.1);
									VirtualInputManager:SendKeyEvent(false,key,false,game);
								end))
						
								--Treadmill auto use part
								if not librarySetting.autoReuse then return; end
						
								if not v:WaitForChild("Frame") then return; end
								if not ffc(v.Frame,librarySetting.treadmillType,true) then return; end
						
								repeat
									safeButton(ffc(v.Frame,librarySetting.treadmillType,true));
									task.wait();
								until (not v.Parent) or (not v.Frame.Visible) or (not librarySetting.legitAutoMachine or not librarySetting.autoReuse)
						
								repeat task.wait(); until (v.Frame2.ListF:FindFirstChild(librarySetting.treadmillPower) or not librarySetting.autoReuse)
						
								repeat
									safeButton(ffc(v.Frame2.ListF,librarySetting.treadmillPower,true));
									task.wait();
								until (not v.Parent) or (not v.Frame2.Visible) or (not librarySetting.legitAutoMachine or not librarySetting.autoReuse)
						
								repeat task.wait(); until (v.Frame3.Visible) or (not librarySetting.legitAutoMachine);
						
								if (not librarySetting.legitAutoMachine) then return; end
								repeat task.wait() until (Stats.Stamina >= 100) or (not librarySetting.legitAutoMachine);
						
								repeat
									safeButton(v.Frame3.Start);
									task.wait();
								until not v.Frame3.Start.Visible or (not librarySetting.legitAutoMachine or not librarySetting.autoReuse)
							end))
						
							legitMachineMaid:GiveTask(plrGUI.ChildRemoved:Connect(function(v)
								if v.Name ~= "BarbellMachineGUI" and v.Name ~= "SquatMachineGUI" and v.Name ~= "TreadmillMachineGUI" then return; end
								doingAction = false; --Should be set before waiting to get on the machine
						
								if not librarySetting.autoReuse then return; end
								if not librarySetting.legitAutoMachine then return; end
								if not lastMachine then return; end
						
								task.wait(librarySetting.reuseWait);
						
								isBusy(); --Checks if they need to eat and waits until they do
						
								doingAction = true;
						
								Character.Humanoid:UnequipTools();
								repeat
									safeClick(lastMachine.Base);
									task.wait();
								until ffc(plrGUI,"BarbellMachineGUI") or ffc(plrGUI,"SquatMachineGUI") or ffc(plrGUI,"TreadmillMachineGUI") or not librarySetting.autoReuse or not librarySetting.legitAutoMachine
							end))
							end,
						})
						
						legitAutoMachine:AddSlider("Minimum Stamina %", {
							Text = "Minimum Stamina %",
							Default = 30,
							Min = 0,
							Max = 100,
							Rounding = 0,
							Compact = true,
							Suffix = "",
					
							Callback = function(Value)
								librarySetting.minimumStamina = Value
							end,
						})
						legitAutoMachine:AddSlider("Maximum Stamina %", {
							Text = "Maximum Stamina %",
							Default = 100,
							Min = 0,
							Max = 100,
							Rounding = 0,
							Compact = true,
							Suffix = "",
					
							Callback = function(Value)
								librarySetting.maximumStamina = Value
							end,
						})
						
						legitAutoMachine:AddToggle("Auto Reuse", {
							Text = "Auto Reuse",
							Value = false, -- Default value (true / false)
							Callback = function(Value)
								librarySetting.autoReuse = Value
							end,
						})
						legitAutoMachine:AddSlider("Reuse Wait", {
							Text = "Reuse Wait",
							Default = 2,
							Min = 0,
							Max = 2,
							Rounding = 2,
							Compact = true,
							Suffix = "",
					
							Callback = function(Value)
								librarySetting.reuseWait = Value
							end,
						})
						legitAutoMachine:AddDropdown("Treadmill Type", {
							Values = { "Stamina", "RunningSpeed"},
					
							Default = 1, -- number index of the value / string
							Multi = false, -- true / false, allows multiple choices to be selected
							AllowNull = false,
							Default = "Stamina",
							Text = "Treadmill Type",
					
							Callback = function(Value)
								librarySetting.treadmillType = Value
							end,
						})

						legitAutoMachine:AddSlider("Treadmill Power", {
							Text = "Treadmill Power",
							Default = 1,
							Min = 1,
							Max = 5,
							Rounding = 0,
							Compact = true,
							Suffix = "",
					
							Callback = function(Value)
								librarySetting.treadmillPower = Value
							end,
						})
						legitAutoMachine:AddSlider("Lift/Squat Power", {
							Text = "Lift/Squat Power",
							Default = 1,
							Min = 1,
							Max = 6,
							Rounding = 0,
							Compact = true,
							Suffix = "",
					
							Callback = function(Value)
								librarySetting["lift/squatPower"] = Value
							end,
						})
						legitAutoMachine:AddSlider("Keypress Delay", {
							Text = "Keypress Delay",
							Default = 0,
							Min = 0,
							Max = 1,
							Rounding = 0,
							Compact = true,
							Suffix = "",
					
							Callback = function(Value)
								librarySetting.keypressDelay = Value
							end,
						})
					end

					do -- // training
						Trainings:AddToggle("Auto Train", {
							Text = "Auto Train",
							Value = true, -- Default value (true / false)
							Callback = function(toggle)
								if not toggle then gMaid.autoTrainMaid = nil; return; end
						
								local env = getsenv(LocalPlayer.Backpack.LocalS);
								local autoTrainDeb = false;
								local tool = ffc(LocalPlayer.Backpack,trainMove) or ffc(Character,trainMove);
							
								gMaid.autoTrainMaid = RunService.Stepped:Connect(function()
									if autoTrainDeb then return; end
									if not loaded() then sprinting = false; return; end
									if eating or Stats.Sleeping or Stats.isKnocked or Stats.isEating or tryingToSleep then sprinting = false; return; end
							
									autoTrainDeb = true;
							
									if trainMove == "Stamina" then
							
										if Stats.Stamina < librarySetting.minTrainingStam and not Stats.isEating then sprinting = false; env.stopSprint(); repeat task.wait() until (Stats.Stamina >= librarySetting.maxTrainingStam) or (not librarySetting.autoTrain) end --Waiting for stamina
										if not Stats.isEating and not sprinting and not Stats.Sleeping and not Stats.isKnocked then sprinting = true; env.runPrompt(); end --If they can run then make them run
							
										autoTrainDeb = false;
										return; --If training stamina then return
									end
							
									if not tool or tool.Name ~= trainMove then tool = ffc(LocalPlayer.Backpack,trainMove) or ffc(Character,trainMove); end --If they changed what training they are using then switch the tool
									if not tool or not tool.Parent then librarySetting.autoTrain = false; autoTrainDeb = false; return; end --If no tool or tool is in nil then turn off and return
									if tool.Parent ~= Character and not Stats.isEating and not Stats.isKnocked and not Stats.Sleeping and not eating then Character.Humanoid:EquipTool(tool); task.wait(0.2); end --If they arent doing something and dont have the tool equipped, equip the tool
									if eating or Stats.Sleeping or Stats.isKnocked then autoTrainDeb = false; return; end --If they are busy then return
									if Stats.Stamina < librarySetting.minTrainingStam then repeat task.wait() until (Stats.Stamina >= librarySetting.maxTrainingStam) or (not librarySetting.autoTrain) end --If has less than staminaP task.wait till max stamina
							
									if librarySetting.trainingType == "Slow" then
										repeat task.wait() until not Stats.isSquatting or not librarySetting.autoTrain;
										repeat task.wait() until not Stats.isPushuping or not librarySetting.autoTrain;
									end
							
									if tool.Parent ~= Character then autoTrainDeb = false; return print("Couldn't equip tool"); end
									tool:Activate();
							
									local task1;
									local task2;
									if librarySetting.trainingType == "Slow" then
							
										task2 = task.delay(5,function()
											task.wait(5);
											task.cancel(task1);
											autoTrainDeb = false;
										end)
							
										task1 = task.spawn(function()
											if librarySetting.training == "Push up" then
												repeat task.wait() until Stats.isPushuping or not librarySetting.autoTrain;
											elseif librarySetting.training == "Squat" then
												repeat task.wait() until Stats.isSquatting or not librarySetting.autoTrain;
											end
											task.cancel(task2);
											autoTrainDeb = false;
										end)
									else
										autoTrainDeb = false;
									end
								end)
								env.stopSprint();
								sprinting = false;
							end,
						})
						Trainings:AddSlider("Stamina %", {
							Text = "Stamina %",
							Default = 10,
							Min = 1,
							Max = 100,
							Rounding = 0,
							Compact = true,
							Suffix = "",
					
							Callback = function(Value)
								staminaP = Value
								librarySetting.minTrainingStam = Value
							end,
						})
						Trainings:AddSlider("Max Stamina %", {
							Text = "Max Stamina %",
							Default = 100,
							Min = 1,
							Max = 100,
							Rounding = 0,
							Compact = true,
							Suffix = "",
					
							Callback = function(Value)
								librarySetting.maxTrainingStam = Value
							end,
						})
						Trainings:AddDropdown("Training", {
							Values = { "Push up", "Squat", "Stamina"},
					
							Default = 1, -- number index of the value / string
							Multi = false, -- true / false, allows multiple choices to be selected
							AllowNull = false,
							Default = "Push up",
							Text = "Training",
					
							Callback = function(Value)
								trainMove = Value
								librarySetting.training = Value
							end,
						})
						Trainings:AddDropdown("Training Type", {
							Values = { "Fast", "Slow"},
					
							Default = 1, -- number index of the value / string
							Multi = false, -- true / false, allows multiple choices to be selected
							AllowNull = false,
							Default = "Slow",
							Text = "Training Type",
					
							Callback = function(Value)
								librarySetting.trainingType = Value
							end,
						})

						Trainings:AddToggle("Auto Strikingspeed", {
							Text = "Auto Strikingspeed",
							Value = true, -- Default value (true / false)
							Callback = function(toggle)
								-- shitcode (messy af)

								librarySetting.autoStrikespeed = toggle
								if not toggle then strikeMaid:DoCleaning(); return; end

								local fightTool = getStyle();
								if not fightTool then
									librarySetting.autoStrikespeed = false
									return;
								end

								if not getBag() then
									librarySetting.autoStrikespeed = false
							
									Library:Notify("Get closer to a bag!",5)
									return;
								end
							
								for i,v in next, BadModels do
									for t,k in next, i:GetChildren() do
										--k.CanCollide = false;
									end
								end
								
								--Stuff that actually matters
                                local shouldM2 = false;
								strikeMaid:GiveTask(Character.ChildAdded:Connect(function(v)
									if v.Name == "Attacking" and v.Value == 4 then
										task.spawn(function() shouldM2 = true; task.wait(2); shouldM2 = false; end)
										v:Destroy();
									end
								end))
								 
								local function tryHit(canHit)
									while (canHit.Value and librarySetting.autoStrikespeed) do
										fightTool:Activate();
										if shouldM2 then
											local key = getKey(LocalPlayer.Backpack.LocalS);
											if not key then return; end
							
											LocalPlayer.Backpack.Action:FireServer(key,"GuardBreak",true);
										elseif not Character:WaitForChild("Attacking",0.2) and canHit.Value then
											fightTool:Activate();
										end
										task.wait(1)
									end
								end
								local curBag = Character.HumanoidRootPart.Position;
								strikeMaid:GiveTask(plrGUI.ChildAdded:Connect(function(v)
									if v.Name ~= "SpeedTraining" then return; end
							
									local canHit = v:WaitForChild("CanHit",5);
									if not canHit then return; end
							
									Character.Humanoid:UnequipTools();
									fightTool.Parent = Character;
									task.wait(0.1);
							
									strikeMaid:GiveTask(v.CanHit:GetPropertyChangedSignal("Value"):Connect(function()
										if not canHit.Value then return; end
							
										fightTool.Parent = Character;
										tryHit(canHit);
									end))
							
									if not canHit.Value then return; end
									tryHit(canHit);
								end))

								strikeMaid:GiveTask(plrGUI.ChildRemoved:Connect(function(v)
									if v.Name ~= "SpeedTraining" then return; end
									if ffc(LocalPlayer.Backpack,"Strike Speed Training") or ffc(Character,"Strike Speed Training") then return; end
							
									local button = getButton("Strike",999);
									if not button then return; end
							
									Character.Humanoid:UnequipTools();
							
									if ((button.Head.Position * Vector3.new(1, 0, 1)) - (Character.HumanoidRootPart.Position * Vector3.new(1, 0, 1))).magnitude > 10 and librarySetting.autoWalk then
										legitMove(button.Head.Position);
										safeClick(button.Head);
										legitMove(curBag);
									else
										safeClick(button.Head);
									end
							
									Character.Humanoid:UnequipTools();
									local strikeTool = LocalPlayer.Backpack:WaitForChild("Strike Speed Training",5) or ffc(Character,"Strike Speed Training");
							
									if not strikeTool then return; end
							
									strikeTool.Parent = Character;
									task.wait(0.3);
									strikeTool:Activate();
								end))
							
								if ffc(plrGUI,"SpeedTraining") then
									if fightTool.Parent ~= Character then Character.Humanoid:UnequipTools(); end
							
									local canHit = plrGUI.SpeedTraining:WaitForChild("CanHit",5);
									if not canHit then return; end
							
									fightTool.Parent = Character;
									task.wait(0.1);
							
									strikeMaid:GiveTask(plrGUI.SpeedTraining.CanHit:GetPropertyChangedSignal("Value"):Connect(function()
										if not canHit.Value then return; end
							
										fightTool.Parent = Character;
										tryHit(canHit);
									end))
									if not canHit.Value then return; end
							
									tryHit(canHit);
								else
									if ffc(LocalPlayer.Backpack,"Strike Speed Training") or ffc(Character,"Strike Speed Training") then return; end
							


									local button = getButton("Strike",999);
									if not button then print("no button"); return; end

									Character.Humanoid:UnequipTools();
									if librarySetting.autoWalk and ((button.Head.Position * Vector3.new(1, 0, 1)) - (Character.HumanoidRootPart.Position * Vector3.new(1, 0, 1))).magnitude > 10 then
										legitMove(button.Head.Position);
										safeClick(button.Head);
										legitMove(curBag);
									else
										safeClick(button.Head);
									end
							
									Character.Humanoid:UnequipTools();
							
									local strikeTool = LocalPlayer.Backpack:WaitForChild("Strike Speed Training",5) or ffc(Character,"Strike Speed Training");
									if not strikeTool then return; end
							
									strikeTool.Parent = Character;
									task.wait(0.2);
									strikeTool:Activate();
								end
							
							

							end,
						})

						Trainings:AddToggle("Auto Walk", {
							Text = "Auto Walk",
							Value = false, -- Default value (true / false)
							Callback = function(Value)
								librarySetting.autoWalk = Value
							end,
						})

					end

					do -- // UI
						RightGroupBox1:AddToggle("No Render", {
							Text = "No Render",
							Value = true, -- Default value (true / false)
							Callback = function(Value)
								local render = true
								if Value == true then
									render = false
								else
									render = true
								end
								game:GetService("RunService"):Set3dRenderingEnabled(render)

							end,
						})

						LeftGroupBox1:AddToggle("RunningSpeed Modifier", {
							Text = "RunningSpeed Modifier",
							Value = false, -- Default value (true / false)
							Callback = function(Value)
								ChangeRunningSpeed(Value)
							end,
						})
						--local Dropdown1 = RightGroupBox2:AddDropdown("Inventory Viewer",)
						LeftGroupBox1:AddSlider("Running Speed", {
							Text = "Running Speed",
							Default = 400,
							Min = 1,
							Max = 2600,
							Rounding = 5,
							Compact = true,
							Suffix = "",
					
							Callback = function(Value)
								librarySetting.runningSpeed = Value
							end,
						})
	
						LeftGroupBox2:AddToggle("Infinite Stamina", {
							Text = "Infinite Stamina",
							Value = false, -- Default value (true / false)
							Callback = function(Value)
								librarySetting.infStamina = Value
								InfStam(Value)
								InfDashStam(Value)
							end,
						})
	
						LeftGroupBox2:AddToggle("Infinite Dashes", {
							Text = "Infinite Dashes",
							Value = false, -- Default value (true / false)
							Callback = function(Value)
								librarySetting.infDashes = Value
								InfDashes(Value)
							end,
						})
	
						-- // esp toggles
	
						Esp:AddToggle("Player ESP", {
							Text = "Player ESP",
							Value = true, -- Default value (true / false)
							Callback = function(Value)
								functions.PlayerEsp(Value)
							end,
						}):AddColorPicker("namecolor", { Default = Color3.new(1,1,1), Callback = function(Value)
							Sense.teamSettings.enemy.nameColor[1] = Value
						end})
	
						
						Esp:AddSlider("DistanceSlider", {
							Text = "Fade out distance",
							Default = 1000,
							Min = 50,
							Max = 15000,
							Rounding = 5,
							Compact = false,
							Suffix = "",
					
							Callback = function(Value)
								Sense.sharedSettings.maxDistance = Value
							end,
						})
	
						Esp:AddToggle("Boxes", {
							Text = "Boxes",
							Value = true, -- Default value (true / false)
							Callback = function(Value)
								Sense.teamSettings.enemy.box = Value
							end,
						}):AddColorPicker("BoxColor", { Default = Color3.new(1,1,1), Callback = function(Value)
							Sense.teamSettings.enemy.boxColor[1] = Value
						end})
	
						Esp:AddToggle("Health", {
							Text = "ShowHealth",
							Value = true, -- Default value (true / false)
							Callback = function(Value)
								Sense.teamSettings.enemy.healthBar = Value
							end,
						})
	
						Esp:AddToggle("Distance", {
							Text = "ShowDistance",
							Value = true, -- Default value (true / false)
							Callback = function(Value)
								Sense.teamSettings.enemy.distance = Value
							end,
						}):AddColorPicker("DistanceColor", { Default = Color3.new(1,1,1), Callback = function(Value)
							Sense.teamSettings.enemy.distanceColor[1] = Value
						end})

						RightGroupBox1:AddToggle("AutoEat", {
							Text = "Auto Eat",
							Value = true, -- Default value (true / false)
							Callback = function(Value)
								librarySetting.autoEat = Value
								if not Value then return; end
								if not loaded() then return; end

								foodTool,lastFood = unpack(getFood() or {});
								repeat
									task.wait(0.2);
									local foodTab = getFood(lastFood) or getFood() or {};
									foodTool,lastFood = unpack(foodTab);
									local eatRet = eat(foodTool,false,true);
									if eatRet == false then
										eating = eatRet;
									end
								until not librarySetting.autoEat;

							end,
						})
						RightGroupBox1:AddSlider("AutoEatAt", {
							Text = "Auto Eat At %",
							Default = 25,
							Min = 1,
							Max = 100,
							Rounding = 0,
							Compact = false,
							Suffix = "%",
					
							Callback = function(Value)
								librarySetting["autoEatAt%"] = Value
							end,
						}) -- ["eatTo%"]
						RightGroupBox1:AddSlider("AutoEatTo", {
							Text = "Auto Eat To %",
							Default = 25,
							Min = 1,
							Max = 100,
							Rounding = 0,
							Compact = false,
							Suffix = "%",
					
							Callback = function(Value)
								librarySetting["eatTo%"] = Value
							end,
						}) 
						
						RightGroupBox1:AddButton("Server Hop", function()
							local req = request({
								Method = "GET";
								Url = "https://games.roblox.com/v1/games/4878988249/servers/Public?sortOrder=Asc&limit=50"
							})
							local decoded = game.HttpService:JSONDecode(req.Body);
							local lowestping = 1000;
							local id = "";
							for i,v in next, decoded.data do
								if v.playing ~= 30 and v.id ~= game.JobId and v.ping < lowestping then
									lowestping = v.ping;
									id = v.id;
								end
							end
							TeleportService:TeleportToPlaceInstance(4878988249,id,plr);
						end)

						RightGroupBox1:AddButton("Suicide", function()
							Character:BreakJoints()
						end)			

						FarmGroupBox1:AddButton("Auto Job (WIP)", function()
							while true do
								wait()
								
								--CashFarm()
								print('cashfarm')
								return
								
							end
						end)

						Settingsbox1:AddSlider("Set Fps Cap", {
							Text = "Set Fps Cap",
							Default = 30,
							Min = 30,
							Max = 1000,
							Rounding = 0,
							Compact = false,
							Suffix = "",
					
							Callback = function(Value)
								setfpscap(Value)
							end,
						})

						Settingsbox1:AddButton("Unload", function()
							Unload()
						end)			
					end
					
					-- // load esp
					Sense.Load() 
					warn(gethwid)

					--legitMove(game.Workspace["Metal Bat: $110000"].Head.Position)

					function Unload()
						warn("Detached.")

						local func;
                        for i,v in next, getconnections(Events.UpdateStats.OnClientEvent) do
                            if v.Function and not isexecutorclosure(v.Function) then
                                func = v.Function;
                            end
                        end
                        local tab = getupvalue(func,1);

						librarySetting.infStamina = false
						librarySetting.infDashes = false
						librarySetting.infiniteJump = false
						librarySetting.infRhythm = false
						librarySetting.fly = false
						librarySetting.runningSpeed = rawget(tab,"RunningSpeed") or oldSpeed;
						librarySetting.legitAutoMachine = false
						librarySetting.autoTrain = false
						ChangeRunningSpeed(false)
						env.stopSprint();

						Library:Unload()
						Sense.Unload()
						maid:DoCleaning()
						globalMaid:DoCleaning()
						gMaid:DoCleaning()
					end

				end)(); 
		end,

		-- Catch...
		function(Error)
			warn("MainThreadFn - Exception caught: %s"..Error)
		end
	)
end

ThreadNew(MainThreadFn())
ThreadStart()

warn("Loaded")
