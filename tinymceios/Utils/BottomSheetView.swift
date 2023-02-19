
import Foundation
import UIKit
import PinLayout

class BottomSheetView: UIView{
    
    let alphaBackground = UIView().apply{
        $0.backgroundColor = UIColor.black.withAlphaComponent(0)
    }
    let container = UIView().apply{
        $0.transform = CGAffineTransform.init(translationX: 0, y: 1000)
    }
    var gesture :UIPanGestureRecognizer?
    var onHide = {}
    var isExpanded = true
    var isDragging = false
    var isFullScreen = false
    var isFirstRun = true
    var padding: CGFloat = 8
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(alphaBackground)
        addSubview(container)
        gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
    }
    
    
    override func layoutSubviews() {
        if !isDragging{
            
            if isFirstRun{
                container.transform = CGAffineTransform(translationX: 0, y: 2000)
                isFirstRun = false
            }
            
            alphaBackground.pin.all()
            
            if isFullScreen{
                container.pin.top(pin.safeArea.top + 24).horizontally().bottom()
            } else{
                container.pin.horizontally().bottom().wrapContent(.vertically, padding: UIEdgeInsets(top: 12, left: 0, bottom: 8, right: 0))
            }
            container.backgroundColor = .white
            container.layer.cornerRadius = 16
            
            if isExpanded{
                show()
            } else{
                dismiss()
            }
            
            alphaBackground.isUserInteractionEnabled = true
            alphaBackground.onTap { UITapGestureRecognizer in
                self.dismissSheet()
            }
            
            if let gesture = gesture {
                container.addGestureRecognizer(gesture)
            }
        }
    }
    
    private func show(){
        UIView.animate(withDuration: 0.2) {
            self.alphaBackground.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.container.transform = CGAffineTransform.init(translationX: 0, y: 0)
        }
    }
    
    func dismissSheet(){
        self.isExpanded = false
        self.setNeedsLayout()
    }
    
    func dismiss(){
        UIView.animate(withDuration: 0.2) {
            self.alphaBackground.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.container.transform = CGAffineTransform.init(translationX: 0, y: 2000)
        } completion: { Bool in
            self.onHide()
        }
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self.container)
            if translation.y > 0{
                self.container.transform = CGAffineTransform.init(translationX: 0, y: translation.y)
            }
            
            if translation.y > self.container.frame.height{
                isDragging = false
                self.isExpanded = false
                self.setNeedsLayout()
            } else{
                isDragging = true
            }
            
        } else if recognizer.state == .ended{
            let velocity = recognizer.velocity(in: self.container)
            let translation = recognizer.translation(in: self.container)
            
            if velocity.y > 500{
                self.isExpanded = false
                self.setNeedsLayout()
            } else if translation.y > self.container.frame.height / 4 {
                self.isExpanded = false
                self.setNeedsLayout()
            } else{
                self.isExpanded = true
                self.setNeedsLayout()
            }
            isDragging = false
        }
    }
    
}
