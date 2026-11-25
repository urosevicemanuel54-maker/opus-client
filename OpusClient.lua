--[[
	OPUS client v1.8 — interface recreation (LocalScript)

	Pixel rebuild of the OPUS menu from the reference screenshot:
	frameless dark window, module tree on the left, settings cards in
	the middle, live "Передпросмотр" panel on the right.

	Interface only. Every control is a mock (slider, fields, search,
	hover states, window drag, collapsible sections) — no game logic.

	Controls:
		RightShift  toggle window
		Escape      close window
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
	return
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

local previous = playerGui:FindFirstChild("OpusClient")
if previous then
	previous:Destroy()
end

---------------------------------------------------------------
-- theme
---------------------------------------------------------------

local Theme = {
	Window = Color3.fromRGB(12, 12, 15),
	Card = Color3.fromRGB(28, 28, 33),
	Field = Color3.fromRGB(9, 9, 12),
	Text = Color3.fromRGB(236, 236, 242),
	Muted = Color3.fromRGB(136, 136, 148),
	Dim = Color3.fromRGB(96, 96, 108),
	Accent = Color3.fromRGB(238, 150, 216),
	Stroke = Color3.fromRGB(88, 88, 100),
}

---------------------------------------------------------------
-- helpers
---------------------------------------------------------------

local function new(className, props, parent)
	local inst = Instance.new(className)
	for key, value in next, props do
		inst[key] = value
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function corner(inst, radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius) }, inst)
end

local function stroke(inst, color, transparency, thickness)
	return new("UIStroke", {
		Color = color or Theme.Stroke,
		Transparency = transparency or 0.65,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, inst)
end

local function label(parent, props)
	return new("TextLabel", props, parent)
end

-- Chevron drawn from two rotated bars so it renders identically on
-- every device (no dependency on a font glyph).
local function chevron(parent, x, y, size, direction, color, transparency)
	local holder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, x, 0, y),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
	}, parent)

	local len = size * 0.68
	local off = size * 0.17
	local bar = {
		BackgroundColor3 = color or Theme.Dim,
		BackgroundTransparency = transparency or 0.2,
		BorderSizePixel = 0,
	}

	local first, second = new("Frame", bar, holder), new("Frame", bar, holder)
	first.Name = "A"
	second.Name = "B"

	if direction == "left" then
		first.AnchorPoint = Vector2.new(0.5, 0.5)
		first.Position = UDim2.new(0.5, 0, 0.5, -off)
		first.Size = UDim2.new(0, 1.5, 0, len)
		first.Rotation = 45

		second.AnchorPoint = Vector2.new(0.5, 0.5)
		second.Position = UDim2.new(0.5, 0, 0.5, off)
		second.Size = UDim2.new(0, 1.5, 0, len)
		second.Rotation = -45
	else
		local sign = (direction == "up") and -1 or 1

		first.AnchorPoint = Vector2.new(0.5, 0.5)
		first.Position = UDim2.new(0.5, -off, 0.5, 0)
		first.Size = UDim2.new(0, len, 0, 1.5)
		first.Rotation = 45 * sign

		second.AnchorPoint = Vector2.new(0.5, 0.5)
		second.Position = UDim2.new(0.5, off, 0.5, 0)
		second.Size = UDim2.new(0, len, 0, 1.5)
		second.Rotation = -45 * sign
	end

	return holder
end

local function formatValue(value)
	local text = string.format("%.2f", value)
	text = string.gsub(text, "0+$", "")
	text = string.gsub(text, "%.$", "")
	if text == "" or text == "-0" then
		text = "0"
	end
	return text
end

---------------------------------------------------------------
-- root
---------------------------------------------------------------

local gui = new("ScreenGui", {
	Name = "OpusClient",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 500,
}, playerGui)

new("Frame", {
	Name = "Shade",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
}, gui)

local BASE_WIDTH, BASE_HEIGHT = 1180, 580

local window = new("Frame", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT),
	BackgroundColor3 = Theme.Window,
	BackgroundTransparency = 0.32,
	BorderSizePixel = 0,
}, gui)
corner(window, 14)
stroke(window, Theme.Stroke, 0.55, 1)

local uiScale = new("UIScale", { Scale = 1 }, window)

local function refreshScale()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local factor = math.min((viewport.X - 60) / BASE_WIDTH, (viewport.Y - 60) / BASE_HEIGHT)
	uiScale.Scale = math.clamp(factor, 0.4, 1.1)
end
refreshScale()

do
	local camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshScale)
	end
end

---------------------------------------------------------------
-- top bar
---------------------------------------------------------------

local topBar = new("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 70),
	BackgroundTransparency = 1,
}, window)

-- logo: hollow diamond on a dark disc
local logo = new("Frame", {
	Name = "Logo",
	Position = UDim2.fromOffset(20, 19),
	Size = UDim2.fromOffset(32, 32),
	BackgroundColor3 = Color3.fromRGB(26, 26, 31),
	BorderSizePixel = 0,
}, topBar)
corner(logo, 16)
stroke(logo, Color3.fromRGB(96, 96, 110), 0.55, 1)

local logoDiamond = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(13, 13),
	BackgroundColor3 = Theme.Text,
	BorderSizePixel = 0,
	Rotation = 45,
}, logo)
corner(logoDiamond, 3)

local logoCore = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(6, 6),
	BackgroundColor3 = Color3.fromRGB(26, 26, 31),
	BorderSizePixel = 0,
	Rotation = 45,
}, logoDiamond)
corner(logoCore, 1)

label(topBar, {
	Position = UDim2.fromOffset(58, 0),
	Size = UDim2.new(0, 90, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "OPUS",
	TextSize = 18,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
})

label(topBar, {
	Position = UDim2.fromOffset(126, 1),
	Size = UDim2.new(0, 140, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "client v1.8",
	TextSize = 13,
	TextColor3 = Theme.Muted,
	TextXAlignment = Enum.TextXAlignment.Left,
})

-- search field
local searchBar = new("Frame", {
	Name = "Search",
	Position = UDim2.fromOffset(276, 16),
	Size = UDim2.fromOffset(334, 38),
	BackgroundColor3 = Color3.fromRGB(9, 9, 12),
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
}, topBar)
corner(searchBar, 19)
stroke(searchBar, Color3.fromRGB(78, 78, 90), 0.55, 1)

local searchIcon = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 15, 0.5, 0),
	Size = UDim2.fromOffset(13, 13),
	BackgroundTransparency = 1,
}, searchBar)

local searchRing = new("Frame", {
	Size = UDim2.fromOffset(9, 9),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, searchIcon)
corner(searchRing, 5)
stroke(searchRing, Color3.fromRGB(150, 150, 162), 0.35, 1.4)

new("Frame", {
	Position = UDim2.fromOffset(8, 8),
	Size = UDim2.fromOffset(1.5, 5),
	BackgroundColor3 = Color3.fromRGB(150, 150, 162),
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	Rotation = -45,
}, searchIcon)

local searchBox = new("TextBox", {
	Name = "SearchBox",
	Position = UDim2.fromOffset(40, 0),
	Size = UDim2.new(1, -54, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "",
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	PlaceholderText = "Поиск...",
	PlaceholderColor3 = Color3.fromRGB(104, 104, 116),
	ClearTextOnFocus = false,
}, searchBar)

-- right side captions
label(topBar, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -24, 0, 16),
	Size = UDim2.fromOffset(260, 20),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "Передпросмотр",
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Right,
})

label(topBar, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -24, 0, 38),
	Size = UDim2.fromOffset(260, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Интеграция",
	TextSize = 12,
	TextColor3 = Theme.Dim,
	TextXAlignment = Enum.TextXAlignment.Right,
})

new("Frame", {
	Name = "TopDivider",
	Position = UDim2.fromOffset(0, 70),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
}, window)

local body = new("Frame", {
	Name = "Body",
	Position = UDim2.fromOffset(0, 71),
	Size = UDim2.new(1, 0, 1, -71),
	BackgroundTransparency = 1,
}, window)


---------------------------------------------------------------
-- sidebar
---------------------------------------------------------------

local sidebar = new("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 206, 1, 0),
	BackgroundTransparency = 1,
}, body)

new("Frame", {
	Name = "TreeGuide",
	Position = UDim2.fromOffset(33, 44),
	Size = UDim2.new(0, 1, 0, 440),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.88,
	BorderSizePixel = 0,
}, sidebar)

local function drawGlyph(parent, kind, x, color, transparency)
	local holder = new("Frame", {
		Name = "Glyph",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, x, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 1,
	}, parent)

	if kind == "dot" then
		local dot = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(4, 4),
			BackgroundColor3 = color,
			BackgroundTransparency = transparency or 0.25,
			BorderSizePixel = 0,
		}, holder)
		corner(dot, 2)
	elseif kind == "ring" then
		local ring = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, holder)
		corner(ring, 5)
		stroke(ring, color, transparency or 0.2, 1.4)
	elseif kind == "pause" then
		for index = 0, 1 do
			local bar = new("Frame", {
				Position = UDim2.fromOffset(3 + index * 4, 2),
				Size = UDim2.fromOffset(2, 8),
				BackgroundColor3 = color,
				BackgroundTransparency = transparency or 0.25,
				BorderSizePixel = 0,
			}, holder)
			corner(bar, 1)
		end
	end

	return holder
end

local filterable = {}
local activeEntry

local function activate(entry)
	if activeEntry and activeEntry.row ~= entry.row then
		activeEntry.row:SetAttribute("Active", false)
		activeEntry.highlight.BackgroundTransparency = 1
		activeEntry.text.TextColor3 = activeEntry.base
	end
	entry.row:SetAttribute("Active", true)
	entry.highlight.BackgroundTransparency = 0.86
	entry.text.TextColor3 = Theme.Text
	activeEntry = entry
end

local function navRow(parent, config)
	local row = new("TextButton", {
		Name = config.name or "Row",
		Size = UDim2.new(1, 0, 0, config.height),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = config.order or 1,
	}, parent)

	local pillX = config.highlightX or 6
	local highlight = new("Frame", {
		Name = "Pill",
		Position = UDim2.fromOffset(pillX, 2),
		Size = UDim2.new(1, -pillX - 8, 1, -4),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, row)
	corner(highlight, 7)

	if config.glyph then
		drawGlyph(row, config.glyph, config.glyphX or 46, config.textColor or Theme.Muted, 0.25)
	end

	local textLabel = label(row, {
		Name = "Caption",
		Position = UDim2.fromOffset(config.textX or 75, 0),
		Size = UDim2.new(1, -(config.textX or 75), 1, 0),
		BackgroundTransparency = 1,
		Font = config.font or Enum.Font.Gotham,
		Text = config.text,
		TextSize = config.textSize or 14,
		TextColor3 = config.textColor or Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local entry = {
		row = row,
		highlight = highlight,
		text = textLabel,
		base = config.textColor or Theme.Muted,
	}

	row.MouseEnter:Connect(function()
		if not row:GetAttribute("Active") then
			highlight.BackgroundTransparency = 0.9
			textLabel.TextColor3 = Theme.Text
		end
	end)

	row.MouseLeave:Connect(function()
		if not row:GetAttribute("Active") then
			highlight.BackgroundTransparency = 1
			textLabel.TextColor3 = entry.base
		end
	end)

	table.insert(filterable, entry)

	return entry
end

-- "Modules" header -------------------------------------------------

local modulesHeader = new("TextButton", {
	Name = "ModulesHeader",
	Position = UDim2.fromOffset(0, 6),
	Size = UDim2.new(0, 206, 0, 32),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
}, sidebar)

local modulesDiamond = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0, 21, 0.5, 0),
	Size = UDim2.fromOffset(8, 8),
	BackgroundColor3 = Theme.Text,
	BorderSizePixel = 0,
	Rotation = 45,
}, modulesHeader)
corner(modulesDiamond, 1)

label(modulesHeader, {
	Name = "Title",
	Position = UDim2.fromOffset(42, 0),
	Size = UDim2.new(1, -60, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Modules",
	TextSize = 15,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
})

local modulesArrow = chevron(modulesHeader, 180, 16, 12, "down", Theme.Dim, 0.15)

-- module tree ------------------------------------------------------

local moduleList = new("Frame", {
	Name = "ModuleList",
	Position = UDim2.fromOffset(0, 44),
	Size = UDim2.new(1, 0, 0, 150),
	BackgroundTransparency = 1,
}, sidebar)
new("UIListLayout", {
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, moduleList)

local moduleData = {
	{ name = "ESP", glyph = "ring" },
	{ name = "Visuals", glyph = "dot" },
	{ name = "Разное", glyph = "pause" },
	{ name = "Образы", glyph = "ring" },
	{ name = "Музыка", glyph = "dot" },
}

local moduleEntries = {}
for index, item in ipairs(moduleData) do
	moduleEntries[index] = navRow(moduleList, {
		name = item.name,
		order = index,
		height = 30,
		text = item.name,
		glyph = item.glyph,
		glyphX = 46,
		textX = 75,
		highlightX = 24,
	})
end

-- settings section -------------------------------------------------

local settingsButton = new("TextButton", {
	Name = "SettingsButton",
	Position = UDim2.fromOffset(2, 288),
	Size = UDim2.fromOffset(202, 36),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
}, sidebar)
corner(settingsButton, 8)

label(settingsButton, {
	Name = "Plus",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0, 21, 0.5, 0),
	Size = UDim2.fromOffset(16, 16),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "+",
	TextSize = 17,
	TextColor3 = Theme.Text,
})

label(settingsButton, {
	Name = "Title",
	Position = UDim2.fromOffset(42, 0),
	Size = UDim2.new(1, -60, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "Настройки",
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
})

local settingsArrow = chevron(settingsButton, 180, 18, 12, "down", Theme.Text, 0.35)

local subList = new("Frame", {
	Name = "SubList",
	Position = UDim2.fromOffset(0, 332),
	Size = UDim2.new(1, 0, 0, 172),
	BackgroundTransparency = 1,
}, sidebar)
new("UIListLayout", {
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, subList)

local subData = { "Config", "Games", "Настройки", "Дополнения", "Themes", "opus_client.rbx" }

local subEntries = {}
for index, name in ipairs(subData) do
	local isFile = name == "opus_client.rbx"
	subEntries[index] = navRow(subList, {
		name = name,
		order = index,
		height = 28,
		text = name,
		textX = 78,
		highlightX = 56,
		font = Enum.Font.Gotham,
		textSize = isFile and 12 or 13,
		textColor = isFile and Theme.Dim or Theme.Muted,
	})
end

activate(subEntries[3])


---------------------------------------------------------------
-- content panel
---------------------------------------------------------------

local content = new("Frame", {
	Name = "Content",
	Position = UDim2.fromOffset(224, 0),
	Size = UDim2.new(0, 595, 1, 0),
	BackgroundTransparency = 1,
}, body)

local backButton = new("TextButton", {
	Name = "Back",
	Position = UDim2.fromOffset(0, 8),
	Size = UDim2.fromOffset(28, 28),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.92,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
}, content)
corner(backButton, 8)
chevron(backButton, 14, 14, 11, "left", Theme.Text, 0.25)

local crumb = label(content, {
	Name = "Breadcrumb",
	Position = UDim2.fromOffset(38, 8),
	Size = UDim2.new(1, -38, 0, 28),
	BackgroundTransparency = 1,
	RichText = true,
	Font = Enum.Font.GothamMedium,
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
})

local function setCrumb(page)
	crumb.Text = string.format(
		'<font color="#7C7C88">Settings / Settings / </font><font color="#E4E4EA">%s</font>',
		page
	)
end
setCrumb("Фон меню")

local function makeCard(y, height)
	local card = new("Frame", {
		Name = "Card",
		Position = UDim2.fromOffset(0, y),
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.42,
		BorderSizePixel = 0,
	}, content)
	corner(card, 10)
	stroke(card, Theme.Stroke, 0.72, 1)
	return card
end

-- card 1: background photo id ---------------------------------------

local photoCard = makeCard(54, 57)

label(photoCard, {
	Name = "Caption",
	Position = UDim2.fromOffset(20, 0),
	Size = UDim2.new(1, -240, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "ID фото или путь к файлу",
	TextSize = 15,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
})

local photoIdField = new("TextBox", {
	Name = "PhotoId",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, 0),
	Size = UDim2.fromOffset(188, 40),
	BackgroundColor3 = Theme.Field,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	Font = Enum.Font.Gotham,
	Text = "6923775330",
	TextSize = 15,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Center,
	ClearTextOnFocus = false,
	PlaceholderText = "ID / путь",
	PlaceholderColor3 = Theme.Dim,
}, photoCard)
corner(photoIdField, 10)
stroke(photoIdField, Theme.Stroke, 0.65, 1)

-- card 2: photo transparency ----------------------------------------

local opacityCard = makeCard(119, 79)

label(opacityCard, {
	Name = "Caption",
	Position = UDim2.fromOffset(20, 3),
	Size = UDim2.new(1, -240, 0, 40),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "Прозрачность фото",
	TextSize = 15,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
})

local opacityField = label(opacityCard, {
	Name = "OpacityValue",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -10, 0, 3),
	Size = UDim2.fromOffset(86, 40),
	BackgroundColor3 = Theme.Field,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	Font = Enum.Font.Gotham,
	Text = "0.3",
	TextSize = 15,
	TextColor3 = Theme.Text,
})
corner(opacityField, 10)
stroke(opacityField, Theme.Stroke, 0.65, 1)

local slider = new("Frame", {
	Name = "Slider",
	Position = UDim2.fromOffset(7, 56),
	Size = UDim2.new(1, -14, 0, 16),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
}, opacityCard)

local sliderTrack = new("Frame", {
	Name = "Track",
	Position = UDim2.new(0, 0, 0.5, -2),
	Size = UDim2.new(1, 0, 0, 4),
	BackgroundColor3 = Color3.fromRGB(80, 80, 92),
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
}, slider)
corner(sliderTrack, 2)

local sliderFill = new("Frame", {
	Name = "Fill",
	Size = UDim2.new(0.3, 0, 1, 0),
	BackgroundColor3 = Theme.Text,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
}, sliderTrack)
corner(sliderFill, 2)

local sliderThumb = new("Frame", {
	Name = "Thumb",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.3, 0, 0.5, 0),
	Size = UDim2.fromOffset(14, 14),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderSizePixel = 0,
}, slider)
corner(sliderThumb, 7)

local previewBlob
local sliderValue = 0.3

local function setSliderAlpha(value)
	value = math.clamp(value, 0, 1)
	sliderValue = value
	sliderFill.Size = UDim2.new(value, 0, 1, 0)
	sliderThumb.Position = UDim2.new(value, 0, 0.5, 0)
	opacityField.Text = formatValue(value)
	if previewBlob then
		previewBlob.BackgroundTransparency = math.clamp(value, 0.05, 0.95)
	end
end
setSliderAlpha(0.3)


---------------------------------------------------------------
-- preview panel
---------------------------------------------------------------

local preview = new("Frame", {
	Name = "Preview",
	Position = UDim2.fromOffset(862, 1),
	Size = UDim2.fromOffset(306, 503),
	BackgroundColor3 = Color3.fromRGB(24, 24, 29),
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, body)
corner(preview, 12)
stroke(preview, Theme.Stroke, 0.75, 1)

previewBlob = new("Frame", {
	Name = "Photo",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 88),
	Size = UDim2.new(0.74, 0, 0, 66),
	BackgroundColor3 = Theme.Accent,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
}, preview)
corner(previewBlob, 33)

local function wire(x, y, width, height, transparency)
	local box = new("Frame", {
		Name = "Wire",
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, height),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, preview)
	stroke(box, Theme.Accent, transparency or 0.55, 1.4)
	return box
end

wire(48, 206, 216, 92)
wire(74, 302, 56, 62)
wire(152, 300, 94, 58)
wire(120, 372, 36, 34)

setSliderAlpha(sliderValue)

---------------------------------------------------------------
-- interaction
---------------------------------------------------------------

local function setChevronDirection(holder, direction)
	local first = holder:FindFirstChild("A")
	local second = holder:FindFirstChild("B")
	if not first or not second then
		return
	end
	if direction == "up" then
		first.Rotation = -45
		second.Rotation = 45
	else
		first.Rotation = 45
		second.Rotation = -45
	end
end

-- window drag ------------------------------------------------------

local function makeDragArea(x, width)
	local area = new("Frame", {
		Name = "DragArea",
		Position = UDim2.fromOffset(x, 0),
		Size = UDim2.fromOffset(width, 70),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
	}, topBar)

	local dragStart
	local startPosition

	area.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragStart = input.Position
		startPosition = window.Position

		local moved

		local moveConnection = UserInputService.InputChanged:Connect(function(change)
			if change.UserInputType ~= Enum.UserInputType.MouseMovement
				and change.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local delta = Vector2.new(change.Position.X - dragStart.X, change.Position.Y - dragStart.Y)
			window.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end)

		moved = UserInputService.InputEnded:Connect(function(released)
			if released.UserInputType == Enum.UserInputType.MouseButton1
				or released.UserInputType == Enum.UserInputType.Touch then
				if moveConnection then
					moveConnection:Disconnect()
					moveConnection = nil
				end
				if moved then
					moved:Disconnect()
					moved = nil
				end
			end
		end)
	end)

	return area
end

makeDragArea(0, 276)
makeDragArea(610, 570)

-- slider -----------------------------------------------------------

local function sliderAlphaFromInput(input)
	local position
	if input.UserInputType == Enum.UserInputType.Touch then
		position = input.Position.X
	else
		position = UserInputService:GetMouseLocation().X
	end

	local left = slider.AbsolutePosition.X
	local width = slider.AbsoluteSize.X
	if width <= 0 then
		return
	end

	setSliderAlpha((position - left) / width)
end

slider.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	sliderAlphaFromInput(input)

	local released
	local moveConnection = UserInputService.InputChanged:Connect(function(change)
		if change.UserInputType == Enum.UserInputType.MouseMovement
			or change.UserInputType == Enum.UserInputType.Touch then
			sliderAlphaFromInput(change)
		end
	end)

	released = UserInputService.InputEnded:Connect(function(change)
		if change.UserInputType == Enum.UserInputType.MouseButton1
			or change.UserInputType == Enum.UserInputType.Touch then
			if moveConnection then
				moveConnection:Disconnect()
				moveConnection = nil
			end
			if released then
				released:Disconnect()
				released = nil
			end
		end
	end)
end)

-- navigation -------------------------------------------------------

local collapsed = { modules = false, subs = false }

for _, entry in ipairs(moduleEntries) do
	entry.group = "modules"
end
for _, entry in ipairs(subEntries) do
	entry.group = "subs"
end

local function applyFilters()
	local query = string.lower(searchBox.Text)

	for _, entry in ipairs(filterable) do
		local visible = not collapsed[entry.group]
		if visible and query ~= "" then
			visible = string.find(string.lower(entry.text.Text), query, 1, true) ~= nil
		end
		entry.row.Visible = visible
	end
end

for index, entry in ipairs(moduleEntries) do
	entry.row.MouseButton1Click:Connect(function()
		activate(entry)
		setCrumb(moduleData[index].name)
	end)
end

for index, entry in ipairs(subEntries) do
	entry.row.MouseButton1Click:Connect(function()
		activate(entry)
		setCrumb(subData[index])
	end)
end

modulesHeader.MouseButton1Click:Connect(function()
	collapsed.modules = not collapsed.modules
	setChevronDirection(modulesArrow, collapsed.modules and "up" or "down")
	applyFilters()
end)

settingsButton.MouseButton1Click:Connect(function()
	collapsed.subs = not collapsed.subs
	setChevronDirection(settingsArrow, collapsed.subs and "up" or "down")
	applyFilters()
end)

settingsButton.MouseEnter:Connect(function()
	TweenService:Create(settingsButton, TweenInfo.new(0.12), { BackgroundTransparency = 0.86 }):Play()
end)
settingsButton.MouseLeave:Connect(function()
	TweenService:Create(settingsButton, TweenInfo.new(0.12), { BackgroundTransparency = 0.9 }):Play()
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilters)

-- keybinds ---------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		gui.Enabled = not gui.Enabled
	elseif input.KeyCode == Enum.KeyCode.Escape and gui.Enabled then
		gui.Enabled = false
	end
end)
