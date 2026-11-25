# OPUS client v1.8 — interface, modules and effects

A Roblox `LocalScript` that rebuilds the OPUS menu from the reference
screenshot: frameless dark window, module tree on the left, settings cards in
the middle, live preview panel on the right — plus working modules, two
languages and a set of animated effects.

The FNaF-style characters from the screenshot are **not** part of the rebuild.

## Files

| File | Purpose |
| --- | --- |
| `OpusClient.lua` | The whole client. Paste into a `LocalScript`. |
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
| `RightControl` | Show / hide the ESP |
| `Escape` | Close the menu |
| Top bar / floating disc | Drag anywhere; the disc snaps to the nearest edge |
| `Поиск...` | Filters both sidebar lists live |
| `Modules` header | Collapse / expand the module tree |
| `+ Настройки` | Collapse / expand the settings list |
| `×` in the top bar | Close the menu (the floating disc brings it back) |

## Tabs — all of them do something

| Tab | What it actually does |
| --- | --- |
| **ESP** | Live player boxes: boxes, names, health bars, distance, team check, fill, line thickness, range. The counter shows how many players are currently in range. |
| **Visuals** | Watermark and FPS counter render on screen; the smoothness slider re-times every animation in the menu. |
| **Разное** | Floating button on/off, background blur on/off, animations on/off, reset everything. |
| **Образы** | Eight gradient presets repaint the menu background live, plus a reset. |
| **Музыка** | Sound ID field, volume, play/pause and a 26-bar visualizer that only animates while playing. |
| **Config** | Named profiles: save, load, delete — stored for the session and restored with one tap. |
| **Games** | Compatibility list with supported / testing badges. |
| **Настройки** | Menu background photo (ID + transparency + apply/reset), language, effects, window transparency. |
| **Дополнения** | Four addon switches. |
| **Themes** | Accent colour (recolours the entire menu), corner radius and window transparency. |

## Language

Russian and English everywhere — the top-bar `RU | EN` pill or **Настройки →
Язык**. Every label, placeholder, breadcrumb, badge and toast is bound to a
key, so switching is instant and needs no reload.

## Effects

* Window fades and springs in / out through a `CanvasGroup` + `UIScale`.
* Sidebar, pages and preview slide in with a short stagger.
* Background blur fades in with the menu (`Lighting.BlurEffect`).
* Search, toggles, sliders, list rows and swatches all tween.
* The preview photo has a slow breathing halo; the floating disc has a
  pulsing accent ring.
* Toasts slide in bottom-right for every action.
* Every animation routes through one helper, so the smoothness slider and the
  animations toggle govern all of them at once.

## Auto sizing

The layout is designed at 1180 × 580 and a `UIScale` fits it to the live
viewport at 94 % coverage, clamped 0.3 – 1.2. It re-reads the viewport on
rotation and on camera changes, and re-clamps the window and the floating
button so nothing is ever stranded off-screen.

## What was read off the screenshot

* **Window** — 1180 × 580, 14 px radius, `rgb(12,12,15)` at 32 % transparency,
  1 px `rgb(88,88,100)` border, black 45 % dim behind it.
* **Top bar** (70 px) — 32 px dark disc logo with a hollow rotated diamond,
  `OPUS` in Gotham Bold 18, `client v1.8` in Gotham Medium 13, 334 × 38 pill
  search field at x = 276 with a drawn magnifier, right-aligned captions.
* **Sidebar** (206 px) — `◆ Modules` header, 1 px tree guide at x = 33, five
  30 px rows (ESP, Visuals, Разное, Образы, Музыка), `+ Настройки` pill at
  y = 288, six 28 px sub rows beneath it.
* **Content** (595 px at x = 224) — back chevron, `Settings / Settings /
  Фон меню` breadcrumb, two cards (57 px and 79 px) with 15 px labels and
  right-aligned fields, 4 px slider track with a 14 px thumb at 0.3.
* **Preview** (306 × 503 at x = 862) — `rgb(24,24,29)` panel, pink photo pill
  at the slider's opacity, pink wireframe boxes.
* Chevrons are drawn from two rotated bars, so they never depend on a font
  glyph.

## Known limits

* Profiles live in memory only — plain Roblox has no writable filesystem from
  a `LocalScript`.
* The Music tab plays whatever asset ID you paste in; no audio is bundled, and
  the visualizer runs on a sine wave rather than real waveform data.
* `CanvasGroup` requires a reasonably recent Roblox client.
