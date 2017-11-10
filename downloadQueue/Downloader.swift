//
//  Downloader.swift
//  downloadQueue
//
//  Created by Natata on 2017/11/10.
//  Copyright © 2017年 Natata. All rights reserved.
//

import Foundation
import Alamofire


protocol DownloaderDelegate {
    func updateProgress(completed: Double)
}

class Downloader {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let urlString: String
    let fileName: String
    let downloadQueue: DownloadQueue?
    
    var delegate: DownloaderDelegate?
    var completion: ((String) -> Void)?
    var downloadRequest: DownloadRequest?
    var destination: DownloadRequest.DownloadFileDestination?
    var isPaused: Bool
    var resumeData: Data?
    
    init(urlString: String, fileName: String, downloadQueue: DownloadQueue?, completion: ((String) -> Void)?) {
        self.urlString = urlString
        self.fileName = fileName
        self.completion = completion
        self.downloadQueue = downloadQueue
        self.isPaused = true
        self.destination = {_, _ in
            let destinationURL = self.documentsURL.appendingPathComponent(fileName, isDirectory: false)
            return (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
        }
    }
    
    deinit {
        print("[downloader] downloader \(fileName) deinit")
    }
    
    func resume() {
        self.isPaused = false
        
        if let resumeData = resumeData {
            print("[downloader] redownload from resume data")
            downloadRequest = Alamofire.download(resumingWith: resumeData, to: destination)
        } else if let downloadRequest = downloadRequest {
            print("[downlaoder] resume")
            downloadRequest.resume()
        } else {
            downloadRequest = Alamofire.download(self.urlString, to: destination)
        }
        setDownloadRequest()
    }
    
    func pause() {
        self.isPaused = true
        if let downloadRequest = downloadRequest {
            print("[downloader] paused")
            downloadRequest.suspend()
        }
    }
    
    func cancel() {
        self.isPaused = true
        if let downloadRequest = downloadRequest {
            print("[downloader] cancel")
            downloadRequest.cancel()
            resumeData = downloadRequest.resumeData
        }
    }
    
    func setDownloadRequest() {
        downloadRequest?.downloadProgress { progress in
            self.delegate?.updateProgress(completed: progress.fractionCompleted)
            }.response { response in
                if response.error == nil,
                    let path = response.destinationURL?.path {
                    self.completion?(path)
                    self.downloadQueue?.complete()
                } else {
                    print("[downloader] error happended: \(response.error?.localizedDescription))")
                    self.resumeData = response.resumeData
                }
        }
    }
}
