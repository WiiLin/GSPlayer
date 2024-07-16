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

            gslog("preload resume \(url)")
            downloader.resume()
        } else {
            guard !VideoLoadManager.shared.loaderMap.keys.contains(url) else {
                gslog("preloading \(url)")
                return
            }
            guard let cacheHandler = try? VideoCacheHandler(url: url) else {
                gslog("cacheHandler nil \(url)")
                return
            }
            gslog("downloadedByteCount: \(cacheHandler.configuration.downloadedByteCount), \(url)")
            guard cacheHandler.configuration.downloadedByteCount < preloadByteCount else {
                gslog("enough \(url) ✅")
                didFinish?( url,nil)
                return
            }

            let downloader = VideoDownloader(url: url, cacheHandler: cacheHandler)
            downloader.delegate = self
            
            downloader.download(from: 0, length: preloadByteCount)
            self.downloaderDictionary[url] = downloader
            gslog("start \(url)")
        }
    }
    
    public func pause(url:URL) {
        downloaderDictionary[url]?.suspend()
        gslog("pause \(url)")
    }
    
    func remove(url: URL) {
        gslog("will remove \(url)")
        guard let downloader = downloaderDictionary[url] else {
            gslog("remove failed downloader = nil  \(url)")
            return
        }
        downloader.cancel()
        downloaderDictionary[url] = nil 
    }
    
}

extension VideoPreloadManager: VideoDownloaderDelegate {
    
    public func downloader(_ downloader: VideoDownloader, didReceive response: URLResponse) {
        gslog("didReceive response, \(downloader.url) ")
    }
    
    public func downloader(_ downloader: VideoDownloader, didReceive data: Data) {
        gslog("didReceive data length \(data.count), \(downloader.url)")
    }
    
    public func downloader(_ downloader: VideoDownloader, didFinished error: Error?) {
        if let error = error {
            gslog("didFinished error \(error), \(downloader.url)")
        } else {
            gslog("didFinished success , \(downloader.url) ✅")
        }
        self.remove(url: downloader.url)
        didFinish?( downloader.url,error)
    }
    
}
