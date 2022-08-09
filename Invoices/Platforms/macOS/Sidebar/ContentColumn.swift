//
//  ContentView.swift
//  Invoices
//
//  Created by Cristian Baluta on 16.07.2021.
//
import Foundation
import SwiftUI
import Combine
import BarChart
import RCPreferences

enum Section: Int {
    case invoice
    case report
}

enum ViewType {
    case noProjects
    case noInvoices
    case charts(ChartConfiguration, ChartConfiguration)
    case newInvoice(InvoiceAndReportState)
    case invoice(InvoiceAndReportState)
    case deleteInvoice(InvoiceFolder)
    case company(CompanyData?)
    case report(ReportState)
    case error(String, String)
}

final class ContentColumnState: ObservableObject {

    @Published var section: Section = .invoice
    @Published var type: ViewType = .noProjects
//    @Published var invoiceReportState: InvoiceReportState?
//    @Published var reportState: ReportState?
//    var currentInvoiceData: InvoiceData? {
//        didSet {
////            if let project = selectedProject, let data = currentInvoiceData {
////                invoiceState = InvoicesState(project: project, data: data)
////                reportState = ReportState(project: project, data: data)
////            } else {
////                invoiceState = nil
////                reportState = nil
////            }
//        }
//    }
//    @Published var projectName: String = ""
//    @Published var invoiceName: String = ""
//    @Published var selectedProject: Project?
//    @Published var totalPrice: String = ""
//    var priceChartConfig = ChartConfiguration()
//    var rateChartConfig = ChartConfiguration()
//    var priceChartEntries: [ChartDataEntry] = []
//    var rateChartEntries: [ChartDataEntry] = []
//    private var pref = RCPreferences<UserPreferences>()

//    init() {
//        print("init ContentViewState")
//
//        priceChartConfig.data.color = .red
//        priceChartConfig.xAxis.labelsColor = .gray
//        priceChartConfig.xAxis.ticksColor = .gray
//        priceChartConfig.labelsCTFont = CTFontCreateWithName(("SFProText-Regular" as CFString), 10, nil)
//        priceChartConfig.xAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
//        priceChartConfig.yAxis.labelsColor = .gray
//        priceChartConfig.yAxis.ticksColor = .gray
//        priceChartConfig.yAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
//        priceChartConfig.yAxis.minTicksSpacing = 30.0
//        priceChartConfig.yAxis.formatter = { value, decimals in
//            let format = value == 0 ? "" : "RON"
//            return String(format: "%.\(decimals)f \(format)", value)
//        }
//
//        rateChartConfig.data.color = .orange
//        rateChartConfig.xAxis.labelsColor = .gray
//        rateChartConfig.xAxis.ticksColor = .gray
//        rateChartConfig.labelsCTFont = CTFontCreateWithName(("SFProText-Regular" as CFString), 10, nil)
//        rateChartConfig.xAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
//        rateChartConfig.yAxis.labelsColor = .gray
//        rateChartConfig.yAxis.ticksColor = .gray
//        rateChartConfig.yAxis.ticksStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 4])
//        rateChartConfig.yAxis.minTicksSpacing = 30.0
//        rateChartConfig.yAxis.formatter = { value, decimals in
//            let format = value == 0 ? "" : "€"
//            return String(format: "%.\(decimals)f \(format)", value)
//        }
//    }

//    func showChart (_ prices: [ChartDataEntry]?, _ rates: [ChartDataEntry]?) {
//        DispatchQueue.main.async {
//            if let prices = prices, let rates = rates {
//                self.priceChartEntries = prices.reversed()
//                self.rateChartEntries = rates.reversed()
//            }
//            self.priceChartConfig.data.entries = self.priceChartEntries
//            self.rateChartConfig.data.entries = self.rateChartEntries
//            self.type = .charts(self.priceChartConfig, self.rateChartConfig)
//            // Bug in charts, need to set the data twice
//            DispatchQueue.main.async {
//                self.priceChartConfig.data.entries = self.priceChartEntries
//                self.rateChartConfig.data.entries = self.rateChartEntries
//                self.type = .charts(self.priceChartConfig, self.rateChartConfig)
//            }
//        }
//    }

//    func showSection (_ section: Section) {
//        self.section = section
//        switch section {
//            case .invoice:
//                type = .invoice(invoiceReportState!)
//            case .report:
//                type = .report(reportState!)
//        }
//    }

//    func generateNewInvoice (using invoice: InvoiceFolder?) {
//        guard let project = selectedProject else {
//            return
//        }
//        InvoicesManager.shared.generateNewInvoice(in: project, using: invoice) { invoiceFolder, invoiceData in
//            self.section = .invoice
////            self.selectedInvoice = invoiceFolder
//            self.invoiceName = invoiceFolder.name
//            self.currentInvoiceData = invoiceData
//            guard let state = self.invoiceState else {
//                return
//            }
//            self.viewState = .newInvoice(state)
//        }
//    }

//    func showInvoice() {
//        guard let state = self.invoiceReportState else {
//            return
//        }
//        type = .invoice(state)
//    }

//    func save() {
//        switch section {
//            case .invoice:
//                invoiceReportState?.save() { invoiceFolder in
//                    if let folder = invoiceFolder {
////                        self.delegate?.didSaveInvoice(folder)
//                    }
//                }
//            case .report:
//                reportState?.save()
//        }
//    }

//    func export (isPdf: Bool) {
//        save()
////        switch section {
////            case .invoice:
//////                invoiceState?.export(isPdf: isPdf)
////            case .report:
//////                reportState?.export(isPdf: isPdf)
////        }
//    }

//    func deleteInvoice (_ invoice: InvoiceFolder) {
////        AppFilesManager.default.executeInSelectedDir { url in
////            let invoiceUrl = url.appendingPathComponent(selectedProject?.name ?? "").appendingPathComponent(invoice.name)
////            do {
////                try FileManager.default.removeItem(at: invoiceUrl)
////                delegate?.didDeleteInvoice()
////            } catch {
////
////            }
////        }
//    }
}

struct ContentColumn: View {

//    @EnvironmentObject var projectsState: ProjectsState
//    @EnvironmentObject var companiesState: CompaniesState
    @EnvironmentObject var contentColumnState: ContentColumnState

    var body: some View {

        let _ = Self._printChanges()

        switch contentColumnState.type {
            case .noProjects:
                NewProjectView() { _ in

                }
                .padding(40)

            case .noInvoices:
                NoInvoicesView() {

                }
                .padding(40)

            case .newInvoice(let invoiceReportState):
                NewInvoiceView()
                .environmentObject(invoiceReportState)
                .padding(40)

            case .charts(let priceChart, let rateChart):
                Text("Chart view")
//                ChartsView(state: state, priceChartConfig: priceChart, rateChartConfig: rateChart)
//                .padding(40)

            case .invoice(let invoiceReportState):
                InvoiceAndReportColumn(state: invoiceReportState)
                .modifier(Toolbar(state: invoiceReportState))

            case .deleteInvoice(let invoice):
                Text("Delete view")
//                DeleteConfirmationView(state: state, invoice: invoice)
//                .padding(40)

            case .company(let companyData):
                Text("Company view")
//                NewCompanyView(state: CompaniesState(data: companyData), company: companyData, callback: {
//                    state.viewState = .noInvoices
//                })
//                .padding(40)

            case .report(let reportState):
                Text("Report view")
//                ReportView(state: reportState).frame(width: 920)
//                .modifier(Toolbar(state: state))

            case .error(let title, let message):
                VStack(alignment: .center) {
                    Text(title).bold()
                    Text(message)
                }
                .padding(40)
        }
        
    }

}
