//
//  String+Validation.swift
//  Eatzy
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return range(of: pattern, options: .regularExpression) != nil
    }

    var containsOnlyLettersAndNumbers: Bool {
        range(of: "^[A-Za-z0-9]+$", options: .regularExpression) != nil
    }

    var hasRequiredPasswordCharacters: Bool {
        let hasLetter = range(of: "[A-Za-z]", options: .regularExpression) != nil
        let hasNumber = range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialCharacter = range(
            of: "[^A-Za-z0-9]",
            options: .regularExpression
        ) != nil

        return hasLetter && hasNumber && hasSpecialCharacter
    }
}
