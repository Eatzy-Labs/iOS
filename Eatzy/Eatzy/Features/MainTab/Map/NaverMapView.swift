//
//  NaverMapView.swift
//  Eatzy
//

import NMapsMap
import SwiftUI

struct NaverMapView: UIViewRepresentable {
    let places: [MapPlace]
    let onMarkerTapped: (MapPlace.ID) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onMarkerTapped: onMarkerTapped)
    }

    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView(frame: .zero)
        let initialPosition = NMGLatLng(lat: 35.8888, lng: 128.6103)

        mapView.moveCamera(
            NMFCameraUpdate(scrollTo: initialPosition, zoomTo: 15)
        )
        context.coordinator.updateMarkers(for: places, on: mapView)

        return mapView
    }

    func updateUIView(_ mapView: NMFMapView, context: Context) {
        context.coordinator.onMarkerTapped = onMarkerTapped
        context.coordinator.updateMarkers(for: places, on: mapView)
    }

    final class Coordinator {
        var onMarkerTapped: (MapPlace.ID) -> Void
        private var markers: [NMFMarker] = []

        init(onMarkerTapped: @escaping (MapPlace.ID) -> Void) {
            self.onMarkerTapped = onMarkerTapped
        }

        func updateMarkers(for places: [MapPlace], on mapView: NMFMapView) {
            markers.forEach { $0.mapView = nil }
            markers = places.map { makeMarker(for: $0, on: mapView) }
        }

        private func makeMarker(for place: MapPlace, on mapView: NMFMapView) -> NMFMarker {
            let marker = NMFMarker()
            marker.position = NMGLatLng(
                lat: place.latitude,
                lng: place.longitude
            )
            marker.iconImage = NMFOverlayImage(image: place.category.markerImage)
            marker.touchHandler = { [weak self] _ in
                self?.onMarkerTapped(place.id)
                return true
            }
            marker.mapView = mapView
            return marker
        }
    }
}

