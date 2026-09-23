//
//  EatzyTabBar.swift
//  Eatzy
//

import SwiftUI

struct EatzyTabBar<Item: Hashable>: View {
    private let items: [Item]
    @Binding private var selection: Item
    private let title: (Item) -> String

    init(
        items: [Item],
        selection: Binding<Item>,
        title: @escaping (Item) -> String
    ) {
        self.items = items
        self._selection = selection
        self.title = title
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: 4) {
                    ForEach(items, id: \.self) { item in
                        tabButton(for: item)
                            .id(item)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
            .background(.coreWhite)
            .onAppear {
                proxy.scrollTo(selection, anchor: .center)
            }
            .onChange(of: selection) { _, newSelection in
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(newSelection, anchor: .center)
                }
            }
        }
    }

    private func tabButton(for item: Item) -> some View {
        let isSelected = item == selection

        return Button {
            selection = item
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Text(title(item))
                    .applyEatzyFont(.button_14_m)
                    .foregroundStyle(isSelected ? Color.orange500 : Color.gray500)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

