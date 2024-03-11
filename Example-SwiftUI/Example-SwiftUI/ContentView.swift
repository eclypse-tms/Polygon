//
//  ContentView.swift
//  Example-SwiftUI
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI
import Polygon

struct ContentView: View {
    @State private var selectedRenderingOption = 1
    @State private var selectedTileablePolygon = DemoPolygons.square
    @State private var selectedPolygonSize = PolygonSize.horizontalTarget
    @State private var specifiedFixedWidth = String(Int(PolygonSize.fixedWidth.defaultWidth))
    @State private var specifiedHorizontalTarget = String(Int(PolygonSize.horizontalTarget.defaultWidth))
    
    @State private var singleOrMultiColorSelection = 1
    @State private var specifiedSingleColor = Color.blue
    @State private var specifiedColorPalette = ColorPalette.viridis
    @State private var specifiedStaggerEffect = 0.0
    @State private var specifiedInterTilingSpace = 2.0
    
    let lightGray = Color(white: 0.85)
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            HStack {
                Spacer()
                    .frame(width: .infinity)
                Picker("", selection: $selectedRenderingOption, content: {
                    Text("Individual Polygons").tag(0)
                    Text("Tiled Polygons").tag(1)
                })
                .pickerStyle(.segmented)
                Spacer()
                    .frame(width: .infinity)
            }
            
            if selectedRenderingOption == 0 {
                individualPolygons()
            } else {
                tiledPolygons()
            }
        }.padding()
            .refreshable(action: {
                
            })
    }
    
    private func tiledPolygons() -> some View {
        
        
        let stack = ZStack(alignment: .bottomTrailing, content: {
            polygonBuilder()
            
            HStack {
                Spacer()
                    .frame(width: .infinity)
                HStack {
                    VStack(alignment: .center, spacing: 12, content: {
                        shapeSelector
                        
                        polygonSizeSelector
                        
                        paddingSelector
                        
                        singleOrMultiColorSelector
                        
                        colorPickerSelector
                        
                        //hexagon shape doesn't support stagger
                        if selectedTileablePolygon != .hexagon {
                            staggeringEffectSelector
                        }
                    })
                    .padding(8)
                    .background(Color.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(8)
            }
        })
        return stack
    }
    
    private func polygonBuilder() -> some View {
        let backgroundColor = Color(white: 0.85) //light gray
        
        let polygonKind: any TileablePolygonKind
        
        switch selectedTileablePolygon {
        case .equilateralTriangle:
            polygonKind = EquilateralTriangle(yAxisStagger: specifiedStaggerEffect)
        case .square:
            polygonKind = Square(yAxisStagger: specifiedStaggerEffect)
        case .hexagon:
            polygonKind = Hexagon()
        case .octagon:
            polygonKind = Octagon(yAxisStagger: specifiedStaggerEffect)
        }
        
        var resultingTiledPolygon = TiledPolygon()
            .kind(polygonKind)
            .interTileSpacing(specifiedInterTilingSpace)
        
        switch singleOrMultiColorSelection {
        case 0: //single color
            resultingTiledPolygon = resultingTiledPolygon.fillColor(specifiedSingleColor)
        default:
            resultingTiledPolygon = resultingTiledPolygon.fillColorPattern(specifiedColorPalette.associatedPalette)
        }
        
        switch selectedPolygonSize {
        case .fixedWidth:
            let parsedValue: CGFloat = Double(specifiedFixedWidth) ?? .zero
            resultingTiledPolygon = resultingTiledPolygon.polygonSize(TileablePolygonSize(fixedWidth: parsedValue))
        case .horizontalTarget:
            let parsedValue: CGFloat = Double(specifiedHorizontalTarget) ?? .zero
            resultingTiledPolygon = resultingTiledPolygon.polygonSize(TileablePolygonSize(horizontalPolygonTarget: parsedValue))
        }
        return resultingTiledPolygon
            .background(backgroundColor)
    }
    
    private var paddingSelector: some View {
        HStack {
            Text("Tile padding")
            Spacer()
                .frame(minWidth: 1)
            Slider(value: $specifiedInterTilingSpace,
                   in: 0...8,
                   step: 1.0,
                   label: {
                Text("Tile padding")
            }, minimumValueLabel: {
                Text("0")
            }, maximumValueLabel: {
                Text("8")
            }, onEditingChanged: { _ in
                renderTiledPolygons()
            }).frame(minWidth: 200)
        }
    }
    
    private var staggeringEffectSelector: some View {
        HStack {
            Text("Stagger effect")
            Spacer()
                .frame(minWidth: 1)
            Slider(value: $specifiedStaggerEffect,
                   in: 0...64,
                   step: 4.0,
                   label: {
                Text("Inter tiling space")
            }, minimumValueLabel: {
                Text("0")
            }, maximumValueLabel: {
                Text("64")
            }, onEditingChanged: { _ in
                renderTiledPolygons()
            }).frame(minWidth: 200)
        }
    }
    
    private var colorPickerSelector: some View {
        HStack {
            switch singleOrMultiColorSelection {
            case 0:
                ColorPicker<Text>("Pick Color", selection: $specifiedSingleColor)
            default:
                Text("Pick a palette")
                Spacer()
                    .frame(width: .infinity)
                Picker("Pick a palette", selection: $specifiedColorPalette, content: {
                    ForEach(ColorPalette.allCases, content: { eachPalette in
                        Text(eachPalette.displayName)
                    })
                })
                .pickerStyle(.automatic)
                .onSubmit {
                    renderTiledPolygons()
                }
            }
        }
    }
    
    private var shapeSelector: some View {
        HStack {
            Text("Shape")
            Spacer()
            Picker("Tileable Polygon Type", selection: $selectedTileablePolygon, content: {
                ForEach(DemoPolygons.allCases, content: { eachPolygon in
                    Text(eachPolygon.displayName)
                })
            }).pickerStyle(.menu)
                .onSubmit {
                    renderTiledPolygons()
                }
        }
    }
    
    private var singleOrMultiColorSelector: some View {
        HStack {
            Text("Coloring")
            Spacer()
                .frame(width: .infinity)
            Picker("Coloring", selection: $singleOrMultiColorSelection, content: {
                Text("Single").tag(0)
                Text("Multi").tag(1)
            })
            .pickerStyle(.segmented)
                .onSubmit {
                    renderTiledPolygons()
                }
        }
    }
    
    private var polygonSizeSelector: some View {
        HStack(spacing: 8, content: {
            Text("Size")
            Spacer()
                .frame(maxWidth: 40)
            Picker("Polygon Size", selection: $selectedPolygonSize, content: {
                ForEach(PolygonSize.allCases, content: { eachSizeOption in
                    Text(eachSizeOption.displayName)
                })
            })
            .pickerStyle(.segmented)
            .frame(alignment: .trailing)
            
            switch selectedPolygonSize {
            case .fixedWidth:
                TextField(text: $specifiedFixedWidth, label: {
                    Text("Width")
                })
                .border(.tertiary)
                .keyboardType(.numberPad)
                .onSubmit {
                    self.renderTiledPolygons()
                }.frame(width: 48)
            default:
                TextField(text: $specifiedHorizontalTarget, label: {
                    Text("Width")
                })
                .border(.tertiary)
                .keyboardType(.numberPad)
                .onSubmit {
                    self.renderTiledPolygons()
                }.frame(width: 48)
            }
        }).frame(alignment: .trailing)
    }
    
    private func renderTiledPolygons() {
        
    }
    
    private func individualPolygons() -> some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()
            HStack {
                Polygon(numberOfSides: 3, rotationAngle: Angle(degrees: 30))
                    .background(lightGray)
                Polygon(numberOfSides: 4, rotationAngle: Angle(degrees: 45))
                    .background(lightGray)
                Polygon(numberOfSides: 5, rotationAngle: Angle(degrees: -18))
                    .background(lightGray)
                Polygon(numberOfSides: 6)
                    .background(lightGray)
                Polygon(numberOfSides: 7, rotationAngle: Angle(degrees: -90))
                    .background(lightGray)
                Polygon(numberOfSides: 8)
                    .background(lightGray)
                Polygon(numberOfSides: 9)
                    .background(lightGray)
            }.frame(maxHeight: 240)
            HStack {
                Polygon(numberOfSides: 10)
                    .background(lightGray)
                Polygon(numberOfSides: 11)
                    .background(lightGray)
                Polygon(numberOfSides: 12)
                    .background(lightGray)
                Polygon(numberOfSides: 13)
                    .background(lightGray)
                Polygon(numberOfSides: 14)
                    .background(lightGray)
                Polygon(numberOfSides: 15)
                    .background(lightGray)
                Polygon(numberOfSides: 16)
                    .background(lightGray)
            }.frame(maxHeight: 240)
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
