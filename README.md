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
// Content goes into contentView, like in UIVisualEffectView
let perspectiveView = PerspectiveView(config: .widgetAnimatable)
perspectiveView.contentView.addSubview(widgetPreview)

// Tilt off and on with a transition
perspectiveView.setTilted(false, animated: true)
perspectiveView.setTilted(true, animated: true)

// Without animation
perspectiveView.isTilted = false
```

### Config

```swift
// .widgetStatic tilts without animation. Every value is configurable
var config = PerspectiveConfig.widgetAnimatable
config.angle = 14
config.corner = .topLeft
config.animation = PerspectiveAnimation(duration: 10, direction: .counterclockwise)
config.shadow?.opacity = 0.4
```
