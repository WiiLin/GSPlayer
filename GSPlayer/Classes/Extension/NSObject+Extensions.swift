//
//  NSObject+Extensions.swift
//  GSPlayer
//
//  Created by SHI-BO LIN on 2024/7/6.
//

import Foundation


protocol ClassNameProtocol {
    var className: String { get }
}

extension ClassNameProtocol {
    var className: String {
        return "\(type(of: self))"
    }
}

extension NSObject: ClassNameProtocol {}
