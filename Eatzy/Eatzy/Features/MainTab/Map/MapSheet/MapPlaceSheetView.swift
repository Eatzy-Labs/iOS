//
//  MapPlaceSheetView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct MapPlaceSheetView: View {
    let store: StoreOf<MapPlaceSheetFeature>

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.gray300)
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            ScrollView(.vertical) {
                if let place = store.place {
                    placeContent(place)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                }
            }

            if store.place?.hasMenu == true {
                EatzyCTAButton("menu", state: .active) {
                    store.send(.menuButtonTapped)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
        }
        .background(.coreWhite)
    }
}

private extension MapPlaceSheetView {
    func placeContent(_ place: MapPlace) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .applyEatzyFont(.head_18_m)
                    .foregroundStyle(.coreBlack)

                Text(place.subtitle)
                    .applyEatzyFont(.caption_12_m)
                    .foregroundStyle(.gray400)
            }

            Divider()
                .overlay(.gray100)
                .padding(.top, 12)

            Text(place.description)
                .applyEatzyFont(.body_16_r)
                .foregroundStyle(.gray900)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20)

            if !place.operatingHours.isEmpty {
                HStack(alignment: .center, spacing: 12) {
                    Text("Operating Hours")
                        .applyEatzyFont(.title_14_sb)
                        .foregroundStyle(.gray900)

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 4) {
                        ForEach(place.operatingHours) { operatingHour in
                            Text("\(operatingHour.label) \(operatingHour.time)")
                                .applyEatzyFont(.body_14_r)
                                .foregroundStyle(.gray900)
                        }
                    }
                }
                .padding(.top, 20)
            }

            if place.imageNames.count == 1,
               let imageName = place.imageNames.first {
                placeImage(imageName)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
            } else if place.imageNames.count >= 2 {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        ForEach(Array(place.imageNames.enumerated()), id: \.offset) { _, imageName in
                            placeImage(imageName)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.top, 20)
            }
        }
    }

    func placeImage(_ imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 165, height: 165)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MapSheetMinimumDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        min(520, context.maxDetentValue - 10)
    }
}

struct MapSheetMaximumDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        context.maxDetentValue - 10
    }
}
