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

`PerspectiveView` is a container, like `UIVisualEffectView`. Put the content into its `contentView`: it tilts and casts the shadow, while `PerspectiveView` keeps its frame.

```swift
let perspectiveView = PerspectiveView(config: .widgetAnimatable)
perspectiveView.contentView.addSubview(widgetPreview)
```

### Tilt On and Off

Lift the view off the page and lay it back down, like a card. On tilt it pops toward the viewer and settles into the tilt. On the way back it levels out in the air and lands without a bounce:

```swift
let perspectiveView = PerspectiveView(config: .widgetAnimatable, isTilted: false)
perspectiveView.setTilted(true, animated: true)
perspectiveView.setTilted(false, animated: true)
```

`isTilted` changes the state without animation. A transition can be interrupted at any moment: the next one starts from the current frame. With Reduce Motion the view doesn't pop.

### Config

`.widgetStatic` tilts without animation. Every value is configurable:

```swift
var config = PerspectiveConfig.widgetAnimatable
config.angle = 14
config.corner = .topLeft
config.animation = PerspectiveAnimation(duration: 10, direction: .counterclockwise)
config.shadow?.opacity = 0.4
```
