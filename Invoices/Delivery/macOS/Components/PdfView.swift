//
//  PdfView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.09.2021.
//

//import SwiftUI
//import PDFKit
//#if os(iOS)
//    import UIKit
//    typealias RCView = UIView
//    typealias RCViewRepresentable = UIViewRepresentable
//#else
//    import AppKit
//    typealias RCView = NSView
//    typealias RCViewRepresentable = NSViewRepresentable
//#endif
//
//struct PDFKitRepresentedView: RCViewRepresentable {
//    var url: URL?
//    let pdfView = PDFView()
//
//    init(_ url: URL?) {
//        self.url = url
//    }
//
//    func makeNSView (context: NSViewRepresentableContext<PDFKitRepresentedView>) -> PDFKitRepresentedView.NSViewType {
//        // Create a `PDFView` and set its `PDFDocument`.
////        if let url = self.url {
////            pdfView.document = PDFDocument(url: url)
////        } else {
////            pdfView.document = nil
////        }
//        return pdfView
//    }
//
//    func updateNSView(_ uiView: RCView, context: NSViewRepresentableContext<PDFKitRepresentedView>) {
//        if let url = self.url {
//            pdfView.document = PDFDocument(url: url)
//        } else {
//            pdfView.document = nil
//        }
//        pdfView.needsDisplay = true
//        pdfView.needsLayout = true
//        pdfView.layoutDocumentView()
//    }
//}
//
//struct PDFKitView: View {
//    var url: URL?
//
//    var body: some View {
//        PDFKitRepresentedView(url)
//    }
//}
