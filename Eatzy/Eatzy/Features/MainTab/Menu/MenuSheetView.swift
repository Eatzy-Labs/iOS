//
//  MenuSheetView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct MenuSheetView: View {
    let store: StoreOf<MenuSheetFeature>

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.gray300)
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text(store.detail.title)
                        .applyEatzyFont(.title_14_sb)
                        .foregroundStyle(.coreBlack)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)

                    LazyVStack(alignment: .leading, spacing: 37) {
                        ForEach(store.detail.dishes) { dish in
                            dishSection(dish)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .background(.coreWhite)
    }
}

private extension MenuSheetView {
    func dishSection(_ dish: MenuSheet.Dish) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 8) {
                    Text(dish.name)
                        .applyEatzyFont(.body_16_m)
                        .foregroundStyle(.gray900)

                    Spacer(minLength: 0)

                    Text(dish.detail)
                        .applyEatzyFont(.caption_12_m)
                        .foregroundStyle(.gray400)
                }

                Text(dish.description)
                    .applyEatzyFont(.caption_12_r)
                    .foregroundStyle(.gray500)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)

            if imageCount(for: dish) > 0 {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<imageCount(for: dish), id: \.self) { index in
                            dishImage(dish, at: index)
                            .frame(width: 140, height: 140)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.leading, 16)
            }
        }
    }

    func imageCount(for dish: MenuSheet.Dish) -> Int {
        max(dish.imageNames.count, dish.imageURLs.count)
    }

    @ViewBuilder
    func dishImage(_ dish: MenuSheet.Dish, at index: Int) -> some View {
        if dish.imageNames.indices.contains(index) {
            Image(dish.imageNames[index])
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            MealRemoteImage(
                primaryURL: URL(string: dish.imageURLs[index]),
                fallbackURL: dish.fallbackImageURLs.indices.contains(index)
                    ? URL(string: dish.fallbackImageURLs[index])
                    : nil
            )
        }
    }
}

private struct MealRemoteImage: View {
    let primaryURL: URL?
    let fallbackURL: URL?

    var body: some View {
        AsyncImage(url: primaryURL) { phase in
            switch phase {
            case let .success(image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                fallbackImage
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.gray100)
            @unknown default:
                placeholder
            }
        }
    }

    @ViewBuilder
    private var fallbackImage: some View {
        if let fallbackURL {
            AsyncImage(url: fallbackURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                placeholder
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Color.gray100
    }
}

#Preview {
    MenuSheetView(store: Store(initialState: MenuSheetFeature.State()) {
        MenuSheetFeature()
    })
}
