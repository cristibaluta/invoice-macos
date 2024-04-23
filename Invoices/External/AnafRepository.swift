//
//  AnafRepository.swift
//  Invoices
//
//  Created by Cristian Baluta on 02.03.2024.
//

import Foundation
import RCHttp
import RCPreferences

struct AnafTokenResponse: Decodable {
    let access_token: String?
    let refresh_token: String?
    let expires_in: Int?
}

enum AnafRepositoryPreferences: String, RCPreferencesProtocol {

    case accessToken = "accessToken"
    case accessTokenExpiration = "accessTokenExpiration"
    case refreshToken = "refreshToken"

    func defaultValue() -> Any {
        switch self {
            case .accessToken: return ""
            case .accessTokenExpiration: return Date()
            case .refreshToken: return ""
        }
    }

}

class AnafRepository {

    private let clientId = "e2ace7f58afabf1b210887b431a67e8a7e3ee71da655e365"
    private let clientSecret = "94d725659f1110fd4ca9eab6f6f57954b9f60ebad15d7e8a7e3ee71da655e365"

    private let pref = RCPreferences<AnafRepositoryPreferences>()

    func getRefreshToken() {
        let params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "refresh_token": pref.string(.refreshToken),
            "grant_type": "refresh_token"
        ]
        let client = RCHttp(baseURL: "https://logincert.anaf.ro")
        client.post(at: "anaf-oauth2/v1/token", parameters: params, contentType: .xForm) { response, data in

            if let tokens = try? JSONDecoder().decode(AnafTokenResponse.self, from: data) {
                print(tokens)
                guard let accessToken = tokens.access_token,
                      let accessTokenExpiration = tokens.expires_in,
                      let refreshToken = tokens.refresh_token else {
                    return
                }
                self.pref.set(accessToken, forKey: .accessToken)
//                self.pref.set(Date().addingTimeInterval(TimeInterval(accessTokenExpiration)), forKey: .accessTokenExpiration)
                self.pref.set(refreshToken, forKey: .refreshToken)
            }
        } failure: { err in
            print(err)
        }
    }

    func validate (xml: String) {
        let params = [
            "text": xml
        ]
        let client = RCHttp(baseURL: "https://webservicesp.anaf.ro")
        client.post(at: "prod/FCTEL/rest/validare/FACT1", parameters: params, contentType: .text) { response, data in

            print(response)
            print(String(data: data, encoding: .utf8))
        } failure: { err in
            print(err)
        }
    }

    func upload (xml: String) {
        let params = [
            "text": xml
        ]
        let client = RCHttp(baseURL: "https://api.anaf.ro")
        client.post(at: "test/FCTEL/rest/upload?standard=UBL&cif=34441362", parameters: params, contentType: .none) { response, data in

            print(response)
            print(String(data: data, encoding: .utf8))
        } failure: { err in
            print(err)
        }
    }
}
