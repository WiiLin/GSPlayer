//
//  VideoPreloadManager.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//

import Foundation

public class VideoPreloadManager: NSObject {
    
    public static let shared = VideoPreloadManager()

    public var preloadByteCount: Int = 1024 * 1024 // = 1M

    public var didFinish: ((_ url: URL,_ error: Error?) -> Void)?

    private(set) var downloaderDictionary: [URL: VideoDownloader] = [:]

    public func startPreload(urls: [URL]) {
        urls.forEach { self.startPreload(url: $0) }
    }

    private func startPreload(url: URL) {
        if let downloader = downloaderDictionary[url] {

            log("preload resume \(url)")
            downloader.resume()
        } else {
            guard !VideoLoadManager.shared.loaderMap.keys.contains(url) else {
                log("preloading \(url)")
                return
            }
            guard let cacheHandler = try? VideoCacheHandler(url: url) else {
                log("cacheHandler nil \(url)")
                return
            }
            log("downloadedByteCount: \(cacheHandler.configuration.downloadedByteCount), \(url)")
            guard cacheHandler.configuration.downloadedByteCount < preloadByteCount else {
                log("enough \(url) ✅")
                didFinish?( url,nil)
                return
            }

            let downloader = VideoDownloader(url: url, cacheHandler: cacheHandler)
            downloader.delegate = self
            
            downloader.download(from: 0, length: preloadByteCount)
            self.downloaderDictionary[url] = downloader
            log("start \(url.lastPathComponent)")
        }
    }
    
    public func pause(url:URL) {
        downloaderDictionary[url]?.suspend()
        log("pause \(url.lastPathComponent)")
    }
    
    func remove(url: URL) {
        log("will remove \(url.lastPathComponent)")
        guard let downloader = downloaderDictionary[url] else {
            log("remove failed downloader = nil  \(url)")
            return
        }
        downloader.cancel()
        downloaderDictionary[url] = nil 
    }
    
}

extension VideoPreloadManager: VideoDownloaderDelegate {
    
    public func downloader(_ downloader: VideoDownloader, didReceive response: URLResponse) {
        log("didReceive response, \(downloader.url) ")
    }
    
    public func downloader(_ downloader: VideoDownloader, didReceive data: Data) {
        log("didReceive data length \(data.count), \(downloader.url)")
    }
    
    public func downloader(_ downloader: VideoDownloader, didFinished error: Error?) {
        if let error = error {
            log("didFinished error \(error), \(downloader.url)")
        } else {
            log("didFinished success , \(downloader.url) ✅")
        }
        self.remove(url: downloader.url)
        didFinish?( downloader.url,error)
    }
    
}
