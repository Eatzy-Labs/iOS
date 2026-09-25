//
//  MapView.swift
//  Eatzy
//

import ComposableArchitecture
import NMapsMap
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
                NaverMapView(places: store.visiblePlaces)
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
}

private extension MapPlace.Category {
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
    let places: [MapPlace]

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView(frame: .zero)
        let kyungpookUniversity = NMGLatLng(lat: 35.8888, lng: 128.6103)

        mapView.moveCamera(
            NMFCameraUpdate(scrollTo: kyungpookUniversity, zoomTo: 15)
        )
        context.coordinator.updateMarkers(for: places, on: mapView)

        return mapView
    }

    func updateUIView(_ uiView: NMFMapView, context: Context) {
        context.coordinator.updateMarkers(for: places, on: uiView)
    }

    final class Coordinator {
        private var markers: [NMFMarker] = []

        func updateMarkers(for places: [MapPlace], on mapView: NMFMapView) {
            markers.forEach { $0.mapView = nil }
            markers = places.map { place in
                let marker = NMFMarker()
                marker.position = NMGLatLng(
                    lat: place.latitude,
                    lng: place.longitude
                )
                marker.iconImage = NMFOverlayImage(image: place.category.markerImage)
                marker.mapView = mapView
                return marker
            }
        }
    }
}

private extension MapPlace.Category {
    var markerImage: UIImage {
        switch self {
        case .all:
            return UIImage(resource: .typeStore)
        case .cafeteria:
            return UIImage(resource: .typeCafeteria)
        case .cafe:
            return UIImage(resource: .typeCafe)
        case .office:
            return UIImage(resource: .typeOffice)
        case .store:
            return UIImage(resource: .typeStore)
        }
    }
}
