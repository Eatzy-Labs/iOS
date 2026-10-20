//
//  MenuView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct MenuView: View {
    let store: StoreOf<MainTabFeature>
    @State private var isCompactHeader = false
    @State private var calendarHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .title(isCompactHeader ? selectedDateTitle : "FOOD"),
                trailing: [
                    .icon(.icSetting, accessibilityLabel: "Settings") {
                        store.send(.settingButtonTapped)
                    }
                ]
            )

            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    EatzyCallendar(selection: selectedDate)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(.coreWhite)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            if calendarHeight != height {
                                calendarHeight = height
                            }
                        }

                    Section {
                        menuContent
                    } header: {
                        cafeteriaHeader
                    }
                }
            }
            .background(.gray100)
            .onScrollGeometryChange(for: Bool.self) { geometry in
                let offset = geometry.contentOffset.y + geometry.contentInsets.top
                return calendarHeight > 0 && offset >= calendarHeight - 0.5
            } action: { _, isCompact in
                isCompactHeader = isCompact
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.coreWhite)
        .task {
            await store.send(.menuViewAppeared).finish()
        }
        .sheet(isPresented: menuSheetPresentation) {
            MenuSheetView(
                store: store.scope(state: \.menuSheet, action: \.menuSheet)
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.coreWhite)
        }
    }
}

private extension MenuView {
    var selectedDateTitle: String {
        let day = Calendar.current.component(.day, from: store.selectedDate)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return "\(day), \(formatter.string(from: store.selectedDate).uppercased())"
    }

    @ViewBuilder
    var cafeteriaHeader: some View {
        if !store.cafeterias.isEmpty {
            EatzyTabBar(
                items: store.cafeterias.map(\.code),
                selection: selectedCafeteria,
                title: cafeteriaTitle(for:)
            )
            .fixedSize(horizontal: false, vertical: true)
            .background(.coreWhite)
        } else if store.isCatalogLoading {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(.coreWhite)
        }
    }

    @ViewBuilder
    var menuContent: some View {
        if let message = store.catalogErrorMessage {
            retryView(message: message, action: .catalogRetryTapped)
        } else if store.isMealsLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        } else if let message = store.mealsErrorMessage {
            retryView(message: message, action: .mealsRetryTapped)
        } else if store.isMenuAvailable {
            LazyVStack(alignment: .leading, spacing: 0) {
                if !breakfastSections.isEmpty {
                    mealSection(
                        title: "BREAKFAST",
                        color: .yellow500,
                        sections: breakfastSections
                    )
                }

                if !lunchSections.isEmpty {
                    mealSection(
                        title: "LUNCH",
                        color: .blue500,
                        sections: lunchSections
                    )
                }

                if !dinnerSections.isEmpty {
                    mealSection(
                        title: "DINNER",
                        color: .purple500,
                        sections: dinnerSections
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        } else if store.mealsResponse != nil {
            Text("No menu information yet")
                .applyEatzyFont(.body_16_r)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        }
    }

    func retryView(message: String, action: MainTabFeature.Action) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .applyEatzyFont(.body_14_r)
                .foregroundStyle(.gray500)

            Button("Retry") {
                store.send(action)
            }
            .applyEatzyFont(.button_14_m)
            .foregroundStyle(.orange500)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    var selectedDate: Binding<Date> {
        Binding(
            get: { store.selectedDate },
            set: { store.send(.dateSelected($0)) }
        )
    }

    var selectedCafeteria: Binding<String> {
        Binding(
            get: { store.selectedCafeteriaCode },
            set: { store.send(.cafeteriaSelected($0)) }
        )
    }

    func cafeteriaTitle(for code: String) -> String {
        store.cafeterias.first(where: { $0.code == code })?.tabTitle ?? code
    }

    var menuSheetPresentation: Binding<Bool> {
        Binding(
            get: { store.isMenuSheetPresented },
            set: { store.send(.menuSheetPresentationChanged($0)) }
        )
    }

    func mealSection(
        title: String,
        color: Color,
        sections: [EatzyCardMenu.Section]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .applyEatzyFont(.caption_12_m)
                .foregroundStyle(color)
                .padding(.horizontal, 4)

            EatzyCardMenu(
                sections: sections,
                onSelect: { section in
                    store.send(.menuSectionTapped(section.id))
                }
            )
        }
        .padding(.top, 20)
    }

    var breakfastSections: [EatzyCardMenu.Section] {
        mealSections(for: "breakfast")
    }

    var lunchSections: [EatzyCardMenu.Section] {
        mealSections(for: "lunch")
    }

    var dinnerSections: [EatzyCardMenu.Section] {
        mealSections(for: "dinner")
    }

    func mealSections(for mealType: String) -> [EatzyCardMenu.Section] {
        MealsPresentation.sections(
            for: mealType,
            in: store.mealsResponse,
            dietaryProfile: store.dietaryProfile,
            taxonomy: store.dietaryTaxonomy,
            appliesDietaryFilter: store.setting.dietaryPreference.savedShowsOnMenu
        )
    }

}
