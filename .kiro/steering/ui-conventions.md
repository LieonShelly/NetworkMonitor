---
inclusion: fileMatch
fileMatchPattern: "**/*.swift"
---

# UI Conventions for SwiftUI Views

When generating SwiftUI views (especially from Figma designs), always use the project's existing design system from the `UIComponent` module. Never use raw `Color(red:green:blue:)`, `Font.custom()`, or hardcoded hex values directly.

## Import

Always import `UIComponent` in SwiftUI view files:
```swift
import UIComponent
```

## Colors — Use `AppColor`

Reference: `#[[file:core/UIComponent/Source/Color/AppColor.swift]]`

| Figma Token | Swift Usage |
|---|---|
| `#000000` / black | `AppColor.black` |
| `#FFFFFF` / white | `AppColor.white` |
| `#FFFDF8` / oat / background | `AppColor.oat` or `AppColor.backgroundPage` |
| `#323232` / grey dark | `AppColor.greyDark` |
| `#6F6F6F` / grey medium | `AppColor.greyMedium` |
| `#B8B8B8` / grey | `AppColor.grey` |
| `#CDCDCD` / grey neutral | `AppColor.greyNeutral` |
| `#EBEBEB` / grey light | `AppColor.greyLight` |
| Text primary color | `AppColor.textPrimary` |
| Custom hex color | `AppColor.color(hex: 0xRRGGBB)` |

## Fonts — Use `AppFont` enum and `.textStyle()` modifier

Reference: `#[[file:core/UIComponent/Source/Font/Font.swift]]` and `#[[file:core/UIComponent/Source/TextStyle.swift]]`

### Semantic Font Tokens (preferred)

| Figma Text Style | Swift Usage |
|---|---|
| Heading (The Little Things 02, 24px) | `.textStyle(font: .heading)` |
| Title (The Little Things 02, 18px) | `.textStyle(font: .title)` |
| Section (The Little Things 02, 14px) | `.textStyle(font: .section)` |
| Body (Poppins, 14px) | `.textStyle(font: .body)` |
| Body Bold (Poppins Bold, 14px) | `.textStyle(font: .bodyBold)` |
| SubTitle (Poppins, 16px) | `.textStyle(font: .subTitle)` |
| Caption (Poppins, 12px) | `.textStyle(font: .caption)` |
| Annotation (IBM Plex Mono, 12px) | `.textStyle(font: .annotation)` |

### With custom color

```swift
Text("HISTORY")
    .textStyle(font: .annotation, color: AppColor.greyMedium)
```

### Custom size with font family

```swift
Text("Custom")
    .textStyle(size: 20, color: AppColor.greyDark, fontFamily: .littleThing)
```

### Available `AppFontType` values for `.textStyle(size:color:fontFamily:)`

| Font Family | `AppFontType` value |
|---|---|
| The Little Things 02 | `.littleThing` |
| Poppins Regular | `.poppinsRegular` |
| Poppins Bold | `.poppinsBold` |
| IBM Plex Mono | `.ibmPlexMonoRegular` |
| SF Pro | `.sfProRegular` / `.sfProMedium` / `.sfProBold` |
| Vividly | `.vividlyRegular` |
| DS Digital | `.dsDigital` |

## Background

Use the `.defaultBackground()` modifier for the standard page background:
```swift
SomeView()
    .defaultBackground()
```

## Figma-to-Code Mapping

When translating Figma designs:
- Figma `fontFamily: "The Little Things 02"` → `fontFamily: .littleThing`
- Figma `fontFamily: "Poppins"` → `fontFamily: .poppinsRegular`
- Figma `fontFamily: "IBM Plex Mono"` → `fontFamily: .ibmPlexMonoRegular`
- Figma fill `oat` or `#FFFDF8` → `AppColor.oat`
- Figma fill `grey dark` or `#323232` → `AppColor.greyDark`
- Figma fill `grey medium` or `#6F6F6F` → `AppColor.greyMedium`
