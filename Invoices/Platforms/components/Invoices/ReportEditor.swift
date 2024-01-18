//
//  ReportView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.11.2021.
//

import SwiftUI
import Combine

struct ReportEditor: View {
    
    @ObservedObject var viewModel: ReportEditorViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 160))
    ]
    
    init (viewModel: ReportEditorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
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
            List(viewModel.reports) { report in
                ReportRowView(report: report) { newReport in
                    viewModel.updateReport(newReport)
                }
            }
        }

    }

}
