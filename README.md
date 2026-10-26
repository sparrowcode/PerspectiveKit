# PerspectiveKit

3D tilt with a dynamic shadow, like widget previews in iOS. SwiftUI & UIKit.

<img src="Assets/Readme/animated-preview.gif" width="300"/>

## Installation

In Xcode: File → Add Package Dependencies → paste URL:

```
https://github.com/sparrowcode/PerspectiveKit
```

## Usage

### SwiftUI

```swift
WidgetPreview()
    .perspective(.widgetAnimatable)
```

### UIKit

```swift
view.applyPerspective(.widgetAnimatable)
view.resetPerspective()
```

### Config

`.widgetStatic` tilts without animation. Every value is configurable:

```swift
var config = PerspectiveConfig.widgetAnimatable
config.angle = 14
config.corner = .topLeft
config.animation = PerspectiveAnimation(duration: 10, direction: .counterclockwise)
config.shadow?.opacity = 0.4
```

Run `Example/PerspectiveKitExample.xcodeproj` to tune values with sliders.
