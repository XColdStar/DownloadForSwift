//
//  CSFileHandle.swift
//  DownloadForSwift
//
//  Created by hanxing on 2019/11/1.
//  Copyright © 2019 hanxing. All rights reserved.
//

import Foundation
import UIKit

class CSFileHandle {
    
    class func tempPath() -> NSString {
        return NSTemporaryDirectory() as NSString
    }
    
    class func libraryPath() -> NSString {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
    }
    
    class func cachePath() -> NSString {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
    }
    
    //MARK: >> 文件是否存在 <<
    class func fileIsExist(filePath: String) -> Bool {
        if filePath.count == 0 {
            return false
        }
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    //MARK: >> 获取文件大小 <<
    class func fileSize(filePath: String) -> UInt64 {
        if filePath.count == 0 {
            return 0
        }
        
        var size: UInt64 = 0
        
        do {
            let infoDic = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            size = infoDic.fileSize()
        } catch {
            print("error:\(error)")
        }
        print("文件大小：\(size)")
        return size
    }
    
    //MARK: >> 文件转移 <<
    class func move(fromFilePath: String, toFilePath: String) -> (isSuccess: Bool,errorInfo: String?) {
        guard fromFilePath.count != 0 else {
            return (false,"源文件路径不存在")
        }
        guard toFilePath.count != 0 else {
            return (false,"目标路径不存在")
        }
        
        print("\(fromFilePath)<<转移到>>\(toFilePath)")
        do {
            try FileManager.default.moveItem(atPath: fromFilePath, toPath: toFilePath)
            print("成功")
        } catch {
            print("失败：\(error)")
            return (false,"\(error)")
        }
    
        return (true,nil)
    }
    
    //MARK: >> 删除文件 <<
    class func remove(filePath: String) -> (isSuccess: Bool,errorInfo: String?) {
        if filePath.count == 0 {
            return (false,"目标文件不存在")
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePath)
            print("文件移除成功")
        } catch  {
            print("文件移除失败：\(error)")
            return (false,"\(error)")
        }
        return (true,nil)
    }
}
