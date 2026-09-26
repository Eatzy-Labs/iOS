//
//  MapView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct MapView: View {
    let store: StoreOf<MapFeature>

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .dropdownTitle(store.selectedUniversity) {
                    store.send(.universityButtonTapped)
                },
                trailing: [
                    .icon(.icSetting, accessibilityLabel: "Settings") {
                        store.send(.settingButtonTapped)
                    }
                ]
            )

            ZStack(alignment: .top) {
                NaverMapView(
                    places: store.visiblePlaces,
                    onMarkerTapped: { store.send(.markerTapped($0)) }
                )
                    .ignoresSafeArea(edges: .bottom)

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        ForEach(MapPlace.Category.allCases, id: \.self) { category in
                            categoryChip(category)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .scrollIndicators(.hidden)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 16)
            }
        }
        .background(.coreWhite)
        .onAppear {
            store.send(.viewAppeared)
        }
        .sheet(isPresented: placeSheetPresentation) {
            MapPlaceSheetView(
                store: store.scope(state: \.placeSheet, action: \.placeSheet)
            )
            .presentationDetents([
                .custom(MapSheetMinimumDetent.self),
                .custom(MapSheetMaximumDetent.self)
            ])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.coreWhite)
        }
    }
}

private extension MapView {
    func categoryChip(_ category: MapPlace.Category) -> some View {
        EatzyChipButton(
            category.title,
            icon: category.icon,
            state: store.selectedCategory == category ? .selected : .unselected
        ) {
            store.send(.categorySelected(category))
        }
    }

    var placeSheetPresentation: Binding<Bool> {
        Binding(
            get: { store.isPlaceSheetPresented },
            set: { store.send(.placeSheetPresentationChanged($0)) }
        )
    }
}
