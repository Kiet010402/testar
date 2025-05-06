-- Anime Rangers X Script (MacLib UI Version)

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

-- Tải MacLib
local success, err = pcall(function()
    loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/raw/main/Maclib.lua"))()
end)

if not success then
    warn("Lỗi khi tải thư viện MacLib: " .. tostring(err))
    -- Thử tải từ URL dự phòng
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/biggaboy212/Maclib/main/Maclib.lua"))()
    end)
end

if not getgenv().Maclib then
    error("Không thể tải thư viện MacLib. Vui lòng kiểm tra kết nối internet hoặc executor.")
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
KeySystem.WebhookURL = "https://discord.com/api/webhooks/1348673902506934384/ZRMIlRzlQq9Hfnjgpu96GGF7jCG8mG1qqfya3ErW9YvbuIKOaXVomOgjg4tM_Xk57yAK"

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
    
    -- Tạo UI MacLib cho nhập key
    local keyWindow = getgenv().Maclib:CreateWindow("HT Hub | Anime Rangers X - Key System")
    local keyTab = keyWindow:CreateTab("Key System")
    local keySection = keyTab:CreateSection("Key Verification")
    
    -- Thêm thông tin
    keySection:CreateHeader("Anime Rangers X")
    keySection:CreateParagraph("Vui lòng nhập key để sử dụng script. Key có thể lấy từ Discord chính thức của HT Hub.")
    
    -- Biến để lưu key
    local inputKey = ""
    
    -- Input box để nhập key
    keySection:CreateInput({
        Text = "Nhập key",
        Callback = function(value)
            inputKey = value
        end
    })
    
    -- Nút xác nhận
    keySection:CreateButton({
        Text = "Xác nhận",
        Callback = function()
            if inputKey == "" then
                keyWindow:SendNotification("Vui lòng nhập key", "Error", 2)
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
                keyWindow:SendNotification("Key hợp lệ!", "Success", 2)
                
                -- Lưu key
                KeySystem.SaveKey(inputKey)
                
                -- Gửi log
                KeySystem.SendWebhook(game.Players.LocalPlayer.Name, inputKey, true)
                
                -- Đóng UI key sau 1 giây
                task.wait(1)
                keyWindow:Destroy()
                return true
            else
                keyWindow:SendNotification("Key không hợp lệ!", "Error", 2)
                
                -- Gửi log
                KeySystem.SendWebhook(game.Players.LocalPlayer.Name, inputKey, false)
            end
        end
    })
    
    -- Nút lấy key
    keySection:CreateButton({
        Text = "Lấy key tại Discord",
        Callback = function()
            setclipboard("https://discord.gg/6WXu2zZC3d")
            keyWindow:SendNotification("Đã sao chép liên kết Discord vào clipboard", "Info", 2)
        end
    })
    
    -- Đợi người dùng nhập key và xác nhận
    return false
end

-- Khởi chạy hệ thống key
local keyValid = KeySystem.CreateKeyUI()
if not keyValid then
    -- Nếu key không hợp lệ, dừng script
    warn("Key không hợp lệ hoặc chưa được nhập. Script sẽ dừng.")
    return
end

-- Delay trước khi mở script
print("HT Hub | Anime Rangers X đang khởi động, vui lòng đợi 15 giây...")
wait(15)
print("Đang tải script...")

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "HTHubARConfig_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Các cài đặt mặc định
    UITheme = "Purple", -- Theme mặc định cho MacLib
    
    -- Cài đặt log
    LogsEnabled = false,
    WarningsEnabled = false,
    
    -- Các cài đặt khác giống như phiên bản cũ
    -- (Thêm các cài đặt khác từ script gốc ở đây)
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

-- Khởi tạo vòng lặp lưu tự động
spawn(function()
    while wait(5) do
        if ConfigSystem.PendingSave then
            ConfigSystem.SaveConfig()
        end
    end
end)

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

-- Kiểm tra xem người chơi đã ở trong map chưa
local function isPlayerInMap()
    local player = game:GetService("Players").LocalPlayer
    if not player then return false end
    
    -- Kiểm tra UnitsFolder
    return player:FindFirstChild("UnitsFolder") ~= nil
end

-- Khởi tạo UI chính với MacLib
local window = getgenv().Maclib:CreateWindow("HT Hub | Anime Rangers X")

-- Tạo các tabs
local infoTab = window:CreateTab("Info")
local playTab = window:CreateTab("Play")
local eventTab = window:CreateTab("Event")
local inGameTab = window:CreateTab("In-Game")
local shopTab = window:CreateTab("Shop")
local settingsTab = window:CreateTab("Settings")
local webhookTab = window:CreateTab("Webhook")

-- Tạo section Info trong tab Info
local infoSection = infoTab:CreateSection("Thông tin")

-- Thêm thông tin script
infoSection:CreateHeader("Anime Rangers X")
infoSection:CreateParagraph("Phiên bản: 0.2 Beta\nTrạng thái: Hoạt động\n\nScript được phát triển bởi Dương Tuấn và ghjiukliop")

-- Thêm khoảng cách
infoSection:CreateSpacer()

-- Thêm thông tin về trạng thái hiện tại
infoSection:CreateHeader("Trạng thái")
local statusLabel = infoSection:CreateLabel("Đang tải thông tin...")

-- Nút kiểm tra trạng thái
infoSection:CreateButton({
    Text = "Cập nhật trạng thái",
    Callback = function()
        local statusText = isPlayerInMap() and "Đang ở trong map" or "Đang ở sảnh chờ"
        statusLabel:UpdateText("Trạng thái: " .. statusText)
        window:SendNotification("Trạng thái hiện tại: " .. statusText, "Info", 3)
    end
})

-- Kiểm tra trạng thái ban đầu
spawn(function()
    wait(1)
    local statusText = isPlayerInMap() and "Đang ở trong map" or "Đang ở sảnh chờ"
    statusLabel:UpdateText("Trạng thái: " .. statusText)
end)

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
local storyTimeDelay = ConfigSystem.CurrentConfig.StoryTimeDelay or 5

-- Hàm để thay đổi map
local function changeWorld(worldDisplay)
    local success, err = pcall(function()
        local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
        if Event then 
            Event = Event:FindFirstChild("Server")
            if Event then
                Event = Event:FindFirstChild("PlayRoom")
                if Event then
                    Event = Event:FindFirstChild("Event")
                end
            end
        end
        
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
        local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
        if Event then 
            Event = Event:FindFirstChild("Server")
            if Event then
                Event = Event:FindFirstChild("PlayRoom")
                if Event then
                    Event = Event:FindFirstChild("Event")
                end
            end
        end
        
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
        local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
        if Event then 
            Event = Event:FindFirstChild("Server")
            if Event then
                Event = Event:FindFirstChild("PlayRoom")
                if Event then
                    Event = Event:FindFirstChild("Event")
                end
            end
        end
        
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
        local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
        if Event then 
            Event = Event:FindFirstChild("Server")
            if Event then
                Event = Event:FindFirstChild("PlayRoom")
                if Event then
                    Event = Event:FindFirstChild("Event")
                end
            end
        end
        
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
        local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
        if Event then 
            Event = Event:FindFirstChild("Server")
            if Event then
                Event = Event:FindFirstChild("PlayRoom")
                if Event then
                    Event = Event:FindFirstChild("Event")
                end
            end
        end
        
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

-- Tạo section Story trong tab Play
local storySection = playTab:CreateSection("Story")

-- Thêm dropdown chọn Map
local mapDropdown = storySection:CreateDropdown({
    Text = "Choose Map",
    Options = {"Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"},
    Callback = function(Option)
        selectedDisplayMap = Option
        selectedMap = mapNameMapping[Option] or "OnePiece"
        ConfigSystem.CurrentConfig.SelectedMap = selectedMap
        ConfigSystem.SaveConfig()
        
        -- Thay đổi map khi người dùng chọn
        changeWorld(Option)
        print("Đã chọn map: " .. Option .. " (thực tế: " .. selectedMap .. ")")
    end
})

-- Thiết lập giá trị mặc định
mapDropdown:SetOption(selectedDisplayMap)

-- Thêm dropdown chọn Chapter
local chapterDropdown = storySection:CreateDropdown({
    Text = "Choose Chapter",
    Options = {"Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10"},
    Callback = function(Option)
        selectedChapter = Option
        ConfigSystem.CurrentConfig.SelectedChapter = Option
        ConfigSystem.SaveConfig()
        
        -- Thay đổi chapter khi người dùng chọn
        changeChapter(selectedMap, Option)
        print("Đã chọn chapter: " .. Option)
    end
})

-- Thiết lập giá trị mặc định
chapterDropdown:SetOption(selectedChapter)

-- Thêm dropdown chọn Difficulty
local difficultyDropdown = storySection:CreateDropdown({
    Text = "Choose Difficulty",
    Options = {"Normal", "Hard", "Nightmare"},
    Callback = function(Option)
        selectedDifficulty = Option
        ConfigSystem.CurrentConfig.SelectedDifficulty = Option
        ConfigSystem.SaveConfig()
        
        -- Thay đổi difficulty khi người dùng chọn
        changeDifficulty(Option)
        print("Đã chọn difficulty: " .. Option)
    end
})

-- Thiết lập giá trị mặc định
difficultyDropdown:SetOption(selectedDifficulty)

-- Thêm toggle Friend Only
local friendOnlyToggle = storySection:CreateToggle({
    Text = "Friend Only",
    CurrentValue = friendOnly,
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
})

-- Thêm input cho Story Time Delay
local storyTimeDelayInput = storySection:CreateInput({
    Text = "Story Time Delay (1-30s)",
    Default = tostring(storyTimeDelay),
    Placeholder = "Nhập delay",
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 30 then
            storyTimeDelay = numValue
            ConfigSystem.CurrentConfig.StoryTimeDelay = numValue
            ConfigSystem.SaveConfig()
            print("Đã đặt Story Time Delay: " .. numValue .. " giây")
        else
            print("Giá trị delay không hợp lệ (1-30)")
            storyTimeDelayInput:Set(tostring(storyTimeDelay))
        end
    end
})

-- Thêm toggle Auto Join Map
local autoJoinMapToggle = storySection:CreateToggle({
    Text = "Auto Join Map",
    CurrentValue = autoJoinMapEnabled,
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
})

-- Thêm nút Join Map ngay lập tức
storySection:CreateButton({
    Text = "Join Map Now",
    Callback = function()
        -- Kiểm tra nếu người chơi đã ở trong map
        if isPlayerInMap() then
            window:SendNotification("Bạn đã ở trong map!", "Error", 2)
            return
        end
        
        window:SendNotification("Đang tham gia map...", "Info", 2)
        
        local success = joinMap()
        if success then
            window:SendNotification("Đã tham gia map thành công!", "Success", 2)
        else
            window:SendNotification("Không thể tham gia map!", "Error", 2)
        end
    end
})

-- Thêm tiêu đề và status hiện tại
storySection:CreateHeader("Trạng thái")
local storyStatusLabel = storySection:CreateLabel("Trạng thái: Đang kiểm tra...")

-- Cập nhật trạng thái ban đầu
spawn(function()
    wait(1)
    local statusText = isPlayerInMap() and "Đang ở trong map" or "Đang ở sảnh chờ"
    storyStatusLabel:UpdateText("Trạng thái: " .. statusText)
end)

-- Nút cập nhật trạng thái
storySection:CreateButton({
    Text = "Cập nhật trạng thái",
    Callback = function()
        local statusText = isPlayerInMap() and "Đang ở trong map" or "Đang ở sảnh chờ"
        storyStatusLabel:UpdateText("Trạng thái: " .. statusText)
        window:SendNotification("Trạng thái hiện tại: " .. statusText, "Info", 3)
    end
})

-- Tab Settings - Cài đặt
local settingsSection = settingsTab:CreateSection("Thiết lập")

-- Biến lưu trạng thái Anti AFK
local antiAFKEnabled = ConfigSystem.CurrentConfig.AntiAFK or true -- Mặc định bật
local antiAFKConnection = nil -- Kết nối sự kiện

-- Tối ưu hệ thống Anti AFK
local function setupAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Ngắt kết nối cũ nếu có
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    
    -- Tạo kết nối mới nếu được bật
    if antiAFKEnabled and LocalPlayer then
        antiAFKConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(0.5) -- Giảm thời gian chờ xuống 0.5 giây
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end

-- Thêm cài đặt Theme (UI Color)
local themeDropdown = settingsSection:CreateDropdown({
    Text = "Chọn Theme",
    Options = {"Purple", "Blue", "Green", "Red", "Orange"},
    Callback = function(Option)
        ConfigSystem.CurrentConfig.UITheme = Option
        ConfigSystem.SaveConfig()
        
        window:SendNotification("Đã đổi theme thành " .. Option, "Info", 2)
        window:SendNotification("Khởi động lại script để áp dụng theme mới", "Warning", 3)
    end
})

-- Thiết lập theme mặc định
themeDropdown:SetOption(ConfigSystem.CurrentConfig.UITheme or "Purple")

-- Toggle hiển thị logs
local logsToggle = settingsSection:CreateToggle({
    Text = "Hiển thị Logs (Console)",
    CurrentValue = LogSystem.Enabled,
    Callback = function(Value)
        LogSystem.Enabled = Value
        ConfigSystem.CurrentConfig.LogsEnabled = Value
        ConfigSystem.SaveConfig()
        
        -- Sử dụng originalPrint thay vì print để tránh bị lọc
        if Value then
            originalPrint("Đã bật hiển thị logs")
        else
            originalPrint("Đã tắt hiển thị logs")
        end
    end
})

-- Toggle hiển thị warnings
local warningsToggle = settingsSection:CreateToggle({
    Text = "Hiển thị Cảnh báo (Warnings)",
    CurrentValue = LogSystem.WarningsEnabled,
    Callback = function(Value)
        LogSystem.WarningsEnabled = Value
        ConfigSystem.CurrentConfig.WarningsEnabled = Value
        ConfigSystem.SaveConfig()
        
        -- Sử dụng originalPrint thay vì print để tránh bị lọc
        if Value then
            originalPrint("Đã bật hiển thị cảnh báo")
        else
            originalPrint("Đã tắt hiển thị cảnh báo")
        end
    end
})

-- Thêm spacer
settingsSection:CreateSpacer()

-- Thêm section Anti-AFK
local antiAFKSection = settingsTab:CreateSection("Anti-AFK")

-- Toggle Anti AFK
local antiAFKToggle = antiAFKSection:CreateToggle({
    Text = "Anti AFK",
    CurrentValue = antiAFKEnabled,
    Callback = function(Value)
        antiAFKEnabled = Value
        ConfigSystem.CurrentConfig.AntiAFK = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            window:SendNotification("Anti AFK đã được bật", "Success", 2)
            setupAntiAFK()
        else
            window:SendNotification("Anti AFK đã được tắt", "Info", 2)
            -- Ngắt kết nối nếu có
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end
    end
})

-- Biến lưu trạng thái Auto Hide UI
local autoHideUIEnabled = ConfigSystem.CurrentConfig.AutoHideUI or false
local autoHideUITimer = nil

-- Thêm section UI Settings
local uiSettingsSection = settingsTab:CreateSection("UI Settings")

-- Toggle Auto Hide UI
local autoHideUIToggle = uiSettingsSection:CreateToggle({
    Text = "Auto Hide UI",
    CurrentValue = autoHideUIEnabled,
    Callback = function(Value)
        autoHideUIEnabled = Value
        ConfigSystem.CurrentConfig.AutoHideUI = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            window:SendNotification("Auto Hide UI đã được bật", "Info", 2)
            
            -- Tạo timer mới để tự động ẩn UI
            if autoHideUITimer then
                task.cancel(autoHideUITimer)
                autoHideUITimer = nil
            end
            
            autoHideUITimer = task.delay(1, function()
                if autoHideUIEnabled and window and window.Visible then
                    window:Toggle() -- MacLib's toggle visibility
                end
            end)
        else
            window:SendNotification("Auto Hide UI đã được tắt", "Info", 2)
            
            -- Hủy timer nếu có
            if autoHideUITimer then
                task.cancel(autoHideUITimer)
                autoHideUITimer = nil
            end
        end
    end
})

-- Thêm nút ẩn UI
local hideUIButton = uiSettingsSection:CreateButton({
    Text = "Hide UI",
    Callback = function()
        window:Toggle() -- MacLib's toggle visibility
    end
})

-- Thêm nút load lại script
local reloadButton = settingsSection:CreateButton({
    Text = "Reload Script",
    Callback = function()
        window:SendNotification("Đang tải lại script...", "Info", 2)
        
        -- Lưu cấu hình
        ConfigSystem.SaveConfig()
        
        -- Đợi một chút rồi tải lại script
        task.delay(1, function()
            -- Đóng UI hiện tại
            window:Destroy()
            
            -- Tải lại script
            loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repository/AnimeRangersNew.lua"))()
        end)
    end
})

-- Thêm nút destroy script
local destroyButton = settingsSection:CreateButton({
    Text = "Destroy Script",
    Callback = function()
        window:SendNotification("Đang hủy script...", "Info", 2)
        
        -- Lưu cấu hình
        ConfigSystem.SaveConfig()
        
        -- Ngắt kết nối Anti-AFK nếu có
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
        
        -- Đợi một chút rồi hủy script
        task.delay(1, function()
            -- Đóng UI hiện tại
            window:Destroy()
        end)
    end
})

-- Thêm thông tin về cấu hình
settingsSection:CreateParagraph("Cấu hình tự động", "Cấu hình của bạn đang được tự động lưu theo tên nhân vật: " .. game:GetService("Players").LocalPlayer.Name)

-- Khởi tạo Anti AFK nếu được bật trong cấu hình
if antiAFKEnabled then
    setupAntiAFK()
end

-- Tự động ẩn UI nếu tính năng được bật khi khởi động script
if autoHideUIEnabled then
    task.delay(1.5, function()
        if window and autoHideUIEnabled then
            window:Toggle()
        end
    end)
end

-- Tab In-Game - Chức năng trong game
local inGameSection = inGameTab:CreateSection("Game Controls")

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

-- Hàm để kiểm tra trạng thái AutoPlay thực tế trong game
local function checkActualAutoPlayState()
    local success, result = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if not player then return false end
        
        local playerData = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Data")
        if not playerData then return false end
        
        local playerFolder = playerData:FindFirstChild(player.Name)
        if not playerFolder then return false end
        
        local dataFolder = playerFolder:FindFirstChild("Data")
        if not dataFolder then return false end
        
        local autoPlayValue = dataFolder:FindFirstChild("AutoPlay")
        if not autoPlayValue then return false end
        
        return autoPlayValue.Value
    end)
    
    if not success then
        warn("Lỗi khi kiểm tra trạng thái AutoPlay: " .. tostring(result))
        return false
    end
    
    return result
end

-- Hàm để bật/tắt Auto Play
local function toggleAutoPlay()
    local success, err = pcall(function()
        local Remote = game:GetService("ReplicatedStorage")
        if Remote then Remote = Remote:FindFirstChild("Remote") end
        if Remote then Remote = Remote:FindFirstChild("Server") end
        if Remote then Remote = Remote:FindFirstChild("Units") end
        if Remote then Remote = Remote:FindFirstChild("AutoPlay") end
        
        if Remote then
            Remote:FireServer()
            print("Đã toggle Auto Play")
        else
            warn("Không tìm thấy Remote AutoPlay")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Auto Play: " .. tostring(err))
    end
end

-- Hàm để bật/tắt Auto Retry
local function toggleAutoRetry()
    local success, err = pcall(function()
        local Remote = game:GetService("ReplicatedStorage")
        if Remote then Remote = Remote:FindFirstChild("Remote") end
        if Remote then Remote = Remote:FindFirstChild("Server") end
        if Remote then Remote = Remote:FindFirstChild("OnGame") end
        if Remote then Remote = Remote:FindFirstChild("Voting") end
        if Remote then Remote = Remote:FindFirstChild("VoteRetry") end
        
        if Remote then
            Remote:FireServer()
            print("Đã toggle Auto Retry")
        else
            warn("Không tìm thấy Remote VoteRetry")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Auto Retry: " .. tostring(err))
    end
end

-- Hàm để bật/tắt Auto Next
local function toggleAutoNext()
    local success, err = pcall(function()
        local Remote = game:GetService("ReplicatedStorage")
        if Remote then Remote = Remote:FindFirstChild("Remote") end
        if Remote then Remote = Remote:FindFirstChild("Server") end
        if Remote then Remote = Remote:FindFirstChild("OnGame") end
        if Remote then Remote = Remote:FindFirstChild("Voting") end
        if Remote then Remote = Remote:FindFirstChild("VoteNext") end
        
        if Remote then
            Remote:FireServer()
            print("Đã toggle Auto Next")
        else
            warn("Không tìm thấy Remote VoteNext")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Auto Next: " .. tostring(err))
    end
end

-- Hàm để bật/tắt Auto Vote
local function toggleAutoVote()
    local success, err = pcall(function()
        local Remote = game:GetService("ReplicatedStorage")
        if Remote then Remote = Remote:FindFirstChild("Remote") end
        if Remote then Remote = Remote:FindFirstChild("Server") end
        if Remote then Remote = Remote:FindFirstChild("OnGame") end
        if Remote then Remote = Remote:FindFirstChild("Voting") end
        if Remote then Remote = Remote:FindFirstChild("VotePlaying") end
        
        if Remote then
            Remote:FireServer()
            print("Đã toggle Auto Vote")
        else
            warn("Không tìm thấy Remote VotePlaying")
        end
    end)
    
    if not success then
        warn("Lỗi khi toggle Auto Vote: " .. tostring(err))
    end
end

-- Hàm để xóa animations
local function removeAnimations()
    if not isPlayerInMap() then
        return false
    end
    
    local success, err = pcall(function()
        -- Xóa UIS.Packages.Transition.Flash từ ReplicatedStorage
        local uis = game:GetService("ReplicatedStorage"):FindFirstChild("UIS")
        if uis then
            local packages = uis:FindFirstChild("Packages")
            if packages then
                local transition = packages:FindFirstChild("Transition")
                if transition then
                    local flash = transition:FindFirstChild("Flash")
                    if flash then
                        flash:Destroy()
                        print("Đã xóa ReplicatedStorage.UIS.Packages.Transition.Flash")
                    end
                end
            end
            
            -- Xóa RewardsUI
            local rewardsUI = uis:FindFirstChild("RewardsUI")
            if rewardsUI then
                rewardsUI:Destroy()
                print("Đã xóa ReplicatedStorage.UIS.RewardsUI")
            end
        end
    end)
    
    if not success then
        warn("Lỗi khi xóa animations: " .. tostring(err))
        return false
    end
    
    return true
end

-- Toggle Auto Play
local autoPlayToggle = inGameSection:CreateToggle({
    Text = "Auto Play",
    CurrentValue = autoPlayEnabled,
    Callback = function(Value)
        -- Cập nhật cấu hình
        autoPlayEnabled = Value
        ConfigSystem.CurrentConfig.AutoPlay = Value
        ConfigSystem.SaveConfig()
        
        -- Kiểm tra trạng thái thực tế của AutoPlay
        local actualState = checkActualAutoPlayState()
        
        -- Chỉ toggle khi trạng thái mong muốn khác với trạng thái hiện tại
        if Value ~= actualState then
            toggleAutoPlay()
            
            if Value then
                window:SendNotification("Auto Play đã được bật", "Success", 2)
            else
                window:SendNotification("Auto Play đã được tắt", "Info", 2)
            end
        else
            window:SendNotification("Trạng thái Auto Play đã phù hợp", "Info", 2)
        end
    end
})

-- Toggle Auto Retry
local autoRetryToggle = inGameSection:CreateToggle({
    Text = "Auto Retry",
    CurrentValue = autoRetryEnabled,
    Callback = function(Value)
        autoRetryEnabled = Value
        ConfigSystem.CurrentConfig.AutoRetry = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            window:SendNotification("Auto Retry đã được bật", "Success", 2)
            
            -- Hủy vòng lặp cũ nếu có
            if autoRetryLoop then
                task.cancel(autoRetryLoop)
                autoRetryLoop = nil
            end
            
            -- Tạo vòng lặp mới
            autoRetryLoop = task.spawn(function()
                while autoRetryEnabled and task.wait(3) do -- Gửi yêu cầu mỗi 3 giây
                    toggleAutoRetry()
                end
            end)
        else
            window:SendNotification("Auto Retry đã được tắt", "Info", 2)
            
            -- Hủy vòng lặp nếu có
            if autoRetryLoop then
                task.cancel(autoRetryLoop)
                autoRetryLoop = nil
            end
        end
    end
})

-- Toggle Auto Next
local autoNextToggle = inGameSection:CreateToggle({
    Text = "Auto Next",
    CurrentValue = autoNextEnabled,
    Callback = function(Value)
        autoNextEnabled = Value
        ConfigSystem.CurrentConfig.AutoNext = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            window:SendNotification("Auto Next đã được bật", "Success", 2)
            
            -- Hủy vòng lặp cũ nếu có
            if autoNextLoop then
                task.cancel(autoNextLoop)
                autoNextLoop = nil
            end
            
            -- Tạo vòng lặp mới
            autoNextLoop = task.spawn(function()
                while autoNextEnabled and task.wait(3) do -- Gửi yêu cầu mỗi 3 giây
                    toggleAutoNext()
                end
            end)
        else
            window:SendNotification("Auto Next đã được tắt", "Info", 2)
            
            -- Hủy vòng lặp nếu có
            if autoNextLoop then
                task.cancel(autoNextLoop)
                autoNextLoop = nil
            end
        end
    end
})

-- Toggle Auto Vote
local autoVoteToggle = inGameSection:CreateToggle({
    Text = "Auto Vote",
    CurrentValue = autoVoteEnabled,
    Callback = function(Value)
        autoVoteEnabled = Value
        ConfigSystem.CurrentConfig.AutoVote = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            window:SendNotification("Auto Vote đã được bật", "Success", 2)
            
            -- Hủy vòng lặp cũ nếu có
            if autoVoteLoop then
                task.cancel(autoVoteLoop)
                autoVoteLoop = nil
            end
            
            -- Gửi vote ngay lập tức
            toggleAutoVote()
            
            -- Tạo vòng lặp mới
            autoVoteLoop = task.spawn(function()
                while autoVoteEnabled and task.wait(0.5) do -- Gửi yêu cầu mỗi 0.5 giây
                    toggleAutoVote()
                end
            end)
        else
            window:SendNotification("Auto Vote đã được tắt", "Info", 2)
            
            -- Hủy vòng lặp nếu có
            if autoVoteLoop then
                task.cancel(autoVoteLoop)
                autoVoteLoop = nil
            end
        end
    end
})

-- Toggle Remove Animation
local removeAnimationToggle = inGameSection:CreateToggle({
    Text = "Remove Animation",
    CurrentValue = removeAnimationEnabled,
    Callback = function(Value)
        removeAnimationEnabled = Value
        ConfigSystem.CurrentConfig.RemoveAnimation = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            window:SendNotification("Remove Animation đã được bật", "Success", 2)
            
            -- Hủy vòng lặp cũ nếu có
            if removeAnimationLoop then
                task.cancel(removeAnimationLoop)
                removeAnimationLoop = nil
            end
            
            -- Thử xóa animations ngay lập tức nếu đang trong map
            if isPlayerInMap() then
                removeAnimations()
            else
                print("Không ở trong map, sẽ xóa animations khi vào map")
            end
            
            -- Tạo vòng lặp mới để xóa animations định kỳ
            removeAnimationLoop = task.spawn(function()
                while removeAnimationEnabled and task.wait(3) do
                    if isPlayerInMap() then
                        removeAnimations()
                    end
                end
            end)
        else
            window:SendNotification("Remove Animation đã được tắt", "Info", 2)
            
            -- Hủy vòng lặp nếu có
            if removeAnimationLoop then
                task.cancel(removeAnimationLoop)
                removeAnimationLoop = nil
            end
        end
    end
})

-- Thêm section TP Lobby
local tpLobbySection = inGameTab:CreateSection("Teleport")

-- Biến lưu trạng thái Auto TP Lobby
local autoTPLobbyEnabled = ConfigSystem.CurrentConfig.AutoTPLobby or false
local autoTPLobbyDelay = ConfigSystem.CurrentConfig.AutoTPLobbyDelay or 10 -- Mặc định 10 phút
local autoTPLobbyLoop = nil

-- Hàm để teleport về lobby
local function teleportToLobby()
    local success, err = pcall(function()
        local Players = game:GetService("Players")
        local TeleportService = game:GetService("TeleportService")
        
        -- Hiển thị thông báo trước khi teleport
        print("Đang teleport về lobby...")
        
        -- Thực hiện teleport
        for _, player in pairs(Players:GetPlayers()) do
            if player == game:GetService("Players").LocalPlayer then
                TeleportService:Teleport(game.PlaceId, player)
                break -- Chỉ teleport người chơi hiện tại
            end
        end
    end)
    
    if not success then
        warn("Lỗi khi teleport về lobby: " .. tostring(err))
    end
end

-- Input cho Auto TP Lobby Delay
local tpLobbyDelayInput = tpLobbySection:CreateInput({
    Text = "Auto TP Lobby Delay (1-60 phút)",
    Default = tostring(autoTPLobbyDelay),
    Placeholder = "Nhập phút",
    Callback = function(Value)
        local numValue = tonumber(Value)
        if numValue and numValue >= 1 and numValue <= 60 then
            autoTPLobbyDelay = numValue
            ConfigSystem.CurrentConfig.AutoTPLobbyDelay = numValue
            ConfigSystem.SaveConfig()
            window:SendNotification("Đã đặt thời gian delay: " .. numValue .. " phút", "Success", 2)
        else
            window:SendNotification("Giá trị không hợp lệ (1-60 phút)", "Error", 2)
            tpLobbyDelayInput:Set(tostring(autoTPLobbyDelay))
        end
    end
})

-- Toggle Auto TP Lobby
local autoTPLobbyToggle = tpLobbySection:CreateToggle({
    Text = "Auto TP Lobby",
    CurrentValue = autoTPLobbyEnabled,
    Callback = function(Value)
        autoTPLobbyEnabled = Value
        ConfigSystem.CurrentConfig.AutoTPLobby = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            window:SendNotification("Auto TP Lobby đã được bật", "Success", 2)
            
            -- Hủy vòng lặp cũ nếu có
            if autoTPLobbyLoop then
                task.cancel(autoTPLobbyLoop)
                autoTPLobbyLoop = nil
            end
            
            -- Tạo vòng lặp mới
            autoTPLobbyLoop = task.spawn(function()
                local timeRemaining = autoTPLobbyDelay * 60 -- Chuyển đổi thành giây
                
                while autoTPLobbyEnabled and task.wait(1) do -- Đếm ngược mỗi giây
                    timeRemaining = timeRemaining - 1
                    
                    -- Hiển thị thông báo khi còn 1 phút
                    if timeRemaining == 60 then
                        window:SendNotification("Sẽ teleport về lobby trong 1 phút nữa", "Warning", 3)
                    end
                    
                    -- Khi hết thời gian, thực hiện teleport
                    if timeRemaining <= 0 then
                        if autoTPLobbyEnabled then
                            teleportToLobby()
                        end
                        
                        -- Reset thời gian đếm ngược
                        timeRemaining = autoTPLobbyDelay * 60
                    end
                end
            end)
        else
            window:SendNotification("Auto TP Lobby đã được tắt", "Info", 2)
            
            -- Hủy vòng lặp nếu có
            if autoTPLobbyLoop then
                task.cancel(autoTPLobbyLoop)
                autoTPLobbyLoop = nil
            end
        end
    end
})

-- Nút TP Lobby ngay lập tức
tpLobbySection:CreateButton({
    Text = "TP Lobby Now",
    Callback = function()
        window:SendNotification("Đang teleport về lobby...", "Info", 2)
        teleportToLobby()
    end
})

-- Tự động đồng bộ trạng thái Auto Play từ game khi khởi động
task.spawn(function()
    wait(3) -- Đợi game load
    local actualState = checkActualAutoPlayState()
    
    -- Cập nhật cấu hình nếu trạng thái thực tế khác với cấu hình
    if autoPlayEnabled ~= actualState then
        autoPlayEnabled = actualState
        ConfigSystem.CurrentConfig.AutoPlay = actualState
        ConfigSystem.SaveConfig()
        
        -- Cập nhật UI nếu có thể
        if autoPlayToggle and autoPlayToggle.Set then
            autoPlayToggle:Set(actualState)
        end
        
        print("Đã cập nhật trạng thái Auto Play từ game: " .. (actualState and "bật" or "tắt"))
    end
end)

-- Tự động xóa animations nếu tính năng được bật khi khởi động
if removeAnimationEnabled then
    task.spawn(function()
        wait(5) -- Đợi game load
        if isPlayerInMap() then
            removeAnimations()
        end
    end)
end

-- Tab Shop - Chức năng Shop
local summonSection = shopTab:CreateSection("Summon")

-- Biến lưu trạng thái Summon
local selectedSummonAmount = ConfigSystem.CurrentConfig.SummonAmount or "x1"
local selectedSummonBanner = ConfigSystem.CurrentConfig.SummonBanner or "Standard"
local autoSummonEnabled = ConfigSystem.CurrentConfig.AutoSummon or false
local autoSummonLoop = nil

-- Hàm thực hiện summon
local function performSummon()
    -- An toàn kiểm tra Remote có tồn tại không
    local success, err = pcall(function()
        local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
        if Remote then Remote = Remote:FindFirstChild("Server") end
        if Remote then Remote = Remote:FindFirstChild("Gambling") end
        if Remote then Remote = Remote:FindFirstChild("UnitsGacha") end
        
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
local summonAmountDropdown = summonSection:CreateDropdown({
    Text = "Choose Summon Amount",
    Options = {"x1", "x10"},
    Callback = function(Option)
        selectedSummonAmount = Option
        ConfigSystem.CurrentConfig.SummonAmount = Option
        ConfigSystem.SaveConfig()
        window:SendNotification("Đã chọn số lượng summon: " .. Option, "Info", 2)
    end
})

-- Thiết lập giá trị mặc định
summonAmountDropdown:SetOption(selectedSummonAmount)

-- Dropdown để chọn banner
local summonBannerDropdown = summonSection:CreateDropdown({
    Text = "Choose Banner",
    Options = {"Standard", "Rate-Up"},
    Callback = function(Option)
        selectedSummonBanner = Option
        ConfigSystem.CurrentConfig.SummonBanner = Option
        ConfigSystem.SaveConfig()
        window:SendNotification("Đã chọn banner: " .. Option, "Info", 2)
    end
})

-- Thiết lập giá trị mặc định
summonBannerDropdown:SetOption(selectedSummonBanner)

-- Nút Summon (thủ công)
summonSection:CreateButton({
    Text = "Summon Now",
    Callback = function()
        window:SendNotification("Đang summon " .. selectedSummonAmount .. " - " .. selectedSummonBanner, "Info", 2)
        performSummon()
    end
})

-- Toggle Auto Summon
local autoSummonToggle = summonSection:CreateToggle({
    Text = "Auto Summon",
    CurrentValue = autoSummonEnabled,
    Callback = function(Value)
        autoSummonEnabled = Value
        ConfigSystem.CurrentConfig.AutoSummon = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            window:SendNotification("Auto Summon đã được bật", "Success", 2)
            
            -- Hủy vòng lặp cũ nếu có
            if autoSummonLoop then
                task.cancel(autoSummonLoop)
                autoSummonLoop = nil
            end
            
            -- Tạo vòng lặp mới
            autoSummonLoop = task.spawn(function()
                while autoSummonEnabled and task.wait(2) do -- Summon mỗi 2 giây
                    performSummon()
                end
            end)
        else
            window:SendNotification("Auto Summon đã được tắt", "Info", 2)
            
            -- Hủy vòng lặp nếu có
            if autoSummonLoop then
                task.cancel(autoSummonLoop)
                autoSummonLoop = nil
            end
        end
    end
})

-- Thêm section Quest trong tab Shop
local questSection = shopTab:CreateSection("Quest")

-- Biến lưu trạng thái Quest
local autoClaimQuestEnabled = ConfigSystem.CurrentConfig.AutoClaimQuest or false
local autoClaimQuestLoop = nil

-- Hàm để nhận tất cả nhiệm vụ
local function claimAllQuests()
    local success, err = pcall(function()
        -- Kiểm tra an toàn đường dẫn PlayerData
        local playerName = game:GetService("Players").LocalPlayer.Name
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        if not ReplicatedStorage then
            warn("Không tìm thấy ReplicatedStorage")
            return
        end
        
        local PlayerData = ReplicatedStorage:FindFirstChild("Player_Data")
        if not PlayerData then
            warn("Không tìm thấy Player_Data")
            return
        end
        
        local PlayerFolder = PlayerData:FindFirstChild(playerName)
        if not PlayerFolder then
            warn("Không tìm thấy dữ liệu người chơi: " .. playerName)
            return
        end
        
        local DailyQuest = PlayerFolder:FindFirstChild("DailyQuest")
        if not DailyQuest then
            warn("Không tìm thấy DailyQuest")
            return
        end
        
        -- Lấy đường dẫn đến QuestEvent
        local QuestEvent = ReplicatedStorage:FindFirstChild("Remote")
        if QuestEvent then QuestEvent = QuestEvent:FindFirstChild("Server") end
        if QuestEvent then QuestEvent = QuestEvent:FindFirstChild("Gameplay") end
        if QuestEvent then QuestEvent = QuestEvent:FindFirstChild("QuestEvent") end
        
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
                task.wait(0.2) -- Chờ một chút giữa các lần claim để tránh lag
            end
        end
    end)
    
    if not success then
        warn("Lỗi khi claim quest: " .. tostring(err))
    end
end

-- Toggle Auto Claim All Quest
local autoClaimQuestToggle = questSection:CreateToggle({
    Text = "Auto Claim All Quests",
    CurrentValue = autoClaimQuestEnabled,
    Callback = function(Value)
        autoClaimQuestEnabled = Value
        ConfigSystem.CurrentConfig.AutoClaimQuest = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            window:SendNotification("Auto Claim Quests đã được bật", "Success", 2)
            
            -- Hủy vòng lặp cũ nếu có
            if autoClaimQuestLoop then
                task.cancel(autoClaimQuestLoop)
                autoClaimQuestLoop = nil
            end
            
            -- Tạo vòng lặp mới
            autoClaimQuestLoop = task.spawn(function()
                while autoClaimQuestEnabled and task.wait(30) do -- Claim mỗi 30 giây
                    claimAllQuests()
                end
            end)
        else
            window:SendNotification("Auto Claim Quests đã được tắt", "Info", 2)
            
            -- Hủy vòng lặp nếu có
            if autoClaimQuestLoop then
                task.cancel(autoClaimQuestLoop)
                autoClaimQuestLoop = nil
            end
        end
    end
})

-- Nút Claim All Quests (thủ công)
questSection:CreateButton({
    Text = "Claim All Quests Now",
    Callback = function()
        window:SendNotification("Đang nhận tất cả nhiệm vụ...", "Info", 2)
        claimAllQuests()
        window:SendNotification("Đã nhận nhiệm vụ!", "Success", 2)
    end
})

-- Thêm section Merchant trong tab Shop
local merchantSection = shopTab:CreateSection("Merchant")

-- Biến lưu trạng thái Merchant
local selectedMerchantItems = ConfigSystem.CurrentConfig.SelectedMerchantItems or {}
local autoMerchantBuyEnabled = ConfigSystem.CurrentConfig.AutoMerchantBuy or false
local autoMerchantBuyLoop = nil

-- Danh sách các item có thể mua từ Merchant
local merchantItems = {
    "Green Bean",
    "Onigiri",
    "Dr. Megga Punk", 
    "Cursed Finger",
    "Stats Key",
    "French Fries",
    "Trait Reroll",
    "Ranger Crystal",
    "Rubber Fruit"
}

-- Hàm để mua item từ Merchant
local function buyMerchantItem(itemName)
    local success, err = pcall(function()
        local merchantRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
        if merchantRemote then merchantRemote = merchantRemote:FindFirstChild("Server") end
        if merchantRemote then merchantRemote = merchantRemote:FindFirstChild("Gameplay") end
        if merchantRemote then merchantRemote = merchantRemote:FindFirstChild("Merchant") end
        
        if merchantRemote then
            local args = {
                [1] = itemName,
                [2] = 1
            }
            
            merchantRemote:FireServer(unpack(args))
            print("Đã mua item: " .. itemName)
        else
            warn("Không tìm thấy Remote Merchant")
        end
    end)
    
    if not success then
        warn("Lỗi khi mua item từ Merchant: " .. tostring(err))
    end
end

-- Dropdown để chọn nhiều items
local merchantItemsDropdown = merchantSection:CreateDropdown({
    Text = "Select Items",
    Options = merchantItems,
    MultiChoice = true,
    Callback = function(Options)
        -- Lưu các item đã chọn
        selectedMerchantItems = Options
        ConfigSystem.CurrentConfig.SelectedMerchantItems = Options
        ConfigSystem.SaveConfig()
        
        -- Hiển thị thông báo
        local selectedItemsText = ""
        for _, item in ipairs(Options) do
            selectedItemsText = selectedItemsText .. item .. ", "
        end
        
        if selectedItemsText ~= "" then
            selectedItemsText = selectedItemsText:sub(1, -3) -- Xóa dấu phẩy cuối cùng
            window:SendNotification("Đã chọn items: " .. selectedItemsText, "Info", 2)
        else
            window:SendNotification("Không có item nào được chọn", "Warning", 2)
        end
    end
})

-- Thiết lập giá trị mặc định
local defaultMerchantItems = {}
for item, isSelected in pairs(selectedMerchantItems) do
    if isSelected then
        table.insert(defaultMerchantItems, item)
    end
end
merchantItemsDropdown:SetOptions(defaultMerchantItems)

-- Nút Buy Selected Item (mua thủ công)
merchantSection:CreateButton({
    Text = "Buy Selected Items",
    Callback = function()
        -- Kiểm tra số lượng item đã chọn
        local selectedItemsCount = #selectedMerchantItems
        
        if selectedItemsCount == 0 then
            window:SendNotification("Không có item nào được chọn để mua", "Warning", 2)
            return
        end
        
        window:SendNotification("Đang mua " .. selectedItemsCount .. " items...", "Info", 2)
        
        -- Mua từng item đã chọn
        for _, item in ipairs(selectedMerchantItems) do
            buyMerchantItem(item)
            task.wait(0.5) -- Chờ 0.5 giây giữa các lần mua
        end
        
        window:SendNotification("Đã mua tất cả items đã chọn!", "Success", 2)
    end
})

-- Toggle Auto Buy
local autoMerchantBuyToggle = merchantSection:CreateToggle({
    Text = "Auto Buy",
    CurrentValue = autoMerchantBuyEnabled,
    Callback = function(Value)
        autoMerchantBuyEnabled = Value
        ConfigSystem.CurrentConfig.AutoMerchantBuy = Value
        ConfigSystem.SaveConfig()
        
        if Value then
            -- Kiểm tra số lượng item đã chọn
            local selectedItemsCount = #selectedMerchantItems
            
            if selectedItemsCount == 0 then
                window:SendNotification("Auto Buy đã bật nhưng không có item nào được chọn", "Warning", 3)
            else
                window:SendNotification("Auto Buy đã được bật, sẽ tự động mua items mỗi 2 giây", "Success", 2)
            end
            
            -- Hủy vòng lặp cũ nếu có
            if autoMerchantBuyLoop then
                task.cancel(autoMerchantBuyLoop)
                autoMerchantBuyLoop = nil
            end
            
            -- Tạo vòng lặp mới để tự động mua
            autoMerchantBuyLoop = task.spawn(function()
                while autoMerchantBuyEnabled and task.wait(2) do -- Mua mỗi 2 giây
                    for _, item in ipairs(selectedMerchantItems) do
                        buyMerchantItem(item)
                        task.wait(0.5) -- Chờ 0.5 giây giữa các lần mua
                    end
                end
            end)
        else
            window:SendNotification("Auto Buy đã được tắt", "Info", 2)
            
            -- Hủy vòng lặp nếu có
            if autoMerchantBuyLoop then
                task.cancel(autoMerchantBuyLoop)
                autoMerchantBuyLoop = nil
            end
        end
    end
})

-- Các tab khác sẽ được chuyển đổi trong các bản cập nhật tiếp theo...

-- Thông báo khi script đã tải xong
window:SendNotification("Script đã tải thành công!", "Success", 3)

-- Thông báo về chế độ logs
originalPrint("================================================================")
originalPrint("HT Hub | Anime Rangers X - Logs đã được tắt để tối ưu hiệu suất")
originalPrint("Để bật lại logs, vào tab Settings -> Hiển thị Logs (Console)")
originalPrint("================================================================")

print("Anime Rangers X Script (MacLib UI) has been loaded!")
