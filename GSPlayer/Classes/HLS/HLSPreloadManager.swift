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

    private var items: [URL: HLSPreloadModel] = [:]

}

public extension HLSPreloadManager {
    func item(with url: URL) -> HLSPreloadModel? {
        return items[url]
    }

    func remove(with url: URL) {
        if let item = items[url] {
            item.reset()
        }
        items[url] = nil
    }

    func preload(with url: URL) {
        if item(with: url) != nil {
            self.remove(with: url)
            self.preload(with: url)
        } else if let item = HLSPreloadModel(url: url){
            item.startBuffering()
            self.items[url] = item
        }
    }
}



