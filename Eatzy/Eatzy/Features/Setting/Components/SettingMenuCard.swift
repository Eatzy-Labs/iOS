//
//  SettingMenuCard.swift
//  Eatzy
//

import SwiftUI

struct SettingMenuCard: View {
    struct Item: Identifiable {
        let id = UUID()
        let title: String
        var value: String? = nil
        var titleColor: Color = .gray900
        var showsChevron = true
        var action: () -> Void = {}
    }

    let items: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider()
                        .overlay(.gray300)
                }

                Button(action: item.action) {
                    HStack(spacing: 8) {
                        Text(item.title)
                            .applyEatzyFont(.body_14_m)
                            .foregroundStyle(item.titleColor)

                        Spacer(minLength: 0)

                        if let value = item.value {
                            Text(value)
                                .applyEatzyFont(.body_14_m)
                                .foregroundStyle(.gray900)
                        }

                        if item.showsChevron {
                            Image(.icChevronRight)
                                .renderingMode(.template)
                                .foregroundStyle(.gray500)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.coreWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
