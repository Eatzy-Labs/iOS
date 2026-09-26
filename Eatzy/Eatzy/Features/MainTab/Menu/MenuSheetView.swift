//
//  MenuSheetView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct MenuSheetView: View {
    let store: StoreOf<MenuSheetFeature>

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 0) {
                Text(store.detail.title)
                    .applyEatzyFont(.title_14_sb)
                    .foregroundStyle(.coreBlack)
                    .padding(.bottom, 20)

                LazyVStack(alignment: .leading, spacing: 37) {
                    ForEach(store.detail.dishes) { dish in
                        dishSection(dish)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 32)
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

            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(dish.imageNames.enumerated()), id: \.offset) { _, imageName in
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 140, height: 140)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    MenuSheetView(store: Store(initialState: MenuSheetFeature.State()) {
        MenuSheetFeature()
    })
}
