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
    typealias RCViewRepresentable = UIViewRepresentable
#else
    import AppKit
    typealias RCViewRepresentable = NSViewRepresentable
#endif

struct HtmlView: RCViewRepresentable {
    
    let htmlString: String?
    let callback: (Data) -> ()
    
    init (htmlString: String?, callback: @escaping (Data) -> ()) {
        self.htmlString = htmlString
        self.callback = callback
    }
    
#if os(iOS)
    func makeUIView(context: UIViewRepresentableContext<HtmlView>) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: UIViewRepresentableContext<HtmlView>) {
        
        webView.loadHTMLString(htmlString ?? "none", baseURL: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let config = WebKit.WKPDFConfiguration()
            config.rect = CGRect(x: 0, y: 0, width: 900, height: 1285)
            webView.createPDF(configuration: config) { result in
                switch result {
                    case .success(let data):
                        callback(data)
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
#else
    func makeNSView(context: NSViewRepresentableContext<HtmlView>) -> WKWebView {
        return WKWebView()
    }

    func updateNSView(_ webView: WKWebView, context: NSViewRepresentableContext<HtmlView>) {
        
        webView.loadHTMLString(htmlString ?? "none", baseURL: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let config = WebKit.WKPDFConfiguration()
            config.rect = CGRect(x: 0, y: 0, width: 900, height: 1285)
            webView.createPDF(configuration: config) { result in
                switch result {
                    case .success(let data):
                        callback(data)
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
#endif
}
