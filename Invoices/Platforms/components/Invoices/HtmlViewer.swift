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
#else
import AppKit
typealias ViewRepresentable = NSViewRepresentable
#endif

struct HtmlViewer: ViewRepresentable {

    static let size = CGSize(width: 900, height: 1285)

    let htmlString: String?
    let onPdfGenerate: (Data) -> ()

    private var config: WKPDFConfiguration {
        let config = WebKit.WKPDFConfiguration()
        config.rect = CGRect(origin: .zero, size: HtmlViewer.size)
        return config
    }
    
    init (htmlString: String?, onPdfGenerate: @escaping (Data) -> ()) {
        self.htmlString = htmlString
        self.onPdfGenerate = onPdfGenerate
    }
    
#if os(iOS)
    func makeUIView(context: UIViewRepresentableContext<HtmlViewer>) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: UIViewRepresentableContext<HtmlViewer>) {
        
        webView.loadHTMLString(htmlString ?? "none", baseURL: nil)
        
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
#else
    func makeNSView(context: NSViewRepresentableContext<HtmlViewer>) -> WKWebView {
        return WKWebView()
    }

    func updateNSView(_ webView: WKWebView, context: NSViewRepresentableContext<HtmlViewer>) {
        
        webView.loadHTMLString(htmlString ?? "none", baseURL: nil)
        
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
#endif
}