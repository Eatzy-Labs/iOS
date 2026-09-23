//
//  EatzyCardMenu.swift
//  Eatzy
//

import SwiftUI

struct EatzyCardMenu: View {
    struct Section: Identifiable {
        struct Item {
            let name: String
            let detail: String

            init(_ name: String, detail: String) {
                self.name = name
                self.detail = detail
            }
        }

        let id: String
        let title: String?
        let titleDetail: String?
        let items: [Item]

        init(
            id: String,
            title: String? = nil,
            titleDetail: String? = nil,
            items: [Item] = []
        ) {
            self.id = id
            self.title = title
            self.titleDetail = titleDetail
            self.items = items
        }
    }

    private let sections: [Section]
    private let onSelect: (Section) -> Void

    @Binding private var selectedSectionID: String?

    init(
        sections: [Section],
        selectedSectionID: Binding<String?>,
        onSelect: @escaping (Section) -> Void = { _ in }
    ) {
        self.sections = sections
        self._selectedSectionID = selectedSectionID
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(sections) { section in
                sectionButton(section)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.coreWhite)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private extension EatzyCardMenu {
    func sectionButton(_ section: Section) -> some View {
        let isSelected = selectedSectionID == section.id

        return Button {
            selectedSectionID = section.id
            onSelect(section)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                if let title = section.title {
                    titleRow(title, detail: section.titleDetail)
                }

                ForEach(section.items.indices, id: \.self) { index in
                    itemRow(section.items[index])
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(isSelected ? Color.gray100 : Color.coreWhite)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func titleRow(_ title: String, detail: String?) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .applyEatzyFont(.title_14_sb)
                .foregroundStyle(.coreBlack)

            Spacer(minLength: 0)

            if let detail {
                detailText(detail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    func itemRow(_ item: Section.Item) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(item.name)
                .applyEatzyFont(.body_14_r)
                .foregroundStyle(.coreBlack)

            Spacer(minLength: 0)

            detailText(item.detail)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    func detailText(_ detail: String) -> some View {
        Text(detail)
            .applyEatzyFont(.caption_11_m)
            .foregroundStyle(.gray400)
            .lineLimit(1)
    }
}

