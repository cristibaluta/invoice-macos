//
//  ReportView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.11.2021.
//

import SwiftUI
import Combine

struct ReportEditorView: View {
    
    @ObservedObject var viewModel: ReportEditorModel
    
    let columns = [
        GridItem(.adaptive(minimum: 160))
    ]

    var body: some View {
        
        let _ = Self._printChanges()

        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<viewModel.allProjects.count, id: \.self) { i in
                        Toggle(viewModel.allProjects[i].name, isOn: $viewModel.allProjects[i].isOn)
                        .onChange(of: viewModel.allProjects[i].isOn) { val in
                            viewModel.updateReports()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 50)
            .padding(10)

            Divider()
            // List of reports
            List(viewModel.reports) { report in
                ReportRowView(report: report) { newReport in
                    viewModel.updateReport(newReport)
                }
            }
        }

    }

}
