//
//  URL+Extensions.swift
//  GSPlayer
//
//  Created by SHI-BO LIN on 2024/7/6.
//

import Foundation


extension String {
    var isMP4: Bool {
        self.hasSuffix(".mp4")
    }

    var isHLS: Bool {
        self.hasSuffix(".m3u8")
    }
}

extension URL {
    var isMP4: Bool {
        absoluteString.isMP4
    }

    var isHLS: Bool {
        absoluteString.isHLS
    }
}
