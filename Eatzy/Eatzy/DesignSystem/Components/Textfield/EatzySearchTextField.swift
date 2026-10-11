//
//  EatzySearchTextField.swift
//  Eatzy
//
//  Created by sun on 10/7/26.
//

import SwiftUI

struct EatzySearchTextField: View {
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    private let placeholder: String
    private let isSelected: Bool
    private let onSubmit: () -> Void

    init(
        text: Binding<String>,
        placeholder: String = "Search Countries",
        isSelected: Bool = false,
        onSubmit: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isSelected = isSelected
        self.onSubmit = onSubmit
    }

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .applyEatzyFont(.body_16_r)
                        .foregroundStyle(.gray500)
                        .allowsHitTesting(false)
                }

                TextField("", text: $text)
                    .focused($isFocused)
                    .applyEatzyFont(.body_16_m)
                    .foregroundStyle(.gray900)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit(onSubmit)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailingButton
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52, alignment: .leading)
        .background(.coreWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(borderColor, lineWidth: 1)
        }
    }
}

private extension EatzySearchTextField {
    var borderColor: Color {
        if isSelected {
            return .orange500
        }
        if !text.isEmpty, !isFocused {
            return .gray900
        }
        return .gray300
    }

    @ViewBuilder
    var trailingButton: some View {
        if text.isEmpty {
            Image(.icSearch)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
        } else if !isSelected, isFocused {
            Button {
                text = ""
            } label: {
                Image(.icDelete)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
    }
}
