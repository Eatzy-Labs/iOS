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
}
