//
//  ResponseModelType.swift
//  Eatzy
//
//  Created by sun on 9/29/26.
//

import Foundation

protocol ResponseModelType: Decodable { }

struct BaseResponseBody<T: ResponseModelType>: Decodable {
    let success: Bool?
    let code: String?
    let message: String
    let data: T?
}

struct EmptyResponseDTO: ResponseModelType, Equatable {
    init() { }

    init(from decoder: Decoder) throws {
        self.init()
    }
}

struct APIErrorResponse: Decodable {
    let message: String?
    let code: String?
}
