//
//  DexcomClient.swift
//  Scrumdinger
//
//  Created by Susan Zheng on 2026-02-06.
//

import Foundation
import Combine
import AuthenticationServices
import UIKit
import CoreData


@MainActor
class DexcomClient: NSObject, ObservableObject {

    // MARK: - Published state
    @Published var isAuthenticated = false
    @Published var glucoseValues: [EGV] = []

    // MARK: - Config (replace these)
    private let clientID = "fAOlRe2wItYjR1oM214c1DDSSwEHyI1N"
    private let clientSecret = "9phw2eAhRFFQutmW"
    private let redirectURI = "https://uselesslyuseful.github.io/Glyco/"

    // MARK: - Tokens
    private var accessToken: String?

    // MARK: - OAuth login
    func login() {
        let encodedRedirect = redirectURI.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        )!

        let urlString =
        "https://sandbox-api.dexcom.com/v2/oauth2/login" +
        "?client_id=\(clientID)" +
        "&redirect_uri=\(encodedRedirect)" +
        "&response_type=code" +
        "&scope=offline_access"

        guard let url = URL(string: urlString) else { return }

        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "glyco"
        ) { callbackURL, _ in
            guard
                let callbackURL,
                let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                    .queryItems?
                    .first(where: { $0.name == "code" })?
                    .value
            else { return }

            Task {
                await self.exchangeCodeForToken(code)
            }
        }

        session.presentationContextProvider = self
        session.start()
    }


    // MARK: - Token exchange
    private func exchangeCodeForToken(_ code: String) async {
        let url = URL(string: "https://sandbox-api.dexcom.com/v2/oauth2/token")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")

        let body =
        "grant_type=authorization_code" +
        "&code=\(code)" +
        "&redirect_uri=\(redirectURI)" +
        "&client_id=\(clientID)" +
        "&client_secret=\(clientSecret)"

        request.httpBody = body.data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let token = try JSONDecoder().decode(TokenResponse.self, from: data)

            accessToken = token.accessToken
            isAuthenticated = true
        } catch {
            print("Token error:", error)
        }
    }

    // MARK: - Fetch glucose data
    func fetchEGVs() async {
        guard let accessToken else { return }

        let endDate = dexcomDateString(from: Date())
        let startDate = dexcomDateString(
            from: Date().addingTimeInterval(-14 * 24 * 60 * 60) // 2 weeks for now
        )

        let urlString =
            "https://sandbox-api.dexcom.com/v3/users/self/egvs" +
            "?startDate=\(startDate)" +
            "&endDate=\(endDate)"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)",
                         forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            print("STATUS:", (response as? HTTPURLResponse)?.statusCode ?? -1)
            print(String(data: data, encoding: .utf8) ?? "no body")

            let decoded = try JSONDecoder().decode(EGVResponse.self, from: data)

            if let error = decoded.error {
                print("Dexcom API error:", error, decoded.errorDescription ?? "")
                return
            }

            glucoseValues = decoded.records ?? []

        } catch {
            print("EGV fetch error:", error)
        }
    }
    
    func importEGVsIntoCoreData(context: NSManagedObjectContext) {
        for egv in glucoseValues {

            // Parse date safely
            let date =
                dexcomDateFormatter.date(from: egv.systemTime) ??
                ISO8601DateFormatter().date(from: egv.systemTime) ??
                Date()

            // Convert to mmol
            let mmol = mgdlToMmol(egv.value)

            // Save using your existing pipeline
            addEntry(
                glucoseValue: mmol,
                dateEntered: date,
                context: context
            )
        }
    }
    
    private let dexcomDateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private func mgdlToMmol(_ value: Int) -> Double {
        Double(value) / 18.0
    }
    
    private func dexcomDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC required
        return formatter.string(from: date)
    }
}

// MARK: - ASWebAuthenticationSession support
extension DexcomClient: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(
        for session: ASWebAuthenticationSession
    ) -> ASPresentationAnchor {
        UIApplication.shared.windows.first!
    }
}

