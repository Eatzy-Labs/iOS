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

                if store.isPlacesLoading {
                    ProgressView()
                        .padding(.top, 80)
                } else if store.isPlaceDetailLoading {
                    ProgressView()
                        .padding(.top, 80)
                } else if let message = store.placesErrorMessage {
                    VStack(spacing: 12) {
                        Text(message)
                            .applyEatzyFont(.body_14_r)
                            .foregroundStyle(.gray500)

                        Button("Retry") {
                            store.send(.placesRetryTapped)
                        }
                        .applyEatzyFont(.button_14_m)
                        .foregroundStyle(.orange500)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 80)
                } else if let message = store.placeDetailErrorMessage {
                    Text(message)
                        .applyEatzyFont(.body_14_r)
                        .foregroundStyle(.gray500)
                        .padding(.horizontal, 20)
                        .padding(.top, 80)
                }
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
    var placeSheetPresentation: Binding<Bool> {
        Binding(
            get: { store.isPlaceSheetPresented },
            set: { store.send(.placeSheetPresentationChanged($0)) }
        )
    }
}
