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

struct HtmlViewer: ViewRepresentable {

    class Coordinator: NSObject {
        var webView: WKWebView?
    }

    static let size = CGSize(width: 900, height: 1285)

    let htmlString: String
    var pdfData: Data?
    let onPdfGenerate: (Data) -> ()

    private var config: WKPDFConfiguration {
        let config = WebKit.WKPDFConfiguration()
        config.rect = CGRect(origin: .zero, size: HtmlViewer.size)
        return config
    }
    
    init (htmlString: String, pdfData: Data?, onPdfGenerate: @escaping (Data) -> ()) {
        self.htmlString = htmlString
        self.pdfData = pdfData
        self.onPdfGenerate = onPdfGenerate
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

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
        generatePdf(webView)
    }

    private func generatePdf(_ webView: WKWebView) {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            webView.createPDF(configuration: config) { result in
                switch result {
                    case .success(let data):
                        onPdfGenerate(data)
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }

}
