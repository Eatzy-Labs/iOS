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

            NaverMapView()
                .ignoresSafeArea(edges: .bottom)
        }
        .background(.coreWhite)
        .onAppear {
            store.send(.mapViewAppeared)
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
