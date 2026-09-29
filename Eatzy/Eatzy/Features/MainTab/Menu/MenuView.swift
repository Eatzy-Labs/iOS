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

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .title("FOOD"),
                trailing: [
                    .icon(.icSetting, accessibilityLabel: "Settings") {
                        store.send(.settingButtonTapped)
                    }
                ]
            )

            EatzyCallendar(selection: selectedDate)
                .fixedSize(horizontal: false, vertical: true)

            if !store.cafeterias.isEmpty {
                EatzyTabBar(
                    items: store.cafeterias.map(\.code),
                    selection: selectedCafeteria,
                    title: cafeteriaTitle(for:)
                )
                .fixedSize(horizontal: false, vertical: true)
            } else if store.isCatalogLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(.coreWhite)
            }

            ScrollView(.vertical) {
                if let message = store.catalogErrorMessage {
                    VStack(spacing: 12) {
                        Text(message)
                            .applyEatzyFont(.body_14_r)
                            .foregroundStyle(.gray500)

                        Button("Retry") {
                            store.send(.catalogRetryTapped)
                        }
                        .applyEatzyFont(.button_14_m)
                        .foregroundStyle(.orange500)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else if store.isMealsLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let message = store.mealsErrorMessage {
                    VStack(spacing: 12) {
                        Text(message)
                            .applyEatzyFont(.body_14_r)
                            .foregroundStyle(.gray500)

                        Button("Retry") {
                            store.send(.mealsRetryTapped)
                        }
                        .applyEatzyFont(.button_14_m)
                        .foregroundStyle(.orange500)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else if store.isMenuAvailable {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if !breakfastSections.isEmpty {
                            mealSection(
                                title: "BREAKFAST",
                                color: .yellow500,
                                sections: breakfastSections,
                                selection: selectedMenuSectionID
                            )
                        }

                        if !lunchSections.isEmpty {
                            mealSection(
                                title: "LUNCH",
                                color: .blue500,
                                sections: lunchSections,
                                selection: selectedMenuSectionID
                            )
                        }

                        if !dinnerSections.isEmpty {
                            mealSection(
                                title: "DINNER",
                                color: .purple500,
                                sections: dinnerSections,
                                selection: selectedMenuSectionID
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(.gray100)
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

    var selectedMenuSectionID: Binding<String?> {
        Binding(
            get: { store.selectedMenuSectionID },
            set: { store.send(.menuSectionSelectionChanged($0)) }
        )
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
        sections: [EatzyCardMenu.Section],
        selection: Binding<String?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .applyEatzyFont(.caption_12_m)
                .foregroundStyle(color)
                .padding(.horizontal, 4)

            EatzyCardMenu(
                sections: sections,
                selectedSectionID: selection,
                onSelect: { section in
                    store.send(.menuSectionTapped(section.id))
                }
            )
        }
        .padding(.top, 20)
    }

    var breakfastSections: [EatzyCardMenu.Section] {
        MealsPresentation.sections(for: "breakfast", in: store.mealsResponse)
    }

    var lunchSections: [EatzyCardMenu.Section] {
        MealsPresentation.sections(for: "lunch", in: store.mealsResponse)
    }

    var dinnerSections: [EatzyCardMenu.Section] {
        MealsPresentation.sections(for: "dinner", in: store.mealsResponse)
    }

}
