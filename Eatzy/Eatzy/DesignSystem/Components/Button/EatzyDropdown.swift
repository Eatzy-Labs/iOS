//
//  EatzyDropdown.swift
//  Eatzy
//

import SwiftUI

struct EatzyDropdown<Option: Hashable>: View {
    private let title: String
    private let options: [Option]
    private let optionTitle: (Option) -> String

    @Binding private var selections: Set<Option>
    @State private var isExpanded = false

    init(
        title: String,
        options: [Option],
        selections: Binding<Set<Option>>,
        optionTitle: @escaping (Option) -> String
    ) {
        var seen = Set<Option>()

        self.title = title
        self.options = options.filter { seen.insert($0).inserted }
        self._selections = selections
        self.optionTitle = optionTitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if isExpanded {
                Divider()
                    .overlay(.gray300)

                optionList
            }
        }
        .background(.coreWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(.gray300, lineWidth: 1)
        }
    }
}

extension EatzyDropdown where Option == String {
    init(
        title: String,
        options: [String],
        selections: Binding<Set<String>>
    ) {
        self.init(
            title: title,
            options: options,
            selections: selections,
            optionTitle: { $0 }
        )
    }
}

private extension EatzyDropdown {
    var header: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(alignment: .center, spacing: 2) {
                Text(title)
                    .applyEatzyFont(.body_18_m)
                    .foregroundStyle(.gray900)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Image(.arrowDownIconLg)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .frame(
                maxWidth: .infinity,
                minHeight: 52,
                maxHeight: 52
            )
            .background(isExpanded ? Color.orange100 : Color.coreWhite)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var optionList: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(options, id: \.self) { option in
                    optionRow(option)
                        .overlay(alignment: .bottom) {
                            if option != options.last {
                                Divider()
                                    .overlay(.gray300)
                            }
                        }
                }
            }
        }
        .scrollDisabled(!isScrollable)
        .scrollIndicators(isScrollable ? .visible : .hidden)
        .frame(height: optionListHeight)
    }

    var isScrollable: Bool {
        options.count > 5
    }

    var optionListHeight: CGFloat {
        CGFloat(min(options.count, 5)) * 52
    }

    func optionRow(_ option: Option) -> some View {
        Button {
            toggleSelection(of: option)
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Text(optionTitle(option))
                    .applyEatzyFont(.body_18_r)
                    .foregroundStyle(.gray900)
                    .lineLimit(1)

                Spacer(minLength: 0)

                if selections.contains(option) {
                    Image(.icSuccess)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 20)
            .frame(
                maxWidth: .infinity,
                minHeight: 52,
                maxHeight: 52
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selections.contains(option) ? .isSelected : [])
    }

    func toggleSelection(of option: Option) {
        if selections.contains(option) {
            selections.remove(option)
        } else {
            selections.insert(option)
        }
    }
}
