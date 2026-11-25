--[[
	OPUS client v1.8 — interface, modules and effects

	Everything from the reference screenshot, rebuilt in Luau, plus:
		* EN / RU language switch (top bar pill + settings page)
		* working ESP in the menu's own style
		* theme accents, toasts, blur, springy animations
		* floating toggle button you can drag to any corner
		* auto sizing that fits phones, tablets and desktops
		* working tabs: ESP, Visuals, Misc, Images, Music,
		  Config, Games, Settings, Addons, Themes

	Controls
		RightShift   show / hide the menu
		RightControl show / hide the ESP
		Escape       close the menu
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
if not localPlayer then
	return
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

for _, name in ipairs({ "OpusClient", "OpusESP", "OpusWatermark" }) do
	local old = playerGui:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end

local oldBlur = Lighting:FindFirstChild("OpusBlur")
if oldBlur then
	oldBlur:Destroy()
end

---------------------------------------------------------------
-- state
---------------------------------------------------------------

local State = {
	locale = "ru",
	windowTransparency = 0.32,
	windowRadius = 14,

	photo = { id = "", transparency = 0.3, gradient = nil },

	esp = {
		enabled = true,
		boxes = true,
		names = true,
		health = true,
		distance = true,
		teamCheck = true,
		fill = false,
		thickness = 1.4,
		maxDistance = 600,
		offsetX = 0,
		offsetY = 0,
	},

	visuals = { watermark = true, fps = true, smoothness = 0.5 },
	misc = { toggleButton = true, blur = true, animations = true },
	music = { id = "", volume = 0.4, playing = false, track = 1 },
	social = { animId = "" },
	addons = { hitsounds = false, trails = true, chat = true, lowspec = false },
	profiles = {},
}

---------------------------------------------------------------
-- strings
---------------------------------------------------------------

local Strings = {
	search = { ru = "Поиск...", en = "Search..." },
	modules = { ru = "Modules", en = "Modules" },
	settings = { ru = "Настройки", en = "Settings" },
	preview = { ru = "Передпросмотр", en = "Preview" },
	integration = { ru = "Интеграция", en = "Integration" },

	esp = { ru = "ESP", en = "ESP" },
	visuals = { ru = "Визуалы", en = "Visuals" },
	misc = { ru = "Разное", en = "Misc" },
	images = { ru = "Образы", en = "Images" },
	music = { ru = "Музыка", en = "Music" },
	config = { ru = "Config", en = "Config" },
	games = { ru = "Games", en = "Games" },
	addons = { ru = "Дополнения", en = "Addons" },
	themes = { ru = "Themes", en = "Themes" },

	apply = { ru = "Применить", en = "Apply" },
	reset = { ru = "Сброс", en = "Reset" },
	save = { ru = "Сохранить", en = "Save" },
	load = { ru = "Загрузить", en = "Load" },
	delete = { ru = "Удалить", en = "Delete" },

	esp_sub = { ru = "Подсветка игроков в стиле меню", en = "Player highlighting in the menu style" },
	esp_enable = { ru = "Включить ESP", en = "Enable ESP" },
	esp_boxes = { ru = "Боксы", en = "Boxes" },
	esp_names = { ru = "Имена", en = "Names" },
	esp_health = { ru = "Здоровье", en = "Health" },
	esp_distance = { ru = "Дистанция", en = "Distance" },
	esp_team = { ru = "Проверка команды", en = "Team check" },
	esp_fill = { ru = "Заливка", en = "Fill" },
	esp_style = { ru = "Внешний вид", en = "Appearance" },
	esp_thickness = { ru = "Толщина линий", en = "Line thickness" },
	esp_range = { ru = "Дальность", en = "Max distance" },
	esp_color = { ru = "Цвет акцента", en = "Accent color" },
	esp_online = { ru = "Игроков в поле", en = "Players in range" },

	visuals_sub = { ru = "Служебные элементы на экране", en = "On-screen overlays" },
	watermark = { ru = "Водяной знак", en = "Watermark" },
	fps_counter = { ru = "Счётчик FPS", en = "FPS counter" },
	smoothness = { ru = "Плавность анимаций", en = "Animation smoothness" },

	misc_sub = { ru = "Поведение и производительность", en = "Behaviour and performance" },
	toggle_button = { ru = "Кнопка-кружок", en = "Floating button" },
	reset_settings = { ru = "Сбросить настройки", en = "Reset settings" },

	images_sub = { ru = "Оформление окна", en = "Window decoration" },
	images_presets = { ru = "Готовые фоны", en = "Background presets" },
	images_note = { ru = "Нажмите на плитку, чтобы применить фон", en = "Tap a tile to apply a background" },

	music_sub = { ru = "Плеер и визуализатор", en = "Player and visualizer" },
	now_playing = { ru = "Сейчас играет", en = "Now playing" },
	play = { ru = "Играть", en = "Play" },
	pause = { ru = "Пауза", en = "Pause" },
	volume = { ru = "Громкость", en = "Volume" },
	sound_id = { ru = "ID звука", en = "Sound ID" },
	playlist = { ru = "Плейлист", en = "Playlist" },

	config_sub = { ru = "Профили настроек", en = "Settings profiles" },
	profile_name = { ru = "Имя профиля", en = "Profile name" },
	config_empty = { ru = "Профилей пока нет", en = "No profiles yet" },
	config_saved = { ru = "Профиль сохранён", en = "Profile saved" },
	config_loaded = { ru = "Профиль загружен", en = "Profile loaded" },
	config_deleted = { ru = "Профиль удалён", en = "Profile deleted" },
	config_missing = { ru = "Введите имя профиля", en = "Enter a profile name" },
	config_nofound = { ru = "Профиль не найден", en = "Profile not found" },

	games_sub = { ru = "Совместимые места", en = "Compatible places" },
	supported = { ru = "Работает", en = "Supported" },
	testing = { ru = "Тест", en = "Testing" },

	addons_sub = { ru = "Дополнительные модули", en = "Extra modules" },
	addon_hitsounds = { ru = "Звуки попадания", en = "Hit sounds" },
	addon_trails = { ru = "Трейлы", en = "Trails" },
	addon_chat = { ru = "Чат-теги", en = "Chat tags" },
	addon_lowspec = { ru = "Режим слабого ПК", en = "Low spec mode" },

	themes_sub = { ru = "Цвета и форма окна", en = "Colours and window shape" },
	accent = { ru = "Акцент", en = "Accent" },
	corner_radius = { ru = "Скругление", en = "Corner radius" },
	window_transparency = { ru = "Прозрачность окна", en = "Window transparency" },

	settings_sub = { ru = "Язык, эффекты и фон меню", en = "Language, effects and background" },
	photo_id = { ru = "ID фото или путь к файлу", en = "Photo ID or file path" },
	photo_transparency = { ru = "Прозрачность фото", en = "Photo transparency" },
	language = { ru = "Язык", en = "Language" },
	language_sub = { ru = "Язык интерфейса", en = "Interface language" },
	effects = { ru = "Эффекты", en = "Effects" },
	blur = { ru = "Размытие фона", en = "Background blur" },
	animations = { ru = "Анимации", en = "Animations" },
	background_menu = { ru = "Фон меню", en = "Menu background" },

	toast_applied = { ru = "Фон применён", en = "Background applied" },
	toast_reset = { ru = "Настройки сброшены", en = "Settings reset" },
	toast_language = { ru = "Язык изменён", en = "Language changed" },
	toast_theme = { ru = "Тема обновлена", en = "Theme updated" },
	ru_label = { ru = "RU", en = "RU" },
	en_label = { ru = "EN", en = "EN" },

	social = { ru = "Соц", en = "Social" },
	social_sub = { ru = "То, что видят другие игроки", en = "What other players can actually see" },
	emotes = { ru = "Эмоции", en = "Emotes" },
	emote_wave = { ru = "Привет", en = "Wave" },
	emote_dance = { ru = "Танец", en = "Dance" },
	emote_laugh = { ru = "Смех", en = "Laugh" },
	emote_cheer = { ru = "Ура", en = "Cheer" },
	emote_point = { ru = "Указать", en = "Point" },
	emote_salute = { ru = "Салют", en = "Salute" },
	emote_shrug = { ru = "Плечи", en = "Shrug" },
	emote_stomp = { ru = "Топот", en = "Stomp" },
	custom_anim = { ru = "Своя анимация", en = "Custom animation" },
	animation_id = { ru = "ID анимации", en = "Animation ID" },
	stop = { ru = "Стоп", en = "Stop" },
	chat = { ru = "Чат", en = "Chat" },
	chat_message = { ru = "Сообщение", en = "Message" },
	send = { ru = "Отправить", en = "Send" },
	social_note = {
		ru = "Эмоции и анимация проигрываются на вашем персонаже и повторяются сервером — их видят все. Чат отправляется в общий канал.",
		en = "Emotes and animations play on your character and are replicated — everyone sees them. Chat goes to the public channel.",
	},

	calibration = { ru = "Калибровка", en = "Calibration" },
	offset_x = { ru = "Смещение по X", en = "Offset X" },
	offset_y = { ru = "Смещение по Y", en = "Offset Y" },
	calibration_note = {
		ru = "Если боксы ESP стоят не по персонажу — подвиньте их этими ползунками.",
		en = "If the ESP boxes sit off the character, nudge them with these sliders.",
	},

	toast_emote = { ru = "Эмоция отправлена", en = "Emote played" },
	toast_noemote = { ru = "Эмоция недоступна", en = "Emote unavailable" },
	toast_nocharacter = { ru = "Персонаж не готов", en = "Character not ready" },
	toast_badid = { ru = "Неверный ID", en = "Invalid ID" },
	toast_stopped = { ru = "Анимация остановлена", en = "Animation stopped" },
	toast_chatfail = { ru = "Чат недоступен", en = "Chat unavailable" },
	preview_live = { ru = "LIVE", en = "LIVE" },
}

---------------------------------------------------------------
-- locale
---------------------------------------------------------------

local Locale = {
	current = State.locale,
	registry = {},
	hooks = {},
}

function Locale.get(key)
	local entry = Strings[key]
	if not entry then
		return key
	end
	return entry[Locale.current] or entry.ru or key
end

function Locale.bind(inst, key, property)
	property = property or "Text"
	if not inst or not key then
		return inst
	end
	table.insert(Locale.registry, { inst = inst, key = key, property = property })
	inst[property] = Locale.get(key)
	return inst
end

function Locale.apply()
	local kept = {}
	for _, item in ipairs(Locale.registry) do
		if item.inst and item.inst.Parent ~= nil then
			item.inst[item.property] = Locale.get(item.key)
			table.insert(kept, item)
		end
	end
	Locale.registry = kept

	local keptHooks = {}
	for _, item in ipairs(Locale.hooks) do
		if item.inst and item.inst.Parent ~= nil then
			item.fn()
			table.insert(keptHooks, item)
		end
	end
	Locale.hooks = keptHooks
end

function Locale.hook(inst, fn)
	table.insert(Locale.hooks, { inst = inst, fn = fn })
	fn()
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
	Stroke = Color3.fromRGB(88, 88, 100),
	Accent = Color3.fromRGB(238, 150, 216),
}

local accentTargets = {}
local repainters = {}

local function bindAccent(inst, property)
	property = property or "BackgroundColor3"
	table.insert(accentTargets, { inst = inst, property = property })
	inst[property] = Theme.Accent
	return inst
end

local function bindRepaint(inst, fn)
	table.insert(repainters, { inst = inst, fn = fn })
	fn()
end

local function setAccent(color)
	Theme.Accent = color

	local keptTargets = {}
	for _, target in ipairs(accentTargets) do
		if target.inst and target.inst.Parent ~= nil then
			target.inst[target.property] = color
			table.insert(keptTargets, target)
		end
	end
	accentTargets = keptTargets

	local keptPainters = {}
	for _, item in ipairs(repainters) do
		if item.inst and item.inst.Parent ~= nil then
			item.fn()
			table.insert(keptPainters, item)
		end
	end
	repainters = keptPainters
end

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
	local existing = inst:FindFirstChildOfClass("UICorner")
	if existing then
		existing.CornerRadius = UDim.new(0, radius)
		return existing
	end
	return new("UICorner", { CornerRadius = UDim.new(0, radius) }, inst)
end

local function stroke(inst, color, transparency, thickness)
	local existing = inst:FindFirstChildOfClass("UIStroke")
	local target = existing or new("UIStroke", {}, inst)
	target.Color = color or Theme.Stroke
	target.Transparency = transparency or 0.65
	target.Thickness = thickness or 1
	target.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return target
end

local function padding(inst, top, right, bottom, left)
	return new("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or top or 0),
		PaddingBottom = UDim.new(0, bottom or top or 0),
		PaddingLeft = UDim.new(0, left or right or top or 0),
	}, inst)
end

-- every animation runs through here so the "smoothness" slider and the
-- animations toggle apply everywhere at once
local function anim(inst, props, duration, style, direction)
	local base = duration or 0.18
	local scale = 0.4 + (State.visuals.smoothness or 0.5) * 2.2
	local info = TweenInfo.new(
		State.misc.animations and (base * scale) or 0,
		style or Enum.EasingStyle.Quint,
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(inst, info, props)
	tween:Play()
	return tween
end

local function formatNumber(value, decimals)
	local text = string.format("%." .. (decimals or 2) .. "f", value)
	if (decimals or 2) > 0 then
		text = string.gsub(text, "0+$", "")
		text = string.gsub(text, "%.$", "")
	end
	if text == "" or text == "-0" then
		text = "0"
	end
	return text
end

local function text(parent, props, key)
	local inst = new("TextLabel", props, parent)
	if key then
		Locale.bind(inst, key)
	end
	return inst
end

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

	local first = new("Frame", bar, holder)
	local second = new("Frame", bar, holder)
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

local toast
local showPage
local setMenu
local updateCrumb
local liveUpdaters = {}


---------------------------------------------------------------
-- ui kit
---------------------------------------------------------------

local Kit = {}

function Kit.title(parent, titleKey, subKey)
	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
	}, parent)

	text(holder, {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 19,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, titleKey)

	if subKey then
		text(holder, {
			Position = UDim2.fromOffset(0, 26),
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = Theme.Dim,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, subKey)
	end

	return holder
end

function Kit.card(parent)
	local card = new("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.42,
		BorderSizePixel = 0,
	}, parent)
	corner(card, 10)
	stroke(card, Theme.Stroke, 0.72, 1)
	padding(card, 10, 16, 10, 16)
	new("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, card)
	return card
end

function Kit.divider(card)
	return new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
	}, card)
end

function Kit.toggle(card, textKey, value, onChange)
	local row = new("TextButton", {
		Name = "ToggleRow",
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
	}, card)

	text(row, {
		Size = UDim2.new(1, -60, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, textKey)

	local pill = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(40, 21),
		BackgroundColor3 = Color3.fromRGB(58, 58, 68),
		BorderSizePixel = 0,
	}, row)
	corner(pill, 11)

	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2.5, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.fromRGB(198, 198, 208),
		BorderSizePixel = 0,
	}, pill)
	corner(knob, 8)

	local state = { value = value and true or false }

	local function paint()
		if state.value then
			anim(pill, { BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.55 }, 0.16)
			anim(knob, {
				Position = UDim2.new(0, 21, 0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			}, 0.22, Enum.EasingStyle.Back)
		else
			anim(pill, { BackgroundColor3 = Color3.fromRGB(58, 58, 68), BackgroundTransparency = 0 }, 0.16)
			anim(knob, {
				Position = UDim2.new(0, 2.5, 0.5, 0),
				BackgroundColor3 = Color3.fromRGB(198, 198, 208),
			}, 0.22, Enum.EasingStyle.Back)
		end
	end

	paint()
	bindRepaint(pill, paint)

	row.MouseButton1Click:Connect(function()
		state.value = not state.value
		paint()
		if onChange then
			onChange(state.value)
		end
	end)

	return {
		get = function()
			return state.value
		end,
		set = function(next)
			state.value = next and true or false
			paint()
		end,
	}
end

function Kit.slider(card, textKey, cfg)
	cfg = cfg or {}
	local minValue = cfg.min or 0
	local maxValue = cfg.max or 1
	local step = cfg.step or 0.01
	local state = { value = cfg.value or minValue }
	local dragConnection
	local endConnection

	local row = new("Frame", {
		Name = "SliderRow",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
	}, card)

	text(row, {
		Size = UDim2.new(1, -70, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, textKey)

	local valueLabel = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(66, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, row)

	local track = new("Frame", {
		Position = UDim2.fromOffset(7, 28),
		Size = UDim2.new(1, -14, 0, 16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
	}, row)

	local line = new("Frame", {
		Position = UDim2.new(0, 0, 0.5, -2),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = Color3.fromRGB(70, 70, 82),
		BorderSizePixel = 0,
	}, track)
	corner(line, 2)

	local fill = new("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, line)
	corner(fill, 2)

	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(13, 13),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, track)
	corner(knob, 7)

	local function alpha()
		if maxValue <= minValue then
			return 0
		end
		return (state.value - minValue) / (maxValue - minValue)
	end

	local function paint()
		local a = alpha()
		anim(fill, { Size = UDim2.new(a, 0, 1, 0) }, 0.08)
		anim(knob, { Position = UDim2.new(a, 0, 0.5, 0) }, 0.08)
		valueLabel.Text = cfg.format and cfg.format(state.value) or formatNumber(state.value, 2)
	end

	local function setValue(value, notify)
		value = math.clamp(value, minValue, maxValue)
		if step > 0 then
			value = math.floor((value / step) + 0.5) * step
			value = math.clamp(value, minValue, maxValue)
		end
		state.value = value
		paint()
		if notify and cfg.onChange then
			cfg.onChange(value)
		end
	end

	local function fromInput(input)
		local position
		if input.UserInputType == Enum.UserInputType.Touch then
			position = input.Position.X
		else
			position = UserInputService:GetMouseLocation().X
		end
		local left = track.AbsolutePosition.X
		local width = track.AbsoluteSize.X
		if width <= 0 then
			return
		end
		setValue(minValue + ((position - left) / width) * (maxValue - minValue), true)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		fromInput(input)

		if dragConnection then
			dragConnection:Disconnect()
			dragConnection = nil
		end
		if endConnection then
			endConnection:Disconnect()
			endConnection = nil
		end

		dragConnection = UserInputService.InputChanged:Connect(function(change)
			if change.UserInputType == Enum.UserInputType.MouseMovement
				or change.UserInputType == Enum.UserInputType.Touch then
				fromInput(change)
			end
		end)

		endConnection = UserInputService.InputEnded:Connect(function(change)
			if change.UserInputType == Enum.UserInputType.MouseButton1
				or change.UserInputType == Enum.UserInputType.Touch then
				if dragConnection then
					dragConnection:Disconnect()
					dragConnection = nil
				end
				if endConnection then
					endConnection:Disconnect()
					endConnection = nil
				end
			end
		end)
	end)

	paint()
	bindRepaint(fill, paint)

	return {
		get = function()
			return state.value
		end,
		set = function(value)
			setValue(value, false)
		end,
	}
end

function Kit.segmented(parent, labels, index, onPick, width)
	local count = #labels

	local holder = new("Frame", {
		Size = UDim2.fromOffset(width or 150, 32),
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
	}, parent)
	corner(holder, 16)
	stroke(holder, Theme.Stroke, 0.7, 1)

	local highlight = new("Frame", {
		Position = UDim2.new((index - 1) / count, 3, 0, 3),
		Size = UDim2.new(1 / count, -6, 1, -6),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
	}, holder)
	corner(highlight, 13)
	bindAccent(highlight)

	local buttons = {}

	local function select(nextIndex, notify)
		anim(highlight, { Position = UDim2.new((nextIndex - 1) / count, 3, 0, 3) }, 0.22)
		for i, button in ipairs(buttons) do
			local active = (i == nextIndex)
			button.TextColor3 = active and Theme.Text or Theme.Dim
			button.Font = active and Enum.Font.GothamBold or Enum.Font.GothamMedium
		end
		if notify and onPick then
			onPick(nextIndex)
		end
	end

	for i = 1, count do
		local button = new("TextButton", {
			Position = UDim2.new((i - 1) / count, 0, 0, 0),
			Size = UDim2.new(1 / count, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			TextSize = 12,
			Font = Enum.Font.GothamMedium,
			TextColor3 = Theme.Dim,
			AutoButtonColor = false,
		}, holder)
		Locale.bind(button, labels[i])
		buttons[i] = button
		button.MouseButton1Click:Connect(function()
			select(i, true)
		end)
	end

	select(index, false)

	return {
		set = function(i)
			select(i, false)
		end,
	}
end

function Kit.field(card, textKey, value, onCommit, placeholder)
	local row = new("Frame", {
		Name = "FieldRow",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, card)

	if textKey then
		text(row, {
			Size = UDim2.new(1, -210, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, textKey)
	end

	local box = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(200, 32),
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.Text,
		Text = value or "",
		PlaceholderText = placeholder or "",
		PlaceholderColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Center,
		ClearTextOnFocus = false,
	}, row)
	corner(box, 8)
	stroke(box, Theme.Stroke, 0.7, 1)

	if onCommit then
		box.FocusLost:Connect(function()
			onCommit(box.Text)
		end)
	end

	return box
end

function Kit.button(parent, textKey, onClick, accent)
	local button = new("TextButton", {
		Size = UDim2.fromOffset(126, 34),
		BackgroundColor3 = accent and Theme.Accent or Color3.fromRGB(40, 40, 47),
		BackgroundTransparency = accent and 0.72 or 0.06,
		BorderSizePixel = 0,
		Text = "",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Theme.Text,
		AutoButtonColor = false,
	}, parent)
	corner(button, 9)
	stroke(button, Theme.Stroke, 0.7, 1)
	Locale.bind(button, textKey)

	if accent then
		bindAccent(button)
		button.BackgroundTransparency = 0.72
	end

	button.MouseEnter:Connect(function()
		anim(button, { BackgroundTransparency = accent and 0.58 or 0 }, 0.12)
	end)
	button.MouseLeave:Connect(function()
		anim(button, { BackgroundTransparency = accent and 0.72 or 0.06 }, 0.12)
	end)
	button.MouseButton1Click:Connect(function()
		if onClick then
			onClick()
		end
	end)

	return button
end

function Kit.swatches(card, textKey, colors, onPick)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
	}, card)

	text(row, {
		Size = UDim2.new(1, -220, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, textKey)

	local holder = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(#colors * 30, 26),
		BackgroundTransparency = 1,
	}, row)

	local dots = {}

	for index, color in ipairs(colors) do
		local dot = new("TextButton", {
			Position = UDim2.fromOffset((index - 1) * 30, 0),
			Size = UDim2.fromOffset(24, 24),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		}, holder)
		corner(dot, 12)
		local ring = stroke(dot, Color3.fromRGB(255, 255, 255), 0.85, 1.4)
		dots[index] = { dot = dot, ring = ring }

		dot.MouseButton1Click:Connect(function()
			for _, item in ipairs(dots) do
				item.ring.Transparency = 0.85
			end
			ring.Transparency = 0.05
			if onPick then
				onPick(color)
			end
		end)
	end

	return dots
end


---------------------------------------------------------------
-- root
---------------------------------------------------------------

local BASE_WIDTH, BASE_HEIGHT = 1180, 580

local gui = new("ScreenGui", {
	Name = "OpusClient",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 500,
}, playerGui)

local blur = new("BlurEffect", { Name = "OpusBlur", Size = 0 }, Lighting)

local shade = new("Frame", {
	Name = "Shade",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	ZIndex = 0,
}, gui)

local window = new("CanvasGroup", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT),
	BackgroundColor3 = Theme.Window,
	BackgroundTransparency = State.windowTransparency,
	BorderSizePixel = 0,
	GroupTransparency = 0,
}, gui)

local windowCorner = corner(window, State.windowRadius)
stroke(window, Theme.Stroke, 0.55, 1)

local uiScale = new("UIScale", { Scale = 1 }, window)

-- background layer (menu photo / gradient) -------------------------

local backgroundHolder = new("Frame", {
	Name = "Background",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	BorderSizePixel = 0,
}, window)
corner(backgroundHolder, State.windowRadius)

local backgroundFill = new("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(30, 30, 36),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, backgroundHolder)
local backgroundGradient = new("UIGradient", {
	Rotation = 45,
	Transparency = NumberSequence.new(1),
}, backgroundFill)

local backgroundImage = new("ImageLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Image = "",
	ImageTransparency = 1,
	ScaleType = Enum.ScaleType.Crop,
	BorderSizePixel = 0,
}, backgroundHolder)

local function setBackgroundImage(id)
	State.photo.gradient = nil
	backgroundFill.BackgroundTransparency = 1
	backgroundGradient.Transparency = NumberSequence.new(1)

	local asset = (id and id ~= "") and ("rbxassetid://" .. tostring(id)) or ""
	local transparency = (asset ~= "") and State.photo.transparency or 1

	backgroundImage.Image = asset
	anim(backgroundImage, { ImageTransparency = transparency }, 0.3)
end

local function setBackgroundGradient(first, second)
	backgroundImage.Image = ""
	backgroundImage.ImageTransparency = 1
	backgroundGradient.Color = ColorSequence.new(first, second)
	backgroundGradient.Transparency = NumberSequence.new(math.clamp(State.photo.transparency + 0.15, 0, 1))
	backgroundFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	anim(backgroundFill, { BackgroundTransparency = 0 }, 0.3)
	State.photo.gradient = { first, second }
end

-- responsive sizing ------------------------------------------------

local currentScale = 1
local menuOpen = true
local toggleButton
local clampToggle

local function computeScale()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local factor = math.min((viewport.X * 0.94) / BASE_WIDTH, (viewport.Y * 0.94) / BASE_HEIGHT)
	return math.clamp(factor, 0.3, 1.2)
end

local function clampWindow()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local width = BASE_WIDTH * currentScale
	local height = BASE_HEIGHT * currentScale
	local centerX = viewport.X / 2 + window.Position.X.Offset
	local centerY = viewport.Y / 2 + window.Position.Y.Offset

	if width >= viewport.X then
		centerX = viewport.X / 2
	else
		centerX = math.clamp(centerX, width / 2, viewport.X - width / 2)
	end
	if height >= viewport.Y then
		centerY = viewport.Y / 2
	else
		centerY = math.clamp(centerY, height / 2, viewport.Y - height / 2)
	end

	window.Position = UDim2.new(0.5, centerX - viewport.X / 2, 0.5, centerY - viewport.Y / 2)
end

local function refreshLayout()
	currentScale = computeScale()
	if menuOpen then
		uiScale.Scale = currentScale
	end
	clampWindow()
	if clampToggle then
		clampToggle()
	end
end

refreshLayout()

---------------------------------------------------------------
-- top bar
---------------------------------------------------------------

local topBar = new("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 70),
	BackgroundTransparency = 1,
}, window)

local logo = new("Frame", {
	Name = "Logo",
	Position = UDim2.fromOffset(20, 19),
	Size = UDim2.fromOffset(32, 32),
	BackgroundColor3 = Color3.fromRGB(26, 26, 31),
	BorderSizePixel = 0,
}, topBar)
corner(logo, 16)
stroke(logo, Color3.fromRGB(96, 96, 110), 0.55, 1)

local logoGlow = new("Frame", {
	Name = "Glow",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(30, 30),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, logo)
corner(logoGlow, 15)
local logoGlowStroke = stroke(logoGlow, Theme.Accent, 0.55, 2)
bindAccent(logoGlowStroke, "Color")

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

text(topBar, {
	Position = UDim2.fromOffset(58, 0),
	Size = UDim2.new(0, 90, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "OPUS",
})

text(topBar, {
	Position = UDim2.fromOffset(126, 1),
	Size = UDim2.new(0, 140, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextColor3 = Theme.Muted,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "client v1.8",
})

-- search
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
	PlaceholderColor3 = Color3.fromRGB(104, 104, 116),
	ClearTextOnFocus = false,
}, searchBar)
Locale.bind(searchBox, "search", "PlaceholderText")

-- captions -------------------------------------------------------

local captionTop = text(topBar, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -152, 0, 16),
	Size = UDim2.fromOffset(260, 20),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Right,
}, "preview")

local captionBottom = text(topBar, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -152, 0, 38),
	Size = UDim2.fromOffset(260, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = Theme.Dim,
	TextXAlignment = Enum.TextXAlignment.Right,
}, "integration")

-- language pill ---------------------------------------------------

local langPill = new("Frame", {
	Name = "Language",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -62, 0, 35),
	Size = UDim2.fromOffset(78, 30),
	BackgroundColor3 = Theme.Field,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
}, topBar)
corner(langPill, 15)
stroke(langPill, Theme.Stroke, 0.7, 1)

local langHighlight = new("Frame", {
	Position = UDim2.new(0, 3, 0, 3),
	Size = UDim2.new(0.5, -6, 1, -6),
	BackgroundColor3 = Theme.Accent,
	BackgroundTransparency = 0.75,
	BorderSizePixel = 0,
}, langPill)
corner(langHighlight, 12)
bindAccent(langHighlight)

local langRu = new("TextButton", {
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.new(0.5, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "RU",
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
	AutoButtonColor = false,
}, langPill)

local langEn = new("TextButton", {
	Position = UDim2.new(0.5, 0, 0, 0),
	Size = UDim2.new(0.5, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "EN",
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.Dim,
	AutoButtonColor = false,
}, langPill)

-- close button ----------------------------------------------------

local closeButton = new("TextButton", {
	Name = "Close",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -20, 0, 35),
	Size = UDim2.fromOffset(32, 32),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.92,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
}, topBar)
corner(closeButton, 16)

for _, rotation in ipairs({ 45, -45 }) do
	new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 11, 0, 1.5),
		BackgroundColor3 = Theme.Text,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Rotation = rotation,
	}, closeButton)
end

new("Frame", {
	Name = "TopDivider",
	Position = UDim2.fromOffset(0, 70),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
}, window)

local accentLine = new("Frame", {
	Name = "AccentLine",
	Position = UDim2.fromOffset(0, 70),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = Theme.Accent,
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
}, window)
bindAccent(accentLine)
new("UIGradient", {
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	}),
}, accentLine)

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

local PageBuilders = {}
local PageMeta = {}

local filterable = {}
local activeEntry

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

local function activate(entry)
	if activeEntry and activeEntry.row ~= entry.row then
		activeEntry.row:SetAttribute("Active", false)
		activeEntry.highlight.BackgroundTransparency = 1
		activeEntry.text.TextColor3 = activeEntry.base
		anim(activeEntry.accentBar, { Size = UDim2.fromOffset(0, 16) }, 0.16)
	end

	entry.row:SetAttribute("Active", true)
	entry.highlight.BackgroundTransparency = 0.86
	entry.text.TextColor3 = Theme.Text
	anim(entry.accentBar, { Size = UDim2.fromOffset(3, 16) }, 0.2, Enum.EasingStyle.Back)
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

	local accentBar = new("Frame", {
		Name = "AccentBar",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, pillX + 5, 0.5, 0),
		Size = UDim2.fromOffset(0, 16),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, row)
	corner(accentBar, 2)
	bindAccent(accentBar)

	if config.glyph then
		drawGlyph(row, config.glyph, config.glyphX or 46, config.textColor or Theme.Muted, 0.25)
	end

	local textLabel = text(row, {
		Name = "Caption",
		Position = UDim2.fromOffset(config.textX or 75, 0),
		Size = UDim2.new(1, -(config.textX or 75), 1, 0),
		BackgroundTransparency = 1,
		Font = config.font or Enum.Font.Gotham,
		TextSize = config.textSize or 14,
		TextColor3 = config.textColor or Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, config.key)

	local entry = {
		row = row,
		highlight = highlight,
		text = textLabel,
		accentBar = accentBar,
		base = config.textColor or Theme.Muted,
		page = config.page,
		group = config.group,
		key = config.key,
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

-- modules header ---------------------------------------------------

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

text(modulesHeader, {
	Position = UDim2.fromOffset(42, 0),
	Size = UDim2.new(1, -60, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
}, "modules")

local modulesArrow = chevron(modulesHeader, 180, 16, 12, "down", Theme.Dim, 0.15)

local moduleList = new("Frame", {
	Name = "ModuleList",
	Position = UDim2.fromOffset(0, 44),
	Size = UDim2.new(1, 0, 0, 180),
	BackgroundTransparency = 1,
}, sidebar)
new("UIListLayout", {
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, moduleList)

local moduleData = {
	{ key = "esp", glyph = "ring", page = "esp" },
	{ key = "visuals", glyph = "dot", page = "visuals" },
	{ key = "social", glyph = "ring", page = "social" },
	{ key = "misc", glyph = "pause", page = "misc" },
	{ key = "images", glyph = "ring", page = "images" },
	{ key = "music", glyph = "dot", page = "music" },
}

local moduleEntries = {}
for index, item in ipairs(moduleData) do
	moduleEntries[index] = navRow(moduleList, {
		name = item.key,
		order = index,
		height = 30,
		key = item.key,
		glyph = item.glyph,
		glyphX = 46,
		textX = 75,
		highlightX = 24,
		page = item.page,
		group = "modules",
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

text(settingsButton, {
	Name = "Plus",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0, 21, 0.5, 0),
	Size = UDim2.fromOffset(16, 16),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 17,
	TextColor3 = Theme.Text,
	Text = "+",
})

text(settingsButton, {
	Name = "Title",
	Position = UDim2.fromOffset(42, 0),
	Size = UDim2.new(1, -60, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
}, "settings")

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

local subData = {
	{ key = "config", page = "config" },
	{ key = "games", page = "games" },
	{ key = "settings", page = "settings" },
	{ key = "addons", page = "addons" },
	{ key = "themes", page = "themes" },
	{ key = nil, label = "opus_client.rbx", page = "themes" },
}

local subEntries = {}
for index, item in ipairs(subData) do
	local isFile = item.label ~= nil
	local entry = navRow(subList, {
		name = item.label or item.key,
		order = index,
		height = 28,
		textX = 78,
		highlightX = 56,
		font = Enum.Font.Gotham,
		textSize = isFile and 12 or 13,
		textColor = isFile and Theme.Dim or Theme.Muted,
		glyph = nil,
		page = item.page,
		group = "subs",
	})

	if isFile then
		entry.text.Text = item.label
	end

	subEntries[index] = entry
end

---------------------------------------------------------------
-- navigation
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

local crumb = new("TextLabel", {
	Name = "Breadcrumb",
	Position = UDim2.fromOffset(38, 8),
	Size = UDim2.new(1, -38, 0, 28),
	BackgroundTransparency = 1,
	RichText = true,
	Font = Enum.Font.GothamMedium,
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "",
}, content)

local pageHost = new("Frame", {
	Name = "Pages",
	Position = UDim2.fromOffset(0, 44),
	Size = UDim2.new(1, 0, 1, -44),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
}, content)

local currentPageFrame
local currentPageId
local history = {}

local function clearLiveUpdaters()
	liveUpdaters = {}
end

local function destroyPage()
	if currentPageFrame then
		currentPageFrame:Destroy()
		currentPageFrame = nil
	end
	clearLiveUpdaters()

	-- drop locale entries that belonged to the page that just went away
	local kept = {}
	for _, item in ipairs(Locale.registry) do
		if item.inst and item.inst.Parent ~= nil then
			table.insert(kept, item)
		end
	end
	Locale.registry = kept
end

updateCrumb = function()
	local meta = PageMeta[currentPageId]
	if not meta then
		return
	end
	local parts = {}
	for index, key in ipairs(meta.crumb) do
		local color = (index == #meta.crumb) and "#E4E4EA" or "#7C7C88"
		table.insert(parts, string.format('<font color="%s">%s</font>', color, Locale.get(key)))
	end
	crumb.Text = table.concat(parts, '<font color="#4E4E58"> / </font>')
end

showPage = function(id, remember)
	if not PageBuilders[id] then
		return
	end

	if remember ~= false and currentPageId and currentPageId ~= id then
		table.insert(history, currentPageId)
	end

	destroyPage()
	currentPageId = id

	local page = new("ScrollingFrame", {
		Name = id,
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Stroke,
		ScrollBarImageTransparency = 0.4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
	}, pageHost)
	padding(page, 4, 8, 18, 0)
	new("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, page)

	PageBuilders[id](page)

	currentPageFrame = page
	updateCrumb()
	anim(page, { Position = UDim2.fromOffset(0, 0) }, 0.24)
end

backButton.MouseButton1Click:Connect(function()
	local previous = table.remove(history)
	if previous then
		showPage(previous, false)
	else
		showPage("settings", false)
	end
end)

-- navigation wiring ------------------------------------------------

for _, entry in ipairs(moduleEntries) do
	entry.row.MouseButton1Click:Connect(function()
		activate(entry)
		showPage(entry.page)
	end)
end

for _, entry in ipairs(subEntries) do
	entry.row.MouseButton1Click:Connect(function()
		activate(entry)
		showPage(entry.page)
	end)
end

local collapsed = { modules = false, subs = false }

local function applyFilters()
	local query = string.lower(searchBox.Text)

	for _, entry in ipairs(filterable) do
		if entry.group then
			local visible = not collapsed[entry.group]
			if visible and query ~= "" then
				visible = string.find(string.lower(entry.text.Text), query, 1, true) ~= nil
			end
			entry.row.Visible = visible
		end
	end
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
	anim(settingsButton, { BackgroundTransparency = 0.86 }, 0.12)
end)
settingsButton.MouseLeave:Connect(function()
	anim(settingsButton, { BackgroundTransparency = 0.9 }, 0.12)
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilters)


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

local blobHalo = new("Frame", {
	Name = "Halo",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, -14),
	Size = UDim2.new(0, 214, 0, 356),
	BackgroundColor3 = Theme.Accent,
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
}, preview)
corner(blobHalo, 107)
bindAccent(blobHalo)

local refreshAvatar

local avatarFrame = new("ViewportFrame", {
	Name = "Avatar",
	Position = UDim2.fromOffset(6, 6),
	Size = UDim2.new(1, -12, 1, -58),
	BackgroundTransparency = 1,
	Ambient = Color3.fromRGB(152, 152, 164),
	LightColor = Color3.fromRGB(255, 255, 255),
	LightDirection = Vector3.new(-0.55, -1, -0.45),
	BorderSizePixel = 0,
}, preview)

local avatarWorld = new("WorldModel", {}, avatarFrame)
local avatarCamera = new("Camera", { FieldOfView = 32 }, avatarWorld)
avatarFrame.CurrentCamera = avatarCamera

local previewName = new("TextLabel", {
	Name = "Name",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -24),
	Size = UDim2.new(1, -30, 0, 20),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Text = "",
}, preview)

local previewHandle = new("TextLabel", {
	Name = "Handle",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -8),
	Size = UDim2.new(1, -30, 0, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.Dim,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Text = "",
}, preview)

local liveBadge = new("Frame", {
	Name = "Live",
	Position = UDim2.fromOffset(12, 12),
	Size = UDim2.fromOffset(54, 20),
	BackgroundColor3 = Theme.Accent,
	BackgroundTransparency = 0.78,
	BorderSizePixel = 0,
}, preview)
corner(liveBadge, 10)
bindAccent(liveBadge)

local liveDot = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 8, 0.5, 0),
	Size = UDim2.fromOffset(5, 5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderSizePixel = 0,
}, liveBadge)
corner(liveDot, 3)

text(liveBadge, {
	Position = UDim2.fromOffset(17, 0),
	Size = UDim2.new(1, -17, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 9,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
}, "preview_live")

local refreshHit = new("TextButton", {
	Name = "Refresh",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
}, preview)
refreshHit.MouseButton1Click:Connect(function()
	if refreshAvatar then
		refreshAvatar()
	end
end)

task.spawn(function()
	while gui.Parent do
		anim(blobHalo, { BackgroundTransparency = 0.8 }, 2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		task.wait(2.5)
		if not gui.Parent then
			break
		end
		anim(blobHalo, { BackgroundTransparency = 0.92 }, 2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		task.wait(2.5)
	end
end)

---------------------------------------------------------------
-- toasts
---------------------------------------------------------------

local toastLayer = new("Frame", {
	Name = "Toasts",
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -18, 1, -18),
	Size = UDim2.fromOffset(230, 240),
	BackgroundTransparency = 1,
	ZIndex = 2,
}, gui)
new("UIListLayout", {
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, toastLayer)

local toastOrder = 0

toast = function(messageKey)
	toastOrder = toastOrder + 1

	local item = new("Frame", {
		LayoutOrder = toastOrder,
		Size = UDim2.fromOffset(210, 34),
		BackgroundColor3 = Color3.fromRGB(20, 20, 25),
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
	}, toastLayer)
	corner(item, 10)
	local itemStroke = stroke(item, Theme.Accent, 0.45, 1)
	padding(item, 0, 12, 0, 12)

	local itemText = text(item, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = Locale.get(messageKey),
	})

	item.BackgroundTransparency = 1
	itemText.TextTransparency = 1
	itemStroke.Transparency = 1
	anim(item, { BackgroundTransparency = 0.08 }, 0.2)
	anim(itemText, { TextTransparency = 0 }, 0.2)
	anim(itemStroke, { Transparency = 0.45 }, 0.2)

	task.delay(2.4, function()
		if not item.Parent then
			return
		end
		anim(item, { BackgroundTransparency = 1 }, 0.28)
		anim(itemText, { TextTransparency = 1 }, 0.28)
		anim(itemStroke, { Transparency = 1 }, 0.28)
		task.delay(0.34, function()
			item:Destroy()
		end)
	end)
end

---------------------------------------------------------------
-- open / close
---------------------------------------------------------------

setMenu = function(open)
	menuOpen = open

	if open then
		window.Visible = true
		window.GroupTransparency = 1
		uiScale.Scale = currentScale * 0.94
		anim(window, { GroupTransparency = 0 }, 0.26)
		anim(uiScale, { Scale = currentScale }, 0.36, Enum.EasingStyle.Back)
		anim(shade, { BackgroundTransparency = 0.55 }, 0.28)
		anim(blur, { Size = State.misc.blur and 10 or 0 }, 0.3)

		sidebar.Position = UDim2.fromOffset(-14, 0)
		anim(sidebar, { Position = UDim2.fromOffset(0, 0) }, 0.4)
		content.Position = UDim2.fromOffset(240, 0)
		anim(content, { Position = UDim2.fromOffset(224, 0) }, 0.4)
		preview.Position = UDim2.fromOffset(876, 1)
		anim(preview, { Position = UDim2.fromOffset(862, 1) }, 0.4)

		if toggleButton then
			toggleButton.Visible = false
		end
	else
		anim(window, { GroupTransparency = 1 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		anim(uiScale, { Scale = currentScale * 0.94 }, 0.2)
		anim(shade, { BackgroundTransparency = 1 }, 0.22)
		anim(blur, { Size = 0 }, 0.22)
		task.delay(0.24, function()
			if not menuOpen then
				window.Visible = false
			end
		end)
		if toggleButton and State.misc.toggleButton then
			toggleButton.Visible = true
		end
	end
end

closeButton.MouseButton1Click:Connect(function()
	setMenu(false)
end)

---------------------------------------------------------------
-- language
---------------------------------------------------------------

local function refreshLangPill()
	local ru = State.locale == "ru"
	anim(langHighlight, { Position = UDim2.new(ru and 0 or 0.5, 3, 0, 3) }, 0.22)
	langRu.TextColor3 = ru and Theme.Text or Theme.Dim
	langEn.TextColor3 = ru and Theme.Dim or Theme.Text
	langRu.Font = ru and Enum.Font.GothamBold or Enum.Font.GothamMedium
	langEn.Font = ru and Enum.Font.GothamMedium or Enum.Font.GothamBold
end

local function setLocale(code)
	if code ~= "ru" and code ~= "en" then
		return
	end

	State.locale = code
	Locale.current = code
	Locale.apply()
	refreshLangPill()
	updateCrumb()

	if currentPageId == "settings" then
		showPage("settings", false)
	end
end

refreshLangPill()

langRu.MouseButton1Click:Connect(function()
	setLocale("ru")
end)

langEn.MouseButton1Click:Connect(function()
	setLocale("en")
end)


---------------------------------------------------------------
-- pages
---------------------------------------------------------------

local espVisible = 0
local updateWatermark
local profileName = "default"
local sound

local playEmote
local playCustomAnimation
local stopCustomAnimation
local sendChatMessage

local Palette = {
	Color3.fromRGB(238, 150, 216),
	Color3.fromRGB(140, 170, 255),
	Color3.fromRGB(130, 240, 205),
	Color3.fromRGB(255, 205, 130),
	Color3.fromRGB(255, 130, 150),
	Color3.fromRGB(190, 150, 255),
	Color3.fromRGB(150, 220, 255),
	Color3.fromRGB(215, 215, 225),
}

local Gradients = {
	{ Color3.fromRGB(238, 150, 216), Color3.fromRGB(92, 48, 128) },
	{ Color3.fromRGB(110, 210, 255), Color3.fromRGB(24, 62, 132) },
	{ Color3.fromRGB(160, 130, 255), Color3.fromRGB(44, 28, 104) },
	{ Color3.fromRGB(120, 240, 200), Color3.fromRGB(18, 84, 84) },
	{ Color3.fromRGB(255, 200, 130), Color3.fromRGB(136, 62, 34) },
	{ Color3.fromRGB(205, 205, 215), Color3.fromRGB(52, 52, 62) },
	{ Color3.fromRGB(255, 130, 150), Color3.fromRGB(112, 20, 52) },
	{ Color3.fromRGB(120, 170, 255), Color3.fromRGB(20, 34, 92) },
}

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for key, item in pairs(value) do
		out[key] = deepCopy(item)
	end
	return out
end

local function snapshot()
	return {
		esp = deepCopy(State.esp),
		visuals = deepCopy(State.visuals),
		misc = deepCopy(State.misc),
		photo = deepCopy(State.photo),
		windowTransparency = State.windowTransparency,
		windowRadius = State.windowRadius,
		accent = Theme.Accent,
	}
end

local function restore(data)
	if not data then
		return
	end
	State.esp = deepCopy(data.esp)
	State.visuals = deepCopy(data.visuals)
	State.misc = deepCopy(data.misc)
	State.photo = deepCopy(data.photo)
	State.windowTransparency = data.windowTransparency or State.windowTransparency
	State.windowRadius = data.windowRadius or State.windowRadius

	if data.accent then
		setAccent(data.accent)
	end

	window.BackgroundTransparency = State.windowTransparency
	windowCorner.CornerRadius = UDim.new(0, State.windowRadius)
	corner(backgroundHolder, State.windowRadius)
end

-- ESP ---------------------------------------------------------------

PageMeta.esp = { crumb = { "modules", "esp" } }

PageBuilders.esp = function(page)
	Kit.title(page, "esp", "esp_sub")

	local main = Kit.card(page)
	Kit.toggle(main, "esp_enable", State.esp.enabled, function(value)
		State.esp.enabled = value
	end)
	Kit.divider(main)
	Kit.toggle(main, "esp_boxes", State.esp.boxes, function(value)
		State.esp.boxes = value
	end)
	Kit.toggle(main, "esp_names", State.esp.names, function(value)
		State.esp.names = value
	end)
	Kit.toggle(main, "esp_health", State.esp.health, function(value)
		State.esp.health = value
	end)
	Kit.toggle(main, "esp_distance", State.esp.distance, function(value)
		State.esp.distance = value
	end)
	Kit.toggle(main, "esp_fill", State.esp.fill, function(value)
		State.esp.fill = value
	end)
	Kit.toggle(main, "esp_team", State.esp.teamCheck, function(value)
		State.esp.teamCheck = value
	end)

	local style = Kit.card(page)
	Kit.slider(style, "esp_thickness", {
		value = State.esp.thickness,
		min = 0.6,
		max = 4,
		step = 0.1,
		format = function(value)
			return formatNumber(value, 1) .. " px"
		end,
		onChange = function(value)
			State.esp.thickness = value
		end,
	})
	Kit.slider(style, "esp_range", {
		value = State.esp.maxDistance,
		min = 100,
		max = 2000,
		step = 50,
		format = function(value)
			return formatNumber(value, 0) .. " m"
		end,
		onChange = function(value)
			State.esp.maxDistance = value
		end,
	})
	Kit.divider(style)
	Kit.swatches(style, "esp_color", Palette, function(color)
		setAccent(color)
	end)

	local info = Kit.card(page)
	local onlineRow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
	}, info)
	text(onlineRow, {
		Size = UDim2.new(1, -90, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, "esp_online")

	local onlineValue = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(80, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "0",
	}, onlineRow)
	bindAccent(onlineValue, "TextColor3")

	table.insert(liveUpdaters, {
		inst = onlineValue,
		fn = function()
			onlineValue.Text = tostring(espVisible)
		end,
	})

	local calibration = Kit.card(page)
	text(calibration, {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, "calibration")

	Kit.slider(calibration, "offset_x", {
		value = State.esp.offsetX or 0,
		min = -80,
		max = 80,
		step = 1,
		format = function(value)
			return formatNumber(value, 0) .. " px"
		end,
		onChange = function(value)
			State.esp.offsetX = value
		end,
	})

	Kit.slider(calibration, "offset_y", {
		value = State.esp.offsetY or 0,
		min = -80,
		max = 80,
		step = 1,
		format = function(value)
			return formatNumber(value, 0) .. " px"
		end,
		onChange = function(value)
			State.esp.offsetY = value
		end,
	})

	text(calibration, {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}, "calibration_note")
end

-- Visuals -----------------------------------------------------------

PageMeta.visuals = { crumb = { "modules", "visuals" } }

PageBuilders.visuals = function(page)
	Kit.title(page, "visuals", "visuals_sub")

	local card = Kit.card(page)
	Kit.toggle(card, "watermark", State.visuals.watermark, function(value)
		State.visuals.watermark = value
		if updateWatermark then
			updateWatermark()
		end
	end)
	Kit.toggle(card, "fps_counter", State.visuals.fps, function(value)
		State.visuals.fps = value
		if updateWatermark then
			updateWatermark()
		end
	end)

	Kit.divider(card)
	Kit.slider(card, "smoothness", {
		value = State.visuals.smoothness,
		min = 0,
		max = 2,
		step = 0.1,
		format = function(value)
			return formatNumber(value, 1) .. "x"
		end,
		onChange = function(value)
			State.visuals.smoothness = value
		end,
	})
end

-- Misc --------------------------------------------------------------

PageMeta.misc = { crumb = { "modules", "misc" } }

PageBuilders.misc = function(page)
	Kit.title(page, "misc", "misc_sub")

	local card = Kit.card(page)
	Kit.toggle(card, "toggle_button", State.misc.toggleButton, function(value)
		State.misc.toggleButton = value
		if toggleButton then
			toggleButton.Visible = value and not menuOpen
		end
	end)
	Kit.toggle(card, "blur", State.misc.blur, function(value)
		State.misc.blur = value
		if menuOpen then
			anim(blur, { Size = value and 10 or 0 }, 0.3)
		end
	end)
	Kit.toggle(card, "animations", State.misc.animations, function(value)
		State.misc.animations = value
	end)

	local actions = Kit.card(page)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, actions)
	local resetButton = Kit.button(row, "reset_settings", function()
		State.esp = {
			enabled = true,
			boxes = true,
			names = true,
			health = true,
			distance = true,
			teamCheck = true,
			fill = false,
			thickness = 1.4,
			maxDistance = 600,
			offsetX = 0,
			offsetY = 0,
		}
		State.visuals = { watermark = true, fps = true, smoothness = 0.5 }
		State.misc = { toggleButton = true, blur = true, animations = true }
		setAccent(Palette[1])
		if updateWatermark then
			updateWatermark()
		end
		showPage("misc", false)
		toast("toast_reset")
	end, true)
	resetButton.Position = UDim2.fromOffset(0, 5)
	resetButton.Size = UDim2.fromOffset(170, 34)
end

-- Images ------------------------------------------------------------

PageMeta.images = { crumb = { "modules", "images" } }

PageBuilders.images = function(page)
	Kit.title(page, "images", "images_sub")

	local card = Kit.card(page)
	text(card, {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, "images_presets")

	local grid = new("Frame", {
		Size = UDim2.new(1, 0, 0, 136),
		BackgroundTransparency = 1,
	}, card)
	new("UIGridLayout", {
		CellSize = UDim2.fromOffset(126, 64),
		CellPadding = UDim2.fromOffset(8, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, grid)

	for index, preset in ipairs(Gradients) do
		local tile = new("TextButton", {
			LayoutOrder = index,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		}, grid)
		corner(tile, 8)
		new("UIGradient", {
			Color = ColorSequence.new(preset[1], preset[2]),
			Rotation = 45,
		}, tile)
		stroke(tile, Color3.fromRGB(255, 255, 255), 0.82, 1)

		tile.MouseButton1Click:Connect(function()
			setBackgroundGradient(preset[1], preset[2])
			toast("toast_applied")
		end)
	end

	local actions = Kit.card(page)
	text(actions, {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, "images_note")

	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, actions)
	local clearButton = Kit.button(row, "reset", function()
		setBackgroundImage("")
		State.photo.id = ""
		State.photo.gradient = nil
		toast("toast_reset")
	end)
	clearButton.Position = UDim2.fromOffset(0, 5)
end

-- Music -------------------------------------------------------------

PageMeta.music = { crumb = { "modules", "music" } }

PageBuilders.music = function(page)
	Kit.title(page, "music", "music_sub")

	local card = Kit.card(page)

	local playerRow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
	}, card)

	text(playerRow, {
		Size = UDim2.new(1, -110, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, "now_playing")

	local titleLabel = new("TextLabel", {
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, -110, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "opus_client — idle",
	}, playerRow)

	local playButton = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(96, 32),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		Text = "",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.Text,
		AutoButtonColor = false,
	}, playerRow)
	corner(playButton, 9)
	stroke(playButton, Theme.Stroke, 0.7, 1)
	bindAccent(playButton)

	local function refreshPlayLabel()
		playButton.Text = Locale.get(State.music.playing and "pause" or "play")
		titleLabel.Text = State.music.playing and "opus_client — playing" or "opus_client — idle"
	end
	Locale.hook(playButton, refreshPlayLabel)

	playButton.MouseButton1Click:Connect(function()
		State.music.playing = not State.music.playing
		if State.music.playing then
			if sound.SoundId ~= "" then
				sound:Play()
			end
		else
			sound:Pause()
		end
		refreshPlayLabel()
	end)

	local barsHolder = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, card)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, barsHolder)

	local bars = {}
	for index = 1, 26 do
		local bar = new("Frame", {
			LayoutOrder = index,
			Size = UDim2.new(0, 4, 0, 4),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
		}, barsHolder)
		corner(bar, 2)
		bars[index] = bar
	end
	bindRepaint(barsHolder, function()
		for _, bar in ipairs(bars) do
			bar.BackgroundColor3 = Theme.Accent
		end
	end)

	table.insert(liveUpdaters, {
		inst = barsHolder,
		fn = function()
			local clock = os.clock()
			for index, bar in ipairs(bars) do
				if bar.Parent then
					local target = 4
					if State.music.playing then
						target = 6 + math.abs(math.sin(clock * 2.4 + index * 0.55)) * 32
					end
					bar.Size = UDim2.new(0, 4, 0, target)
				end
			end
		end,
	})

	Kit.divider(card)
	Kit.field(card, "sound_id", State.music.id, function(value)
		State.music.id = value
		if value ~= "" then
			sound.SoundId = "rbxassetid://" .. value
		else
			sound.SoundId = ""
		end
	end, "rbxassetid")

	Kit.slider(card, "volume", {
		value = State.music.volume,
		min = 0,
		max = 1,
		step = 0.05,
		format = function(value)
			return formatNumber(value * 100, 0) .. "%"
		end,
		onChange = function(value)
			State.music.volume = value
			sound.Volume = value
		end,
	})
end

-- Config ------------------------------------------------------------

PageMeta.config = { crumb = { "settings", "config" } }

PageBuilders.config = function(page)
	Kit.title(page, "config", "config_sub")

	local card = Kit.card(page)
	Kit.field(card, "profile_name", profileName, function(value)
		if value ~= "" then
			profileName = value
		end
	end, "profile")

	local status = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, card)

	local function refreshStatus()
		local count = 0
		for _ in pairs(State.profiles) do
			count = count + 1
		end
		if count == 0 then
			status.Text = Locale.get("config_empty")
		else
			status.Text = string.format("%d", count) .. " / " .. tostring(profileName)
		end
	end
	refreshStatus()

	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, card)

	local saveButton = Kit.button(row, "save", function()
		if profileName == "" then
			toast("config_missing")
			return
		end
		State.profiles[profileName] = snapshot()
		refreshStatus()
		toast("config_saved")
	end, true)
	saveButton.Position = UDim2.fromOffset(0, 5)

	local loadButton = Kit.button(row, "load", function()
		local data = State.profiles[profileName]
		if not data then
			toast("config_nofound")
			return
		end
		restore(data)
		showPage("config", false)
		toast("config_loaded")
	end)
	loadButton.Position = UDim2.fromOffset(136, 5)

	local deleteButton = Kit.button(row, "delete", function()
		if State.profiles[profileName] then
			State.profiles[profileName] = nil
			refreshStatus()
			toast("config_deleted")
		else
			toast("config_nofound")
		end
	end)
	deleteButton.Position = UDim2.fromOffset(272, 5)
end

-- Games -------------------------------------------------------------

PageMeta.games = { crumb = { "settings", "games" } }

PageBuilders.games = function(page)
	Kit.title(page, "games", "games_sub")

	local card = Kit.card(page)
	for index, entry in ipairs({
		{ "Murder Mystery 2", true },
		{ "Arsenal", true },
		{ "Jailbreak", false },
		{ "Da Hood", true },
		{ "Blox Fruits", false },
	}) do
		if index > 1 then
			Kit.divider(card)
		end

		local row = new("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
		}, card)

		local label = new("TextLabel", {
			Size = UDim2.new(1, -110, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = entry[1],
		}, row)

		local badge = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(96, 22),
			BackgroundColor3 = entry[2] and Theme.Accent or Color3.fromRGB(60, 60, 70),
			BackgroundTransparency = entry[2] and 0.68 or 0,
			BorderSizePixel = 0,
		}, row)
		corner(badge, 11)
		if entry[2] then
			bindAccent(badge)
			badge.BackgroundTransparency = 0.68
		end

		local badgeText = text(badge, {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, entry[2] and "supported" or "testing")
		badgeText.Name = "Badge"
	end
end

-- Addons ------------------------------------------------------------

PageMeta.addons = { crumb = { "settings", "addons" } }

PageBuilders.addons = function(page)
	Kit.title(page, "addons", "addons_sub")

	local card = Kit.card(page)
	Kit.toggle(card, "addon_hitsounds", State.addons.hitsounds, function(value)
		State.addons.hitsounds = value
	end)
	Kit.toggle(card, "addon_trails", State.addons.trails, function(value)
		State.addons.trails = value
	end)
	Kit.toggle(card, "addon_chat", State.addons.chat, function(value)
		State.addons.chat = value
	end)
	Kit.toggle(card, "addon_lowspec", State.addons.lowspec, function(value)
		State.addons.lowspec = value
	end)
end

-- Themes ------------------------------------------------------------

PageMeta.themes = { crumb = { "settings", "themes" } }

PageBuilders.themes = function(page)
	Kit.title(page, "themes", "themes_sub")

	local card = Kit.card(page)
	Kit.swatches(card, "accent", Palette, function(color)
		setAccent(color)
		toast("toast_theme")
	end)

	Kit.divider(card)
	Kit.slider(card, "corner_radius", {
		value = State.windowRadius,
		min = 0,
		max = 28,
		step = 1,
		format = function(value)
			return formatNumber(value, 0) .. " px"
		end,
		onChange = function(value)
			State.windowRadius = value
			windowCorner.CornerRadius = UDim.new(0, value)
			corner(backgroundHolder, value)
		end,
	})

	Kit.slider(card, "window_transparency", {
		value = State.windowTransparency,
		min = 0,
		max = 0.9,
		step = 0.02,
		format = function(value)
			return formatNumber(value, 2)
		end,
		onChange = function(value)
			State.windowTransparency = value
			window.BackgroundTransparency = value
		end,
	})
end

-- Settings ----------------------------------------------------------

PageMeta.settings = { crumb = { "settings", "settings", "background_menu" } }

PageBuilders.settings = function(page)
	Kit.title(page, "settings", "settings_sub")

	local photoCard = Kit.card(page)
	local idBox = Kit.field(photoCard, "photo_id", State.photo.id, function(value)
		State.photo.id = value
		setBackgroundImage(value)
		toast("toast_applied")
	end, "rbxassetid")

	Kit.slider(photoCard, "photo_transparency", {
		value = State.photo.transparency,
		min = 0,
		max = 1,
		step = 0.01,
		format = function(value)
			return formatNumber(value, 2)
		end,
		onChange = function(value)
			State.photo.transparency = value
			if State.photo.id ~= "" then
				backgroundImage.ImageTransparency = value
			end
			if State.photo.gradient then
				backgroundGradient.Transparency = NumberSequence.new(math.clamp(value + 0.15, 0, 1))
			end
		end,
	})

	Kit.divider(photoCard)
	local photoActions = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, photoCard)

	local applyButton = Kit.button(photoActions, "apply", function()
		setBackgroundImage(State.photo.id)
		toast("toast_applied")
	end, true)
	applyButton.Position = UDim2.fromOffset(0, 5)

	local clearButton = Kit.button(photoActions, "reset", function()
		State.photo.id = ""
		State.photo.gradient = nil
		idBox.Text = ""
		setBackgroundImage("")
		toast("toast_reset")
	end)
	clearButton.Position = UDim2.fromOffset(136, 5)

	local langCard = Kit.card(page)
	local langRow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
	}, langCard)

	text(langRow, {
		Size = UDim2.new(1, -170, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, "language_sub")

	local langHolder = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(150, 32),
		BackgroundTransparency = 1,
	}, langRow)

	local langSelect = Kit.segmented(langHolder, { "ru_label", "en_label" }, State.locale == "ru" and 1 or 2, function(index)
		setLocale(index == 1 and "ru" or "en")
	end, 150)

	langSelect.set(State.locale == "ru" and 1 or 2)

	local effectsCard = Kit.card(page)
	Kit.toggle(effectsCard, "blur", State.misc.blur, function(value)
		State.misc.blur = value
		if menuOpen then
			anim(blur, { Size = value and 10 or 0 }, 0.3)
		end
	end)
	Kit.toggle(effectsCard, "animations", State.misc.animations, function(value)
		State.misc.animations = value
	end)
	Kit.divider(effectsCard)
	Kit.slider(effectsCard, "window_transparency", {
		value = State.windowTransparency,
		min = 0,
		max = 0.9,
		step = 0.02,
		format = function(value)
			return formatNumber(value, 2)
		end,
		onChange = function(value)
			State.windowTransparency = value
			window.BackgroundTransparency = value
		end,
	})
end


-- Social ------------------------------------------------------------

PageMeta.social = { crumb = { "modules", "social" } }

PageBuilders.social = function(page)
	Kit.title(page, "social", "social_sub")

	local emoteCard = Kit.card(page)
	text(emoteCard, {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, "emotes")

	local grid = new("Frame", {
		Size = UDim2.new(1, 0, 0, 80),
		BackgroundTransparency = 1,
	}, emoteCard)
	new("UIGridLayout", {
		CellSize = UDim2.fromOffset(126, 36),
		CellPadding = UDim2.fromOffset(8, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, grid)

	local emotes = {
		{ "wave", "emote_wave" },
		{ "dance", "emote_dance" },
		{ "laugh", "emote_laugh" },
		{ "cheer", "emote_cheer" },
		{ "point", "emote_point" },
		{ "salute", "emote_salute" },
		{ "shrug", "emote_shrug" },
		{ "stomp", "emote_stomp" },
	}

	for index, emote in ipairs(emotes) do
		local button = Kit.button(grid, emote[2], function()
			if playEmote then
				playEmote(emote[1])
			end
		end, index == 2)
		button.LayoutOrder = index
	end

	local animCard = Kit.card(page)
	text(animCard, {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, "custom_anim")

	Kit.field(animCard, "animation_id", State.social.animId, function(value)
		State.social.animId = value
	end, "rbxassetid")

	local animRow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, animCard)

	local playButton = Kit.button(animRow, "play", function()
		if playCustomAnimation then
			playCustomAnimation(State.social.animId)
		end
	end, true)
	playButton.Position = UDim2.fromOffset(0, 5)

	local stopButton = Kit.button(animRow, "stop", function()
		if stopCustomAnimation then
			stopCustomAnimation()
		end
	end)
	stopButton.Position = UDim2.fromOffset(136, 5)

	local chatCard = Kit.card(page)
	text(chatCard, {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, "chat")

	local chatBox = Kit.field(chatCard, "chat_message", "", nil, "привет")

	local chatRow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, chatCard)

	local sendButton = Kit.button(chatRow, "send", function()
		if sendChatMessage then
			sendChatMessage(chatBox.Text)
		end
		chatBox.Text = ""
	end, true)
	sendButton.Position = UDim2.fromOffset(0, 5)

	text(chatCard, {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Theme.Dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}, "social_note")
end


---------------------------------------------------------------
-- sound
---------------------------------------------------------------

sound = new("Sound", {
	Name = "OpusMusic",
	Volume = State.music.volume,
	SoundId = "",
}, gui)

---------------------------------------------------------------
-- watermark
---------------------------------------------------------------

local fpsValue = 60
local watermark = new("Frame", {
	Name = "Watermark",
	Position = UDim2.fromOffset(18, 16),
	Size = UDim2.fromOffset(196, 26),
	BackgroundColor3 = Color3.fromRGB(12, 12, 15),
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	ZIndex = 0,
}, gui)
corner(watermark, 13)
local watermarkStroke = stroke(watermark, Theme.Accent, 0.5, 1)
bindAccent(watermarkStroke, "Color")

local watermarkLabel = new("TextLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = Theme.Text,
	Text = "OPUS v1.8",
}, watermark)

updateWatermark = function()
	watermark.Visible = State.visuals.watermark
	if State.visuals.fps then
		watermarkLabel.Text = string.format("OPUS v1.8   ·   %d fps", math.floor(fpsValue + 0.5))
	else
		watermarkLabel.Text = "OPUS v1.8"
	end
end
updateWatermark()

---------------------------------------------------------------
-- esp
---------------------------------------------------------------

local espGui = new("ScreenGui", {
	Name = "OpusESP",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 499,
}, playerGui)

local espBoxes = {}

local function getBox(player)
	local box = espBoxes[player]
	if box then
		return box
	end

	local frame = new("Frame", {
		Name = tostring(player.UserId),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
	}, espGui)
	corner(frame, 2)
	local frameStroke = stroke(frame, Theme.Accent, 0.05, State.esp.thickness)

	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.86,
		BorderSizePixel = 0,
		Visible = false,
	}, frame)
	corner(fill, 2)

	local nameLabel = new("TextLabel", {
		Name = "Name",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0, -3),
		Size = UDim2.new(0, 220, 0, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.35,
		Text = "",
	}, frame)

	local healthBack = new("Frame", {
		Name = "Health",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, -6, 0, 0),
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
	}, frame)
	corner(healthBack, 2)

	local healthFill = new("Frame", {
		Name = "Fill",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, healthBack)
	corner(healthFill, 2)

	local distanceLabel = new("TextLabel", {
		Name = "Distance",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 3),
		Size = UDim2.new(0, 220, 0, 12),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = Theme.Accent,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.4,
		Text = "",
	}, frame)

	box = {
		frame = frame,
		stroke = frameStroke,
		fill = fill,
		name = nameLabel,
		healthBack = healthBack,
		healthFill = healthFill,
		distance = distanceLabel,
	}

	espBoxes[player] = box
	return box
end

local function hideBox(player)
	local box = espBoxes[player]
	if box and box.frame.Visible then
		box.frame.Visible = false
	end
end

local function updateEsp()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local cameraPosition = camera.CFrame.Position
	local visible = 0

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local shown = State.esp.enabled
			and player ~= localPlayer
			and root ~= nil
			and humanoid ~= nil
			and humanoid.Health > 0

		if shown and State.esp.teamCheck and player.Team ~= nil and player.Team == localPlayer.Team then
			shown = false
		end

		local distance = 0
		if shown then
			distance = (root.Position - cameraPosition).Magnitude
			if distance > State.esp.maxDistance then
				shown = false
			end
		end

		local geometry
		if shown then
			local okBox, boxCFrame, boxSize = pcall(function()
				return character:GetBoundingBox()
			end)

			if okBox and boxSize and boxSize.Y > 0.1 then
				local half = boxSize.Y / 2
				local topWorld = boxCFrame.Position + Vector3.new(0, half, 0)
				local bottomWorld = boxCFrame.Position - Vector3.new(0, half, 0)

				local topPoint = camera:WorldToScreenPoint(topWorld)
				local bottomPoint = camera:WorldToScreenPoint(bottomWorld)

				if topPoint.Z > 0 and bottomPoint.Z > 0 then
					local height = math.abs(topPoint.Y - bottomPoint.Y)
					local ratio = math.clamp(boxSize.X / math.max(boxSize.Y, 0.01), 0.34, 0.95)
					local width = height * ratio
					if height >= 18 and width >= 6 then
						geometry = {
							x = topPoint.X - width / 2 + (State.esp.offsetX or 0),
							y = math.min(topPoint.Y, bottomPoint.Y) + (State.esp.offsetY or 0),
							width = width,
							height = height,
						}
					end
				end
			end
		end

		if geometry then
			local box = getBox(player)
			local frame = box.frame
			frame.Visible = true
			frame.Position = UDim2.fromOffset(geometry.x, geometry.y)
			frame.Size = UDim2.fromOffset(geometry.width, geometry.height)

			box.stroke.Color = Theme.Accent
			box.stroke.Thickness = State.esp.thickness
			box.stroke.Transparency = State.esp.boxes and 0.05 or 1

			box.fill.Visible = State.esp.fill and State.esp.boxes
			box.fill.BackgroundColor3 = Theme.Accent
			box.fill.BackgroundTransparency = 0.86

			box.name.Visible = State.esp.names
			box.name.Text = player.Name

			box.healthBack.Visible = State.esp.health
			box.healthFill.Visible = State.esp.health
			box.healthFill.BackgroundColor3 = Theme.Accent
			box.healthFill.Size = UDim2.new(
				1,
				0,
				math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1),
				0
			)

			box.distance.Visible = State.esp.distance
			box.distance.TextColor3 = Theme.Accent
			box.distance.Text = string.format("%d m", math.floor(distance + 0.5))

			visible = visible + 1
		else
			hideBox(player)
		end
	end

	espVisible = visible
end

Players.PlayerRemoving:Connect(function(player)
	local box = espBoxes[player]
	if box then
		box.frame:Destroy()
		espBoxes[player] = nil
	end
end)

---------------------------------------------------------------
-- floating toggle button
---------------------------------------------------------------

toggleButton = new("TextButton", {
	Name = "Toggle",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(80, 200),
	Size = UDim2.fromOffset(54, 54),
	BackgroundColor3 = Color3.fromRGB(14, 14, 18),
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	ZIndex = 5,
}, gui)
corner(toggleButton, 27)
local toggleStroke = stroke(toggleButton, Theme.Accent, 0.35, 1.6)
bindAccent(toggleStroke, "Color")

local toggleGlow = new("Frame", {
	Name = "Glow",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, toggleButton)
corner(toggleGlow, 27)
local toggleGlowStroke = stroke(toggleGlow, Theme.Accent, 0.55, 2)
bindAccent(toggleGlowStroke, "Color")

local toggleDiamond = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(18, 18),
	BackgroundColor3 = Theme.Text,
	BorderSizePixel = 0,
	Rotation = 45,
}, toggleButton)
corner(toggleDiamond, 4)

local toggleCore = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(8, 8),
	BackgroundColor3 = Color3.fromRGB(14, 14, 18),
	BorderSizePixel = 0,
	Rotation = 45,
}, toggleDiamond)
corner(toggleCore, 2)

do
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	toggleButton.Position = UDim2.fromOffset(viewport.X - 46, viewport.Y * 0.5)
end

clampToggle = function()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	toggleButton.Position = UDim2.fromOffset(
		math.clamp(toggleButton.Position.X.Offset, 40, viewport.X - 40),
		math.clamp(toggleButton.Position.Y.Offset, 40, viewport.Y - 40)
	)
end

local function snapToggle()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local position = toggleButton.Position
	local x = (position.X.Offset < viewport.X / 2) and 40 or (viewport.X - 40)
	local y = math.clamp(position.Y.Offset, 40, viewport.Y - 40)
	anim(toggleButton, { Position = UDim2.fromOffset(x, y) }, 0.3, Enum.EasingStyle.Back)
end

toggleButton.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local dragStart = input.Position
	local startPosition = toggleButton.Position
	local moved = false
	local moveConnection
	local endConnection

	moveConnection = UserInputService.InputChanged:Connect(function(change)
		if change.UserInputType ~= Enum.UserInputType.MouseMovement
			and change.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = Vector2.new(change.Position.X - dragStart.X, change.Position.Y - dragStart.Y)
		if delta.Magnitude > 8 then
			moved = true
		end
		toggleButton.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	endConnection = UserInputService.InputEnded:Connect(function(change)
		if change.UserInputType ~= Enum.UserInputType.MouseButton1
			and change.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if moveConnection then
			moveConnection:Disconnect()
			moveConnection = nil
		end
		if endConnection then
			endConnection:Disconnect()
			endConnection = nil
		end

		if moved then
			snapToggle()
		else
			setMenu(true)
		end
	end)
end)

toggleButton.MouseEnter:Connect(function()
	anim(toggleButton, { Size = UDim2.fromOffset(58, 58) }, 0.18, Enum.EasingStyle.Back)
end)
toggleButton.MouseLeave:Connect(function()
	anim(toggleButton, { Size = UDim2.fromOffset(54, 54) }, 0.18)
end)

task.spawn(function()
	while toggleButton.Parent do
		toggleGlow.Size = UDim2.fromScale(1, 1)
		toggleGlowStroke.Transparency = 0.55
		anim(toggleGlow, { Size = UDim2.fromScale(1.6, 1.6) }, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		anim(toggleGlowStroke, { Transparency = 1 }, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		task.wait(1.7)
	end
end)

---------------------------------------------------------------
-- avatar preview
---------------------------------------------------------------

local avatarModel
local avatarAngle = 0

refreshAvatar = function()
	if avatarModel then
		avatarModel:Destroy()
		avatarModel = nil
	end

	local character = localPlayer.Character
	if not character then
		return
	end

	local clone = character:Clone()
	for _, item in ipairs(clone:GetDescendants()) do
		if item:IsA("BaseScript") or item:IsA("Humanoid") or item:IsA("ForceField") then
			item:Destroy()
		end
	end

	clone:PivotTo(CFrame.new(0, 0, 0))
	clone.Parent = avatarWorld
	avatarModel = clone

	local ok, box, size = pcall(function()
		return clone:GetBoundingBox()
	end)

	if ok and size and size.Y > 0.1 then
		local center = box.Position
		local distance = size.Y * 1.55 + 1.8
		avatarCamera.CFrame = CFrame.lookAt(center + Vector3.new(0, 0, -distance), center)
	end

	previewName.Text = localPlayer.DisplayName or localPlayer.Name
	previewHandle.Text = "@" .. localPlayer.Name
	avatarAngle = 0
end

RunService.RenderStepped:Connect(function(delta)
	if not avatarModel or not menuOpen then
		return
	end
	avatarAngle = (avatarAngle + delta * 24) % 360
	avatarModel:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(avatarAngle), 0))
end)

refreshAvatar()

localPlayer.CharacterAdded:Connect(function()
	task.delay(0.7, refreshAvatar)
	task.delay(2.5, refreshAvatar)
end)

---------------------------------------------------------------
-- social — the parts other players can actually see
---------------------------------------------------------------

local customTrack
local customAnimation

local function liveHumanoid()
	local character = localPlayer.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		return humanoid
	end
	return nil
end

playEmote = function(name)
	local humanoid = liveHumanoid()
	if not humanoid then
		toast("toast_nocharacter")
		return
	end

	local ok, played = pcall(function()
		return humanoid:PlayEmote(name)
	end)

	if ok and played then
		toast("toast_emote")
	else
		toast("toast_noemote")
	end
end

playCustomAnimation = function(id)
	id = tostring(id or "")
	if id == "" then
		toast("toast_badid")
		return
	end

	local humanoid = liveHumanoid()
	if not humanoid then
		toast("toast_nocharacter")
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = new("Animator", {}, humanoid)
	end

	if customTrack then
		customTrack:Stop()
		customTrack = nil
	end
	if customAnimation then
		customAnimation:Destroy()
		customAnimation = nil
	end

	local animation = new("Animation", { AnimationId = "rbxassetid://" .. id }, humanoid)
	customAnimation = animation

	local ok, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if ok and track then
		customTrack = track
		customTrack.Looped = true
		customTrack:Play()
		toast("toast_emote")
	else
		animation:Destroy()
		customAnimation = nil
		toast("toast_badid")
	end
end

stopCustomAnimation = function()
	if customTrack then
		customTrack:Stop()
		customTrack = nil
		toast("toast_stopped")
	end
end

sendChatMessage = function(message)
	message = tostring(message or "")
	if message == "" then
		return
	end

	local TextChatService = game:GetService("TextChatService")
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		local channels = TextChatService:FindFirstChild("TextChannels")
		local general = channels and channels:FindFirstChild("RBXGeneral")
		if general then
			local ok = pcall(function()
				general:SendAsync(message)
			end)
			if ok then
				return
			end
		end
	end

	local events = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
	local sayRequest = events and events:FindFirstChild("SayMessageRequest")
	if sayRequest then
		sayRequest:FireServer(message, "All")
	else
		toast("toast_chatfail")
	end
end

---------------------------------------------------------------
-- frame loop
---------------------------------------------------------------

local fpsFrames = 0
local fpsClock = 0

RunService.RenderStepped:Connect(function(delta)
	fpsFrames = fpsFrames + 1
	fpsClock = fpsClock + delta
	if fpsClock >= 0.5 then
		fpsValue = fpsFrames / fpsClock
		fpsFrames = 0
		fpsClock = 0
		if State.visuals.watermark then
			updateWatermark()
		end
	end

	updateEsp()

	local kept = {}
	for _, item in ipairs(liveUpdaters) do
		if item.inst and item.inst.Parent ~= nil then
			item.fn(delta)
			table.insert(kept, item)
		end
	end
	liveUpdaters = kept
end)

---------------------------------------------------------------
-- keybinds
---------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		setMenu(not menuOpen)
	elseif input.KeyCode == Enum.KeyCode.Escape and menuOpen then
		setMenu(false)
	elseif input.KeyCode == Enum.KeyCode.RightControl then
		State.esp.enabled = not State.esp.enabled
	end
end)

---------------------------------------------------------------
-- window dragging
---------------------------------------------------------------

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
	local moveConnection
	local endConnection

	area.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragStart = input.Position
		startPosition = window.Position

		if moveConnection then
			moveConnection:Disconnect()
			moveConnection = nil
		end
		if endConnection then
			endConnection:Disconnect()
			endConnection = nil
		end

		moveConnection = UserInputService.InputChanged:Connect(function(change)
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

		endConnection = UserInputService.InputEnded:Connect(function(change)
			if change.UserInputType == Enum.UserInputType.MouseButton1
				or change.UserInputType == Enum.UserInputType.Touch then
				if moveConnection then
					moveConnection:Disconnect()
					moveConnection = nil
				end
				if endConnection then
					endConnection:Disconnect()
					endConnection = nil
				end
			end
		end)
	end)
end

makeDragArea(0, 268)
makeDragArea(616, 144)

---------------------------------------------------------------
-- responsive rebinding
---------------------------------------------------------------

local cameraConnection

local function bindCamera()
	if cameraConnection then
		cameraConnection:Disconnect()
		cameraConnection = nil
	end

	local camera = workspace.CurrentCamera
	if camera then
		cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshLayout)
	end

	refreshLayout()
end

bindCamera()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)

---------------------------------------------------------------
-- boot
---------------------------------------------------------------

activate(subEntries[3])
showPage("settings", false)
setMenu(true)
