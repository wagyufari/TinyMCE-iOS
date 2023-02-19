//
//  TinyMCEToolbar.swift
//  StackPinLayout
//
//  Created by Muhammad Ghifari on 18/2/2023.
//

import Foundation
import UIKit
import PinLayout
import WebKit

class ToolbarButtonImage: UIView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView = UIImageView()
    var isSelected: Bool = false {
        didSet{
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    init(image: UIImage?, tint: UIColor? = nil, size: CGFloat? = nil){
        super.init(frame: .zero)
        let size = size ?? 22
        addSubview(imageView)
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = tint ?? .neutral600
        imageView.pin.height(size).width(size)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = isSelected ? .blue200 : .clear
        layer.cornerRadius = 4
        pin.wrapContent(padding: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
    }
}

class TinyMCEToolbar: UIView{
    
    var currentFontSize: HtmlFontSize = .Paragraph
    
    let stackView = UIStackPinView().apply{
        $0.isManualWrap = true
        $0.axis = .horizontal
        $0.spacing = 4
        $0.verticalAlignment = .CenterVertically
    }
    let scrollView = UIScrollView()
    
    
    let fontSizeContainer = UIView()
    let fontSizeName = UILabel()
    let fontSizeDropdownIcon = UIImageView()
    
    let undo = ToolbarButtonImage(image: UIImage(named: "undo"))
    let redo = ToolbarButtonImage(image: UIImage(named: "redo"))
    let bold = ToolbarButtonImage(image: UIImage(named: "bold"))
    let italic = ToolbarButtonImage(image: UIImage(named: "italic"))
    let underline = ToolbarButtonImage(image: UIImage(named: "underline"))
    let strikethrough = ToolbarButtonImage(image: UIImage(named: "strikethrough"))
    
    let unorderedList = ToolbarButtonImage(image: UIImage(named: "unordered_list"))
    let orderedList = ToolbarButtonImage(image: UIImage(named: "ordered_list"))
    
    let webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init(frame: .zero)
        backgroundColor = .white
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.showsHorizontalScrollIndicator = false
        
        undo.onTap { UITapGestureRecognizer in
            self.evaluateExecute(command: "'undo'")
        }
        redo.onTap { UITapGestureRecognizer in
            self.evaluateExecute(command: "'redo'")
        }
        bold.onTap { UITapGestureRecognizer in
            self.evaluateExecute(command: "'bold'")
        }
        italic.onTap { UITapGestureRecognizer in
            self.evaluateExecute(command: "'italic'")
        }
        underline.onTap { UITapGestureRecognizer in
            self.evaluateExecute(command: "'underline'")
        }
        strikethrough.onTap { UITapGestureRecognizer in
            self.evaluateExecute(command: "'strikethrough'")
        }
        
        fontSizeContainer.onTap { UITapGestureRecognizer in
            FontSizeSheetController.show(with: self.parentViewController, currentFontSize: self.currentFontSize){ format in
                self.evaluateExecute(command: "'formatblock', false, '\(format)'")
            }
        }
        
        orderedList.onTap { UITapGestureRecognizer in
            self.evaluateExecute(command: "'InsertOrderedList'")
        }
        unorderedList.onTap { UITapGestureRecognizer in
            self.evaluateExecute(command: "'InsertUnorderedList'")
        }
        
        fontSizeName.text = "Paragraph"
        fontSizeName.font = .systemFont(ofSize: 14)
        fontSizeDropdownIcon.image = UIImage(named: "expand_more")?.withRenderingMode(.alwaysTemplate)
        fontSizeDropdownIcon.tintColor = .neutral700
        fontSizeContainer.backgroundColor = .neutral300
        fontSizeContainer.layer.cornerRadius = 4
        
        fontSizeContainer.addSubview(fontSizeName)
        fontSizeContainer.addSubview(fontSizeDropdownIcon)
    }
    
    func evaluateExecute(command: String) {
        webView.evaluateJavaScript("var editor = tinymce.get('textarea'); editor.execCommand(\(command));") { (result, error) in}
    }
    
    override func layoutSubviews() {
        performLayout()
    }
    
    func bindData(formatter: [String:Any]) {
        undo.imageView.tintColor = formatter["hasUndo"] as? Bool == true ? .neutral800 : .neutral600
        redo.imageView.tintColor = formatter["hasRedo"] as? Bool == true ? .neutral800 : .neutral600
        bold.isSelected = formatter["isBold"] as? Bool == true
        italic.isSelected = formatter["isItalic"] as? Bool == true
        underline.isSelected = formatter["isUnderline"] as? Bool == true
        strikethrough.isSelected = formatter["isStrikethrough"] as? Bool == true
        orderedList.isSelected = formatter["isOrderedList"] as? Bool == true
        unorderedList.isSelected = formatter["isUnorderedList"] as? Bool == true
        currentFontSize = HtmlFontSize(rawValue: formatter["formatblock"] as? String ?? "p") ?? .Paragraph
        fontSizeName.text = currentFontSize.title()
    }
    
    func performLayout() {
        pin.height(46)
        
        scrollView.pin.all()
        
        stackView.removeArrangedSubviews()
        
        fontSizeName.pin.sizeToFit()
        fontSizeDropdownIcon.pin.height(20).width(20).right(of: fontSizeName).marginLeft(32)
        fontSizeName.pin.vCenter()
        fontSizeContainer.pin.wrapContent(padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 4))
        
        stackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0)))
        stackView.addArrangedSubview(undo)
        stackView.addArrangedSubview(redo)
        stackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0)))
        stackView.addArrangedSubview(fontSizeContainer)
        stackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0)))
        stackView.addArrangedSubview(bold)
        stackView.addArrangedSubview(italic)
        stackView.addArrangedSubview(underline)
        stackView.addArrangedSubview(strikethrough)
        stackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0)))
        stackView.addArrangedSubview(unorderedList)
        stackView.addArrangedSubview(orderedList)
        stackView.pin.wrapContent().vCenter()
        stackView.performAlignment()
        
        didPerformLayout()
    }
    
    private func didPerformLayout() {
        scrollView.contentSize = CGSize(width: stackView.frame.maxX, height: scrollView.bounds.height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


