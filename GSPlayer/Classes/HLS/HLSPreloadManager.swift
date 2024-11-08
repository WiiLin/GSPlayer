//
//  HLSPreloadManager.swift
//  GSPlayer
//
//  Created by SHI-BO LIN on 2024/7/6.
//

import Foundation
import AVFoundation

public class HLSPreloadManager: NSObject {

    public static let shared = HLSPreloadManager()

    private var items: [String: HLSPreloadModel] = [:]

}

public extension HLSPreloadManager {
    func item(with key: String) -> HLSPreloadModel? {
        return items[key]
    }

    func remove(with key: String) {
        if let item = items[key] {
            item.reset()
        }
        items[key] = nil
    }

    func preload(with key: String, url: URL) {
        if item(with: key) != nil {
            self.remove(with: key)
            self.preload(with: key, url: url)
        } else if let item = HLSPreloadModel(url: url){
            item.startBuffering()
            self.items[key] = item
        }
    }
}



