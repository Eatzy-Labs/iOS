//
//  SplashView.swift
//  Eatzy
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.coreWhite
                .ignoresSafeArea()

            SplashLottieView()
                .aspectRatio(375.0 / 137.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
        }
    }
}
