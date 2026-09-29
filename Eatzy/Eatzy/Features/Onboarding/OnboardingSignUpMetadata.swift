//
//  OnboardingSignUpMetadata.swift
//  Eatzy
//

enum OnboardingSignUpMetadata {
    static let universityCodes = [
        "KNU": "knu"
    ]

    static let nationalityCodes = [
        "Korea": "KR",
        "United States": "US",
        "China": "CN",
        "Japan": "JP",
        "Vietnam": "VN"
    ]
}

extension OnboardingFeature.State {
    var selectedUniversityCode: String? {
        selectedUniversity.first.flatMap { OnboardingSignUpMetadata.universityCodes[$0] }
    }

    var selectedNationalityCode: String? {
        selectedCountry.first.flatMap { OnboardingSignUpMetadata.nationalityCodes[$0] }
    }
}
