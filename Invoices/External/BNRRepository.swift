//
//  BNRRepository.swift
//  Invoices
//
//  Created by Cristian Baluta on 06.06.2024.
//

import Foundation
import RCHttp

class BNRRepository {

    func getLatest10ExchangeRates(completion: @escaping (Data) -> Void) {
        let client = RCHttp(baseURL: "https://bnr.ro")
        client.get(at: "nbrfxrates10days.xml") { response, data in
            print(data)
            completion(data)
        } failure: { err in
            print(err)
        }
    }
}
