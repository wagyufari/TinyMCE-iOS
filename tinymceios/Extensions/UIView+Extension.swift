//
//  UIView+GestureRecognizer.swift
//  ONE
//
//  Created by dennis farandy on 11/6/15.
//  Copyright © 2015 Happy5. All rights reserved.
//


//this taken from
//https://github.com/marcbaldwin/GestureRecognizerClosures/tree/master/GestureRecognizerClosures

import Foundation
import UIKit

extension UIView {
    
    func onTap(_ handler: @escaping (UITapGestureRecognizer) -> Void) {
        onTapWithTapCount(1, run: handler)
    }
    
    func onDoubleTap(_ handler: @escaping (UITapGestureRecognizer) -> Void) {
        onTapWithTapCount(2, run: handler)
    }
    
    func onLongPress(_ handler: @escaping (UILongPressGestureRecognizer) -> Void) {
        addGestureRecognizer(UILongPressGestureRecognizer { gesture in
            handler(gesture as! UILongPressGestureRecognizer)
            })
    }
    
    func onSwipeLeft(_ handler: @escaping (UISwipeGestureRecognizer) -> Void) {
        onSwipeWithDirection(.left, run: handler)
    }
    
    func onSwipeRight(_ handler: @escaping (UISwipeGestureRecognizer) -> Void) {
        onSwipeWithDirection(.right, run: handler)
    }
    
    func onSwipeUp(_ handler: @escaping (UISwipeGestureRecognizer) -> Void) {
        onSwipeWithDirection(.up, run: handler)
    }
    
    func onSwipeDown(_ handler: @escaping (UISwipeGestureRecognizer) -> Void) {
        onSwipeWithDirection(.down, run: handler)
    }
    
    func onPan(_ handler: @escaping (UIPanGestureRecognizer) -> Void) {
        addGestureRecognizer(UIPanGestureRecognizer { gesture in
            handler(gesture as! UIPanGestureRecognizer)
            })
    }
    
    func onPinch(_ handler: @escaping (UIPinchGestureRecognizer) -> Void) {
        addGestureRecognizer(UIPinchGestureRecognizer { gesture in
            handler(gesture as! UIPinchGestureRecognizer)
            })
    }
    
    func onRotate(_ handler: @escaping (UIRotationGestureRecognizer) -> Void) {
        addGestureRecognizer(UIRotationGestureRecognizer { gesture in
            handler(gesture as! UIRotationGestureRecognizer)
            })
    }
}

private extension UIView {
    
    func onTapWithTapCount(_ numberOfTaps: Int, run handler: @escaping (UITapGestureRecognizer) -> Void) {
        let tapGesture = UITapGestureRecognizer{ gesture in
            handler(gesture as! UITapGestureRecognizer)
        }
        tapGesture.numberOfTapsRequired = numberOfTaps
        addGestureRecognizer(tapGesture)
    }
    
    func onSwipeWithDirection(_ direction: UISwipeGestureRecognizer.Direction, run handler: @escaping (UISwipeGestureRecognizer) -> Void) {
        let swipeGesture = UISwipeGestureRecognizer { gesture in
            handler(gesture as! UISwipeGestureRecognizer)
        }
        swipeGesture.direction = direction
        addGestureRecognizer(swipeGesture)
    }
}


extension UIGestureRecognizer {
    fileprivate var handler: GestureRecognizerClosureHandler! {
        get { return objc_getAssociatedObject(self, &AssociatedKey.gestureHandler) as? GestureRecognizerClosureHandler }
        set { objc_setAssociatedObject(self, &AssociatedKey.gestureHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    convenience init(handler: @escaping (UIGestureRecognizer) -> Void) {
        let handler = GestureRecognizerClosureHandler(handler: handler)
        self.init(target: handler, action: #selector(GestureRecognizerClosureHandler.handleGesture(_:)))
        self.handler = handler
    }
}

class GestureRecognizerClosureHandler: NSObject {
    fileprivate let handler: (UIGestureRecognizer) -> Void
    init(handler: @escaping (UIGestureRecognizer) -> Void) { self.handler = handler }
    @objc func handleGesture(_ gestureRecognizer: UIGestureRecognizer) { handler(gestureRecognizer) }
}


struct AssociatedKey {
    static var gestureHandler = "one_gestureHandler"
    static var buttonHandler = "one_buttonHandler"
    static var barbuttonHandler = "one_barbuttonHandler"
    
    static var viewEmptyState = "one_viewEmptyState"
}

extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
