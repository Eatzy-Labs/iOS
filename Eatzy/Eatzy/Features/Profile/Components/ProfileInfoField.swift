//
//  ProfileInfoField.swift
//  Eatzy
//

import SwiftUI

struct ProfileInfoField: View {
    let value: String

    var body: some View {
        Text(value)
            .applyEatzyFont(.body_16_m)
            .foregroundStyle(.gray900)
            .padding(.leading, 20)
            .padding(.trailing, 12)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.coreWhite)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(.gray300, lineWidth: 1)
            }
    }
}

