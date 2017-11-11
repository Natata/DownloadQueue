# DownloadQueue
alamofire-based downloader and auto-driven downlaod queue

create downloaders and push them to the queue
and them will download one by one automatically

## Usage

### init queue
```
let downloadQueue = DownloadQueue.sharedInstance()
```

### create a downloader and push it to queue
```
let downloader = Downloader(urlString: urlString, fileName: fileName, downloadQueue: downloadQueue) { (videoPath) in
    print("[Download] video path: \(videoPath)")
    
    // Do something after complete
}
downloader.delegate = viewCell // NOTE: this viewCell has progress bar to present progress

// push it and the download will start automatically
downloadQueue.push(downloader: downloader)
```

### pause, resume and cancel
```
downloadQueue.pause()

downloadQueue.resume()

downloadQueue.delete(fileName: fileName)
```
