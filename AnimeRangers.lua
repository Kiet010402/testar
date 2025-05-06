-- Anime Rangers X Script - MacLib Version

-- Kiểm tra Place ID
local currentPlaceId = game.PlaceId
local allowedPlaceId = 72829404259339

-- Hệ thống kiểm soát logs
local LogSystem = {
    Enabled = false, -- Mặc định tắt logs
    WarningsEnabled = false -- Mặc định tắt cả warnings
}

-- Ghi đè hàm print để kiểm soát logs
local originalPrint = print
print = function(...)
    if LogSystem.Enabled then
        originalPrint(...)
    end
end

-- Ghi đè hàm warn để kiểm soát warnings
local originalWarn = warn
warn = function(...)
    if LogSystem.WarningsEnabled then
        originalWarn(...)
    end
end

if currentPlaceId ~= allowedPlaceId then
    warn("Script này chỉ hoạt động trên game Anime Rangers X (Place ID: " .. tostring(allowedPlaceId) .. ")")
    return
end

-- Hệ thống xác thực key
local KeySystem = {}
KeySystem.Keys = {
    "HT_ANIME_RANGERS_ACCESS_5723",  -- Key 1
    "RANGER_PRO_ACCESS_9841",        -- Key 2
    "PREMIUM_ANIME_ACCESS_3619"      -- Key 3
}
KeySystem.KeyFileName = "htkey_anime_rangers.txt"
KeySystem.WebhookURL = "https://discord.com/api/webhooks/1348673902506934384/ZRMIlRzlQq9Hfnjgpu96GGF7jCG8mG1qqfya3ErW9YvbuIKOaXVomOgjg4tM_Xk57yAK" -- Thay bằng webhook của bạn

-- Hàm kiểm tra key đã lưu
KeySystem.CheckSavedKey = function()
    if not isfile then
        return false, "Executor của bạn không hỗ trợ isfile/readfile"
    end
    
    if isfile(KeySystem.KeyFileName) then
        local savedKey = readfile(KeySystem.KeyFileName)
        for _, validKey in ipairs(KeySystem.Keys) do
            if savedKey == validKey then
                return true, "Key hợp lệ"
            end
        end
        -- Nếu key không hợp lệ, xóa file
        delfile(KeySystem.KeyFileName)
    end
    
    return false, "Key không hợp lệ hoặc chưa được lưu"
end

-- Hàm lưu key
KeySystem.SaveKey = function(key)
    if not writefile then
        return false, "Executor của bạn không hỗ trợ writefile"
    end
    
    writefile(KeySystem.KeyFileName, key)
    return true, "Đã lưu key"
end

-- Hàm gửi log đến webhook Discord
KeySystem.SendWebhook = function(username, key, status)
    if KeySystem.WebhookURL == "https://discord.com/api/webhooks/1348673902506934384/ZRMIlRzlQq9Hfnjgpu96GGF7jCG8mG1qqfya3ErW9YvbuIKOaXVomOgjg4tM_Xk57yAK" then
        return -- Bỏ qua nếu webhook chưa được cấu hình
    end
    
    local HttpService = game:GetService("HttpService")
    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "Anime Rangers X Script - Key Log",
            ["description"] = "Người dùng đã sử dụng script",
            ["type"] = "rich",
            ["color"] = status and 65280 or 16711680,
            ["fields"] = {
                {
                    ["name"] = "Username",
                    ["value"] = username,
                    ["inline"] = true
                },
                {
                    ["name"] = "Key Status",
                    ["value"] = status and "Hợp lệ" or "Không hợp lệ",
                    ["inline"] = true
                },
                {
                    ["name"] = "Key Used",
                    ["value"] = key ~= "" and key or "N/A",
                    ["inline"] = true
                }
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    
    local success, _ = pcall(function()
        HttpService:PostAsync(KeySystem.WebhookURL, HttpService:JSONEncode(data))
    end)
    
    return success
end

-- Tạo UI nhập key với MacLib
KeySystem.CreateKeyUI = function()
    local success, keyValid = KeySystem.CheckSavedKey()
    if success then
        print("HT Hub | Key hợp lệ, đang tải script...")
        KeySystem.SendWebhook(game.Players.LocalPlayer.Name, "Key đã lưu", true)
        return true
    end
    
    -- Tải MacLib
    local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()
    
    -- Tạo Window
    local KeyWindow = MacLib:Window({
        Title = "HT Hub | Anime Rangers X - Key System",
        Subtitle = "Vui lòng nhập key để tiếp tục",
        Size = UDim2.fromOffset(400, 300),
        DragStyle = 1,
        ShowUserInfo = false,
        AcrylicBlur = true,
    })
    
    local TabGroup = KeyWindow:TabGroup()
    local KeyTab = TabGroup:Tab({Name = "Key", Image = "rbxassetid://10734950309"})
    local KeySection = KeyTab:Section({Side = "Left"})
    
    -- Biến để theo dõi trạng thái xác thực
    local keyAuthenticated = false
    
    -- Thêm components vào UI
    KeySection:Header({
        Name = "🔑 Key System"
    })
    
    KeySection:Paragraph({
        Header = "Hướng dẫn",
        Body = "Nhập key vào ô bên dưới để sử dụng script. Nếu bạn chưa có key, hãy nhấn nút 'Lấy key tại discord'."
    })
    
    local KeyInput = KeySection:Input({
        Name = "Key",
        Placeholder = "Nhập key vào đây...",
        AcceptedCharacters = "All",
        Callback = function(value)
            -- Xử lý khi nhấn Enter
        end
    }, "KeyInput")
    
    KeySection:Button({
        Name = "Xác nhận",
        Callback = function()
            local inputKey = KeyInput.Value
            
            if inputKey == "" then
                KeyWindow:Notify({
                    Title = "Lỗi",
                    Description = "Vui lòng nhập key",
                    Lifetime = 3
                })
                return
            end
            
            local isKeyValid = false
            for _, validKey in ipairs(KeySystem.Keys) do
                if inputKey == validKey then
                    isKeyValid = true
                    break
                end
            end
            
            if isKeyValid then
                KeyWindow:Notify({
                    Title = "Thành công",
                    Description = "Key hợp lệ! Đang tải script...",
                    Lifetime = 3
                })
                
                -- Lưu key
                KeySystem.SaveKey(inputKey)
                
                -- Gửi log
                KeySystem.SendWebhook(game.Players.LocalPlayer.Name, inputKey, true)
                
                -- Đánh dấu đã xác thực thành công
                keyAuthenticated = true
                
                -- Xóa UI sau 1 giây
                task.delay(1, function()
                    KeyWindow:Destroy()
                end)
            else
                KeyWindow:Notify({
                    Title = "Lỗi",
                    Description = "Key không hợp lệ, vui lòng thử lại",
                    Lifetime = 3
                })
                
                -- Gửi log
                KeySystem.SendWebhook(game.Players.LocalPlayer.Name, inputKey, false)
            end
        end
    })
    
    KeySection:Button({
        Name = "Lấy key tại discord",
        Callback = function()
            setclipboard("https://discord.gg/6WXu2zZC3d")
            KeyWindow:Notify({
                Title = "Thông báo",
                Description = "Đã sao chép liên kết vào clipboard",
                Lifetime = 3
            })
        end
    })
    
    -- Đợi cho đến khi xác thực thành công hoặc hết thời gian
    local startTime = tick()
    local timeout = 300 -- 5 phút timeout
    
    -- Hiển thị tab
    KeyTab:Select()
    
    repeat
        task.wait(0.1)
    until keyAuthenticated or (tick() - startTime > timeout)
    
    if keyAuthenticated then
        return true
    else
        -- Nếu hết thời gian chờ mà không xác thực, đóng UI và trả về false
        KeyWindow:Destroy()
        return false
    end
end

-- Khởi chạy hệ thống key
local keyValid = KeySystem.CreateKeyUI()
if not keyValid then
    -- Nếu key không hợp lệ, dừng script
    warn("Key không hợp lệ hoặc đã hết thời gian chờ. Script sẽ dừng.")
    return
end

-- Delay 15 giây trước khi mở script
print("HT Hub | Anime Rangers X đang khởi động, vui lòng đợi 15 giây...")
task.wait(15)
print("Đang tải script...")

-- Utility function để kiểm tra và lấy service/object một cách an toàn
local function safeGetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

-- Utility function để kiểm tra và lấy child một cách an toàn
local function safeGetChild(parent, childName, waitTime)
    if not parent then return nil end
    
    local child = parent:FindFirstChild(childName)
    
    -- Chỉ sử dụng WaitForChild nếu thực sự cần thiết
    if not child and waitTime and waitTime > 0 then
        local success, result = pcall(function()
            return parent:WaitForChild(childName, waitTime)
        end)
        if success then child = result end
    end
    
    return child
end

-- Utility function để lấy đường dẫn đầy đủ một cách an toàn
local function safeGetPath(startPoint, path, waitTime)
    if not startPoint then return nil end
    waitTime = waitTime or 0.5 -- Giảm thời gian chờ mặc định xuống 0.5 giây
    
    local current = startPoint
    for _, name in ipairs(path) do
        if not current then return nil end
        current = safeGetChild(current, name, waitTime)
    end
    
    return current
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "HTHubARConfig_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Các cài đặt mặc định
    UITheme = "Dark",
    
    -- Cài đặt log
    LogsEnabled = false,
    WarningsEnabled = false,
    
    -- Cài đặt Shop/Summon
    SummonAmount = "x1",
    SummonBanner = "Standard",
    AutoSummon = false,
    
    -- Cài đặt Quest
    AutoClaimQuest = false,
    
    -- Cài đặt Story
    SelectedMap = "OnePiece",
    SelectedChapter = "Chapter1",
    SelectedDifficulty = "Normal",
    FriendOnly = false,
    AutoJoinMap = false,
    StoryTimeDelay = 5,
    
    -- Cài đặt Ranger Stage
    SelectedRangerMap = "OnePiece",
    SelectedRangerMaps = {}, -- Thêm cấu hình mặc định cho map đã chọn (ban đầu rỗng hoặc chỉ có map default)
    SelectedActs = {RangerStage1 = true},
    RangerFriendOnly = false,
    AutoJoinRanger = false,
    RangerTimeDelay = 5,
    
    -- Cài đặt Boss Event
    AutoBossEvent = false,
    BossEventTimeDelay = 5,
    
    -- Cài đặt Challenge
    AutoChallenge = false,
    ChallengeTimeDelay = 5,
    
    -- Cài đặt In-Game
    AutoPlay = false,
    AutoRetry = false,
    AutoNext = false,
    AutoVote = false,
    RemoveAnimation = true,
    
    -- Cài đặt Update Units
    AutoUpdate = false,
    AutoUpdateRandom = false,
    Slot1Level = 0,
    Slot2Level = 0,
    Slot3Level = 0,
    Slot4Level = 0,
    Slot5Level = 0,
    Slot6Level = 0,
    
    -- Cài đặt AFK
    AutoJoinAFK = false,
    
    -- Cài đặt UI
    AutoHideUI = false,
    
    -- Cài đặt Merchant
    SelectedMerchantItems = {},
    AutoMerchantBuy = false,
    
    -- Cài đặt Auto TP Lobby
    AutoTPLobby = false,
    AutoTPLobbyDelay = 10, -- Mặc định 10 phút
    
    -- Cài đặt Auto Scan Units
    AutoScanUnits = true, -- Mặc định bật
    
    -- Cài đặt Easter Egg
    AutoJoinEasterEgg = false,
    EasterEggTimeDelay = 5,
    
    -- Cài đặt Anti AFK
    AntiAFK = true, -- Mặc định bật
    
    -- Cài đặt Auto Leave
    AutoLeave = false,
    
    -- Cài đặt Webhook
    WebhookURL = "",
    AutoSendWebhook = false,
    
    -- Cài đặt Auto Movement
    AutoMovement = false,
    
    -- Cài đặt FPS Boost
    BoostFPS = false,
    
    -- Cài đặt Auto Join All Ranger
    AutoJoinAllRanger = false,
    
    -- Cài đặt Egg Event
    AutoBuyEgg = false,
    AutoOpenEgg = false,
}
ConfigSystem.CurrentConfig = {}

-- Cache cho ConfigSystem để giảm lượng I/O
ConfigSystem.LastSaveTime = 0
ConfigSystem.SaveCooldown = 2 -- 2 giây giữa các lần lưu
ConfigSystem.PendingSave = false

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    -- Kiểm tra thời gian từ lần lưu cuối
    local currentTime = os.time()
    if currentTime - ConfigSystem.LastSaveTime < ConfigSystem.SaveCooldown then
        -- Đã lưu gần đây, đánh dấu để lưu sau
        ConfigSystem.PendingSave = true
        return
    end
    
    local success, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        writefile(ConfigSystem.FileName, HttpService:JSONEncode(ConfigSystem.CurrentConfig))
    end)
    
    if success then
        ConfigSystem.LastSaveTime = currentTime
        ConfigSystem.PendingSave = false
        -- Không cần in thông báo mỗi lần lưu để giảm spam
    else
        warn("Lưu cấu hình thất bại:", err)
    end
end

-- Hàm để tải cấu hình
ConfigSystem.LoadConfig = function()
    local success, content = pcall(function()
        if isfile(ConfigSystem.FileName) then
            return readfile(ConfigSystem.FileName)
        end
        return nil
    end)
    
    if success and content then
        local success2, data = pcall(function()
            local HttpService = game:GetService("HttpService")
            return HttpService:JSONDecode(content)
        end)
        
        if success2 and data then
            -- Merge with default config to ensure all settings exist
            for key, value in pairs(ConfigSystem.DefaultConfig) do
                if data[key] == nil then
                    data[key] = value
                end
            end
            
        ConfigSystem.CurrentConfig = data
        
        -- Cập nhật cài đặt log
        if data.LogsEnabled ~= nil then
            LogSystem.Enabled = data.LogsEnabled
        end
        
        if data.WarningsEnabled ~= nil then
            LogSystem.WarningsEnabled = data.WarningsEnabled
        end
        
        return true
        end
    end
    
    -- Nếu tải thất bại, sử dụng cấu hình mặc định
        ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
        ConfigSystem.SaveConfig()
        return false
    end

-- Thiết lập timer để lưu định kỳ nếu có thay đổi chưa lưu
spawn(function()
    while wait(5) do
        if ConfigSystem.PendingSave then
            ConfigSystem.SaveConfig()
        end
end
end)

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

-- CHUYỂN SANG SỬ DỤNG MACLIB
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

-- Tạo Window chính với MacLib
local Window = MacLib:Window({
    Title = "HT Hub | Anime Rangers X",
    Subtitle = "Phiên bản: 0.2 Beta",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.LeftControl,
    AcrylicBlur = true,
})

-- Biến toàn cục để theo dõi UI
local isMinimized = false

-- Biến lưu trạng thái Summon
local selectedSummonAmount = ConfigSystem.CurrentConfig.SummonAmount or "x1"
local selectedSummonBanner = ConfigSystem.CurrentConfig.SummonBanner or "Standard"
local autoSummonEnabled = ConfigSystem.CurrentConfig.AutoSummon or false
local autoSummonLoop = nil

-- Biến lưu trạng thái Quest
local autoClaimQuestEnabled = ConfigSystem.CurrentConfig.AutoClaimQuest or false
local autoClaimQuestLoop = nil

-- Mapping giữa tên hiển thị và tên thật của map
local mapNameMapping = {
    ["Voocha Village"] = "OnePiece",
    ["Green Planet"] = "Namek",
    ["Demon Forest"] = "DemonSlayer",
    ["Leaf Village"] = "Naruto",
    ["Z City"] = "OPM"
}

-- Mapping ngược lại để hiển thị tên cho người dùng
local reverseMapNameMapping = {}
for display, real in pairs(mapNameMapping) do
    reverseMapNameMapping[real] = display
end

-- Biến lưu trạng thái Story
local selectedMap = ConfigSystem.CurrentConfig.SelectedMap or "OnePiece"
local selectedDisplayMap = reverseMapNameMapping[selectedMap] or "Voocha Village"
local selectedChapter = ConfigSystem.CurrentConfig.SelectedChapter or "Chapter1"
local selectedDifficulty = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal"
local friendOnly = ConfigSystem.CurrentConfig.FriendOnly or false
local autoJoinMapEnabled = ConfigSystem.CurrentConfig.AutoJoinMap or false
local autoJoinMapLoop = nil

-- Biến lưu trạng thái Ranger Stage
local selectedRangerMap = ConfigSystem.CurrentConfig.SelectedRangerMap or "OnePiece"
local selectedRangerDisplayMap = reverseMapNameMapping[selectedRangerMap] or "Voocha Village"
-- Thêm biến lưu các map đã chọn
local selectedRangerMaps = ConfigSystem.CurrentConfig.SelectedRangerMaps or { [selectedRangerMap] = true } -- Lưu dạng table {MapName = true}
local selectedActs = ConfigSystem.CurrentConfig.SelectedActs or {RangerStage1 = true}
local currentActIndex = 1  -- Lưu trữ index của Act hiện tại đang được sử dụng
local orderedActs = {}     -- Lưu trữ danh sách các Acts theo thứ tự
local rangerFriendOnly = ConfigSystem.CurrentConfig.RangerFriendOnly or false
local autoJoinRangerEnabled = ConfigSystem.CurrentConfig.AutoJoinRanger or false
local autoJoinRangerLoop = nil

-- Biến lưu trạng thái Boss Event
local autoBossEventEnabled = ConfigSystem.CurrentConfig.AutoBossEvent or false
local autoBossEventLoop = nil

-- Biến lưu trạng thái Challenge
local autoChallengeEnabled = ConfigSystem.CurrentConfig.AutoChallenge or false
local autoChallengeLoop = nil
local challengeTimeDelay = ConfigSystem.CurrentConfig.ChallengeTimeDelay or 5

-- Biến lưu trạng thái In-Game
local autoPlayEnabled = ConfigSystem.CurrentConfig.AutoPlay or false
local autoRetryEnabled = ConfigSystem.CurrentConfig.AutoRetry or false
local autoNextEnabled = ConfigSystem.CurrentConfig.AutoNext or false
local autoVoteEnabled = ConfigSystem.CurrentConfig.AutoVote or false
local removeAnimationEnabled = ConfigSystem.CurrentConfig.RemoveAnimation or true
local autoRetryLoop = nil
local autoNextLoop = nil
local autoVoteLoop = nil
local removeAnimationLoop = nil

-- Biến lưu trạng thái Update Units
local autoUpdateEnabled = ConfigSystem.CurrentConfig.AutoUpdate or false
local autoUpdateRandomEnabled = ConfigSystem.CurrentConfig.AutoUpdateRandom or false
local autoUpdateLoop = nil
local autoUpdateRandomLoop = nil
local unitSlotLevels = {
    ConfigSystem.CurrentConfig.Slot1Level or 0,
    ConfigSystem.CurrentConfig.Slot2Level or 0,
    ConfigSystem.CurrentConfig.Slot3Level or 0,
    ConfigSystem.CurrentConfig.Slot4Level or 0,
    ConfigSystem.CurrentConfig.Slot5Level or 0,
    ConfigSystem.CurrentConfig.Slot6Level or 0
}
local unitSlots = {}

-- Biến lưu trạng thái Time Delay
local storyTimeDelay = ConfigSystem.CurrentConfig.StoryTimeDelay or 5
local rangerTimeDelay = ConfigSystem.CurrentConfig.RangerTimeDelay or 5
local bossEventTimeDelay = ConfigSystem.CurrentConfig.BossEventTimeDelay or 5

-- Biến lưu trạng thái AFK
local autoJoinAFKEnabled = ConfigSystem.CurrentConfig.AutoJoinAFK or false
local autoJoinAFKLoop = nil

-- Biến lưu trạng thái Auto Hide UI
local autoHideUIEnabled = ConfigSystem.CurrentConfig.AutoHideUI or false
local autoHideUITimer = nil

-- Thông tin người chơi
local playerName = game:GetService("Players").LocalPlayer.Name

-- Kiểm tra xem người chơi đã ở trong map chưa
local function isPlayerInMap()
    local player = game:GetService("Players").LocalPlayer
    if not player then return false end
    
    -- Kiểm tra UnitsFolder một cách hiệu quả
    return player:FindFirstChild("UnitsFolder") ~= nil
end

-- Tạo TabGroup
local TabGroup = Window:TabGroup()

-- Tạo tab với MacLib
local tabs = {
    Info = TabGroup:Tab({Name = "Info", Image = "rbxassetid://7733964719"}),
    Play = TabGroup:Tab({Name = "Play", Image = "rbxassetid://7743871480"}),
    Event = TabGroup:Tab({Name = "Event", Image = "rbxassetid://8997385940"}),
    InGame = TabGroup:Tab({Name = "In-Game", Image = "rbxassetid://7733799901"}),
    Shop = TabGroup:Tab({Name = "Shop", Image = "rbxassetid://7734056747"}),
    Settings = TabGroup:Tab({Name = "Settings", Image = "rbxassetid://6031280882"}),
    Webhook = TabGroup:Tab({Name = "Webhook", Image = "rbxassetid://7734058803"})
}

-- Tạo section trong các tab
local sections = {
    -- Info Tab
    InfoSection = tabs.Info:Section({Side = "Left"}),
    
    -- Play Tab
    StorySection = tabs.Play:Section({Side = "Left"}),
    RangerSection = tabs.Play:Section({Side = "Right"}),
    ChallengeSection = tabs.Play:Section({Side = "Left"}),
    BossEventSection = tabs.Play:Section({Side = "Right"}),
    
    -- Event Tab
    EasterEggSection = tabs.Event:Section({Side = "Left"}),
    
    -- In-Game Tab
    InGameSection = tabs.InGame:Section({Side = "Left"}),
    UnitsUpdateSection = tabs.InGame:Section({Side = "Right"}),
    
    -- Shop Tab
    SummonSection = tabs.Shop:Section({Side = "Left"}),
    QuestSection = tabs.Shop:Section({Side = "Right"}),
    MerchantSection = tabs.Shop:Section({Side = "Left"}),
    EggEventSection = tabs.Shop:Section({Side = "Right"}),
    
    -- Settings Tab
    SettingsSection = tabs.Settings:Section({Side = "Left"}),
    AFKSection = tabs.Settings:Section({Side = "Right"}),
    UISettingsSection = tabs.Settings:Section({Side = "Left"}),
    FPSBoostSection = tabs.Settings:Section({Side = "Right"}),
    MovementSection = tabs.Settings:Section({Side = "Left"}),
    
    -- Webhook Tab
    WebhookSection = tabs.Webhook:Section({Side = "Left"})
}

-- Thêm header và content cho InfoSection
sections.InfoSection:Header({
    Name = "Thông tin"
})

sections.InfoSection:Paragraph({
    Header = "Anime Rangers X",
    Body = "Phiên bản: 0.2 Beta\nTrạng thái: Hoạt động"
})

sections.InfoSection:Paragraph({
    Header = "Người phát triển",
    Body = "Script được phát triển bởi Dương Tuấn và ghjiukliop"
})

-- Hàm để thay đổi map
local function changeWorld(worldDisplay)
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            -- Chuyển đổi từ tên hiển thị sang tên thật
            local worldReal = mapNameMapping[worldDisplay] or "OnePiece"
            
            local args = {
                [1] = "Change-World",
                [2] = {
                    ["World"] = worldReal
                }
            }
            
            Event:FireServer(unpack(args))
            print("Đã đổi map: " .. worldDisplay .. " (thực tế: " .. worldReal .. ")")
        else
            warn("Không tìm thấy Event để đổi map")
        end
    end)
    
    if not success then
        warn("Lỗi khi đổi map: " .. tostring(err))
    end
end

-- Hàm để thay đổi chapter
local function changeChapter(map, chapter)
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            local args = {
                [1] = "Change-Chapter",
                [2] = {
                    ["Chapter"] = map .. "_" .. chapter
                }
            }
            
            Event:FireServer(unpack(args))
            print("Đã đổi chapter: " .. map .. "_" .. chapter)
        else
            warn("Không tìm thấy Event để đổi chapter")
        end
    end)
    
    if not success then
        warn("Lỗi khi đổi chapter: " .. tostring(err))
    end
end

-- Hàm để thay đổi difficulty
local function changeDifficulty(difficulty)
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            local args = {
                [1] = "Change-Difficulty",
                [2] = {
                    ["Difficulty"] = difficulty
                }
            }
            
            Event:FireServer(unpack(args))
            print("Đã đổi difficulty: " .. difficulty)
        else
            warn("Không tìm thấy Event để đổi difficulty")
        end
    end)
    
    if not success then
        warn("Lỗi khi đổi difficulty: " .. tostring(err))
    end
end

-- Hàm để toggle Friend Only
local function toggleFriendOnly()
    local success, err = pcall(function()
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if Event then
            local args = {
                [1] = "Change-FriendOnly"
            }
            
            Event:FireServer(unpack(args))
            print("Đã toggle Friend Only")
        else
            warn("Không tìm thấy Event để toggle Friend Only")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Friend Only: " .. tostring(err))
    end
end

-- Hàm để tự động tham gia map
local function joinMap()
    -- Kiểm tra xem người chơi đã ở trong map chưa
    if isPlayerInMap() then
        print("Đã phát hiện người chơi đang ở trong map, không thực hiện join map")
        return false
    end
    
    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if not Event then
            warn("Không tìm thấy Event để join map")
            return
        end
        
        -- 1. Create
        Event:FireServer("Create")
        wait(0.5)
        
        -- 2. Friend Only (nếu được bật)
        if friendOnly then
            Event:FireServer("Change-FriendOnly")
            wait(0.5)
        end
        
        -- 3. Chọn Map và Chapter
        -- 3.1 Đổi Map
        local args1 = {
            [1] = "Change-World",
            [2] = {
                ["World"] = selectedMap
            }
        }
        Event:FireServer(unpack(args1))
        wait(0.5)
        
        -- 3.2 Đổi Chapter
        local args2 = {
            [1] = "Change-Chapter",
            [2] = {
                ["Chapter"] = selectedMap .. "_" .. selectedChapter
            }
        }
        Event:FireServer(unpack(args2))
        wait(0.5)
        
        -- 3.3 Đổi Difficulty
        local args3 = {
            [1] = "Change-Difficulty",
            [2] = {
                ["Difficulty"] = selectedDifficulty
            }
        }
        Event:FireServer(unpack(args3))
        wait(0.5)
        
        -- 4. Submit
        Event:FireServer("Submit")
        wait(1)
        
        -- 5. Start
        Event:FireServer("Start")
        
        print("Đã join map: " .. selectedMap .. "_" .. selectedChapter .. " với độ khó " .. selectedDifficulty)
    end)
    
    if not success then
        warn("Lỗi khi join map: " .. tostring(err))
        return false
    end
    
    return true
end

-- Story Section
sections.StorySection:Header({
    Name = "Story"
})

-- Dropdown để chọn Map với MacLib
local mapOptions = {"Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"}
sections.StorySection:Dropdown({
    Name = "Choose Map",
    Options = mapOptions,
    Multi = false,
    Default = selectedDisplayMap,
    Callback = function(Value)
        selectedDisplayMap = Value
        selectedMap = mapNameMapping[Value] or "OnePiece"
        ConfigSystem.CurrentConfig.SelectedMap = selectedMap
        ConfigSystem.SaveConfig()
        
        -- Thay đổi map khi người dùng chọn
        changeWorld(Value)
        print("Đã chọn map: " .. Value .. " (thực tế: " .. selectedMap .. ")")
    end
}, "MapDropdown")

-- Dropdown để chọn Chapter
local chapterOptions = {"Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10"}
sections.StorySection:Dropdown({
    Name = "Choose Chapter",
    Options = chapterOptions,
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SelectedChapter or "Chapter1",
    Callback = function(Value)
        selectedChapter = Value
        ConfigSystem.CurrentConfig.SelectedChapter = Value
        ConfigSystem.SaveConfig()
        
        -- Thay đổi chapter khi người dùng chọn
        changeChapter(selectedMap, Value)
        print("Đã chọn chapter: " .. Value)
    end
}, "ChapterDropdown")

-- Dropdown để chọn Difficulty
local difficultyOptions = {"Normal", "Hard", "Nightmare"}
sections.StorySection:Dropdown({
    Name = "Choose Difficulty",
    Options = difficultyOptions,
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal",
    Callback = function(Value)
        selectedDifficulty = Value
        ConfigSystem.CurrentConfig.SelectedDifficulty = Value
        ConfigSystem.SaveConfig()
        
        -- Thay đổi difficulty khi người dùng chọn
        changeDifficulty(Value)
        print("Đã chọn difficulty: " .. Value)
    end
}, "DifficultyDropdown")

-- Toggle Friend Only
sections.StorySection:Toggle({
    Name = "Friend Only",
    Default = ConfigSystem.CurrentConfig.FriendOnly or false,
    Callback = function(Value)
        friendOnly = Value
        ConfigSystem.CurrentConfig.FriendOnly = Value
        ConfigSystem.SaveConfig()
        
        -- Toggle Friend Only khi người dùng thay đổi
        toggleFriendOnly()
        
        if Value then
            print("Đã bật chế độ Friend Only")
        else
            print("Đã tắt chế độ Friend Only")
        end
    end
}, "FriendOnlyToggle")

-- Toggle Auto Join Map
sections.StorySection:Toggle({
    Name = "Auto Join Map",
    Default = ConfigSystem.CurrentConfig.AutoJoinMap or false,
    Callback = function(Value)
        autoJoinMapEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinMap = Value
        ConfigSystem.SaveConfig()
        
        if autoJoinMapEnabled then
            -- Kiểm tra ngay lập tức nếu người chơi đang ở trong map
            if isPlayerInMap() then
                print("Đang ở trong map, Auto Join Map sẽ hoạt động khi bạn rời khỏi map")
            else
                print("Auto Join Map đã được bật, sẽ bắt đầu sau " .. storyTimeDelay .. " giây")
                
                -- Thực hiện join map sau thời gian delay
                spawn(function()
                    wait(storyTimeDelay) -- Chờ theo time delay đã đặt
                    if autoJoinMapEnabled and not isPlayerInMap() then
                        joinMap()
                    end
                end)
            end
            
            -- Tạo vòng lặp Auto Join Map
            spawn(function()
                while autoJoinMapEnabled and wait(10) do -- Thử join map mỗi 10 giây
                    -- Chỉ thực hiện join map nếu người chơi không ở trong map
                    if not isPlayerInMap() then
                        -- Áp dụng time delay
                        print("Đợi " .. storyTimeDelay .. " giây trước khi join map")
                        wait(storyTimeDelay)
                        
                        -- Kiểm tra lại sau khi delay
                        if autoJoinMapEnabled and not isPlayerInMap() then
                            joinMap()
                        end
                    else
                        -- Người chơi đang ở trong map, không cần join
                        print("Đang ở trong map, đợi đến khi người chơi rời khỏi map")
                    end
                end
            end)
        else
            print("Auto Join Map đã được tắt")
        end
    end
}, "AutoJoinMapToggle")

-- Input cho Story Time Delay
sections.StorySection:Input({
    Name = "Story Time Delay (1-30s)",
    Placeholder = "Nhập delay",
    Default = tostring(storyTimeDelay),
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 30 then
            storyTimeDelay = numValue
            ConfigSystem.CurrentConfig.StoryTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Story Time Delay: " .. numValue .. " giây")
        else
            print("Giá trị delay không hợp lệ (1-30)")
            Window:Notify({
                Title = "Lỗi",
                Description = "Giá trị delay không hợp lệ (1-30)",
                Lifetime = 3
            })
        end
    end
}, "StoryTimeDelayInput")

-- Paragraph cho trạng thái
sections.StorySection:Paragraph({
    Header = "Trạng thái",
    Body = "Nhấn nút bên dưới để cập nhật trạng thái"
})

-- Button cập nhật trạng thái
sections.StorySection:Button({
    Name = "Cập nhật trạng thái",
    Callback = function()
        local statusText = isPlayerInMap() and "Đang ở trong map" or "Đang ở sảnh chờ"
        
        -- Hiển thị thông báo với trạng thái hiện tại
        Window:Notify({
            Title = "Trạng thái hiện tại",
            Description = statusText,
            Lifetime = 3
        })
        
        print("Trạng thái: " .. statusText)
    end
})

-- Shop Tab: Summon Section
sections.SummonSection:Header({
    Name = "Summon"
})

-- Hàm thực hiện summon
local function performSummon()
    -- An toàn kiểm tra Remote có tồn tại không
    local success, err = pcall(function()
        local Remote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "Gambling", "UnitsGacha"}, 2)
        
        if Remote then
            local args = {
                [1] = selectedSummonAmount,
                [2] = selectedSummonBanner,
                [3] = {}
            }
            
            Remote:FireServer(unpack(args))
            print("Đã summon: " .. selectedSummonAmount .. " - " .. selectedSummonBanner)
        else
            warn("Không tìm thấy Remote UnitsGacha")
        end
    end)
    
    if not success then
        warn("Lỗi khi summon: " .. tostring(err))
    end
end

-- Dropdown để chọn số lượng summon
sections.SummonSection:Dropdown({
    Name = "Choose Summon Amount",
    Options = {"x1", "x10"},
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SummonAmount or "x1",
    Callback = function(Value)
        selectedSummonAmount = Value
        ConfigSystem.CurrentConfig.SummonAmount = Value
        ConfigSystem.SaveConfig()
        print("Đã chọn summon amount: " .. Value)
    end
}, "SummonAmountDropdown")

-- Dropdown để chọn banner
sections.SummonSection:Dropdown({
    Name = "Choose Banner",
    Options = {"Standard", "Rate-Up"},
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SummonBanner or "Standard",
    Callback = function(Value)
        selectedSummonBanner = Value
        ConfigSystem.CurrentConfig.SummonBanner = Value
        ConfigSystem.SaveConfig()
        print("Đã chọn banner: " .. Value)
    end
}, "SummonBannerDropdown")

-- Toggle Auto Summon
sections.SummonSection:Toggle({
    Name = "Auto Summon",
    Default = ConfigSystem.CurrentConfig.AutoSummon or false,
    Callback = function(Value)
        autoSummonEnabled = Value
        ConfigSystem.CurrentConfig.AutoSummon = Value
        ConfigSystem.SaveConfig()
        
        if autoSummonEnabled then
            print("Auto Summon đã được bật")
            
            -- Tạo vòng lặp Auto Summon
            if autoSummonLoop then
                autoSummonLoop:Disconnect()
                autoSummonLoop = nil
            end
            
            -- Sử dụng spawn thay vì coroutine
            spawn(function()
                while autoSummonEnabled and wait(2) do -- Summon mỗi 2 giây
                    performSummon()
                end
            end)
            
        else
            print("Auto Summon đã được tắt")
            
            if autoSummonLoop then
                autoSummonLoop:Disconnect()
                autoSummonLoop = nil
            end
        end
    end
}, "AutoSummonToggle")

-- Shop Tab: Quest Section
sections.QuestSection:Header({
    Name = "Quest"
})

-- Hàm để nhận tất cả nhiệm vụ
local function claimAllQuests()
    local success, err = pcall(function()
        -- Kiểm tra an toàn đường dẫn PlayerData
        local ReplicatedStorage = safeGetService("ReplicatedStorage")
        if not ReplicatedStorage then
            warn("Không tìm thấy ReplicatedStorage")
            return
        end
        
        local PlayerData = safeGetChild(ReplicatedStorage, "Player_Data", 2)
        if not PlayerData then
            warn("Không tìm thấy Player_Data")
            return
        end
        
        local PlayerFolder = safeGetChild(PlayerData, playerName, 2)
        if not PlayerFolder then
            warn("Không tìm thấy dữ liệu người chơi: " .. playerName)
            return
        end
        
        local DailyQuest = safeGetChild(PlayerFolder, "DailyQuest", 2)
        if not DailyQuest then
            warn("Không tìm thấy DailyQuest")
            return
        end
        
        -- Lấy đường dẫn đến QuestEvent
        local QuestEvent = safeGetPath(ReplicatedStorage, {"Remote", "Server", "Gameplay", "QuestEvent"}, 2)
        if not QuestEvent then
            warn("Không tìm thấy QuestEvent")
            return
        end
        
        -- Tìm tất cả nhiệm vụ có thể nhận
        for _, quest in pairs(DailyQuest:GetChildren()) do
            if quest then
                local args = {
                    [1] = "ClaimAll",
                    [2] = quest
                }
                
                QuestEvent:FireServer(unpack(args))
                wait(0.2) -- Chờ một chút giữa các lần claim để tránh lag
            end
        end
    end)
    
    if not success then
        warn("Lỗi khi claim quest: " .. tostring(err))
    end
end

-- Toggle Auto Claim All Quest
sections.QuestSection:Toggle({
    Name = "Auto Claim All Quests",
    Default = ConfigSystem.CurrentConfig.AutoClaimQuest or false,
    Callback = function(Value)
        autoClaimQuestEnabled = Value
        ConfigSystem.CurrentConfig.AutoClaimQuest = Value
        ConfigSystem.SaveConfig()
        
        if autoClaimQuestEnabled then
            print("Auto Claim Quests đã được bật")
            
            -- Tạo vòng lặp Auto Claim Quests
            spawn(function()
                while autoClaimQuestEnabled and wait(1) do -- Claim mỗi giây
                    claimAllQuests()
                end
            end)
        else
            print("Auto Claim Quests đã được tắt")
        end
    end
}, "AutoClaimQuestToggle")

-- In-Game Tab: Units Update Section
sections.UnitsUpdateSection:Header({
    Name = "Units Update"
})

for i = 1, 6 do
    sections.UnitsUpdateSection:Input({
        Name = "Slot " .. i .. " Level (0-10)",
        Placeholder = "Nhập level",
        Default = tostring(unitSlotLevels[i] or 0),
        Callback = function(Value)
            local numValue = tonumber(Value)
            if numValue and numValue >= 0 and numValue <= 10 then
                unitSlotLevels[i] = numValue
                ConfigSystem.CurrentConfig["Slot" .. i .. "Level"] = numValue
                ConfigSystem.SaveConfig()
                print("Đã đặt Slot " .. i .. " Level: " .. numValue)
            else
                print("Giá trị level không hợp lệ (0-10)")
                Window:Notify({
                    Title = "Lỗi",
                    Description = "Giá trị level không hợp lệ (0-10)",
                    Lifetime = 3
                })
            end
        end
    }, "Slot" .. i .. "LevelInput")
end

-- Toggle Auto Update Units
sections.UnitsUpdateSection:Toggle({
    Name = "Auto Update",
    Default = ConfigSystem.CurrentConfig.AutoUpdate or false,
    Callback = function(Value)
        autoUpdateEnabled = Value
        ConfigSystem.CurrentConfig.AutoUpdate = Value
        ConfigSystem.SaveConfig()
        
        if autoUpdateEnabled then
            print("Auto Update Units đã được bật")
            
            -- Tự động nâng cấp ngay lập tức nếu trong map
            if isPlayerInMap() then
                spawn(function() 
                    wait(1)
                    updateAllUnits() 
                end)
            end
            
            -- Tạo vòng lặp theo dõi để nâng cấp
            spawn(function()
                while autoUpdateEnabled and wait(2) do
                    if isPlayerInMap() then
                        updateAllUnits()
                    end
                end
            end)
        else
            print("Auto Update Units đã được tắt")
        end
    end
}, "AutoUpdateToggle")

-- Toggle Auto Update Random Unit
sections.UnitsUpdateSection:Toggle({
    Name = "Auto Update Random",
    Default = ConfigSystem.CurrentConfig.AutoUpdateRandom or false,
    Callback = function(Value)
        autoUpdateRandomEnabled = Value
        ConfigSystem.CurrentConfig.AutoUpdateRandom = Value
        ConfigSystem.SaveConfig()
        
        if autoUpdateRandomEnabled then
            print("Auto Update Random Unit đã được bật")
            
            -- Tự động nâng cấp ngay lập tức nếu trong map
            if isPlayerInMap() then
                spawn(function() 
                    wait(1)
                    updateRandomUnit() 
                end)
            end
            
            -- Tạo vòng lặp theo dõi để nâng cấp ngẫu nhiên
            spawn(function()
                while autoUpdateRandomEnabled and wait(5) do  -- Mỗi 5 giây nâng cấp một lần
                    if isPlayerInMap() then
                        updateRandomUnit()
                    end
                end
            end)
        else
            print("Auto Update Random Unit đã được tắt")
        end
    end
}, "AutoUpdateRandomToggle")

-- Nút Update All Now (thủ công)
sections.UnitsUpdateSection:Button({
    Name = "Update All Now",
    Callback = function()
        -- Kiểm tra nếu người chơi đang ở trong map
        if not isPlayerInMap() then
            Window:Notify({
                Title = "Lỗi",
                Description = "Bạn cần vào map trước khi nâng cấp đơn vị",
                Lifetime = 3
            })
            return
        end
        
        print("Đang nâng cấp tất cả đơn vị...")
        updateAllUnits()
    end
})

-- Hàm để nâng cấp đơn vị
local function updateUnit(unitObject, targetLevel)
    if not unitObject then return false end
    
    local success, err = pcall(function()
        -- Lấy Remote
        local Remote = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "Gameplay", "TowerStat"}, 2)
        
        if not Remote then
            warn("Không tìm thấy Remote để nâng cấp đơn vị")
            return
        end
        
        -- Lấy level hiện tại
        local currentLevel = 0
        if unitObject:FindFirstChild("UpgradeLevel") then
            currentLevel = unitObject.UpgradeLevel.Value
        end
        
        -- Nếu đơn vị đã đạt level mong muốn, không cần nâng cấp
        if currentLevel >= targetLevel then
            return
        end
        
        -- Nâng cấp đơn vị từng level một
        while currentLevel < targetLevel do
            -- Gửi yêu cầu nâng cấp
            local args = {
                [1] = unitObject
            }
            
            Remote:FireServer(unpack(args))
            
            -- Cập nhật lại level hiện tại
            if unitObject:FindFirstChild("UpgradeLevel") then
                currentLevel = unitObject.UpgradeLevel.Value
                print("Đã nâng cấp " .. unitObject.Name .. " lên level " .. currentLevel)
            else
                -- Nếu không thể lấy level, thoát khỏi vòng lặp
                break
            end
            
            wait(0.5) -- Đợi một chút giữa các lần nâng cấp
        end
    end)
    
    if not success then
        warn("Lỗi khi nâng cấp đơn vị: " .. tostring(err))
        return false
    end
    
    return true
end

-- Hàm để nâng cấp tất cả các đơn vị đã đặt
local function updateAllUnits()
    local success, err = pcall(function()
        -- Kiểm tra xem có đang ở trong map không
        if not isPlayerInMap() then
            return
        end
        
        -- Lấy danh sách các đơn vị đã đặt
        local unitsPlaced = {}
        
        -- Kiểm tra xem có thư mục Agent không
        local agentFolder = workspace:FindFirstChild("Agent")
        if not agentFolder then
            warn("Không tìm thấy thư mục Agent")
            return
        end
        
        -- Kiểm tra xem có thư mục Troops không
        local troopsFolder = agentFolder:FindFirstChild("Troops")
        if not troopsFolder then
            warn("Không tìm thấy thư mục Troops")
            return
        end
        
        -- Tìm thư mục của người chơi
        local playerFolder = troopsFolder:FindFirstChild(game.Players.LocalPlayer.Name)
        if not playerFolder then
            warn("Không tìm thấy thư mục của người chơi")
            return
        end
        
        -- Lấy danh sách các đơn vị đã đặt
        for _, unit in ipairs(playerFolder:GetChildren()) do
            table.insert(unitsPlaced, unit)
        end
        
        -- Nếu không có đơn vị nào được đặt, không cần nâng cấp
        if #unitsPlaced == 0 then
            warn("Không có đơn vị nào được đặt")
            return
        end
        
        -- Nâng cấp từng đơn vị
        for i, unit in ipairs(unitsPlaced) do
            -- Lấy level mục tiêu từ cài đặt
            local targetLevel = i <= #unitSlotLevels and unitSlotLevels[i] or 0
            
            -- Nếu level mục tiêu > 0, tiến hành nâng cấp
            if targetLevel > 0 then
                updateUnit(unit, targetLevel)
            end
        end
    end)
    
    if not success then
        warn("Lỗi khi nâng cấp tất cả đơn vị: " .. tostring(err))
    end
end

-- Hàm để nâng cấp ngẫu nhiên đơn vị đến level tối đa
local function updateRandomUnit()
    local success, err = pcall(function()
        -- Kiểm tra xem có đang ở trong map không
        if not isPlayerInMap() then
            return
        end
        
        -- Lấy danh sách các đơn vị đã đặt
        local unitsPlaced = {}
        
        -- Kiểm tra xem có thư mục Agent không
        local agentFolder = workspace:FindFirstChild("Agent")
        if not agentFolder then
            warn("Không tìm thấy thư mục Agent")
            return
        end
        
        -- Kiểm tra xem có thư mục Troops không
        local troopsFolder = agentFolder:FindFirstChild("Troops")
        if not troopsFolder then
            warn("Không tìm thấy thư mục Troops")
            return
        end
        
        -- Tìm thư mục của người chơi
        local playerFolder = troopsFolder:FindFirstChild(game.Players.LocalPlayer.Name)
        if not playerFolder then
            warn("Không tìm thấy thư mục của người chơi")
            return
        end
        
        -- Lấy danh sách các đơn vị đã đặt
        for _, unit in ipairs(playerFolder:GetChildren()) do
            table.insert(unitsPlaced, unit)
        end
        
        -- Nếu không có đơn vị nào được đặt, không cần nâng cấp
        if #unitsPlaced == 0 then
            warn("Không có đơn vị nào được đặt")
            return
        end
        
        -- Chọn ngẫu nhiên một đơn vị để nâng cấp
        local randomIndex = math.random(1, #unitsPlaced)
        local randomUnit = unitsPlaced[randomIndex]
        
        -- Nâng cấp đơn vị đến level tối đa (thường là 9-10)
        updateUnit(randomUnit, 10) -- Level tối đa
    end)
    
    if not success then
        warn("Lỗi khi nâng cấp ngẫu nhiên đơn vị: " .. tostring(err))
    end
end

-- Settings Section
sections.SettingsSection:Header({
    Name = "General Settings"
})

-- Toggle Log System
sections.SettingsSection:Toggle({
    Name = "Enable Logs",
    Default = ConfigSystem.CurrentConfig.LogsEnabled or false,
    Callback = function(Value)
        LogSystem.Enabled = Value
        ConfigSystem.CurrentConfig.LogsEnabled = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Logs đã được bật")
        else
            print("Logs đã được tắt")
        end
    end
}, "LogsToggle")

-- Toggle Warning System
sections.SettingsSection:Toggle({
    Name = "Enable Warnings",
    Default = ConfigSystem.CurrentConfig.WarningsEnabled or false,
    Callback = function(Value)
        LogSystem.WarningsEnabled = Value
        ConfigSystem.CurrentConfig.WarningsEnabled = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Warnings đã được bật")
        else
            print("Warnings đã được tắt")
        end
    end
}, "WarningsToggle")

-- Auto TP Lobby Section
local autoTPLobbyEnabled = ConfigSystem.CurrentConfig.AutoTPLobby or false
local autoTPLobbyDelay = ConfigSystem.CurrentConfig.AutoTPLobbyDelay or 10 -- Mặc định 10 phút
local autoTPLobbyLoop = nil

-- Hàm teleport về lobby
local function teleportToLobby()
    local success, err = pcall(function()
        local Players = game:GetService("Players")
        local TeleportService = game:GetService("TeleportService")
        
        -- Hiển thị thông báo trước khi teleport
        print("Auto TP Lobby: Đang teleport về lobby...")
        
        -- Thực hiện teleport tất cả người chơi
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
    end)
    
    if not success then
        warn("Lỗi khi teleport về lobby: " .. tostring(err))
    end
end

-- Toggle Auto TP Lobby
sections.SettingsSection:Toggle({
    Name = "Auto TP Lobby",
    Default = autoTPLobbyEnabled,
    Callback = function(Value)
        autoTPLobbyEnabled = Value
        ConfigSystem.CurrentConfig.AutoTPLobby = Value
        ConfigSystem.SaveConfig()
        
        if autoTPLobbyEnabled then
            print("Auto TP Lobby đã được bật. Sẽ tự động teleport về lobby sau " .. autoTPLobbyDelay .. " phút")
            
            -- Hủy vòng lặp cũ nếu có
            if autoTPLobbyLoop then
                autoTPLobbyLoop:Disconnect()
                autoTPLobbyLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoTPLobbyEnabled do
                    -- Đợi theo thời gian delay đã đặt (đổi từ phút sang giây)
                    local waitTime = autoTPLobbyDelay * 60
                    for i = waitTime, 1, -1 do
                        if not autoTPLobbyEnabled then break end
                        
                        -- Thông báo khi còn 1 phút
                        if i == 60 then
                            print("Auto TP Lobby: Còn 1 phút nữa sẽ teleport về lobby")
                        end
                        
                        wait(1)
                    end
                    
                    -- Kiểm tra lại xem auto TP lobby có còn được bật không
                    if autoTPLobbyEnabled then
                        teleportToLobby()
                        -- Đợi một chút sau khi teleport
                        wait(5)
                    end
                end
            end)
        else
            print("Auto TP Lobby đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoTPLobbyLoop then
                autoTPLobbyLoop:Disconnect()
                autoTPLobbyLoop = nil
            end
        end
    end
}, "AutoTPLobbyToggle")

-- Input cho Auto TP Lobby Delay
sections.SettingsSection:Input({
    Name = "TP Lobby Delay (minutes)",
    Placeholder = "Nhập số phút",
    Default = tostring(autoTPLobbyDelay),
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 then
            autoTPLobbyDelay = numValue
            ConfigSystem.CurrentConfig.AutoTPLobbyDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Auto TP Lobby Delay: " .. numValue .. " phút")
        else
            print("Giá trị delay không hợp lệ (phải >= 1)")
            Window:Notify({
                Title = "Lỗi",
                Description = "Giá trị delay không hợp lệ (phải >= 1)",
                Lifetime = 3
            })
        end
    end
}, "AutoTPLobbyDelayInput")

-- Auto Scan Units Toggle
local autoScanUnitsEnabled = ConfigSystem.CurrentConfig.AutoScanUnits or true -- Mặc định bật

sections.SettingsSection:Toggle({
    Name = "Auto Scan Units",
    Default = autoScanUnitsEnabled,
    Callback = function(Value)
        autoScanUnitsEnabled = Value
        ConfigSystem.CurrentConfig.AutoScanUnits = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            print("Auto Scan Units đã được bật")
            
            -- Thực hiện scan units ngay lập tức
            spawn(function()
                -- TODO: Thêm code scan units nếu cần
                print("Đang thực hiện scan units...")
            end)
        else
            print("Auto Scan Units đã được tắt")
        end
    end
}, "AutoScanUnitsToggle")

-- AFK Section
sections.AFKSection:Header({
    Name = "AFK Settings"
})

-- Hàm để tham gia AFK
local function joinAFK()
    -- Kiểm tra xem người chơi đã ở trong map chưa
    if isPlayerInMap() then
        print("Đã phát hiện người chơi đang ở trong map, không thực hiện join AFK")
        return false
    end
    
    local success, err = pcall(function()
        -- Lấy Event
        local Event = safeGetPath(game:GetService("ReplicatedStorage"), {"Remote", "Server", "PlayRoom", "Event"}, 2)
        
        if not Event then
            warn("Không tìm thấy Event để tham gia AFK")
            return
        end
        
        -- Gọi AFK
        local args = {
            [1] = "AFK"
        }
        
        Event:FireServer(unpack(args))
        print("Đã gửi yêu cầu tham gia AFK")
    end)
    
    if not success then
        warn("Lỗi khi tham gia AFK: " .. tostring(err))
        return false
    end
    
    return true
end

-- Anti AFK Toggle
local antiAFKEnabled = ConfigSystem.CurrentConfig.AntiAFK or true -- Mặc định bật
local antiAFKLoop = nil

sections.AFKSection:Toggle({
    Name = "Anti AFK",
    Default = antiAFKEnabled,
    Callback = function(Value)
        antiAFKEnabled = Value
        ConfigSystem.CurrentConfig.AntiAFK = Value
        ConfigSystem.SaveConfig()
        
        if antiAFKEnabled then
            print("Anti AFK đã được bật")
            
            -- Hủy vòng lặp cũ nếu có
            if antiAFKLoop then
                antiAFKLoop:Disconnect()
                antiAFKLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                -- Tạo một GC instance 
                local VirtualUser = game:GetService("VirtualUser")
                
                while antiAFKEnabled do
                    -- Mỗi 5 phút, mô phỏng click chuột để tránh AFK
                    wait(300)
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    print("Anti AFK: Đã thực hiện hành động chống AFK")
                end
            end)
        else
            print("Anti AFK đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if antiAFKLoop then
                antiAFKLoop:Disconnect()
                antiAFKLoop = nil
            end
        end
    end
}, "AntiAFKToggle")

-- Auto Join AFK Toggle
local autoJoinAFKEnabled = ConfigSystem.CurrentConfig.AutoJoinAFK or false
local autoJoinAFKLoop = nil

sections.AFKSection:Toggle({
    Name = "Auto Join AFK",
    Default = autoJoinAFKEnabled,
    Callback = function(Value)
        autoJoinAFKEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinAFK = Value
        ConfigSystem.SaveConfig()
        
        if autoJoinAFKEnabled then
            print("Auto Join AFK đã được bật")
            
            -- Hủy vòng lặp cũ nếu có
            if autoJoinAFKLoop then
                autoJoinAFKLoop:Disconnect()
                autoJoinAFKLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoJoinAFKEnabled do
                    -- Chỉ thực hiện join AFK nếu người chơi không ở trong map
                    if not isPlayerInMap() then
                        print("Auto Join AFK: Đang tham gia AFK...")
                        joinAFK()
                        wait(5) -- Đợi 5 giây giữa các lần thử
                    else
                        print("Auto Join AFK: Đang ở trong map, đợi đến khi người chơi rời khỏi map")
                        wait(10) -- Đợi 10 giây rồi kiểm tra lại
                    end
                end
            end)
        else
            print("Auto Join AFK đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoJoinAFKLoop then
                autoJoinAFKLoop:Disconnect()
                autoJoinAFKLoop = nil
            end
        end
    end
}, "AutoJoinAFKToggle")

-- Nút Join AFK Now (thủ công)
sections.AFKSection:Button({
    Name = "Join AFK Now",
    Callback = function()
        -- Kiểm tra nếu người chơi đang ở trong map
        if isPlayerInMap() then
            Window:Notify({
                Title = "Lỗi",
                Description = "Bạn đang ở trong map, không thể tham gia AFK mới",
                Lifetime = 3
            })
            return
        end
        
        print("Đang tham gia AFK...")
        joinAFK()
    end
})

-- FPS Boost Section
sections.FPSBoostSection:Header({
    Name = "Performance Boost"
})

-- Hàm để tăng FPS
local function boostFPS()
    local success, err = pcall(function()
        -- Giảm chất lượng đồ họa
        settings().Rendering.QualityLevel = 1
        
        -- Tắt các hiệu ứng không cần thiết
        local lighting = game:GetService("Lighting")
        
        -- Lưu các giá trị ban đầu để khôi phục nếu cần
        local originalSettings = {
            Brightness = lighting.Brightness,
            GlobalShadows = lighting.GlobalShadows,
            ShadowSoftness = lighting.ShadowSoftness,
            Technology = lighting.Technology,
            Ambient = lighting.Ambient,
            OutdoorAmbient = lighting.OutdoorAmbient
        }
        
        -- Áp dụng cài đặt để tăng FPS
        lighting.Brightness = 1
        lighting.GlobalShadows = false
        lighting.ShadowSoftness = 0
        lighting.Technology = Enum.Technology.Compatibility
        lighting.Ambient = Color3.fromRGB(127, 127, 127)
        lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        
        -- Xóa các hiệu ứng đặc biệt
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                v.Enabled = false
            end
        end
        
        -- Giảm chất lượng mô hình
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 0
                v.BlastRadius = 0
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("MeshPart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.TextureID = 10385902758728957
            end
        end
        
        -- Giảm chất lượng khung hình
        settings().Rendering.QualityLevel = 1
        
        -- Giảm khoảng cách render
        settings().Rendering.MaxQualityLevel = 1
        
        -- Tắt các animations không cần thiết
        for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
            if v:IsA("AnimationController") or v:IsA("AnimationController") then
                v:Destroy()
            end
        end
        
        -- Tắt các effects phức tạp
        for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
            if v:IsA("BlurEffect") or v:IsA("UIBlur") then
                v.Enabled = false
            end
        end
        
        print("Đã áp dụng FPS Boost")
    end)
    
    if not success then
        warn("Lỗi khi áp dụng FPS Boost: " .. tostring(err))
    end
end

-- Toggle FPS Boost
local boostFPSEnabled = ConfigSystem.CurrentConfig.BoostFPS or false
local boostFPSLoop = nil

sections.FPSBoostSection:Toggle({
    Name = "FPS Boost",
    Default = boostFPSEnabled,
    Callback = function(Value)
        boostFPSEnabled = Value
        ConfigSystem.CurrentConfig.BoostFPS = Value
        ConfigSystem.SaveConfig()
        
        if boostFPSEnabled then
            print("FPS Boost đã được bật")
            
            -- Áp dụng FPS Boost ngay lập tức
            boostFPS()
            
            -- Tạo vòng lặp để liên tục áp dụng FPS Boost
            spawn(function()
                while boostFPSEnabled and wait(30) do -- Làm mới mỗi 30 giây
                    boostFPS()
                end
            end)
        else
            print("FPS Boost đã được tắt")
            
            -- Khôi phục cài đặt mặc định nếu cần
            spawn(function()
                -- Khôi phục chất lượng đồ họa
                settings().Rendering.QualityLevel = 5
                
                -- Khôi phục lighting
                local lighting = game:GetService("Lighting")
                lighting.Brightness = 2
                lighting.GlobalShadows = true
                lighting.ShadowSoftness = 0.5
                lighting.Technology = Enum.Technology.Future
                
                -- Khôi phục hiệu ứng đặc biệt
                for _, v in pairs(lighting:GetChildren()) do
                    if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                        v.Enabled = true
                    end
                end
                
                print("Đã khôi phục cài đặt mặc định")
            end)
        end
    end
}, "BoostFPSToggle")

-- Nút Apply FPS Boost Now
sections.FPSBoostSection:Button({
    Name = "Apply FPS Boost Now",
    Callback = function()
        print("Đang áp dụng FPS Boost...")
        boostFPS()
        
        Window:Notify({
            Title = "FPS Boost",
            Description = "Đã áp dụng FPS Boost thành công",
            Lifetime = 3
        })
    end
})

-- Movement Section
sections.MovementSection:Header({
    Name = "Movement Controls"
})

-- Auto Movement Toggle
local autoMovementEnabled = ConfigSystem.CurrentConfig.AutoMovement or false
local autoMovementLoop = nil

-- Hàm di chuyển tự động
local function autoMove()
    local success, err = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        
        if not player.Character then
            return
        end
        
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return
        end
        
        -- Di chuyển theo hướng ngẫu nhiên
        local randomAngle = math.random() * math.pi * 2
        local direction = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
        
        -- Đặt hướng di chuyển
        humanoid:Move(direction)
        
        -- Chờ một khoảng thời gian ngắn
        wait(0.5)
        
        -- Dừng lại
        humanoid:Move(Vector3.new(0, 0, 0))
    end)
    
    if not success then
        warn("Lỗi khi thực hiện di chuyển tự động: " .. tostring(err))
    end
end

sections.MovementSection:Toggle({
    Name = "Auto Movement",
    Default = autoMovementEnabled,
    Callback = function(Value)
        autoMovementEnabled = Value
        ConfigSystem.CurrentConfig.AutoMovement = Value
        ConfigSystem.SaveConfig()
        
        if autoMovementEnabled then
            print("Auto Movement đã được bật")
            
            -- Hủy vòng lặp cũ nếu có
            if autoMovementLoop then
                autoMovementLoop:Disconnect()
                autoMovementLoop = nil
            end
            
            -- Tạo vòng lặp mới
            spawn(function()
                while autoMovementEnabled and wait(30) do -- Mỗi 30 giây di chuyển một lần
                    autoMove()
                end
            end)
        else
            print("Auto Movement đã được tắt")
            
            -- Hủy vòng lặp nếu có
            if autoMovementLoop then
                autoMovementLoop:Disconnect()
                autoMovementLoop = nil
            end
        end
    end
}, "AutoMovementToggle")

-- Webhook Section
sections.WebhookSection:Header({
    Name = "Discord Webhook"
})

-- Biến lưu trạng thái Webhook
local webhookURL = ConfigSystem.CurrentConfig.WebhookURL or ""
local autoSendWebhookEnabled = ConfigSystem.CurrentConfig.AutoSendWebhook or false
local autoSendWebhookLoop = nil

-- Hàm để gửi thông tin đến webhook
local function sendWebhook(message)
    local success, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        
        if webhookURL == "" then
            warn("Webhook URL chưa được thiết lập")
            return
        end
        
        -- Tạo dữ liệu để gửi
        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "Anime Rangers X - Status Update",
                ["description"] = message or "Status update from Anime Rangers X Script",
                ["type"] = "rich",
                ["color"] = 65280, -- Màu xanh lá
                ["fields"] = {
                    {
                        ["name"] = "Username",
                        ["value"] = game.Players.LocalPlayer.Name,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Status",
                        ["value"] = isPlayerInMap() and "In Game" or "In Lobby",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Time",
                        ["value"] = os.date("%H:%M:%S"),
                        ["inline"] = true
                    }
                },
                ["timestamp"] = DateTime.now():ToIsoDate()
            }}
        }
        
        -- Gửi dữ liệu
        local response = HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data))
        print("Đã gửi webhook thành công")
    end)
    
    if not success then
        warn("Lỗi khi gửi webhook: " .. tostring(err))
    end
end

-- Input để nhập Webhook URL
sections.WebhookSection:Input({
    Name = "Webhook URL",
    Placeholder = "Nhập Discord Webhook URL",
    Default = webhookURL,
    Callback = function(Value)
        webhookURL = Value
        ConfigSystem.CurrentConfig.WebhookURL = Value
        ConfigSystem.SaveConfig()
        
        if Value ~= "" then
            print("Đã lưu Webhook URL")
            
            -- Gửi test webhook
            sendWebhook("Test webhook connection")
        else
            print("Đã xóa Webhook URL")
        end
    end
}, "WebhookURLInput")

-- Toggle Auto Send Webhook
sections.WebhookSection:Toggle({
    Name = "Auto Send Status",
    Default = autoSendWebhookEnabled,
    Callback = function(Value)
        autoSendWebhookEnabled = Value
        ConfigSystem.CurrentConfig.AutoSendWebhook = Value
        ConfigSystem.SaveConfig()
        
        if autoSendWebhookEnabled then
            if webhookURL == "" then
                Window:Notify({
                    Title = "Lỗi",
                    Description = "Vui lòng nhập Webhook URL trước",
                    Lifetime = 3
                })
                autoSendWebhookEnabled = false
                ConfigSystem.CurrentConfig.AutoSendWebhook = false
                ConfigSystem.SaveConfig()
                return
            end
            
            print("Auto Send Status đã được bật")
            
            -- Gửi webhook ngay lập tức
            sendWebhook("Auto Status Update Started")
            
            -- Tạo vòng lặp để gửi webhook
            spawn(function()
                while autoSendWebhookEnabled and wait(300) do -- Mỗi 5 phút gửi một lần
                    sendWebhook("Periodic Status Update")
                end
            end)
        else
            print("Auto Send Status đã được tắt")
        end
    end
}, "AutoSendWebhookToggle")

-- Button để gửi webhook ngay lập tức
sections.WebhookSection:Button({
    Name = "Send Status Now",
    Callback = function()
        if webhookURL == "" then
            Window:Notify({
                Title = "Lỗi",
                Description = "Vui lòng nhập Webhook URL trước",
                Lifetime = 3
            })
            return
        end
        
        print("Đang gửi status webhook...")
        sendWebhook("Manual Status Update")
        
        Window:Notify({
            Title = "Webhook",
            Description = "Đã gửi status webhook thành công",
            Lifetime = 3
        })
    end
})

-- UI Settings Section
sections.UISettingsSection:Header({
    Name = "UI Settings"
})

-- Toggle Auto Hide UI
local autoHideUIEnabled = ConfigSystem.CurrentConfig.AutoHideUI or false
local autoHideUITimer = nil

sections.UISettingsSection:Toggle({
    Name = "Auto Hide UI",
    Default = autoHideUIEnabled,
    Callback = function(Value)
        autoHideUIEnabled = Value
        ConfigSystem.CurrentConfig.AutoHideUI = Value
        ConfigSystem.SaveConfig()
        
        if autoHideUIEnabled then
            print("Auto Hide UI đã được bật")
            
            -- Hủy timer cũ nếu có
            if autoHideUITimer then
                autoHideUITimer:Disconnect()
                autoHideUITimer = nil
            end
            
            -- Tạo timer mới
            spawn(function()
                while autoHideUIEnabled and wait(60) do -- Mỗi 60 giây kiểm tra một lần
                    -- Nếu người chơi đang ở trong map, ẩn UI
                    if isPlayerInMap() then
                        Window:Minimize()
                        print("Auto Hide UI: Đã tự động ẩn UI")
                    end
                end
            end)
        else
            print("Auto Hide UI đã được tắt")
            
            -- Hủy timer nếu có
            if autoHideUITimer then
                autoHideUITimer:Disconnect()
                autoHideUITimer = nil
            end
        end
    end
}, "AutoHideUIToggle")

-- Global Settings
local globalSettings = {
    UIBlurToggle = Window:GlobalSetting({
        Name = "UI Blur",
        Default = Window:GetAcrylicBlurState(),
        Callback = function(bool)
            Window:SetAcrylicBlurState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Enabled" or "Disabled") .. " UI Blur",
                Lifetime = 5
            })
        end,
    }),
    NotificationToggler = Window:GlobalSetting({
        Name = "Notifications",
        Default = Window:GetNotificationsState(),
        Callback = function(bool)
            Window:SetNotificationsState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Enabled" or "Disabled") .. " Notifications",
                Lifetime = 5
            })
        end,
    }),
    ShowUserInfo = Window:GlobalSetting({
        Name = "Show User Info",
        Default = Window:GetUserInfoState(),
        Callback = function(bool)
            Window:SetUserInfoState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Showing" or "Redacted") .. " User Info",
                Lifetime = 5
            })
        end,
    })
}

-- Chọn tab mặc định khi mở UI
tabs.Info:Select()

-- Hoàn tất khởi tạo
print("HT Hub | Anime Rangers X đã được khởi động thành công!")
Window:Notify({
    Title = "HT Hub | Anime Rangers X",
    Description = "Script đã được khởi động thành công!",
    Lifetime = 5
}) 
