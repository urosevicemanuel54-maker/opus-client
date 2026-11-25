# OPUS client v1.8 — interface recreation

A Roblox `LocalScript` that rebuilds the OPUS menu from the reference
screenshot: frameless dark window, module tree on the left, settings cards
in the middle, live preview panel on the right.

The FNaF-style characters from the screenshot are **not** part of the
rebuild — everything else (layout, spacing, colours, typography, slider,
fields, hover states) is measured off the image.

> This is the interface only. It contains no ESP, no aimbot and no game
> logic of any kind — every control is a mock so the menu can be dropped
> into a place and styled.

## Files

| File | Purpose |
| --- | --- |
| `OpusClient.lua` | The whole menu. Paste into a `LocalScript`. |
| `Loader.lua` | Optional one-liner loader (needs `loadstring`). |

## Usage

### Studio

1. `StarterPlayer` → `StarterPlayerScripts` → **+** → `LocalScript`
2. Rename it to `OpusClient`
3. Paste the contents of `OpusClient.lua`
4. Play

### Executor

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/urosevicemanuel54-maker/opus-client/main/OpusClient.lua"))()
```

The repository has to stay public for the raw URL to resolve.

## Controls

| Input | Action |
| --- | --- |
| `RightShift` | Show / hide the menu |
| `Escape` | Close the menu |
| Top bar | Drag the window |
| `Поиск...` | Filters both sidebar lists live |
| `Modules` header | Collapse / expand the module tree |
| `+ Настройки` | Collapse / expand the settings list |
| Slider | Drag it — the preview photo opacity follows |
| `ID фото или путь к файлу` | Editable field |

## What was read off the screenshot

* **Window** — 1180 × 580, 14 px radius, `rgb(12,12,15)` at 32 % transparency,
  1 px `rgb(88,88,100)` border, black 45 % dim behind it.
* **Top bar** (70 px) — 32 px dark disc logo with a hollow rotated diamond,
  `OPUS` in Gotham Bold 18, `client v1.8` in Gotham Medium 13
  `rgb(136,136,148)`, 334 × 38 pill search field at x = 276 with a drawn
  magnifier (circle + rotated 1.5 px handle), `Передпросмотр` /
  `Интеграция` right-aligned, hairline divider under the bar.
* **Sidebar** (206 px) — `◆ Modules` header with a 12 px chevron, 1 px tree
  guide at x = 33, five rows at 30 px each (ESP, Visuals, Разное, Образы,
  Музыка) with ring / dot / pause glyphs, `+ Настройки` pill at y = 288,
  six 28 px sub rows beneath it.
* **Content** (595 px at x = 224) — back chevron button, `Settings /
  Settings / Фон меню` breadcrumb in RichText, two cards (57 px and 79 px)
  each holding a 15 px label plus a right-aligned field, and a 4 px slider
  track with a 14 px white thumb sitting at 0.3.
* **Preview** (306 × 503 at x = 862) — `rgb(24,24,29)` panel, the pink photo
  `rgb(238,150,216)` pill at the slider's opacity, and wireframe boxes
  stroked in the same pink.
* Every chevron is drawn from two rotated bars rather than a font glyph so
  it renders identically on mobile and desktop.

## Responsive scaling

The window is fixed at 1180 × 580 internally and a `UIScale` shrinks it to
fit the viewport (clamped 0.4 – 1.1), so it stays proportional on phones,
tablets and desktops.
