//
//  ContentView.swift
//  Example-SwiftUI
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI
import Polygon

struct ContentView: View {
    @State private var selectedRenderType = 0
    let lightGray = Color(white: 0.85)
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Picker("", selection: $selectedRenderType, content: {
                Text("Individual Polygons").tag(0)
                Text("Tiled Polygons").tag(1)
            })
            .pickerStyle(.segmented)
            .frame(maxWidth: 300)
            
            if selectedRenderType == 0 {
                individualPolygons()
            } else {
                tiledPolygons()
            }
            
        }.padding()
    }
    
    private func tiledPolygons() -> some View {
        let backgroundColor = Color(white: 0.85) //light gray
        
        // configure the polygon
        let tiledPolygon = TiledPolygon()
            .kind(Hexagon())
            .interTileSpacing(4)
            .polygonSize(TilablePolygonSize(fixedWidth: 80))
            .background(backgroundColor)
            .padding(0)
        
        return tiledPolygon
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
        }.padding()
    }
}

#Preview {
    ContentView()
}
