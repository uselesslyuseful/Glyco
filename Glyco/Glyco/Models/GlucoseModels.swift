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
struct EGVResponse: Codable {
    let records: [EGV]
}

struct EGV: Identifiable, Codable {
    let id = UUID()
    let value: Int
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case value
        case timestamp = "systemTime"
    }
}
