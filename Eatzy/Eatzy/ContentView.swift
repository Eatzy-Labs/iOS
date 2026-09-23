//
//  ContentView.swift
//  Eatzy
//
//  Created by sun on 9/23/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(.typeCafeteria)
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .applyEatzyFont(.title_18_sb)
                .foregroundStyle(.blue500)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
