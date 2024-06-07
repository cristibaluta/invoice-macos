//
//  CurrencyInteractor.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.06.2024.
//

import Foundation

class CurrencyInteractor: NSObject, XMLParserDelegate {
    private var foundEURRate: String?
    private var dateToSearch: String?
    private var isTargetDate = false
    private var isTargetCurrency = false

    func getLatestEuroExchangeRateFromLastDayOfTheMonth(completion: @escaping (String?) -> Void) {

        dateToSearch = Date().endOfMonth(lastWorkingDay: true).yyyyMMdd_dashes

        BNRRepository().getLatest10ExchangeRates { data in
            let rate = self.parse(xmlData: data)
            completion(rate)
        }
    }

    func parse(xmlData: Data) -> String? {
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        if parser.parse() {
            return foundEURRate
        } else {
            print("Failed to parse XML")
            return nil
        }
    }

    // XMLParserDelegate methods
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {

        if elementName == "Cube" {
            if let date = attributeDict["date"], date == dateToSearch {
                isTargetDate = true
            }
        }

        if elementName == "Rate" && isTargetDate {
            if let currency = attributeDict["currency"], currency == "EUR" {
                isTargetCurrency = true
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isTargetCurrency && isTargetDate {
            foundEURRate = string
            isTargetDate = false
            isTargetCurrency = false
        }
    }

    func parser(_ parser: XMLParser, 
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
    }
}
