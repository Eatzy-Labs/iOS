//
//  EatzyCheckbox.swift
//  Eatzy
//

import SwiftUI

struct EatzyCheckbox: View {
    @Binding private var isChecked: Bool

    init(isChecked: Binding<Bool>) {
        self._isChecked = isChecked
    }

    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            ZStack {
                if isChecked {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.orange500)
                        .frame(width: 24, height: 24)

                    Image(.icCheck)
                        .frame(width: 24, height: 24)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.gray700, lineWidth: 1)
                        .frame(width: 20, height: 20)
                }
            }
            .frame(width: 24, height: 24)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

