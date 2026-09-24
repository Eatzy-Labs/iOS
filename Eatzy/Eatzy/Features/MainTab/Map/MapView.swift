//
//  MapView.swift
//  Eatzy
//

import ComposableArchitecture
import NMapsMap
import SwiftUI

struct MapView: View {
    let store: StoreOf<MainTabFeature>

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .dropdownTitle(store.selectedUniversity) {
                    store.send(.mapUniversityTapped)
                },
                trailing: [
                    .icon(.icSetting, accessibilityLabel: "Settings") {
                        store.send(.mapSettingButtonTapped)
                    }
                ]
            )

            ZStack(alignment: .top) {
                NaverMapView()
                    .ignoresSafeArea(edges: .bottom)

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        ForEach(MainTabFeature.State.MapCategory.allCases, id: \.self) { category in
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
            store.send(.mapViewAppeared)
        }
    }
}

private extension MapView {
    func categoryChip(_ category: MainTabFeature.State.MapCategory) -> some View {
        EatzyChipButton(
            category.title,
            icon: category.icon,
            state: store.selectedMapCategory == category ? .selected : .unselected
        ) {
            store.send(.mapCategorySelected(category))
        }
    }
}

private extension MainTabFeature.State.MapCategory {
    var title: String {
        switch self {
        case .all: return "All"
        case .cafeteria: return "Cafeteria"
        case .cafe: return "Cafe"
        case .store: return "Store"
        case .office: return "Office"
        }
    }

    var icon: ImageResource {
        switch self {
        case .all: return .icAll
        case .cafeteria: return .icCafeteria
        case .cafe: return .icCafe
        case .store: return .icStore
        case .office: return .icOffice
        }
    }
}

private struct NaverMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView(frame: .zero)
        let kyungpookUniversity = NMGLatLng(lat: 35.8888, lng: 128.6103)

        mapView.moveCamera(
            NMFCameraUpdate(scrollTo: kyungpookUniversity, zoomTo: 15)
        )

        return mapView
    }

    func updateUIView(_ uiView: NMFMapView, context: Context) {}
}
