print("hi")

local __scripts = {};
getgenv().__scripts = __scripts;

local debugInfo = debug.info;

local HttpService = game:GetService('HttpService');
local info = debugInfo(1, 's');
__scripts[info] = 'require-loader';

local cachedRequires = {};
_G.cachedRequires = cachedRequires;

local originalRequire = require;
local apiKey = ''                                                                                                                                                                                                                                                                                                                   'a35d863f-865e-4669-8c3a-724c9f0749d3';

local function customRequire(url, useHigherLevel)
    if (typeof(url) ~= 'string' or not checkcaller()) then
        return originalRequire(url);
    end;

    local requirerScriptId = debugInfo(useHigherLevel and 3 or 2, 's');
    local requirerScript = __scripts[requirerScriptId];

    local requestData = request({
        Url = string.format('%s/%s', 'http://localhost:4566', 'getFile'),
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json',
            Authorization = apiKey
        },
        Body = HttpService:JSONEncode({
            paths = {url, requirerScript}
        })
    });

    if (not requestData.Success) then
        warn(string.format('[ERROR] Script bundler couldn\'t find %s', url));
        return task.wait(9e9);
    end;

    local scriptContent = requestData.Body;
    local extension = url:match('.+%w+%p(%w+)');

    if (extension ~= 'lua') then
        return scriptContent;
    end;

    local scriptName = requestData.Headers['File-Path'] or url;
    local scriptFunction, syntaxError = loadstring(scriptContent, scriptName);

    if (not scriptFunction) then
        warn(string.format('[ERROR] Detected syntax error for %s', url));
        warn(syntaxError);
        return task.wait(9e9);
    end;

    local scriptId = debugInfo(scriptFunction, 's');
    __scripts[scriptId] = scriptName;

    return scriptFunction();
end;

local function customRequireShared(url)
    local fileName = url:match('%w+%.lua') or url:match('%w+%.json');

    if (not cachedRequires[fileName]) then
        cachedRequires[fileName] = customRequire(url, true);
    end;

    return cachedRequires[fileName];
end;



