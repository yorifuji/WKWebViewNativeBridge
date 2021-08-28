//
//  ViewController.swift
//  WKWebViewNativeBridge
//
//  Created by yorifuji on 2021/08/28.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var webView: WKWebView!
    let handlerName = "nativeBridge"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadLocalHTML()
    }
}

extension ViewController {
    private func setupWebView() {

        let userContentController: WKUserContentController = WKUserContentController()
        userContentController.add(self, name: handlerName)

        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        view = webView
    }

    private func loadLocalHTML() {
        guard let path: String = Bundle.main.path(forResource: "index", ofType: "html") else { return }
        let localHTMLUrl = URL(fileURLWithPath: path, isDirectory: false)
        webView.loadFileURL(localHTMLUrl, allowingReadAccessTo: localHTMLUrl)
    }

    private func evalJavaScript() {
        let message = "asynchronus message."
        let executeScript: String = "callFromNative(\"\(message)\");"
        webView.evaluateJavaScript(executeScript, completionHandler: { (object, error) -> Void in
            if let object = object {
                print(object)
            }
            if let error = error {
                print(error)
            }
        })
    }

}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == handlerName) {
            print(message.body)
            evalJavaScript()
        }
    }
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {


        // decode json stringify text.
        let jsonText = prompt.data(using: .utf8)!
        let json = try! JSONDecoder().decode([String : String].self, from: jsonText)
        // json["foo"] --> bar

        // return json stringify text.
        let dict = ["body" : "synchronus message."]
        let data = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let text = String(data: data, encoding: String.Encoding.utf8) ?? ""
        completionHandler(text)
    }
}

