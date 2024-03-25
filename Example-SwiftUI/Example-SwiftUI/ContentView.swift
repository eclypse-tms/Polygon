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
    @State private var selectedTileablePolygon = TileablePolygonType.hexagon
    @State private var selectedPolygonSize = PolygonSize.horizontalTarget
    @State private var specifiedFixedWidth = String(Int(PolygonSize.fixedWidth.defaultWidth))
    @State private var specifiedHorizontalTarget = String(Int(PolygonSize.horizontalTarget.defaultWidth))
    
    @State private var singleOrMultiColorSelection = 0
    @State private var specifiedSingleColor = Color.blue
    @State private var specifiedColorPalette = ColorPalette.viridis
    @State private var specifiedStaggerEffect = 0.0
    @State private var specifiedInterTilingSpace = 2.0
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer(minLength: 1)
            HStack {
                Spacer()
                    .frame(minWidth: 1, maxWidth: 4096)
                Picker("", selection: $selectedRenderingOption, content: {
                    Text("Individual Polygons").tag(0)
                    Text("Tiled Polygons").tag(1)
                })
                .pickerStyle(.segmented)
                Spacer()
                    .frame(minWidth: 1, maxWidth: 4096)
            }
            
            if selectedRenderingOption == 0 {
                individualPolygons()
            } else {
                tiledPolygons()
            }
        }.padding(0)
    }
    
    private func tiledPolygons() -> some View {
        let stack = ZStack(alignment: .bottomTrailing, content: {
            polygonBuilder()
            tilingControlPanel()
        })
        return stack
    }
    
    private func tilingControlPanel() -> some View {
        HStack {
            Spacer()
                .frame(minWidth: 1)
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
                .background(Color.background)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(8)
        }
    }
    
    private func polygonBuilder() -> some View {
        let backgroundColor = (colorScheme == .dark) ? Color(white: 0.15) : Color(white: 0.85)
        
        let polygonKind: any TileablePolygonKind
        
        switch selectedTileablePolygon {
        case .equilateralTriangle:
            polygonKind = EquilateralTriangle()
        case .square:
            polygonKind = Square()
        case .hexagon:
            polygonKind = Hexagon()
        case .octagon:
            polygonKind = Octagon()
        case .rectangle:
            polygonKind = Rectangle(widthToHeightRatio: 0.5)
        }
        
        var resultingTiledPolygon = TiledPolygon()
            .kind(polygonKind)
            .interTileSpacing(specifiedInterTilingSpace)
            .staggerEffect(StaggerEffect(specifiedStaggerEffect))
        
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
            .padding(0)
    }
    
    private var paddingSelector: some View {
        HStack {
            Text("Tile padding")
            Spacer()
                .frame(minWidth: 20)
            Slider(value: $specifiedInterTilingSpace,
                   in: 0...8,
                   step: 1.0,
                   label: {
                Text("")
            }, minimumValueLabel: {
                Text("0")
            }, maximumValueLabel: {
                Text("8")
            }, onEditingChanged: { _ in
                reactToChange()
            }).frame(minWidth: 200)
        }
    }
    
    private var staggeringEffectSelector: some View {
        HStack {
            Text("Stagger effect")
            Spacer()
                .frame(minWidth: 1)
            Slider(value: $specifiedStaggerEffect,
                   in: 0.0...1.0,
                   step: 0.05,
                   label: {
                Text("")
            }, minimumValueLabel: {
                Text("0%")
            }, maximumValueLabel: {
                Text("100%")
            }, onEditingChanged: { _ in
                reactToChange()
            }).frame(minWidth: 200)
        }
    }
    
    private var colorPickerSelector: some View {
        HStack {
            switch singleOrMultiColorSelection {
            case 0:
                Text("Pick Color")
                Spacer()
                    .frame(minWidth: 1)
                ColorPicker<Text>("", selection: $specifiedSingleColor)
            default:
                Text("Pick a palette")
                Spacer()
                    .frame(minWidth: 1)
                Picker("", selection: $specifiedColorPalette, content: {
                    ForEach(ColorPalette.allCases, content: { eachPalette in
                        Text(eachPalette.displayName)
                    })
                })
                .pickerStyle(.automatic)
                .onSubmit {
                    reactToChange()
                }
            }
        }
    }
    
    private var shapeSelector: some View {
        HStack {
            Text("Shape")
            Spacer()
                .frame(minWidth: 1)
            Picker("", selection: $selectedTileablePolygon, content: {
                ForEach(TileablePolygonType.allCases, content: { eachPolygon in
                    Text(eachPolygon.displayName)
                })
            }).pickerStyle(.menu)
                .onSubmit {
                    reactToChange()
                }
        }
    }
    
    private var singleOrMultiColorSelector: some View {
        HStack {
            Text("Coloring")
            Spacer()
                .frame(minWidth: 1)
            Picker("", selection: $singleOrMultiColorSelection, content: {
                Text("Single").tag(0)
                Text("Multi").tag(1)
            })
            .pickerStyle(.segmented)
                .onSubmit {
                    reactToChange()
                }
        }
    }
    
    private var polygonSizeSelector: some View {
        HStack(spacing: 8, content: {
            Text("Size")
            Spacer()
                .frame(minWidth: 1)
            Picker("", selection: $selectedPolygonSize, content: {
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
                //.keyboardType(.numberPad)
                .onSubmit {
                    self.reactToChange()
                }.frame(width: 48)
            default:
                TextField(text: $specifiedHorizontalTarget, label: {
                    Text("Width")
                })
                .border(.tertiary)
                //.keyboardType(.numberPad)
                .onSubmit {
                    self.reactToChange()
                }.frame(width: 48)
            }
        }).frame(alignment: .trailing)
    }
    
    private func reactToChange() {
        //nothing to do here
    }
    
    private func individualPolygons() -> some View {
        let tileBackground = (colorScheme == .dark) ? Color(white: 0.15) : Color(white: 0.85)
        let resultingStack = VStack(alignment: .center, spacing: 8) {
            Spacer()
            HStack {
                Polygon(numberOfSides: 3, rotationAngle: Angle(degrees: 30))
                    .background(tileBackground)
                Polygon(numberOfSides: 4, rotationAngle: Angle(degrees: 45))
                    .background(tileBackground)
                Polygon(numberOfSides: 5, rotationAngle: Angle(degrees: -18))
                    .background(tileBackground)
                Polygon(numberOfSides: 6)
                    .background(tileBackground)
                Polygon(numberOfSides: 7, rotationAngle: Angle(degrees: -90))
                    .background(tileBackground)
                Polygon(numberOfSides: 8)
                    .background(tileBackground)
                Polygon(numberOfSides: 9)
                    .background(tileBackground)
            }.frame(maxHeight: 240)
            HStack {
                Polygon(numberOfSides: 10)
                    .background(tileBackground)
                Polygon(numberOfSides: 11)
                    .background(tileBackground)
                Polygon(numberOfSides: 12)
                    .background(tileBackground)
                Polygon(numberOfSides: 13)
                    .background(tileBackground)
                Polygon(numberOfSides: 14)
                    .background(tileBackground)
                Polygon(numberOfSides: 15)
                    .background(tileBackground)
                Polygon(numberOfSides: 16)
                    .background(tileBackground)
            }.frame(maxHeight: 240)
            Spacer()
        }
        
        return resultingStack
    }
}

#Preview {
    ContentView()
}
