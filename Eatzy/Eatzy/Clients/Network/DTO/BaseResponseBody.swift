//
//  ResponseModelType.swift
//  Eatzy
//
//  Created by sun on 9/29/26.
//

import Foundation

struct EmptyResponseDTO: Decodable, Equatable {
    init() { }

    init(from decoder: Decoder) throws {
        self.init()
    }
}

struct APIErrorResponse: Decodable {
    let code: String
    let detail: String?
    let errors: [String]?
    let instance: String?
    let reason: String?
    let status: Int?
    let title: String?
    let type: String?
}
