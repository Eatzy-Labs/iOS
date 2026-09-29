//
//  EatzyChipButton.swift
//  Eatzy
//

import SwiftUI

struct EatzyChipButton: View {
    enum SelectionState {
        case selected
        case unselected

        fileprivate var foregroundColor: Color {
            switch self {
            case .selected:
                return .coreWhite
            case .unselected:
                return .gray500
            }
        }

        fileprivate var backgroundColor: Color {
            switch self {
            case .selected:
                return .orange500
            case .unselected:
                return .coreWhite
            }
        }

        fileprivate var borderColor: Color {
            switch self {
            case .selected:
                return .clear
            case .unselected:
                return .orange200
            }
        }
    }

    private let title: String
    private let icon: ImageResource
    private let state: SelectionState
    private let action: () -> Void

    init(
        _ title: String,
        icon: ImageResource,
        state: SelectionState,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.state = state
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 4) {
                Image(icon)
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)

                Text(title)
                    .applyEatzyFont(.button_14_m)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .foregroundStyle(state.foregroundColor)
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .frame(height: 40)
            .background(state.backgroundColor, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
            .overlay {
                Capsule()
                    .strokeBorder(state.borderColor, lineWidth: 1)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(state == .selected ? .isSelected : [])
    }
}
