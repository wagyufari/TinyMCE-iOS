//
//  FontSizeSheetView.swift
//  StackPinLayout
//
//  Created by Muhammad Ghifari on 18/2/2023.
//

import Foundation
import PinLayout

class FontSizeSheetController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let callback: (String)->Void
    let currentFontSize: HtmlFontSize
    
    init(currentFontSize: HtmlFontSize, _ callback: @escaping (String)->Void ){
        self.currentFontSize = currentFontSize
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
    }
    
    let parentView = FontSizeSheetView()
    
    override func viewDidLoad() {
        view = parentView
        parentView.onHide = {
            self.dismiss(animated: false, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.parentView.setNeedsLayout()
            self.parentView.layoutIfNeeded()
        }
        parentView.callback = { format in
            self.parentView.dismissSheet()
            self.callback(format)
        }
        parentView.paragraph.currentFontSize = currentFontSize
        parentView.heading1.currentFontSize = currentFontSize
        parentView.heading2.currentFontSize = currentFontSize
        parentView.heading3.currentFontSize = currentFontSize
        parentView.heading4.currentFontSize = currentFontSize
        parentView.heading5.currentFontSize = currentFontSize
        parentView.heading6.currentFontSize = currentFontSize
    }
    
    static func show(with: UIViewController?, currentFontSize: HtmlFontSize, _ callback: @escaping (String) -> Void){
        DispatchQueue.main.async {
            let controller = FontSizeSheetController(currentFontSize: currentFontSize){ String in
                callback(String)
            }
            controller.modalPresentationStyle = .overFullScreen
            with?.present(controller, animated: false, completion: nil)
        }
    }
}

class FontSizeLabel: UIView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let fontLabel = UILabel()
    let htmlFontSize: HtmlFontSize
    
    var currentFontSize: HtmlFontSize = .Paragraph {
        didSet{
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    init(font: (UIFont, HtmlFontSize)){
        htmlFontSize = font.1
        super.init(frame: .zero)
        addSubview(fontLabel)
        fontLabel.text = font.1.title()
        fontLabel.font = font.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fontLabel.pin.sizeToFit()
        backgroundColor = currentFontSize == htmlFontSize ? .blue200 : .clear
        layer.cornerRadius = 4
        pin.wrapContent(padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
    }
}

class FontSizeSheetView: BottomSheetView{
    
    let stackView = UIStackPinView().apply{
        $0.isManualWrap = true
        $0.spacing = 12
    }
    
    var callback: (String)->Void = { format in
        
    }
    
    let paragraph = FontSizeLabel(font: (.systemFont(ofSize: 16), .Paragraph))
    let heading1 = FontSizeLabel(font: (.systemFont(ofSize: 32, weight: .bold), .Heading1))
    let heading2 = FontSizeLabel(font: (.systemFont(ofSize: 24, weight: .bold), .Heading2))
    let heading3 = FontSizeLabel(font: (.systemFont(ofSize: 18.72, weight: .bold), .Heading3))
    let heading4 = FontSizeLabel(font: (.systemFont(ofSize: 16, weight: .bold), .Heading4))
    let heading5 = FontSizeLabel(font: (.systemFont(ofSize: 13, weight: .bold), .Heading5))
    let heading6 = FontSizeLabel(font: (.systemFont(ofSize: 10.72, weight: .bold), .Heading6))
    
    let footer = UIView()
    
    override init() {
        super.init()
        container.addSubview(stackView)
        container.addSubview(footer)
        
        paragraph.onTap { UITapGestureRecognizer in
            self.callback("p")
        }
        heading1.onTap { UITapGestureRecognizer in
            self.callback("h1")
        }
        heading2.onTap { UITapGestureRecognizer in
            self.callback("h2")
        }
        heading3.onTap { UITapGestureRecognizer in
            self.callback("h3")
        }
        heading4.onTap { UITapGestureRecognizer in
            self.callback("h4")
        }
        heading5.onTap { UITapGestureRecognizer in
            self.callback("h5")
        }
        heading6.onTap { UITapGestureRecognizer in
            self.callback("h6")
        }
    }
    
    override func layoutSubviews() {
        
        
        stackView.pin.horizontally(24)
        
        stackView.addArrangedSubview(paragraph)
        stackView.addArrangedSubview(heading1)
        stackView.addArrangedSubview(heading2)
        stackView.addArrangedSubview(heading3)
        stackView.addArrangedSubview(heading4)
        stackView.addArrangedSubview(heading5)
        stackView.addArrangedSubview(heading6)
        
        stackView.pin.wrapContent(.vertically)
        footer.pin.horizontally().height(pin.safeArea.bottom).below(of: stackView)
        
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Divider: UIView{
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .neutral300
        pin.height(1)
    }
}
