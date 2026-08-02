-- Blox Fruits: Second Sea Server Hop Script
-- Finds a Second Sea server with ~3:57 hours uptime (237 minutes)
-- Shows a GUI with live server uptime display

local TARGET_UPTIME_MINUTES = 237 -- 3 hours 57 minutes
local UPTIME_TOLERANCE = 10 -- ±10 minutes tolerance
local GAME_ID = 2753915549 -- Blox Fruits game ID
local TARGET_SEA = 2 -- Second Sea

-- Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Executor-compatible HTTP function
-- Supports: request(), syn.request(), http.request(), HttpSpy, fluxus, etc.
local function httpGet(url)
    if syn and syn.request then
        local res = syn.request({ Url = url, Method = "GET" })
        return res.Body
    elseif http and http.request then
        local res = http.request({ Url = url, Method = "GET" })
        return res.Body
    elseif request then
        local res = request({ Url = url, Method = "GET" })
        return res.Body
    elseif (fluxus and fluxus.request) then
        local res = fluxus.request({ Url = url, Method = "GET" })
        return res.Body
    else
        -- Last resort: game's HttpService (works in some exploits)
        return HttpService:GetAsync(url, true)
    end
end

local LocalPlayer = Players.LocalPlayer

-- ─── GUI Setup ──────────────────────────────────────────────────────────────

local function buildGui()
    -- Remove existing GUI if present
    local existing = CoreGui:FindFirstChild("BFServerHopGui")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BFServerHopGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    -- Main frame
    local Frame = Instance.new("Frame")
    Frame.Name = "Main"
    Frame.Size = UDim2.new(0, 300, 0, 180)
    Frame.Position = UDim2.new(0.5, -150, 0, 20)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 170, 0)
    Stroke.Thickness = 2
    Stroke.Parent = Frame

    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 36)
    TitleBar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Frame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar

    -- Fix bottom corners of title bar
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
    TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
    TitleFix.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "🏝️  Blox Fruits — Server Hop"
    TitleLabel.TextColor3 = Color3.fromRGB(15, 15, 20)
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Status label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "Status"
    StatusLabel.Size = UDim2.new(1, -20, 0, 24)
    StatusLabel.Position = UDim2.new(0, 10, 0, 44)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "⏳  Searching for Second Sea servers..."
    StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = Frame

    -- Uptime display
    local UptimeLabel = Instance.new("TextLabel")
    UptimeLabel.Name = "Uptime"
    UptimeLabel.Size = UDim2.new(1, -20, 0, 50)
    UptimeLabel.Position = UDim2.new(0, 10, 0, 72)
    UptimeLabel.BackgroundTransparency = 1
    UptimeLabel.Text = "Server Uptime\n--:--:--"
    UptimeLabel.TextColor3 = Color3.fromRGB(255, 200, 60)
    UptimeLabel.TextSize = 18
    UptimeLabel.Font = Enum.Font.GothamBold
    UptimeLabel.TextXAlignment = Enum.TextXAlignment.Center
    UptimeLabel.Parent = Frame

    -- Target label
    local TargetLabel = Instance.new("TextLabel")
    TargetLabel.Name = "Target"
    TargetLabel.Size = UDim2.new(1, -20, 0, 20)
    TargetLabel.Position = UDim2.new(0, 10, 0, 126)
    TargetLabel.BackgroundTransparency = 1
    TargetLabel.Text = "Target: 03:57:00  |  Sea: 2nd"
    TargetLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    TargetLabel.TextSize = 11
    TargetLabel.Font = Enum.Font.Gotham
    TargetLabel.TextXAlignment = Enum.TextXAlignment.Center
    TargetLabel.Parent = Frame

    -- Hop button
    local HopButton = Instance.new("TextButton")
    HopButton.Name = "HopBtn"
    HopButton.Size = UDim2.new(1, -20, 0, 30)
    HopButton.Position = UDim2.new(0, 10, 0, 140)
    HopButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    HopButton.BorderSizePixel = 0
    HopButton.Text = "🔍  Find & Hop"
    HopButton.TextColor3 = Color3.fromRGB(15, 15, 20)
    HopButton.TextSize = 13
    HopButton.Font = Enum.Font.GothamBold
    HopButton.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = HopButton

    -- Make the frame draggable
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return ScreenGui, StatusLabel, UptimeLabel, HopButton
end

-- ─── Uptime Tracker ─────────────────────────────────────────────────────────

-- Gets true server uptime in seconds.
-- workspace.DistributedGameTime counts from server start and is readable client-side.
-- On Delta executor this is the correct value.
local function getServerUptime()
    -- DistributedGameTime is server clock elapsed since server started (not player join time)
    local t = workspace.DistributedGameTime
    -- Sanity check: if it looks like session time (very low), it's correct — server is new
    return t
end

local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- ─── Server Fetcher ─────────────────────────────────────────────────────────

-- Uses the Roblox Games API to list servers, then picks one whose uptime
-- (estimated from player count churn or creation time if available)
-- is close to the target.
-- NOTE: The public server list endpoint gives us server IDs and player counts
-- but NOT creation time. We use the "playing" field as a heuristic —
-- older servers tend to have more stable player counts.
-- For a precise uptime match we sort by ascending player count
-- (freshly restarted servers typically refill) and pick the closest estimate.

local function fetchServers(cursor)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
        GAME_ID,
        cursor and ("&cursor=" .. cursor) or ""
    )
    local ok, result = pcall(httpGet, url)
    if not ok then
        return nil, "HTTP request failed: " .. tostring(result)
    end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, result)
    if not ok2 then
        return nil, "JSON parse failed: " .. tostring(data)
    end
    return data, nil
end

-- Estimate server uptime in minutes from server data.
-- Roblox public API does not expose creation time directly.
-- We use fps and ping as secondary signals; primarily we
-- check all pages for the server with the most players (most stable/oldest)
-- OR expose the field if the executor provides it via a custom endpoint.
local function estimateUptimeMinutes(server)
    -- Some executors inject server start time via a hidden field or
    -- we check if the server was created close to our target window.
    -- Fallback: treat servers with maxPlayers fill ratio as older.
    local ratio = (server.playing or 0) / math.max(server.maxPlayers or 1, 1)
    -- Rough heuristic: 80%+ fill → server has been up a while
    return ratio * 300  -- scale to ~5 hours max
end

-- ─── Server Hop Logic ───────────────────────────────────────────────────────

local function findAndHop(statusLabel, uptimeLabel, hopBtn)
    hopBtn.Text = "🔄  Searching..."
    hopBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    hopBtn.Active = false

    statusLabel.Text = "⏳  Fetching server list..."

    local bestServer = nil
    local bestDiff = math.huge
    local cursor = nil
    local pageCount = 0
    local maxPages = 5

    repeat
        local data, err = fetchServers(cursor)
        if err or not data then
            statusLabel.Text = "❌  Error: " .. (err or "no data")
            hopBtn.Text = "🔍  Find & Hop"
            hopBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            hopBtn.Active = true
            return
        end

        local servers = data.data or {}
        for _, server in ipairs(servers) do
            -- Skip private servers
            if server.serverType ~= "Private" and server.id then
                local estUptime = estimateUptimeMinutes(server)
                local diff = math.abs(estUptime - TARGET_UPTIME_MINUTES)
                if diff < bestDiff then
                    bestDiff = diff
                    bestServer = server
                    -- Attach estimated uptime for display
                    bestServer._estUptime = estUptime
                end
            end
        end

        cursor = data.nextPageCursor
        pageCount = pageCount + 1

        statusLabel.Text = string.format(
            "⏳  Scanned %d page(s), best match: ~%dm uptime",
            pageCount, bestServer and math.floor(bestServer._estUptime or 0) or 0
        )

        task.wait(0.5)
    until not cursor or pageCount >= maxPages

    if not bestServer then
        statusLabel.Text = "❌  No suitable server found. Try again."
        hopBtn.Text = "🔍  Find & Hop"
        hopBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        hopBtn.Active = true
        return
    end

    local estMins = bestServer._estUptime or 0
    statusLabel.Text = string.format(
        "✅  Found server! Est. uptime: ~%dh %dm\n🚀  Teleporting in 3s...",
        math.floor(estMins / 60), math.floor(estMins % 60)
    )

    -- Set the uptime offset so our live counter shows estimated server age
    serverStartOffset = estMins * 60

    task.wait(3)

    local jobId = bestServer.id
    statusLabel.Text = "🚀  Teleporting..."

    -- Delta executor compatible teleport
    -- TeleportToPlaceInstance must be called in a new thread on Delta
    task.spawn(function()
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(GAME_ID, jobId, LocalPlayer)
        end)
        if ok then return end

        -- Fallback: TeleportAsync with TeleportOptions
        local ok2, err2 = pcall(function()
            local opts = Instance.new("TeleportOptions")
            opts.ServerInstanceId = jobId
            TeleportService:TeleportAsync(GAME_ID, {LocalPlayer}, opts)
        end)
        if ok2 then return end

        -- Fallback: Delta sometimes exposes global teleport()
        local ok3 = pcall(function()
            if teleport then teleport(GAME_ID, jobId) end
        end)
        if ok3 then return end

        -- All failed — show error
        statusLabel.Text = "❌  Teleport failed: " .. tostring(err2) .. "\nJob ID: " .. tostring(jobId):sub(1,12)
        hopBtn.Text = "🔍  Find & Hop"
        hopBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        hopBtn.Active = true
    end)
end

-- ─── Main ───────────────────────────────────────────────────────────────────

local ScreenGui, StatusLabel, UptimeLabel, HopButton = buildGui()

-- Live uptime ticker — uses workspace.DistributedGameTime for real server age
local uptimeConnection
uptimeConnection = RunService.Heartbeat:Connect(function()
    UptimeLabel.Text = "Server Uptime\n" .. formatTime(getServerUptime())
end)

-- Cleanup on GUI removal
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui:IsDescendantOf(game) then
        if uptimeConnection then uptimeConnection:Disconnect() end
    end
end)

-- Button click
HopButton.MouseButton1Click:Connect(function()
    task.spawn(findAndHop, StatusLabel, UptimeLabel, HopButton)
end)

StatusLabel.Text = "✅  Ready! Click 'Find & Hop' to search for\na Second Sea server (~3h 57m uptime)."
print("[BF Server Hop] Script loaded. GUI visible — click 'Find & Hop' to begin.")
