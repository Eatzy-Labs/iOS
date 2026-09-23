//
//  EatzyTextfield.swift
//  Eatzy
//

import SwiftUI

struct EatzyTextfield: View {
    enum State: Equatable {
        case placeholder
        case writing
        case success
        case error(message: String)
    }

    private let placeholder: String
    private let maximumLength: Int

    @Binding private var text: String
    @Binding private var state: State

    init(
        text: Binding<String>,
        state: Binding<State>,
        placeholder: String,
        maximumLength: Int = 8
    ) {
        self._text = text
        self._state = state
        self.placeholder = placeholder
        self.maximumLength = max(0, maximumLength)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            inputField
            caption
        }
        .onChange(of: text) { oldValue, newValue in
            handleTextChange(from: oldValue, to: newValue)
        }
    }
}

private extension EatzyTextfield {
    var inputField: some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .applyEatzyFont(.body_16_r)
                        .foregroundStyle(.gray500)
                        .allowsHitTesting(false)
                }

                TextField("", text: $text)
                    .applyEatzyFont(.body_16_m)
                    .foregroundStyle(.gray900)
            }

            statusIcon
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.coreWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(borderColor, lineWidth: 1)
        }
    }

    var caption: some View {
        HStack(alignment: .center, spacing: 8) {
            if case let .error(message) = state {
                Text(message)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Text("\(text.count)/\(maximumLength)")
        }
        .applyEatzyFont(.caption_12_m)
        .foregroundStyle(captionColor)
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    @ViewBuilder
    var statusIcon: some View {
        switch state {
        case .placeholder, .writing:
            EmptyView()

        case .success:
            Image(.icSuccess)
                .frame(width: 24, height: 24)

        case .error:
            Button {
                text = ""
                state = .placeholder
            } label: {
                Image(.icDelete)
                    .renderingMode(.template)
                    .foregroundStyle(.red500)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("입력 내용 삭제")
        }
    }

    func handleTextChange(from oldValue: String, to newValue: String) {
        if newValue.count > maximumLength {
            text = String(newValue.prefix(maximumLength))
            return
        }

        guard newValue != oldValue else { return }
        state = newValue.isEmpty ? .placeholder : .writing
    }

    var borderColor: Color {
        switch state {
        case .placeholder, .writing:
            return .gray300
        case .success:
            return .orange500
        case .error:
            return .red500
        }
    }

    var captionColor: Color {
        switch state {
        case .placeholder, .writing:
            return .gray500
        case .success:
            return .orange500
        case .error:
            return .red500
        }
    }
}
