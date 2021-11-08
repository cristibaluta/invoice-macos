//
//  HtmlView.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.09.2021.
//

import Foundation
import SwiftUI
import WebKit

struct HtmlView: NSViewRepresentable {
    
    let htmlString: String?
    let callback: (Data) -> ()
    
    init (htmlString: String?, callback: @escaping (Data) -> ()) {
        self.htmlString = htmlString
        self.callback = callback
    }
    
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
            
//            webView.evaluateJavaScript("document.getElementById('email').value", completionHandler: { result, error in
//                print(">>>> js evaluating email")
//                print(result)
//                print(error)
//            })
//
//            let builderBlock = unsafeBitCast({ msg in print(msg)}, to: AnyObject.self)
//            let ctx = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
//            ctx?.setObject(builderBlock, forKeyedSubscript: "myUpdateCallback" as (NSCopying & NSObjectProtocol))
////            ctx["myUpdateCallback"] = { msg in
////                print(msg)
////            };
//            ctx?.evaluateScript("document.getElementById('email').addEventListener('input', myUpdateCallback, false);")
        }
    }
}
