//
//  EatzyToggle.swift
//  Eatzy
//

import SwiftUI

struct EatzyToggle: View {
    @Binding private var isOn: Bool

    init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.1)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? Color.orange500 : Color.gray700)

                RoundedRectangle(cornerRadius: 100)
                    .fill(.coreWhite)
                    .frame(width: 36, height: 24)
                    .padding(2)
            }
            .frame(width: 60, height: 28)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

