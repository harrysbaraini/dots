-- url-router.lua
-- Routes URLs to the correct Brave Browser profile based on domain patterns.
-- Requires setting Hammerspoon as the default browser in System Settings.

local M = {}

-- Brave profile directory names (from ~/Library/Application Support/BraveSoftware/Brave-Browser/)
local profiles = {
	personal = "Default",
	valleymetro = "Profile Valley Metro",
	juiced = "Profile Juiced",
	kdg = "Profile KDG",
}

-- Routing rules: { pattern = "lua pattern matched against host+path", profile = "<key from profiles>" }
-- Patterns are matched against "host/path" (no scheme, no query/fragment).
-- A trailing "/" is appended internally so patterns like "github.com/org" match exactly
-- at a segment boundary (github.com/org, github.com/org/, github.com/org/repo)
-- but NOT github.com/orgtypo.
-- Use Lua patterns: %.=literal dot, /=path separator.
-- Patterns are matched top-to-bottom; first match wins. Fallback is personal profile.
local routes = {
	-- Personal
	{ pattern = "sirius%.test", profile = "personal" },
	{ pattern = "vans%.dev", profile = "personal" },
	{ pattern = "github%.com/vansdevcode", profile = "personal" },
	{ pattern = "github%.com/harrysbaraini", profile = "personal" },

	-- Valley Metro
	{ pattern = "valleymetro%.org", profile = "valleymetro" },
	{ pattern = "asana%.com", profile = "valleymetro" },
	{ pattern = "forge%.laravel%.com/vm%-dev", profile = "valleymetro" },
	{ pattern = "cloud%.digitalocean%.com/projects/24141bfa%-afbb%-4456%-a845%-478681a71262", profile = "valleymetro" },

	-- Juiced
	{ pattern = "github%.com/juicedhq", profile = "juiced" },
	{ pattern = "linear%.app/juiced%-hq", profile = "juiced" },

	-- KDG / Kirschbaum
	{ pattern = "kirschbaumdevelopment%.com", profile = "kdg" },
	{ pattern = "clockify%.me", profile = "kdg" },
	{ pattern = "slack%.com", profile = "kdg" },
}

-- Match a pattern ensuring it ends at a segment boundary (/, ?, #, or end-of-string).
-- Append a trailing / to the input so patterns without anchors still require a full segment match.
local function matchRoute(hostAndPath, pattern)
	local padded = hostAndPath .. "/"
	return padded:find(pattern)
end

local function profileForUrl(url)
	-- Strip scheme, keep host+path (drop query string and fragment)
	local hostAndPath = url:match("^https?://([^?#]+)") or ""
	if hostAndPath == "" then
		return profiles.personal
	end

	-- Remove trailing slash for consistent matching
	hostAndPath = hostAndPath:lower():gsub("/$", "")

	for _, route in ipairs(routes) do
		local match = matchRoute(hostAndPath, route.pattern)
		print(
			string.format("[url-router] testing '%s' against '%s' → %s", hostAndPath, route.pattern, tostring(match))
		)
		if match then
			return profiles[route.profile]
		end
	end

	return profiles.personal
end

local function openInBrave(url, profileDir)
	hs.task
		.new("/usr/bin/open", nil, {
			"-na",
			"Brave Browser",
			"--args",
			"--profile-directory=" .. profileDir,
			url,
		})
		:start()
end

hs.urlevent.httpCallback = function(scheme, host, params, fullURL, senderPID)
	local url = fullURL
	if not url or url == "" then
		url = scheme .. "://" .. (host or "")
	end

	local profileDir = profileForUrl(url)
	print(string.format("[url-router] %s → %s", url:sub(1, 60), profileDir))
	openInBrave(url, profileDir)
end

return M
