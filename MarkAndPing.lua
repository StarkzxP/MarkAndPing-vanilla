local addonName = "MarkAndPing"
local addonTitle = "Mark and Ping"

local addonChatPrefix = addonName .. "Alert"
local messagePrefix = "|cFFFFDB58[" .. addonTitle .. "]|r "
local defaultVolume = "medium"
local currentVolume = defaultVolume
local soundFiles = {
    high = "Interface\\AddOns\\" .. addonName .. "\\Media\\ping_sound_high.ogg",
    medium = "Interface\\AddOns\\" .. addonName .. "\\Media\\ping_sound_medium.ogg",
    low = "Interface\\AddOns\\" .. addonName .. "\\Media\\ping_sound_low.ogg"
}
local COMM_PREFIX = "MAPv2"
local markerID = 1
local maxCharges = 5
local currentCharges = maxCharges
local rechargeTime = 10
local rechargeTimerActive = false

local nextRechargeTime = 0
local rechargeFrame = CreateFrame("Frame")
rechargeFrame:Hide()

local function printLine(message, prefix)
    if prefix then
        message = messagePrefix .. message
    end
    DEFAULT_CHAT_FRAME:AddMessage(message)
end

local function SetVolume(volume)
    if soundFiles[volume] then
        currentVolume = volume
        MarkAndPingDB.volume = volume
        printLine("Volume set to: " .. volume, true)
    else
        printLine("Invalid volume level. Use: high, medium, or low.", true)
    end
end

local function PlayPingSound()
    local soundFile = soundFiles[currentVolume]
    if soundFile then
        PlaySoundFile(soundFile)
    else
        printLine("Sound file not found for volume: " .. currentVolume, true)
    end
end

local function GetUnitLink(unit)
    return UnitName(unit) or "Unknown"
end

local function SendPingMessage(sender, unitLink)
    printLine(sender .. " marked: " .. unitLink, true)
end

local function NotifyGroup(unitLink)
    local inParty = GetNumPartyMembers() > 0
    local inRaid = GetNumRaidMembers() > 0

    if inRaid then
        SendAddonMessage(addonChatPrefix, unitLink, "RAID")
    elseif inParty then
        SendAddonMessage(addonChatPrefix, unitLink, "PARTY")
    end
end

rechargeFrame:SetScript("OnUpdate", function()
    if GetTime() >= nextRechargeTime and currentCharges < maxCharges then
        currentCharges = currentCharges + 1
        if currentCharges < maxCharges then
            nextRechargeTime = GetTime() + rechargeTime
        else
            rechargeFrame:Hide()
            rechargeTimerActive = false
        end
    end
end)

local function UseCharge()
    if currentCharges > 0 then
        currentCharges = currentCharges - 1

        if not rechargeTimerActive then
            rechargeTimerActive = true
            nextRechargeTime = GetTime() + rechargeTime
            rechargeFrame:Show()
        end
        return true
    else
        printLine("You have to wait before sending more pings.", true)
        return false
    end
end

local function GetUnitColor(unit)
    if UnitIsPlayer(unit) then
        local _, classFile = UnitClass(unit)
        if classFile and RAID_CLASS_COLORS[classFile] then
            local classColor = RAID_CLASS_COLORS[classFile]
            return string.format("|cff%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
        end
    else
        local reaction = UnitReaction(unit, "player")
        if reaction >= 5 then
            return "|cFF00FF00"
        elseif reaction == 4 then
            return "|cFFFFFF00"
        else
            return "|cFFFF0000"
        end
    end
    return "|cFFFFFFFF"
end

function MarkAndNotify(unit)
    if not (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) then
        printLine("You must be in a raid or party to use this.")
        return
    end
    if UnitExists(unit) and UseCharge() then
        local coloredName = GetUnitColor(unit) .. GetUnitLink(unit) .. "|r"
        NotifyGroup(coloredName)
    end
end

local function LoadSettings()
    if not MarkAndPingDB then
        MarkAndPingDB = {}
    end
    currentVolume = MarkAndPingDB.volume or defaultVolume
end

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function()
    LoadSettings()

    setglobal("BINDING_HEADER_MARK_AND_PING", addonTitle)
    setglobal("BINDING_NAME_MARK_AND_PING", addonTitle .. " Key")

    this:UnregisterEvent("PLAYER_LOGIN")
end)

local function FindGroupMemberTarget(senderName)
    if senderName == UnitName("player") then
        return "playertarget"
    end

    local groupMembers = GetNumRaidMembers()
    local groupPrefix = "raid"
    if groupMembers == 0 and GetNumPartyMembers() > 0 then
        groupMembers = GetNumPartyMembers()
        groupPrefix = "party"
    end

    for i = 1, groupMembers do
        local unit = groupPrefix .. i
        print("unitname " .. UnitName(unit))
        if UnitName(unit) == senderName then
            print("groupunit " .. unit .. " sender " .. senderName)
            return unit .. "target"
        end
    end
    return nil
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:SetScript("OnEvent", function()
    if arg1 == addonChatPrefix then
        if IsRaidLeader() then
            local unit = FindGroupMemberTarget(arg4)
            if unit and not GetRaidTargetIndex(unit) then
                SetRaidTarget(unit, markerID)
            end
        end
        SendPingMessage(arg4 or "Unknown", arg2)
        PlayPingSound()
    end
end)

local function SplitString(input)
    local parts = {}
    input = input or ""
    for part in string.gmatch(input, "%S+") do
        table.insert(parts, part)
    end
    return parts
end

SLASH_MPING1 = "/mping"
SlashCmdList["MPING"] = function(msg)
    local args = SplitString(msg)
    local command = args[1]
    local value = args[2]

    if command == "volume" and value then
        SetVolume(value)
    elseif command == "ping" then
        PlayPingSound()
    else
        printLine("Usage:", true)
        printLine("/mping volume [low|medium|high] - Set volume level")
        printLine("/mping ping - Test ping sound")
    end
end
