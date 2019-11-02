//
//  CSDownloadTask.swift
//  DownloadForSwift
//
//  Created by hanxing on 2019/11/1.
//  Copyright © 2019 hanxing. All rights reserved.
//

import UIKit
import Foundation

enum DownloadState {
    case Pause              //暂停
    case Downloading   //下载中
    case Success          //下载成功
    case Failed              //下载失败
}

typealias ProgressCallback =  (_ progress: Float) -> ()
typealias FinishCallback =  (_ isSuccess: Bool, _ filePath: String?, _ errorInfo: String?) -> ()

class CSDownloadTask: NSObject,URLSessionDataDelegate {
    var state: DownloadState?
    var task: URLSessionDataTask?
    var cachePath: String?
    var tempPath: String?
    var progressCallback: ProgressCallback?
    var finishCallback: FinishCallback?
    var outputStream: OutputStream?
    var totalSize: Float = 0
    var tempSize: UInt64 = 0
    
    lazy var sessionManager: URLSession = {
        let config = URLSessionConfiguration.default
        // 在应用进入后台时，让系统决定决定是否在后台继续下载。如果是false，进入后台将暂停下载
//        config.isDiscretionary = true
        let manager = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        return manager
    }()
    
    //MARK: >> 下载 <<
    func download(url:String,progressCallback: @escaping ProgressCallback,finishCallback: @escaping FinishCallback) -> URLSessionDataTask? {
        
        guard let requestURL = URL(string: url) else {
            finishCallback(false,nil,"下载失败")
            return nil
        }
        //MARK: >> 判断即将请求URL是否是正在进行的,存在就恢复，不存在就执行下载任务 <<
        guard requestURL != self.task?.originalRequest?.url else {
            resume()
            return self.task
        }
        
        self.progressCallback = progressCallback
        self.finishCallback = finishCallback
        let fileName = requestURL.lastPathComponent
        
        guard fileName.count != 0  else {
            print("fileName为空：:\(fileName)")
            return nil
        }
        
        cachePath = CSFileHandle.cachePath().appendingPathComponent(fileName)
        tempPath = CSFileHandle.tempPath().appendingPathComponent(fileName)
        print("缓存路径：\(String(describing: cachePath))")
        print("临时路径：\(String(describing: tempPath))")
        
        var request = URLRequest(url: requestURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        //MARK: >> 检测临时文件是否存在 <<
        if CSFileHandle.fileIsExist(filePath: tempPath!) {
            let offset = CSFileHandle.fileSize(filePath: tempPath!)
            self.tempSize = offset
            request.setValue("bytes=\(offset)-", forHTTPHeaderField: "Range")
        } else {
            request.setValue("bytes=0-", forHTTPHeaderField: "Range")
        }
        startDownloadTask(request: request)
        return self.task
    }
    
    //MARK: >> 开启下载任务 <<
    fileprivate func startDownloadTask(request: URLRequest) {
        self.state = .Downloading
        self.task = self.sessionManager.dataTask(with: request)
        self.task?.resume()
    }
    
    //MARK: >> 暂停 <<
    func pause() {
        guard self.task != nil else {
            return
        }
        if state == .Downloading {
            self.task?.suspend()
            self.state = .Pause
        }
    }
    
    //MARK: >> 恢复下载 <<
    func resume() {
        guard self.task != nil else {
            return
        }
        if  state == .Pause {
            self.state = .Downloading
            self.task?.resume()
        }
    }
}

extension CSDownloadTask {
    
    //MARK: >> 第一次接受数据时响应 <<
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let totalSizeString = (response as! HTTPURLResponse).allHeaderFields["Content-Length"] as! NSString
        totalSize = totalSizeString.floatValue
        print("第一次接受数据时响应：totalSize=\(totalSize)")
        self.outputStream = OutputStream(toFileAtPath: self.tempPath!, append: true)
        self.outputStream?.open()
        completionHandler(.allow)
    }
    
    //MARK: >> 开始接收数据 <<
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {

        print("收到数据：\(data.count)")
        let bytes = [UInt8](data)
        self.outputStream?.write(UnsafePointer<UInt8>(bytes), maxLength: data.count)
        self.tempSize += UInt64(data.count)
        let p = Float(self.tempSize) / totalSize
        print("p=\(p)")
        if progressCallback != nil {
            progressCallback!(p)
        }
    }
    
    //MARK: >> 请求完成或失败 <<
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        
        var isSuccess: Bool
        if error != nil {
            print("错误信息：\(String(describing: error))")
            isSuccess = false
            if error?.code == -1001 {
                state = .Pause
            }
            state = .Failed
        } else {
            let result = CSFileHandle.move(fromFilePath: self.tempPath!, toFilePath: self.cachePath!)
            isSuccess = result.isSuccess
            state = .Success
        }
    
        if finishCallback != nil {
            finishCallback!(isSuccess, isSuccess ? cachePath : tempPath, isSuccess ? "成功" : "失败")
        }
        self.outputStream?.close()
    }
}
