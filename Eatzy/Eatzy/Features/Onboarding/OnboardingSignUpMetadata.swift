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
        "Vietnam": "VN",
        "Thailand": "TH",
        "Indonesia": "ID",
        "Malaysia": "MY"
    ]

    static func nationalityCode(for value: String) -> String {
        nationalityCodes[value] ?? value
    }

    static func nationalityName(for code: String) -> String {
        nationalityCodes.first(where: { $0.value == code })?.key ?? code
    }
}

extension OnboardingFeature.State {
    var selectedUniversityCode: String? {
        selectedUniversity.first.flatMap { OnboardingSignUpMetadata.universityCodes[$0] }
    }

    var selectedNationalityCode: String? {
        selectedCountry.first.flatMap { OnboardingSignUpMetadata.nationalityCodes[$0] }
    }
}
