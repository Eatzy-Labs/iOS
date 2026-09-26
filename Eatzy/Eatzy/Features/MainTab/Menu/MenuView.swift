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

            EatzyTabBar(
                items: MainTabFeature.cafeterias,
                selection: selectedCafeteria,
                title: { $0 }
            )
            .fixedSize(horizontal: false, vertical: true)

            ScrollView(.vertical) {
                if store.isMenuAvailable {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        mealSection(
                            title: "BREAKFAST",
                            color: .yellow500,
                            sections: breakfastSections,
                            selection: selectedMenuSectionID
                        )

                        mealSection(
                            title: "LUNCH",
                            color: .blue500,
                            sections: lunchSections,
                            selection: selectedMenuSectionID
                        )

                        mealSection(
                            title: "DINNER",
                            color: .purple500,
                            sections: dinnerSections,
                            selection: selectedMenuSectionID
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(.gray100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.coreWhite)
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
            get: { store.selectedCafeteria },
            set: { store.send(.cafeteriaSelected($0)) }
        )
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
        [
            .init(
                id: "breakfast",
                items: [
                    .init("White Rice", detail: "백미밥"),
                    .init("Dried Pollack and Radish Soup", detail: "북어무채국"),
                    .init("Kkanpung Chicken Stir-fry", detail: "닭가슴살깐풍볶음"),
                    .init("Seasoned Bean Sprouts", detail: "콩나물무침"),
                    .init("Spicy Mixed Fermented Squid", detail: "비빔오징어젓"),
                    .init("Kimchi", detail: "배추김치")
                ]
            )
        ]
    }

    var lunchSections: [EatzyCardMenu.Section] {
        [
            .init(
                id: "lunch-daily-special-1",
                title: "[Daily Special]",
                items: [
                    .init("Eel Rice Bowl", detail: "장어덮밥"),
                    .init("Squid and Radish Soup", detail: "오징어무국"),
                    .init("Kimchi", detail: "배추김치")
                ]
            ),
            .init(
                id: "lunch-daily-special-2",
                title: "[Daily Special]",
                items: [
                    .init("Bulgogi Bibimbap", detail: "불고기비빔밥")
                ]
            ),
            .init(
                id: "lunch-pork-cutlet",
                title: "Sweet Potato Pork Cutlet",
                titleDetail: "고구마돈가스"
            )
        ]
    }

    var dinnerSections: [EatzyCardMenu.Section] {
        [
            .init(
                id: "dinner-daily-special-1",
                title: "[Daily Special]",
                items: [
                    .init("Eel Rice Bowl", detail: "장어덮밥"),
                    .init("Squid and Radish Soup", detail: "오징어무국"),
                    .init("Kimchi", detail: "배추김치")
                ]
            ),
            .init(
                id: "dinner-daily-special-2",
                title: "[Daily Special]",
                items: [
                    .init("Bulgogi Bibimbap", detail: "불고기비빔밥")
                ]
            ),
            .init(
                id: "dinner-pork-cutlet",
                title: "Sweet Potato Pork Cutlet",
                titleDetail: "고구마돈가스"
            )
        ]
    }

}
