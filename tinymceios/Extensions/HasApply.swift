//
//  HasApply.swift
//  MentionTextView
//
//  Created by Muhammad Ghifari on 29/07/21.
//

import Foundation

protocol HasApply { }

extension NSObject: HasApply { }

extension HasApply {
    func apply(closure:(Self) -> ()) -> Self {
        closure(self)
        return self
    }
}
