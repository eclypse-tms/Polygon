<p align="center">
  <img width="150" height="150" src="./assets/polygon_app_icon.svg">
</p>

<p align="center">
    <img src="https://img.shields.io/badge/SwiftUI-15+-green?logo=swift" alt="Swift 5.x">
    <img src="https://img.shields.io/badge/UIKit-15+-orange?logo=uikit" alt="UIKit">
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" alt="MIT License">
</p>

# Polygon 
Draws an equilateral polygon of any side within any SwiftUI or UIView. Extremely simply API. An example of polygons from triangle to 16-sided-polygon.

<p align="center">
  <img src="./assets/hero_image.jpg" width="454.5" height="326.5">
</p>

## Polygon Usage - SwiftUI

```
var body: some View {
  Polygon(numberOfSides: 5, // draws a pentagon
          fillColor: .green, // the color to fill the polygon width
          rotationAngle: Angle(degrees: 30), // rotate the shape in any angle
          borderWidth: 2,
          borderColor: .black)
}
```

## Polygon Usage - UIKit
```
let pentagon = UIPolygon()
pentagon.fillColor = UIColor.green // the color to fill the polygon width
pentagon.numberOfSides = 5 // draws a pentagon
pentagon.rotationAngle = 30 // rotate the shape in any angle between -179° thru 180°
pentagon.borderWidth = 2
// Add the polygon to a view
```

## Result
<p align="center">
    <img src="./assets/demo.jpg" width="531" height="176.5"  alt="polygon preview">
</p>


## Installation (iOS, watchOS, tvOS, macCatalyst)

### Swift Package Manager 
Add Polygon to your project via Swift Package Manager.

`https://github.com/eclypse-tms/Polygon`

### Manually
Drop the [source files](https://github.com/eclypse-tms/Polygon/tree/version_1/Sources/Polygon) into your project.




## Animatable Polygon Variation for UIKit

The library includes another variation called `AnimatableUIPolygon`. You can freely use one or the other according to your needs. AnimatablePolygon works exactly the same way as the vanilla Polygon except that it draws its shape on a sublayer. This opens up the possibility of applying any CAAnimation on that sublayer. 

```
let pentagon = AnimatableUIPolygon()
pentagon.backgroundColor = .systemGray5 //optional background color
pentagon.fillColor = UIColor.green // the color to fill the polygon width
pentagon.numberOfSides = 5 // draws a pentagon
pentagon.rotationAngle = 30 // rotate the shape in any angle between -179° thru 180°
pentagon.borderWidth = 2
// Add the polygon to a view

//create an animation
let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
opacityAnimation.fromValue = Float(1.0)
opacityAnimation.toValue = Float(0.0)
opacityAnimation.duration = 0.5
pentagon.apply(animation: opacityAnimation)
```

<p align="center">
    <img src="./assets/animatable_polygon_demo.gif" alt="polygon hiding">
</p>

## Polygons in SwiftUI are animatable 
In SwiftUI, the Polygon class implements Shape protocol - which makes it animatable.

