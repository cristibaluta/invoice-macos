//
//  HtmlView.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.09.2021.
//

import Foundation
import SwiftUI
import WebKit
#if os(iOS)
import UIKit
typealias ViewRepresentable = UIViewRepresentable
typealias ViewContext = UIViewRepresentableContext<HtmlViewer>
#else
import AppKit
typealias ViewRepresentable = NSViewRepresentable
typealias ViewContext = NSViewRepresentableContext<HtmlViewer>
#endif

class WrappedData {
    var data: Data = Data()
}

struct HtmlViewer: ViewRepresentable {

    static let size = CGSize(width: 900, height: 1285)

    let htmlString: String
    let wrappedPdfData: WrappedData

#if os(iOS)
    func makeUIView(context: ViewContext) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: ViewContext) {
        updateView(webView, context: context)
    }
#else
    func makeNSView(context: ViewContext) -> WKWebView {
        return WKWebView()
    }

    func updateNSView(_ webView: WKWebView, context: ViewContext) {
        updateView(webView, context: context)
    }
#endif

    private func updateView(_ webView: WKWebView, context: ViewContext) {
        webView.loadHTMLString(htmlString, baseURL: nil)
        // We need a delay before generating the pdf because the data is not yet on screen
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
            generatePdf(webView)
        }
    }

    private func generatePdf(_ webView: WKWebView) {
        webView.createPDF(configuration: config) { result in
            switch result {
                case .success(let data):
                    print(">>>>> pdf generated")
                    self.wrappedPdfData.data = data
                case .failure(let error):
                    print(error)
            }
        }
    }

    private var config: WKPDFConfiguration {
        let config = WebKit.WKPDFConfiguration()
        config.rect = CGRect(origin: .zero, size: HtmlViewer.size)
        return config
    }

}
