//
//  MealsPresentation.swift
//  Eatzy
//

import Foundation

enum MealsPresentation {
    static func sections(
        for mealType: String,
        in response: MealsResponseDTO?,
        dietaryProfile: DietaryProfileDTO? = nil,
        taxonomy: DietaryTaxonomyResponseDTO? = nil,
        appliesDietaryFilter: Bool = true
    ) -> [EatzyCardMenu.Section] {
        guard let meal = response?.meals.first(where: { $0.mealType == mealType }) else {
            return []
        }

        return meal.options.enumerated().compactMap { index, option in
            let items = option.items.map { item in
                EatzyCardMenu.Section.Item(
                    displayName(for: item),
                    detail: translatedDetail(for: item),
                    isRestricted: appliesDietaryFilter && isRestricted(
                        item,
                        profile: dietaryProfile,
                        taxonomy: taxonomy
                    )
                )
            }
            let notice = nonEmpty(option.notice ?? option.noticeEn ?? option.noticeKo)

            guard !items.isEmpty || notice != nil else { return nil }
            return EatzyCardMenu.Section(
                id: sectionID(mealType: mealType, option: option, index: index),
                title: nonEmpty(option.label ?? option.labelEn ?? option.labelKo) ?? notice,
                items: items
            )
        }
    }

    static func sheet(
        for sectionID: String,
        in response: MealsResponseDTO?,
        dietaryProfile: DietaryProfileDTO? = nil,
        taxonomy: DietaryTaxonomyResponseDTO? = nil,
        appliesDietaryFilter: Bool = true
    ) -> MenuSheet? {
        guard let response else { return nil }

        for meal in response.meals {
            for (index, option) in meal.options.enumerated() where
                self.sectionID(mealType: meal.mealType, option: option, index: index) == sectionID
            {
                let title = nonEmpty(option.label ?? option.labelEn ?? option.labelKo)
                    ?? meal.mealType.uppercased()
                let dishes = option.items.enumerated().map { itemIndex, item in
                    let dish = item.dish
                    return MenuSheet.Dish(
                        id: dish?.id.map(String.init)
                            ?? "\(sectionID)-\(item.position ?? itemIndex)",
                        name: displayName(for: item),
                        detail: translatedDetail(for: item),
                        description: dish?.explanationEn ?? dish?.explanationKo ?? "",
                        isRestricted: appliesDietaryFilter && isRestricted(
                            item,
                            profile: dietaryProfile,
                            taxonomy: taxonomy
                        ),
                        imageURLs: dish?.imageUrls ?? [],
                        fallbackImageURLs: dish?.imageFallbackUrls ?? []
                    )
                }
                return MenuSheet(title: title, dishes: dishes)
            }
        }
        return nil
    }

    private static func sectionID(
        mealType: String,
        option: MealOptionDTO,
        index: Int
    ) -> String {
        "\(mealType)-\(option.position ?? index)"
    }

    private static func displayName(for item: MealItemDTO) -> String {
        item.name ?? item.nameEn ?? item.nameKo ?? ""
    }

    private static func translatedDetail(for item: MealItemDTO) -> String {
        let displayName = displayName(for: item)
        guard let koreanName = nonEmpty(item.nameKo), koreanName != displayName else { return "" }
        return koreanName
    }

    private static func isRestricted(
        _ item: MealItemDTO,
        profile: DietaryProfileDTO?,
        taxonomy: DietaryTaxonomyResponseDTO?
    ) -> Bool {
        guard let profile, let dietary = item.dish?.dietary else { return false }

        var avoidedIngredients = Set(profile.avoidedIngredients)
        for dietCode in profile.diets {
            guard let diet = taxonomy?.diets.first(where: { $0.code == dietCode }) else {
                continue
            }
            avoidedIngredients.formUnion(diet.presetIngredients)
        }

        let containsAvoidedIngredient = dietary.ingredients?.contains { code, status in
            avoidedIngredients.contains(code) && status.uppercased() == "PRESENT"
        } == true

        let exceedsSpiceLevel: Bool
        if let maximumSpiceLevel = profile.maxSpiceLevel,
           let spiceLevel = dietary.spiceLevel {
            exceedsSpiceLevel = spiceLevel > maximumSpiceLevel
        } else {
            exceedsSpiceLevel = false
        }

        return containsAvoidedIngredient || exceedsSpiceLevel
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else { return nil }
        return value
    }
}
