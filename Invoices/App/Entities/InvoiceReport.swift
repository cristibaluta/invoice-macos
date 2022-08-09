//
//  InvoiceReport.swift
//  Invoices
//
//  Created by Cristian Baluta on 03.01.2022.
//

import Foundation

struct InvoiceReport: Codable {
    
    var project_name: String
    var group: String
    var description: String
    var duration: Decimal
    
    enum CodingKeys: CodingKey {
        case project_name, group, description, duration
    }
    
    func encode (to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(project_name, forKey: .project_name)
        try container.encode(group, forKey: .group)
        try container.encode(description, forKey: .description)
        try container.encode(duration.stringValue, forKey: .duration)
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        project_name = try container.decode(String.self, forKey: .project_name)
        group = try container.decode(String.self, forKey: .group)
        description = try container.decode(String.self, forKey: .description)
        duration = Decimal(string: try container.decode(String.self, forKey: .duration)) ?? 0
    }
    
    init (project_name: String,
          group: String,
          description: String,
          duration: Decimal) {
        
        self.project_name = project_name
        self.group = group
        self.description = description
        self.duration = duration
    }
}
