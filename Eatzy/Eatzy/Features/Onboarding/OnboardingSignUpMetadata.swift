//
//  OnboardingSignUpMetadata.swift
//  Eatzy
//

extension OnboardingFeature.State {
    var selectedUniversityCode: String? {
        selectedUniversity.first
    }

    var selectedNationalityCode: String? {
        selectedCountry.first
    }
}
