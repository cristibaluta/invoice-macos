//
//  PdfView.swift
//  Invoices
//
//  Created by Cristian Baluta on 07.09.2021.
//

import SwiftUI
import AppKit
import PDFKit

struct PDFKitRepresentedView: NSViewRepresentable {
    var url: URL?
    let pdfView = PDFView()

    init(_ url: URL?) {
        self.url = url
    }

    func makeNSView (context: NSViewRepresentableContext<PDFKitRepresentedView>) -> PDFKitRepresentedView.NSViewType {
        // Create a `PDFView` and set its `PDFDocument`.
//        if let url = self.url {
//            pdfView.document = PDFDocument(url: url)
//        } else {
//            pdfView.document = nil
//        }
        return pdfView
    }

    func updateNSView(_ uiView: NSView, context: NSViewRepresentableContext<PDFKitRepresentedView>) {
        if let url = self.url {
            pdfView.document = PDFDocument(url: url)
        } else {
            pdfView.document = nil
        }
        pdfView.needsDisplay = true
        pdfView.needsLayout = true
        pdfView.layoutDocumentView()
    }
}

struct PDFKitView: View {
    var url: URL?

    var body: some View {
        PDFKitRepresentedView(url)
    }
}
