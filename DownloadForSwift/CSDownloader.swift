//
//  CSDownloader.swift
//  DownloadForSwift
//
//  Created by hanxing on 2019/11/1.
//  Copyright © 2019 hanxing. All rights reserved.
//

import UIKit

class CSDownloader: NSObject {

    static let instance = CSDownloader()
    lazy var taskQueue = {
        return Dictionary<String, Any>()
    }()
    
    
    func download(url: String, progressCallback: @escaping ProgressCallback,finishCallback: @escaping FinishCallback) {
        var task = taskQueue[url] as? CSDownloadTask
        if task == nil {
            task = CSDownloadTask()
            taskQueue[url] = task
        }
        //MARK: >> finishCallback作为尾随闭包可以简写 <<
        _ = task!.download(url: url, progressCallback: progressCallback) {[weak self] (isSuccess, filePath, errorInfo) in
            if isSuccess {
                self?.taskQueue .removeValue(forKey: url)
            }
            finishCallback(isSuccess,filePath,errorInfo)
        }
    }
    
     //MARK: >> 暂停 <<
    func pause(url: String) {
        if let task = taskQueue[url] as? CSDownloadTask {
            task.pause()
        } else {
            print("暂停下载失败")
        }
    }
       
       //MARK: >> 恢复下载 <<
    func resume(url: String) {
        if let task = taskQueue[url] as? CSDownloadTask {
            task.resume()
        } else {
            print("恢复下载失败")
        }
    }
    
}
