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

    public var didStart: ((_ url: URL) -> Void)?
    public var didPause: ((_ url: URL) -> Void)?
    public var didFinish: ((_ url: URL,_ error: Error?) -> Void)?

    private(set) var downloaderDictionary: [URL: VideoDownloader] = [:]

    public func startPreload(urls: [URL]) {
        urls.forEach { self.startPreload(url: $0) }
    }

    private func startPreload(url: URL) {
        if let downloader = downloaderDictionary[url] {
            print("🗂️ VideoPreloadManager preload resume \(url)")
            downloader.resume()
        } else {
            guard !VideoLoadManager.shared.loaderMap.keys.contains(url) else {
                print("🗂️ VideoPreloadManager preloading \(url)")
                return
            }
            guard let cacheHandler = try? VideoCacheHandler(url: url) else {
                print("🗂️ VideoPreloadManager cacheHandler nil \(url)")
                return
            }
            print("🗂️ VideoPreloadManager downloadedByteCount: \(cacheHandler.configuration.downloadedByteCount), \(url)")
            guard cacheHandler.configuration.downloadedByteCount < preloadByteCount else {
                print("🗂️ VideoPreloadManager enough \(url) ✅")
                didFinish?( url,nil)
                return
            }

            let downloader = VideoDownloader(url: url, cacheHandler: cacheHandler)
            downloader.delegate = self
            
            downloader.download(from: 0, length: preloadByteCount)
            self.downloaderDictionary[url] = downloader
            print("🗂️ VideoPreloadManager start \(url.lastPathComponent)")
        }
    }
    
    public func pause(url:URL) {
        downloaderDictionary[url]?.suspend()
        didPause?(url)
        print("🗂️ VideoPreloadManager pause \(url.lastPathComponent)")
    }
    
    func remove(url: URL) {
        print("🗂️ VideoPreloadManager will remove \(url.lastPathComponent)")
        guard let downloader = downloaderDictionary[url] else {
            print("🗂️ VideoPreloadManager remove failed downloader = nil  \(url)")
            return
        }
        downloader.cancel()
        downloaderDictionary[url] = nil 
    }
    
}

extension VideoPreloadManager: VideoDownloaderDelegate {
    
    public func downloader(_ downloader: VideoDownloader, didReceive response: URLResponse) {
        print("🗂️ VideoPreloadManager didReceive response, \(downloader.url)")
    }
    
    public func downloader(_ downloader: VideoDownloader, didReceive data: Data) {
        print("🗂️ VideoPreloadManager didReceive data length \(data.count), \(downloader.url)")
    }
    
    public func downloader(_ downloader: VideoDownloader, didFinished error: Error?) {
        if let error = error {
            print("🗂️ VideoPreloadManager didFinished error \(error), \(downloader.url)")
        } else {
            print("🗂️ VideoPreloadManager didFinished success , \(downloader.url) ✅")
        }
        self.remove(url: downloader.url)
        didFinish?( downloader.url,error)
    }
    
}
