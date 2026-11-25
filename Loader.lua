--[[
	OPUS client v1.8 — loader

	One-liner (executor):

		loadstring(game:HttpGet("https://raw.githubusercontent.com/urosevicemanuel54-maker/opus-client/main/OpusClient.lua"))()

	Inside Roblox Studio there is no loadstring(), so paste OpusClient.lua
	into a LocalScript under StarterPlayer > StarterPlayerScripts instead.
	Keep the repository public, otherwise the raw URL answers 404.
--]]

local SOURCE = "https://raw.githubusercontent.com/urosevicemanuel54-maker/opus-client/main/OpusClient.lua"

local function download(url)
	if type(game.HttpGet) == "function" then
		return game:HttpGet(url)
	end
	-- Studio / plain Roblox: needs HttpService requests enabled in
	-- Game Settings > Security.
	local HttpService = game:GetService("HttpService")
	return HttpService:GetAsync(url)
end

if type(loadstring) ~= "function" then
	warn("[OpusClient] loadstring is not available here — paste OpusClient.lua into a LocalScript instead.")
	return
end

local ok, result = pcall(download, SOURCE)

if not ok or type(result) ~= "string" or #result < 100 then
	warn("[OpusClient] could not download the interface from " .. SOURCE)
	return
end

local chunk, compileError = loadstring(result, "OpusClient")

if not chunk then
	warn("[OpusClient] compile error: " .. tostring(compileError))
	return
end

local success, runtimeError = pcall(chunk)

if not success then
	warn("[OpusClient] runtime error: " .. tostring(runtimeError))
end
