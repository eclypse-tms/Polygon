<p align="center">
  <img width="150" height="150" src="./assets/polygon_app_icon.svg">
</p>

<p align="center">
    <img src="https://img.shields.io/badge/UIKit-darkslategray?logo=uikit" alt="UIKit">
    <img src="https://img.shields.io/badge/SwiftUI-darkslategray?logo=swift" alt="SwiftUI">
	<img src="https://img.shields.io/badge/iOS-15+-blue" alt="SwiftUI">
	<img src="https://img.shields.io/badge/macOS-12+-blue" alt="SwiftUI">
</p>

# Polygon 
Draws an equilateral polygon of any side within any SwiftUI or UIView. Extremely simply API. Here is an example of individual polygons from triangle to 16-sided-polygon.

<p align="center">
  <img src="./assets/hero_image.jpg" width="454.5" height="326.5">
</p>

<br/>

## ... or you can tile them
<p align="center">
  <img src="./assets/tileable_polygons_demo.gif" width="600" height="410">
</p>

<br/>

## Polygon Usage - SwiftUI

#### Single polygon

```
var body: some View {
  Polygon(numberOfSides: 5, // draws a pentagon
          fillColor: .green, // the color to fill the polygon width
          rotationAngle: Angle(degrees: 30), // rotate the shape in any angle
          borderWidth: 2,
          borderColor: .black)
}
```

#### Tiled Polygons
```
var body: some View {
  TiledPolygon()
     .kind(Hexagon())
     .interTileSpacing(2) // space between adjacent tiles
     .fillColorPattern(Color.viridisPalette) //apply multi color
     .polygonSize(TileablePolygonSize(fixedWidth: 64) //size of each tile
     .background(Color.gray) // inter-tiling color
}

```

## Polygon Usage - UIKit

#### Single Polygon
```
let pentagon = UIPolygon()
pentagon.fillColor = UIColor.green // the color to fill the polygon width
pentagon.numberOfSides = 5 // draws a pentagon
pentagon.rotationAngle = 30 // rotate the shape in any angle between -179° thru 180°
pentagon.borderWidth = 2
```

#### Tiled Polygons

```
let tiledPolygon = UITiledPolygon()
tiledPolygon.tileablePolygonKind = Hexagon() //tile hexagons
tiledPolygon.interTileSpacing = 2.0 // space between adjacent tiles      
tiledPolygon.polygonSize = TileablePolygonSize(fixedWidth: 64) //size of each tile
tiledPolygon.backgroundColor = .systemGray5 // inter-tiling color
```

## Installation (iOS, macOS, macCatalyst)

### Swift Package Manager 
Add Polygon to your project via Swift Package Manager.

`https://github.com/eclypse-tms/Polygon`


### Manually
Drop the [source files](https://github.com/eclypse-tms/Polygon/tree/version_1/Sources/Polygon) into your project.


## Works in iOS, macOS and macCatalyst out of the box
* Polygon library supports iOS 15 and above with UIKit and SwiftUI. 
	- Either import UIKit or SwiftUI - depending on your app
* Polygon also support macOS 12 and above via SwiftUI.
	- Import SwiftUI into your AppKit based app with the help of NSHostingView or NSHostingController
* We included 2 example apps - one for [SwiftUI](./Example-SwiftUI) and one for [UIKit](./Example-UIKit). Check them out.

<br/>


## Breaking Change with version 2
Since we added support for SwiftUI, previously named `Polygon` class has been renamed to `UIPolygon` to follow the UIKit's naming convention. The class name `Polygon` is now used for SwiftUI variation.

## Breaking Change with version 3
Now all UIPolygons are animatable.


## How to Animate Polygons in UIKit

UIPolygon is animatable since it draws its shape on a layer. We can apply any CAAnimation on a polygon such as this: 

```
let pentagon = UIPolygon()
pentagon.backgroundColor = .systemGray5 //optional background color
pentagon.fillColor = UIColor.green // the color to fill the polygon width
pentagon.numberOfSides = 5 // draws a pentagon
... other code

//create a fade-out animation
let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
opacityAnimation.fromValue = Float(1.0)
opacityAnimation.toValue = Float(0.0)
opacityAnimation.duration = 0.5
pentagon.apply(animation: opacityAnimation)
```

<p align="center">
    <img src="./assets/animatable_polygon_demo.gif" alt="polygon hiding">
</p>

<br/>

## Polygons in SwiftUI are animatable 
In SwiftUI, the Polygon class conforms to the `Shape` protocol - which makes them animatable.


