//
//  HLSPreloadItem.swift
//  GSPlayer
//
//  Created by SHI-BO LIN on 2024/7/6.
//

import AVFoundation



public class HLSPreloadModel: NSObject {
   
    public let url: URL

    public private(set) var avPlayer: AVPlayer?

    public private(set) var playerItem: AVPlayerItem?

    public private(set) var readyToPlay: Bool = false

    private var playerBufferingObservation: NSKeyValueObservation?
   
    deinit {
        reset()
    }

    init?(url: URL) {
        guard url.isHLS else { return nil }
        self.url = url
        super.init()
    }
}

public extension HLSPreloadModel {
    func startBuffering() {
        
        guard readyToPlay == false else { return }

        let asset: AVURLAsset =  AVURLAsset(url: url)

        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: nil)

        item.preferredForwardBufferDuration = 2

        item.canUseNetworkResourcesForLiveStreamingWhilePaused = false

        let player = AVPlayer(playerItem: item)

        player.automaticallyWaitsToMinimizeStalling = false

        playerBufferingObservation = item.observe(\.loadedTimeRanges) { [unowned self] playerItem, _ in
            guard let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue else { return }
            let loadedTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration)
            let totalTime = CMTimeGetSeconds(playerItem.duration)
            gslog("\(url), loadedTimeRanges: \(loadedTime)/\(totalTime)")
            if loadedTime >= 0.5, readyToPlay == false {
                self.readyToPlay = true
                gslog("\(url) readyToPlay ✅")
                resetObservation()
            }
        }

        self.playerItem = item

        self.avPlayer = player

        gslog("\(url) startBuffering")
    }

    func reset() {
        gslog("\(url) reset")
        resetObservation()
        avPlayer?.pause()
        avPlayer?.replaceCurrentItem(with: nil)
        avPlayer = nil
    }
}

private extension HLSPreloadModel {
    func resetObservation() {
        playerBufferingObservation?.invalidate()
        playerBufferingObservation = nil
    }
}
