//
//  SplashLottieView.swift
//  Eatzy
//
//  Created by sun on 10/7/26.
//

import Lottie
import SwiftUI

struct SplashLottieView: UIViewRepresentable {
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: "splash")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        return animationView
    }

    func updateUIView(_ animationView: LottieAnimationView, context: Context) {
        guard !animationView.isAnimationPlaying else { return }
        animationView.play()
    }
}
