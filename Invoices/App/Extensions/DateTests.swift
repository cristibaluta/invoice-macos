//
//  DateTests.swift
//  InvoicesTests
//
//  Created by Cristian Baluta on 08.08.2022.
//

import XCTest
@testable import Invoices

class DateTests: XCTestCase {

    func testLastWorkingDay() throws {
        let date = Date(yyyyMMdd: "2022.07.15")
        let date2 = date?.endOfMonth(lastWorkingDay: true)
        XCTAssert(date2?.yyyyMMdd == "2022.07.29")
    }
}
