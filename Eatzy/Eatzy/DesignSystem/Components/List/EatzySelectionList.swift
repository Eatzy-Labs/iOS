//
//  EatzySelectionList.swift
//  Eatzy
//

import SwiftUI

struct EatzySelectionList<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option?
    let optionTitle: (Option) -> String

    init(
        options: [Option],
        selection: Binding<Option?>,
        optionTitle: @escaping (Option) -> String = { String(describing: $0) }
    ) {
        self.options = options
        self._selection = selection
        self.optionTitle = optionTitle
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        Text(optionTitle(option))
                            .applyEatzyFont(.body_14_r)
                            .foregroundStyle(.gray900)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if selection == option {
                            Image(.icSuccess)
                                .padding(2)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52)
                    .background(.coreWhite)
                    .contentShape(Rectangle())
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.gray300)
                            .frame(height: 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
