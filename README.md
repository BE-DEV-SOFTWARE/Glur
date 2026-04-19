# Glur

A small SwiftUI package for **beautiful progressive blur** on your views. It uses **Metal** (no **CIFilter**, no **private APIs**) and exposes a **simple, SwiftUI-first API**: a `UnitPoint` anchor, sizes in **points**, and one modifier—`.glur(...)`.

## Installation

Add the package in Xcode (**File → Add Package Dependencies…**), then `import Glur`.

> [!NOTE]  
> The Metal path is used on **iOS 17+**, **macOS 14+**, and **tvOS 17+**. Older OS versions use a simpler compatibility blur. **watchOS** always uses the compatibility path.

## API (`View.glur`)


| Parameter         | Required            | Description                                                                                                                     |
| ----------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `startingPoint`   | yes                 | `UnitPoint` anchor on the layer: `(x * layerWidth, y * layerHeight)` in points (`x`/`y` may be outside 0…1; result is clipped). |
| `direction`       | yes                 | `GlurDirection`: how the `width` × `height` rectangle is placed from that anchor (see below).                                   |
| `width`, `height` | yes                 | Non-negative **points** for the blur region, relative to the **same** view the modifier measures.                               |
| `radius`          | no (default `8`)    | Blur strength inside the region.                                                                                                |
| `spread`          | no (default `0.07`) | Edge softness in normalized layer space (`0` = sharp; larger = softer transition).                                              |
| `noise`           | no (default `0.1`)  | Grain inside the blurred region.                                                                                                |
| `drawingGroup`    | no (default `true`) | Use `drawingGroup()` before the shader path.                                                                                    |


### `GlurDirection`

- `**.center`** — region centered on the anchor.  
- `**.up` / `.down**` — anchor on the bottom or top **edge midpoint**; grows up or down; `width` centered on `x`.  
- `**.left` / `.right`** — anchor on the right or left **edge midpoint**; grows sideways; `height` centered on `y`.  
- `.upLeft` **/** `.upRight` **/** `.downLeft` **/** `.downRight` — corner-anchored rectangles.

### Examples

```swift
.glur(
    startingPoint: UnitPoint(x: 0.5, y: 0.7),
    direction: .down,
    width: 320,
    height: 96
)

.glur(startingPoint: .center, direction: .center, width: 400, height: 300)

.glur(startingPoint: .bottomTrailing, direction: .downRight, width: 200, height: 120)
```

> [!WARNING]  
> In the **iOS Simulator**, SwiftUI layer shaders may not appear if the layer is larger than **~545 pt** on an edge; devices are usually fine.

## How it works

Metal stitchable blur + optional noise via SwiftUI’s **Shader** API. Blur strength follows a soft **rectangle** in the shader (with `spread` for the edge falloff). Works best on pure SwiftUI content; see Apple’s Shader/layer limitations.

- [Original proof of concept](https://twitter.com/joogps/status/1667240291869270032)  
- [Shader API](https://developer.apple.com/documentation/swiftui/shader)  
- [Metal + SwiftUI tutorial (Cindori)](https://cindori.com/developer/swiftui-shaders-wave)

## Demo

Open **GlurDemo** in Xcode and run it on a simulator or device.

---

## Fork & maintainer

This repository is a **fork** of [Glur](https://github.com/joogps/Glur) by **João Gabriel Pozzobon dos Santos**. It keeps the same spirit—fast, good-looking progressive blur—while extending placement (e.g. `UnitPoint`, point sizes, corners, and `spread`) for more control over *where* the blur appears.

Maintained by Jonathan Bereyziat from **[Be-Dev](https://be-dev.ch)** · [jonathan@be-dev.ch](mailto:jonathan@be-dev.ch)