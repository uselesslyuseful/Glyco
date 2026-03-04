//
//  GlucoseModels.swift
//  Scrumdinger
//
//  Created by Susan Zheng on 2026-02-06.
//

import Foundation

// MARK: - Token
struct TokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
    }
}

// MARK: - EGVs
struct EGVResponse: Decodable {
    let records: [EGV]?

    let error: String?
    let errorDescription: String?

    private enum CodingKeys: String, CodingKey {
        case records
        case error
        case errorDescription = "error_description"
    }
}

struct EGV: Identifiable, Decodable {
    let id = UUID()
    let systemTime: String
    let displayTime: String?
    let value: Int
    let trend: String?

    private enum CodingKeys: String, CodingKey {
        case systemTime
        case displayTime
        case value
        case trend
    }
}
