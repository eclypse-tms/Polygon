//
//  ContentView.swift
//  Example-SwiftUI
//
//  Created by Nessa Kucuk, Turker on 3/2/24.
//

import SwiftUI
import Polygon

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            HStack {
                Polygon(numberOfSides: 3, rotationAngle: Angle(degrees: 30))
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 4, rotationAngle: Angle(degrees: 45))
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 5, rotationAngle: Angle(degrees: -18))
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 6)
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 7, rotationAngle: Angle(degrees: -90))
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 8)
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 9)
                    .background(Color.init(uiColor: .systemGray5))
            }.frame(maxHeight: 240)
            HStack {
                Polygon(numberOfSides: 10)
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 11)
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 12)
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 13)
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 14)
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 15)
                    .background(Color.init(uiColor: .systemGray5))
                Polygon(numberOfSides: 16)
                    .background(Color.init(uiColor: .systemGray5))
            }.frame(maxHeight: 240)
            Spacer()
        }.padding()
    }
}

#Preview {
    ContentView()
}
