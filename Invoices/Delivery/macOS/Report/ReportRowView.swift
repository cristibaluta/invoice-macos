//
//  ReportRowView.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.11.2021.
//

import SwiftUI

struct ReportRowView: View {
    
    var report: Report
    var completion: (Report) -> Void
    
    @State var group: String = ""
    @State var notes: String = ""
    @State var duration: String = ""
    
    init (report: Report, completion: @escaping (Report) -> Void) {
        self.report = report
        self.completion = completion
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            TextField("Group", text: $group).frame(width: 100).onChange(of: group) {_ in
                completion(Report(id: report.id,
                                  project_name: report.project_name,
                                  group: group,
                                  description: notes,
                                  duration: report.duration))
            }
            TextEditor(text: $notes).onChange(of: notes) {_ in
                completion(Report(id: report.id,
                                  project_name: report.project_name,
                                  group: group,
                                  description: notes,
                                  duration: report.duration))
            }
            Text(duration).frame(width: 50)
        }
        .padding(.bottom, 10)
        .contextMenu {
            Button(action: {
                group = "Meetings"
                completion(Report(id: report.id,
                                  project_name: report.project_name,
                                  group: group,
                                  description: notes,
                                  duration: report.duration))
            }) {
                Text("Mark as meeting")
            }
        }
        .onAppear {
            group = report.group ?? ""
            notes = report.description
            duration = report.duration.stringFormatWith2Digits
        }
    }
}
