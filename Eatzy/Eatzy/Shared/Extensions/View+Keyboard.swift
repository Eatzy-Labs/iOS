//
//  View+Keyboard.swift
//  Eatzy
//

import SwiftUI

extension View {
    func hideKeyboardOnBackgroundTap() -> some View {
        background {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
