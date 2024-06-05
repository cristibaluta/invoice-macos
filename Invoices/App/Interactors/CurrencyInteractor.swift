//
//  CurrencyInteractor.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.06.2024.
//

import Foundation

class CurrencyRateParser: NSObject, XMLParserDelegate {
    private var currentDate: String
    private var currentElement = ""
    private var foundEURRate: String?
    private var dateToSearch: String
    private var isTargetDate = false

    init(date: String) {
        self.dateToSearch = date
        self.currentDate = ""
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
        currentElement = elementName

        if elementName == "Cube" {
            if let date = attributeDict["date"] {
                currentDate = date
                isTargetDate = (date == dateToSearch)
            }
        }

        if elementName == "Rate" && isTargetDate {
            if let currency = attributeDict["currency"], currency == "EUR" {
                currentElement = "Rate"
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "Rate" && isTargetDate {
            foundEURRate = string
            currentElement = ""
            isTargetDate = false
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = ""
    }
}
