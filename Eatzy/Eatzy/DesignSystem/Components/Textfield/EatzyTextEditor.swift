//
//  EatzyTextEditor.swift
//  Eatzy
//
//  Created by sun on 10/12/26.
//

import SwiftUI

struct EatzyTextEditor: View {
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    private let placeholder: String
    private let maximumLength: Int
    private let errorMessage: String?
    private let onFocusChanged: (Bool) -> Void

    init(
        text: Binding<String>,
        placeholder: String = "Type here",
        maximumLength: Int = 200,
        errorMessage: String? = nil,
        onFocusChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self._text = text
        self.placeholder = placeholder
        self.maximumLength = max(0, maximumLength)
        self.errorMessage = errorMessage
        self.onFocusChanged = onFocusChanged
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .applyEatzyFont(.body_16_r)
                        .foregroundStyle(.gray500)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .focused($isFocused)
                    .applyEatzyFont(.body_16_r)
                    .foregroundStyle(.gray900)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, -5)
                    .padding(.vertical, -8)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
            .background(.coreWhite)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(errorMessage == nil ? .gray300 : .red500, lineWidth: 1)
            }

            HStack(alignment: .top, spacing: 8) {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red500)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Spacer(minLength: 0)
                }

                Text("\(text.count)/\(maximumLength)")
                    .foregroundStyle(.gray500)
            }
            .applyEatzyFont(.caption_12_m)
            .padding(.horizontal, 4)
        }
        .onChange(of: text) { _, newValue in
            guard newValue.count > maximumLength else { return }
            text = String(newValue.prefix(maximumLength))
        }
        .onChange(of: isFocused) { _, isFocused in
            onFocusChanged(isFocused)
        }
    }
}
