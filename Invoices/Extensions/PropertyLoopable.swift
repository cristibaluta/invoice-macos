//
//  PropertyLoopable.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.01.2022.
//

import Foundation

protocol PropertyLoopable {
    func allProperties() -> [String]
}

extension PropertyLoopable {
    func allProperties() -> [String] {

        var result: [String] = []
        let mirror = Mirror(reflecting: self)

        // Optional check to make sure we're iterating over a struct or class
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            return []
        }

        for (property, _) in mirror.children {
            guard let property = property else {
                continue
            }
            result.append(property)
        }

        return result
    }
}
