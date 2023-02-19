//
//  ViewController.swift
//  StackPinLayout
//
//  Created by Muhammad Ghifari on 29/07/21.
//

import UIKit
import PinLayout
import WebKit
import Typist

class ViewController: UIViewController, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "JSEvent" {
            if let json = (message.body as? String)?.toJsonMap() {
                
                if let editorHeight = json["height"] as? Int {
                    parentView?.editorHeight = editorHeight
                    UIView.animate(withDuration: 0.2) {
                        self.parentView?.setNeedsLayout()
                        self.parentView?.layoutIfNeeded()
                    }
                }
                
                if let mention = (json["mention"] as? [String: Any]), let isMentionDetected = mention["isMentionDetected"] as? Bool{
                    
                    if isMentionDetected {
                        let javascript = "var cursorPosition = tinymce.activeEditor.selection.getRng(); JSON.stringify({ yBottom: cursorPosition.getBoundingClientRect().bottom + window.scrollY, yTop: cursorPosition.getBoundingClientRect().top + window.scrollY })"

                        parentView?.webView.evaluateJavaScript(javascript) { (result, error) in
                            if error != nil {
                                print("Error getting cursor position: \(error!)")
                            } else {
                                if let jsonString = result as? String, let json = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: []) as? [String: CGFloat] {
                                    let yTop = json["yTop"] ?? 0
                                    let yBottom = json["yBottom"] ?? 0
                                    var webViewMinY = self.parentView?.webView.frame.minY ?? 0
                                    let safeTop = self.parentView?.pin.safeArea.top ?? 0
                                    webViewMinY = webViewMinY < safeTop ? safeTop : webViewMinY
                                    self.parentView?.cursorYAxisTop = yTop + webViewMinY
                                    self.parentView?.cursorYAxisBottom = yBottom + webViewMinY
                                    self.parentView?.setNeedsLayout()
                                    self.parentView?.layoutIfNeeded()
                                }
                            }
                        }
                        
                    } else {
                        self.parentView?.cursorYAxisTop = -1
                        self.parentView?.setNeedsLayout()
                        self.parentView?.layoutIfNeeded()
                    }
                }
                
                if let formatter = json["formatter"] as? [String:Any] {
                    self.parentView?.toolbar.bindData(formatter: formatter)
                }
            }
        }
    }
    
    
    var parentView: ViewControllerView?
    let userController = WKUserContentController()
    
    override func viewDidLoad() {
        let config = WKWebViewConfiguration()
        config.userContentController = userController
        parentView = ViewControllerView(configuration: config)
        guard let parentView = parentView else { return }
        view = parentView
        
        userController.add(self, name: "JSEvent")
        
        guard let htmlPath = Bundle.main.path(forResource: "editor", ofType: "html") else {
            print("HTML file not found")
            return
        }

        let htmlURL = URL(fileURLWithPath: htmlPath, isDirectory: false)
        parentView.webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        parentView.webView.allowsBackForwardNavigationGestures = false
        parentView.webView.scrollView.isScrollEnabled = false
        
    }
}


extension String {
    var htmlDecoded: String {
            guard let data = self.data(using: .utf8) else {
                return self
            }
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            do {
                let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
                return attributedString.string
            } catch {
                return self
            }
        }
}

class ViewControllerView:UIView{
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let webView: WKWebView
    
    var editorHeight = 0
    var cursorYAxisTop: CGFloat = -1
    var cursorYAxisBottom: CGFloat = -1
    
    let keyboard = Typist.shared
    var keyboardHeight:CGFloat = 0
    
    let commentViewContainer = UIView()
    let commentViewPlaceholder = UILabel()
    let commentViewBottomPadding = UIView()
    
    let testMentionView = UIView()
    
    var toolbar:TinyMCEToolbar
    
    var keyboardShown = false
    init(configuration: WKWebViewConfiguration) {
        webView = WKWebView(frame: .zero, configuration: configuration)
        toolbar = TinyMCEToolbar(webView: webView)
        super.init(frame: .zero)

        addSubview(webView)
        addSubview(testMentionView)
        addSubview(toolbar)
        testMentionView.backgroundColor = .green
        
        addSubview(commentViewContainer)
        commentViewContainer.addSubview(commentViewPlaceholder)
        commentViewContainer.addSubview(commentViewBottomPadding)
        commentViewContainer.backgroundColor = .white
        
        keyboard.on(event: .willShow) { [weak self] (options) in
            self?.keyboardHeight = options.endFrame.size.height
            self?.keyboardShown = true
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
        .start()
        
        keyboard.on(event: .willHide) { [weak self] (options) in
            self?.keyboardHeight = self?.pin.safeArea.bottom ?? 0
            self?.keyboardShown = false
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
        .start()
        
        commentViewPlaceholder.text = "Write a comment"
        commentViewContainer.onTap { UITapGestureRecognizer in
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        keyboardHeight = keyboardHeight == 0 ? pin.safeArea.bottom : keyboardHeight
        performLayout()
        backgroundColor = .white
    }
    
    func performLayout() {
        let approximateEditorPadding = 32
        var heightValue = CGFloat(editorHeight + approximateEditorPadding)
        
        toolbar.pin.horizontally().bottom(keyboardHeight).wrapContent(.vertically)
        let maxPossibleHeight = bounds.height - keyboardHeight - pin.safeArea.top - toolbar.frame.height
        heightValue = heightValue > maxPossibleHeight ? maxPossibleHeight : heightValue
        
        webView.pin.horizontally().above(of: toolbar).height(heightValue)
        webView.layer.shadowColor = UIColor.black.cgColor
        webView.layer.shadowOffset = CGSize(width: 3, height: 3)
        webView.layer.shadowOpacity = 0.7
        webView.layer.shadowRadius = 4
        
        commentViewBottomPadding.pin.height(pin.safeArea.bottom + keyboardHeight)
        commentViewPlaceholder.pin.sizeToFit(.width).horizontally(16).above(of: commentViewBottomPadding)
        commentViewContainer.pin.bottom().horizontally()
        commentViewContainer.layer.shadowColor = UIColor.black.cgColor
        commentViewContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
        commentViewContainer.layer.shadowOpacity = 0.7
        commentViewContainer.layer.shadowRadius = 4
        commentViewContainer.isHidden = true
        
        let isMentionPositionedAbove = cursorYAxisTop > (webView.frame.maxY - cursorYAxisTop)
        
        testMentionView.isHidden = cursorYAxisTop == -1
        testMentionView.pin.horizontally()
        
        if isMentionPositionedAbove {
            testMentionView.pin.height(cursorYAxisTop).top()
        } else {
            testMentionView.pin.top(cursorYAxisBottom).height(webView.frame.maxY - cursorYAxisTop)
        }
    }
    
}

extension String {
    func toJsonMap() -> [String:Any]? {
        return try? JSONSerialization.jsonObject(with: self.data(using: .utf8)!, options: []) as? [String: Any]
    }
}



