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
                .frame(width: 375, height: 137)
        }
    }
}
