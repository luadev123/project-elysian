local debugMode = true;
_G = debugMode and _G or {};

local scriptLoadAt = tick();

local function printf() end;

if (not game:IsLoaded()) then
    game.Loaded:Wait();
end;

local Services = sharedRequire('Modules/Services.lua');
local toCamelCase = sharedRequire('Modules/toCamelCase.lua');

local AnalayticsAPI = sharedRequire('Modules/classes/AnalyticsAPI.lua');
local errorAnalytics = AnalayticsAPI.new(getServerConstant('UA-187309782-1'));
local Utility = sharedRequire('@Modules/Utility.lua');

local _ = sharedRequire('@Modules/prettyPrint.lua');

local Players, TeleportService, ScriptContext, MemStorageService, HttpService, ReplicatedStorage = Services:Get(getServerConstant('Players'), 'TeleportService', 'ScriptContext', 'MemStorageService', 'HttpService', 'ReplicatedStorage');

do -- //Hook print debug
    if (debugMode) then
        local oldPrint = print;
        local oldWarn = warn;
        function print(...)
            return oldPrint('[DEBUG]', ...);
        end;

        function warn(...)
            return oldWarn('[DEBUG]', ...);
        end;

        function printf(msg, ...)
            return oldPrint(string.format('[DEBUG] ' .. msg, ...));
        end;
    else
        function print() end;
        function warn() end;
        function printf() end;
    end;
end;

local LocalPlayer = Players.LocalPlayer
local executed = false;

local supportedGamesList = HttpService:JSONDecode(sharedRequire('../gameList.json'));
local gameName = supportedGamesList[tostring(game.GameId)];

--//Base library

for _, v in next, getconnections(LocalPlayer.Idled) do
    if (v.Function) then continue end;
    v:Disable();
end;

--//Load special game Hub

local window;
local column1;
local column2;

if(debugMode) then
    warn("Script is running in debug mode")
end;

local myScriptId = debug.info(1, 's');
local seenErrors = {};

local hubVersion = typeof(ah_metadata) == 'table' and rawget(ah_metadata, 'version') or '';
if (typeof(hubVersion) ~= getServerConstant('string')) then return SX_CRASH() end;

local function onScriptError(message)
    if (table.find(seenErrors, message)) then
        return;
    end;

    if (message:find(myScriptId)) then
        table.insert(seenErrors, message);
        local reportMessage = 'elysian_v_' .. hubVersion .. message;
        errorAnalytics:Report(gameName, reportMessage, 1);
    end;
end

if (not debugMode) then
    ScriptContext.ErrorDetailed:Connect(onScriptError);
    if (gameName) then
        errorAnalytics:Report('Loaded', gameName, 1);

        if (not MemStorageService:HasItem('AnalyticsGame')) then
            MemStorageService:SetItem('AnalyticsGame', true);
            errorAnalytics:Report('RealLoaded', gameName, 1);
        end;
    end;
end;

GAMES_SETUP();

Utility.setupRenderOverload();
printf('[Script] [Game] Took %.02f to load', tick() - loadingGameStart);

printf('[Script] [Full] Took %.02f to load', tick() - scriptLoadAt);

getgenv().ah_loaded = true;
