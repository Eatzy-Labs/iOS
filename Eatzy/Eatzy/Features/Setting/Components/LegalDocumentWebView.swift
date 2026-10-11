//
//  LegalDocumentWebView.swift
//  Eatzy
//
//  Created by sun on 10/7/26.
//

import SwiftUI
import WebKit

struct LegalDocumentWebView: UIViewRepresentable {
    let url: URL?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        if let url {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
