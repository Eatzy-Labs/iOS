//
//  SettingLoginCard.swift
//  Eatzy
//

import SwiftUI

struct SettingLoginCard: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Login required")
                    .applyEatzyFont(.display_16_sb)
                    .foregroundStyle(.gray700)

                Text("Sign in to access profile features")
                    .applyEatzyFont(.body_14_r)
                    .foregroundStyle(.gray400)
            }

            EatzyCTAButton("Login / Sign Up", state: .active, action: action)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.coreWhite)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
