//
//  UIStackPinView.swift
//  StackPinLayout
//
//  Created by Muhammad Ghifari on 18/04/22.
//

import Foundation
import UIKit

class UIStackPinView: UIView{
    
    var subViews: [UIView] = []
    var axis: NSLayoutConstraint.Axis = .vertical
    var padding: CGFloat = 0
    var spacing: CGFloat = 0
    var maxLength: Int = 999
    var isManualWrap = false
    var isCenterChild = false
    var firstItemSpacing: CGFloat = 0
    
    var verticalAlignment: StackPinAlignment = .Top
    var horizontalAlignment: StackPinAlignment = .Start
    
    func addArrangedSubview(_ view:UIView)  {
        subViews.append(view)
        setNeedsLayout()
        layoutIfNeeded()
        if !isManualWrap{
            if axis == .vertical{
                pin.horizontally(padding).top(padding).bottom().wrapContent(.vertically)
            } else{
                pin.vertically(padding).left().wrapContent(.horizontally)
            }
        }
    }
    
    func addSpacer(size:CGFloat){
        subViews.append(UIView().apply{
            $0.pin.size(size)
        })
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func removeArrangedSubviews(){
        subViews = []
        removeSubViews()
        setNeedsLayout()
        layoutIfNeeded()
        pin.horizontally(padding).top(padding).bottom().height(0)
    }
    
    override func layoutSubviews() {
        subViews.forEach { view in
            if !isManualWrap{
                if axis == .vertical{
                    view.pin.width(bounds.width)
                } else{
                    view.pin.height(bounds.height)
                }
            }
            addSubview(view)
        }
        
        if subViews.count > 1 {
            for (index, view) in subViews.enumerated() {
                if index != 0 {
                    if axis == .vertical {
                        view.pin.below(of: subViews[index-1]).marginTop(spacing)
                    } else{
                        view.pin.right(of: subViews[index-1]).marginLeft(spacing)
                    }
                } else {
                    if axis == .vertical {
                        view.pin.top().marginTop(firstItemSpacing)
                    } else {
                        view.pin.left().marginLeft(firstItemSpacing)
                    }
                }
            }
        } else{
            if axis == .vertical {
                subViews.first?.pin.top().marginTop(firstItemSpacing)
            } else {
                subViews.first?.pin.left().marginLeft(firstItemSpacing)
            }
        }
    }
    
    func performAlignment() {
        subViews.forEach { view in
            if axis == .vertical{
                switch horizontalAlignment {
                case .CenterHorizontally:
                    view.pin.hCenter()
                case .Start:
                    view.pin.left()
                case .End:
                    view.pin.right()
                default:
                    print("Nothing")
                }
            } else{
                switch verticalAlignment {
                case .CenterVertically:
                    view.pin.vCenter()
                case .Bottom:
                    view.pin.bottom()
                case .Top:
                    view.pin.top()
                default:
                    print("Nothing")
                }
            }
        }
    }
    
    func addDivider(){
      addArrangedSubview(Divider())
    }
    
}

extension UIStackPinView {
    func card(){
         backgroundColor = .white
         layer.cornerRadius = 6
    }
}

enum StackPinAlignment{
    case CenterVertically
    case CenterHorizontally
    case Bottom
    case Top
    case Start
    case End
}
 
extension UIView{
    func removeSubViews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
}
