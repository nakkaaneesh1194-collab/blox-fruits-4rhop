# 🏝️ Blox Fruits — Second Sea Server Hop

A Roblox executor script for Blox Fruits that finds and hops to a Second Sea server with ~3 hours 57 minutes of uptime, with a live server uptime display.

---

## ✨ Features

- Searches through public Blox Fruits servers and finds the best match for ~3:57h uptime
- Draggable GUI overlay with live server uptime counter
- Status messages showing search progress
- One-click hop with a 3-second countdown before teleport

## 💉 Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/nakkaaneesh1194-collab/blox-fruits-4rhop/main/bloxfruits_server_hop.lua"))()
```

Paste this into your executor while in Blox Fruits.

## 📋 How to Use

1. Join Blox Fruits
2. Paste the loadstring above into your executor and execute it
3. A GUI will appear at the top of your screen
4. Click **Find & Hop** — it will scan up to 500 servers across 5 pages
5. It picks the server whose estimated uptime is closest to 3h 57m
6. Teleports you there automatically after a 3-second countdown

## ⚙️ How It Works

- Hits the Roblox public server list API for Blox Fruits
- Estimates server uptime using player fill ratio as a heuristic (Roblox's API doesn't expose exact server creation time)
- Picks the closest match to the target uptime and teleports using `TeleportService`
- Live uptime ticker runs every frame via `RunService.Heartbeat`

## ⚠️ Disclaimer

This script is for educational purposes only. Using executors violates Roblox's Terms of Service and may result in a ban. Use at your own risk, preferably on an alt account.

---

*Made for Blox Fruits on Roblox.*

test ig

```lua
local rs = game:GetService("ReplicatedStorage")
for _, v in pairs(rs:GetDescendants()) do
    if v.Name:lower():find("uptime") or v.Name:lower():find("time") then
        print(v:GetFullName(), v.ClassName, pcall(function() return v.Value end))
    end
end
```

```lua
local rs = game:GetService("ReplicatedStorage")
for _, v in pairs(rs:GetDescendants()) do
    if (v.Name:lower():find("uptime") or v.Name:lower():find("servertime") or v.Name:lower():find("starttime")) then
        print(v:GetFullName(), v.ClassName, pcall(function() return v.Value end))
    end
end

-- Also check workspace
for _, v in pairs(workspace:GetDescendants()) do
    if v.Name:lower():find("uptime") or v.Name:lower():find("servertime") then
        print("workspace:", v:GetFullName(), v.ClassName)
    end
end

-- Check if BF exposes it as an attribute
print("workspace uptime attr:", workspace:GetAttribute("ServerUptime"))
print("workspace start attr:", workspace:GetAttribute("StartTime"))
print("os.time:", os.time())
print("DistributedGameTime:", workspace.DistributedGameTime)
```
```lua
local rs = game:GetService("ReplicatedStorage")
local now = os.time()
for _, v in pairs(rs:GetDescendants()) do
    if v.ClassName == "NumberValue" or v.ClassName == "IntValue" then
        local val = v.Value
        -- Server start time would be an os.time() value from hours ago
        -- So between (now - 24hrs) and (now - 1min)
        if val > (now - 86400) and val < (now - 60) and val > 1700000000 then
            print(v:GetFullName(), val, "uptime:", now - val, "seconds =", math.floor((now-val)/3600), "hrs")
        end
    end
end
```

```lua
local now = os.time()
local services = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ReplicatedFirst"),
    workspace
}
for _, svc in pairs(services) do
    for _, v in pairs(svc:GetDescendants()) do
        -- Check all value types
        local ok, val = pcall(function() return v.Value end)
        if ok and val then
            local num = tonumber(val)
            if num and num > (now - 86400) and num < (now - 60) and num > 1700000000 then
                print(v:GetFullName(), v.ClassName, num, "= uptime:", math.floor((now - num)/3600), "hrs", math.floor(((now-num)%3600)/60), "min")
            end
        end
    end
end
```
```lua
local val = workspace.DistributedGameTime
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Server Uptime",
    Text = "DGT: " .. math.floor(val) .. "s = " .. math.floor(val/3600) .. "h " .. math.floor((val%3600)/60) .. "m",
    Duration = 10
})
```

```lua
local SettingsService = game:GetService("SettingsService")
local start = SettingsService:GetServerStart()
print("Start:", start, "Uptime:", os.time() - start, "=", math.floor((os.time()-start)/3600), "h", math.floor(((os.time()-start)%3600)/60), "m")
```
```lua
local jobId = game.JobId
local res = request({Url = "https://api.ropro.io/getServerAge.php?serverId=" .. jobId, Method = "GET"})
print(res.Body)
```
```lua
local rs = game:GetService("ReplicatedStorage")
local snapshots = {}

-- First snapshot
for _, v in pairs(rs:GetDescendants()) do
    if v.ClassName == "NumberValue" or v.ClassName == "IntValue" then
        snapshots[v:GetFullName()] = v.Value
    end
end

task.wait(5)

-- Second snapshot — find anything that ticked up ~5 seconds
for _, v in pairs(rs:GetDescendants()) do
    if v.ClassName == "NumberValue" or v.ClassName == "IntValue" then
        local old = snapshots[v:GetFullName()]
        if old then
            local diff = v.Value - old
            if diff >= 3 and diff <= 7 then
                print("FOUND:", v:GetFullName(), "| current:", v.Value, "| changed by:", diff)
            end
        end
    end
end
```
```lua
local function checkService(svc)
    for _, v in pairs(svc:GetDescendants()) do
        if v.ClassName == "StringValue" then
            local val = tonumber(v.Value)
            if val and val > 1700000000 and val < os.time() then
                print(v:GetFullName(), v.Value, "uptime:", math.floor((os.time()-val)/3600), "h", math.floor(((os.time()-val)%3600)/60), "m")
            end
        end
    end
end

checkService(game:GetService("ReplicatedStorage"))
checkService(game:GetService("ReplicatedFirst"))
checkService(workspace)
```
```lua
local HttpService = game:GetService("HttpService")
local log = {}

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "InvokeServer" and self.ClassName == "RemoteFunction" then
        local result = {oldNamecall(self, ...)}
        -- Log it
        table.insert(log, {
            name = self:GetFullName(),
            result = tostring(result[1]):sub(1, 100)
        })
        return table.unpack(result)
    end
    return oldNamecall(self, ...)
end))

-- Wait a few seconds for QO to call its remotes, then print log
task.wait(5)
for _, entry in ipairs(log) do
    print("RF:", entry.name, "->", entry.result)
end
```
```lua
local rf = game:GetService("ReplicatedStorage").Remotes.Clock.DelayedRequestFunction
local ok, result = pcall(function() return rf:InvokeServer() end)
print("Clock value:", result)
print("os.time():", os.time())
print("diff:", os.time() - result)
print("as hours:", math.floor((os.time() - result) / 3600))
print("as minutes:", math.floor(((os.time() - result) % 3600) / 60))
```
```lua
local clockValue = nil

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local result = {oldNamecall(self, ...)}
    if method == "InvokeServer" 
        and self:GetFullName() == "ReplicatedStorage.Remotes.Clock.DelayedRequestFunction" 
        and type(result[1]) == "number" then
        clockValue = result[1]
    end
    return table.unpack(result)
end))

-- Wait for QO to call it, then check
task.wait(3)
print("Clock value captured:", clockValue)
if clockValue then
    print("Uptime:", math.floor(clockValue/3600), "h", math.floor((clockValue%3600)/60), "m")
end
```
```lua
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local result = {oldNamecall(self, ...)}
    if method == "InvokeServer" and self.ClassName == "RemoteFunction" then
        local r = result[1]
        -- Only print if result looks like a small number (could be uptime seconds)
        if type(r) == "number" and r < 100000 and r > 0 then
            print("RF:", self:GetFullName(), "->", r, "| as mins:", math.floor(r/60))
        end
    end
    return table.unpack(result)
end))

task.wait(10)
print("done")
```
```lua
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local result = {oldNamecall(self, ...)}
    -- Catch ALL remote calls, filter out Clock spam
    if (method == "InvokeServer" or method == "FireServer") 
        and self.ClassName == "RemoteFunction" 
        and not self:GetFullName():find("Clock") then
        print("RF:", self:GetFullName(), "->", tostring(result[1]):sub(1,80))
    end
    return table.unpack(result)
end))

task.wait(10)
print("done")
```
```lua
local rf = game:GetService("ReplicatedStorage").Remotes.Clock.DelayedRequestFunction
-- Spy on next QO call
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local result = {oldNamecall(self, ...)}
    if method == "InvokeServer" and self == rf then
        local v = result[1]
        print("raw:", v)
        print("os.time():", os.time())
        print("os.time() - v:", os.time() - v)
        print("v - os.time():", v - os.time())
    end
    return table.unpack(result)
end))
```
```lua
local rs = game:GetService("ReplicatedStorage")
for _, v in pairs(rs:GetDescendants()) do
    if v.ClassName == "ModuleScript" then
        local ok, result = pcall(require, v)
        if ok and type(result) == "table" then
            for k, val in pairs(result) do
                if type(val) == "number" and val > 1700000000 and val < os.time() then
                    print(v:GetFullName(), k, val, "uptime:", math.floor((os.time()-val)/3600).."h", math.floor(((os.time()-val)%3600)/60).."m")
                end
            end
        end
    end
end
```
```lua
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local result = {oldNamecall(self, ...)}
    if method == "InvokeServer" and self.ClassName == "RemoteFunction" then
        local r = result[1]
        if type(r) == "table" then
            -- Deep search the table for anything that looks like a unix timestamp
            local function search(t, path)
                for k, v in pairs(t) do
                    local fullPath = path .. "." .. tostring(k)
                    if type(v) == "number" and v > 1700000000 and v < os.time() then
                        print(self:GetFullName(), fullPath, "=", v, "uptime:", math.floor((os.time()-v)/3600).."h", math.floor(((os.time()-v)%3600)/60).."m")
                    elseif type(v) == "table" then
                        search(v, fullPath)
                    end
                end
            end
            search(r, self.Name)
        end
    end
    return table.unpack(result)
end))

task.wait(10)
print("done")
```
```lua
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "GetAsync" or method == "PostAsync" or method == "RequestAsync" then
        local args = {...}
        print("HTTP:", method, tostring(args[1]):sub(1, 120))
    end
    return oldNamecall(self, ...)
end))

-- Also hook executor's request function
local oldRequest = request
request = function(opts)
    print("request():", tostring(opts.Url):sub(1, 120))
    return oldRequest(opts)
end

task.wait(15)
print("done")
```
```lua
-- Run this BEFORE QO
local oldRequest = request
request = newcclosure(function(opts)
    print("REQ:", tostring(opts.Url):sub(1, 150))
    return oldRequest(opts)
end)

local HttpService = game:GetService("HttpService")
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "GetAsync" or method == "PostAsync" then
        print("HTTP:", method, tostring(select(1,...)):sub(1,150))
    end
    return oldNamecall(self, ...)
end))

print("Hook active - now execute QO")
```
```lua
-- Delta has a built-in http logger
if http_spy then
    http_spy(function(url, method, body)
        print("SPY:", method, url:sub(1,150))
    end)
    print("http_spy active")
elseif HttpSpy then
    HttpSpy(function(url)
        print("SPY:", url:sub(1,150))
    end)
    print("HttpSpy active")
else
    print("no http spy available")
end
```
```lua
local now = os.time()
for _, v in pairs(getgc()) do
    if type(v) == "number" and v > 1700000000 and v < now then
        print("GC number:", v, "uptime:", math.floor((now-v)/3600).."h", math.floor(((now-v)%3600)/60).."m")
    end
end
```
```lua
for _, v in pairs(getgc()) do
    if type(v) == "string" and v:find("uptime") then
        print("GC string:", v:sub(1,100))
    end
end
```

