//
//  EatzyButtonOption.swift
//  Eatzy
//

import SwiftUI

struct EatzyButtonOption: View {
    enum SelectionState {
        case selected
        case unselected

        fileprivate var foregroundColor: Color {
            switch self {
            case .selected:
                return .orange500
            case .unselected:
                return .gray900
            }
        }

        fileprivate var borderColor: Color {
            switch self {
            case .selected:
                return .orange500
            case .unselected:
                return .gray500
            }
        }
    }

    private let title: String
    private let state: SelectionState
    private let action: () -> Void

    init(
        _ title: String,
        state: SelectionState,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.state = state
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .applyEatzyFont(.button_18_m)
                    .foregroundStyle(state.foregroundColor)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.coreWhite)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .inset(by: 0.5)
                    .stroke(state.borderColor, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(state == .selected ? .isSelected : [])
    }
}

