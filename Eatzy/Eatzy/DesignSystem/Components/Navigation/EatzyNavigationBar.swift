//
//  EatzyNavigationBar.swift
//  Eatzy
//

import SwiftUI

struct EatzyNavigationBar: View {
    enum Leading {
        case title(String)
        case dropdownTitle(String, action: () -> Void)
        case back(action: () -> Void)
    }

    enum TrailingItem {
        case icon(
            ImageResource,
            accessibilityLabel: String = "",
            action: () -> Void
        )
        case text(
            String,
            color: Color,
            action: () -> Void
        )
    }

    private let leading: Leading
    private let trailing: [TrailingItem]

    init(
        leading: Leading,
        trailing: [TrailingItem] = []
    ) {
        self.leading = leading
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            leadingContent

            Spacer()

            HStack(alignment: .center, spacing: 16) {
                ForEach(trailing.indices, id: \.self) { index in
                    trailingContent(for: trailing[index])
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56, alignment: .leading)
        .background(.coreWhite)
    }

    @ViewBuilder
    private var leadingContent: some View {
        switch leading {
        case let .title(title):
            titleLabel(title)

        case let .dropdownTitle(title, action):
            Button(action: action) {
                HStack(alignment: .center, spacing: 4) {
                    titleLabel(title)

                    Image(.icChevronRight)
                        .rotationEffect(.degrees(90))
                        .frame(width: 24, height: 24)
                }
            }
            .buttonStyle(.plain)

        case let .back(action):
            Button(action: action) {
                Image(.icBack)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("뒤로가기")
        }
    }

    @ViewBuilder
    private func trailingContent(for item: TrailingItem) -> some View {
        switch item {
        case let .icon(resource, accessibilityLabel, action):
            Button(action: action) {
                Image(resource)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel)

        case let .text(title, color, action):
            Button(action: action) {
                Text(title)
                    .applyEatzyFont(.button_16_m)
                    .foregroundStyle(color)
            }
            .buttonStyle(.plain)
        }
    }

    private func titleLabel(_ title: String) -> some View {
        Text(title)
            .applyEatzyFont(.title_16_sb)
            .foregroundStyle(.gray900)
    }
}
