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