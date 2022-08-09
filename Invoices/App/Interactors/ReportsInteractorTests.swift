//
//  ReportsInteractorTests.swift
//  Invoices
//
//  Created by Cristian Baluta on 24.11.2021.
//

import XCTest
@testable import Invoices

class ReportsInteractorTests: XCTestCase {

    let reports = [
        Report(project_name: "p", group: "g1", description: "d1", duration: 8),
        Report(project_name: "p", group: "g2", description: "d2", duration: 4.5),
        Report(project_name: "p", group: "g2", description: "d3", duration: 4.5),
        Report(project_name: "p", group: "g2", description: "d3.3", duration: 6.5),
        Report(project_name: "p", group: "g3", description: "d4", duration: 20),
        Report(project_name: "p", group: "g4", description: "d5", duration: 30)
    ]
    
    func testSameDuration() throws {
        let duration: Decimal = 8+4.5+4.5+6.5+20+30
        let projects = ReportsInteractor().groupReports(reports, duration: duration)
        
        let groups = projects["p"]!
        XCTAssertTrue(groups.count == 4, "Should be 4 groups")
        
        XCTAssertTrue(groups["g1"]?.count == 1, "Should be 1 report")
        XCTAssertTrue(groups["g2"]?.count == 3, "Should be 3 reports")
        XCTAssertTrue(groups["g3"]?.count == 1, "Should be 1 report")
        XCTAssertTrue(groups["g4"]?.count == 1, "Should be 1 report")
        
        XCTAssertTrue(groups["g1"]![0].duration == 8, "")
        XCTAssertTrue(groups["g2"]![0].duration + groups["g2"]![1].duration + groups["g2"]![2].duration == 15.5, "")
        XCTAssertTrue(groups["g3"]![0].duration == 20, "")
        XCTAssertTrue(groups["g4"]![0].duration == 30, "")
        
        XCTAssertTrue(groups["g1"]![0].duration +
                      groups["g2"]![0].duration +
                      groups["g2"]![1].duration +
                      groups["g2"]![2].duration +
                      groups["g3"]![0].duration +
                      groups["g4"]![0].duration == duration, "Total duration is wrong")
    }
    
    func testExtraDuration() throws {
        let duration: Decimal = 8+4.5+4.5+6.5+20+30
        let extraDuration: Decimal = 33
        let projects = ReportsInteractor().groupReports(reports, duration: duration + extraDuration)
        
        let groups = projects["p"]!
        XCTAssertTrue(groups.count == 4, "Should be 4 groups")
        
        XCTAssertTrue(groups["g1"]?.count == 1, "Should be 1 report")
        XCTAssertTrue(groups["g2"]?.count == 3, "Should be 3 reports")
        XCTAssertTrue(groups["g3"]?.count == 1, "Should be 1 report")
        XCTAssertTrue(groups["g4"]?.count == 1, "Should be 1 report")
        
        XCTAssertTrue(groups["g1"]![0].duration > 8, "")
        XCTAssertTrue(groups["g2"]![0].duration + groups["g2"]![1].duration + groups["g2"]![2].duration > 15.5, "")
        XCTAssertTrue(groups["g3"]![0].duration > 20, "")
        XCTAssertTrue(groups["g4"]![0].duration > 30, "")
        
        XCTAssertTrue(groups["g1"]![0].duration +
                      groups["g2"]![0].duration +
                      groups["g2"]![1].duration +
                      groups["g2"]![2].duration +
                      groups["g3"]![0].duration +
                      groups["g4"]![0].duration == duration + extraDuration, "Total duration is wrong")
    }
    
    func testLessDuration() throws {
        let duration: Decimal = 8+4.5+4.5+6.5+20+30
        let extraDuration: Decimal = -53
        let projects = ReportsInteractor().groupReports(reports, duration: duration + extraDuration)
        
        let groups = projects["p"]!
        XCTAssertTrue(groups.count == 4, "Should be 4 groups")
        
        XCTAssertTrue(groups["g1"]?.count == 1, "Should be 1 report")
        XCTAssertTrue(groups["g2"]?.count == 3, "Should be 3 reports")
        XCTAssertTrue(groups["g3"]?.count == 1, "Should be 1 report")
        XCTAssertTrue(groups["g4"]?.count == 1, "Should be 1 report")
        
        XCTAssertTrue(groups["g1"]![0].duration >= 0.5, "")
        XCTAssertTrue(groups["g2"]![0].duration + groups["g2"]![1].duration + groups["g2"]![2].duration >= 0.5, "")
        XCTAssertTrue(groups["g3"]![0].duration >= 0.5, "")
        XCTAssertTrue(groups["g4"]![0].duration >= 0.5, "")
        
        XCTAssertTrue(groups["g1"]![0].duration +
                      groups["g2"]![0].duration +
                      groups["g2"]![1].duration +
                      groups["g2"]![2].duration +
                      groups["g3"]![0].duration +
                      groups["g4"]![0].duration == duration + extraDuration, "Total duration is wrong")
    }
}
