//
//  ViewController.swift
//  downloadQueue
//
//  Created by Natata on 2017/11/10.
//  Copyright © 2017年 Natata. All rights reserved.
//

import Foundation

class DownloadQueue {
    private static var mInstance: DownloadQueue?
    
    private var queue: [Downloader]
    
    static func sharedInstance() -> DownloadQueue {
        if self.mInstance == nil {
            self.mInstance = DownloadQueue()
        }
        
        return mInstance!
    }
    
    private init() {
        queue = []
    }
    
    deinit {
        print("[queue] deinit")
    }
    
    func push(downloader: Downloader) {
        print("[queue] push")
        self.queue.append(downloader)
        self.launchNext()
    }
    
    func launchNext() {
        print("[queue] launch next")
        if self.queue.count == 0 {
            return
        }
        
        self.queue[0].resume()
    }
    
    func pause() {
        print("[queue] pause")
        if self.queue.count > 0 {
            self.queue[0].pause()
        }
    }
    
    func resume() {
        print("[queue] resume")
        if self.queue.count > 0 {
            self.queue[0].resume()
        }
    }
    
    func complete() {
        print("[queue] complete")
        if self.queue.count > 0 {
            self.queue.removeFirst()
        }
        self.launchNext()
    }
    
    func delete(fileName: String) {
        for (i, downloader) in self.queue.enumerated() {
            if downloader.fileName == fileName {
                print("[queue] delete \(fileName) downloader")
                downloader.cancel()
                self.queue.remove(at: i)
            }
        }
        
        self.launchNext()
    }
    
    func findDownloader(videoName: String) -> Downloader? {
        for downloader in self.queue {
            if downloader.fileName == videoName {
                return downloader
            }
        }
        
        return nil
    }
}

