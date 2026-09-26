//
//  MapPlaceSheetView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct MapPlaceSheetView: View {
    let store: StoreOf<MapPlaceSheetFeature>

    var body: some View {
        Color.coreWhite
            .ignoresSafeArea()
    }
}

struct MapSheetMinimumDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        min(480, context.maxDetentValue - 10)
    }
}

struct MapSheetMaximumDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        context.maxDetentValue - 10
    }
}

