//
//  SettingProfileCard.swift
//  Eatzy
//

import SwiftUI

struct SettingProfileCard: View {
    let userID: String
    let university: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ID: \(userID)")
                        .applyEatzyFont(.title_16_sb)
                        .foregroundStyle(.gray900)

                    Text(university)
                        .applyEatzyFont(.caption_12_m)
                        .foregroundStyle(.gray700)
                }

                HStack(spacing: 8) {
                    Text("Profile")
                        .applyEatzyFont(.body_14_m)
                        .foregroundStyle(.gray900)

                    Spacer(minLength: 0)

                    Image(.icChevronRight)
                        .renderingMode(.template)
                        .foregroundStyle(.gray500)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.coreWhite)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
