local component = require("component")
local event = require("event")
local internet = require("internet")

local chatbox = component.chat_box

function messageReceived(id, _, sender, content)
    if content == "stop" then
        chatbox.say("Stopping AI Assistant!")
        
        event.ignore("chat_message", messageReceived)
    else
        sendAIMessage(sender .. " said: " .. content)
    end
end

function extractText(str)
    local startPos = string.find(str, "text\": \"")

    if startPos then
        local endPos = string.find(str, "\"", startPos + 8)
        if endPos then
            return string.sub(str, startPos + 8, endPos - 1)
        end
    end

    return nil
end

function sendAIMessage(msg)
    local geminiHttp = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=<your gemini key>"

    local context = "You are an assistant for a minecraft base in the Gregtech New Horizons modpack in minecraft."

    local data = "{ \"contents\": [{ \"parts\": [{ \"text\": \"" .. "Context: " .. context .. "User " .. msg .. "\"}]}]}"

    local headers = {
        ["Content-Type"] = "application/json",
    }
    
    local response = internet.request(geminiHttp, data, headers)

    local result = ""
    for chunk in response do result = result..chunk end

    for str in extractText(result):gmatch("[^\\]+") do
        if str ~= "n" then
            chatbox.say(str)
        end
    end
end

chatbox.setName("Diamond Assistant")

event.listen("chat_message", messageReceived)
