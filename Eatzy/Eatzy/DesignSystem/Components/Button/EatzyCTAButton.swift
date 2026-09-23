//
//  EatzyCTAButton.swift
//  Eatzy
//

import SwiftUI

struct EatzyCTAButton: View {
    enum ButtonState {
        case active
        case inactive

        fileprivate var backgroundColor: Color {
            switch self {
            case .active:
                return .orange500
            case .inactive:
                return .gray400
            }
        }

        fileprivate var isEnabled: Bool {
            self == .active
        }
    }

    private let title: String
    private let state: ButtonState
    private let action: () -> Void

    init(
        _ title: String,
        state: ButtonState,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.state = state
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 10) {
                Text(title)
                    .applyEatzyFont(.button_18_m)
                    .foregroundStyle(.coreWhite)
            }
            .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .center)
            .background(state.backgroundColor)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!state.isEnabled)
    }
}
