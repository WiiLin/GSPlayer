//
//  GSLogManager.swift
//  GSPlayer
//
//  Created by SHI-BO LIN on 2024/7/6.
//

import Foundation


func log(_ message: String, file: String = #file, line: Int = #line) {
    GSLogManager.shared.log(message, file: file, line: line)
}

public class GSLogManager {
    static let shared = GSLogManager()

    public var isLoggingEnabled: Bool = true

    private init() {}

    func log(_ message: String, file: String = #file, line: Int = #line) {
        if isLoggingEnabled {
            let fileName = (file as NSString).lastPathComponent
            print("[\(fileName):\(line)] \(message)")
        }
    }
}
