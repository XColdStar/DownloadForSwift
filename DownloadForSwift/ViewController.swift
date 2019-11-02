//
//  ViewController.swift
//  DownloadForSwift
//
//  Created by hanxing on 2019/11/1.
//  Copyright © 2019 hanxing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var downloadBtn: UIButton!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    
    lazy var ball: UIButton = {
        let ball = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        ball.backgroundColor  = UIColor.red
        ball.layer.cornerRadius = 50;
        ball.clipsToBounds = true
        ball.addTarget(self, action: #selector(ballAction(button:)), for: .touchUpInside)
        return ball
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.gray
        view.addSubview(ball)
    }

    @objc func ballAction(button: UIButton) {
        print("阿拉啦啦啦啦啦啦啦啦啦啦阿拉啦啦啦啦啦啦啦啦啦啦阿拉啦啦啦啦啦啦啦啦啦啦")
    }
    
    @IBAction func downloadAcion(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var url: String?
        
        switch sender.tag {
        case 1:
            url = "http://download.xunleizuida.com/1905/%E9%97%AA%E7%94%B5%E4%BE%A0%E7%AC%AC%E4%BA%94%E5%AD%A3-22.mp4"
            break
        case 2:
            url = "http://download.xunleizuida.com/1905/%E9%97%AA%E7%94%B5%E4%BE%A0%E7%AC%AC%E4%BA%94%E5%AD%A3-21.mp4"
            break
        case 3:
            url = "http://download.xunleizuida.com/1905/%E9%97%AA%E7%94%B5%E4%BE%A0%E7%AC%AC%E4%BA%94%E5%AD%A3-20.mp4"
            break
        case 4:
            url = "http://download.xunleizuida.com/1904/%E9%97%AA%E7%94%B5%E4%BE%A0%E7%AC%AC%E4%BA%94%E5%AD%A3-19.mp4"
            break
        default:
            url = "http://download.xunleizuida.com/1904/%E9%97%AA%E7%94%B5%E4%BE%A0%E7%AC%AC%E4%BA%94%E5%AD%A3-18.mp4"
            break
        }
       
        download(url: url!, sender: sender)
    }
    
    fileprivate func download(url:String,sender: UIButton) {
         if sender.isSelected {
                    print("开始下载")
                    CSDownloader.instance.download(url: url, progressCallback: { (progress) in
                        
                        DispatchQueue.main.async {
                             switch sender.tag {
                                                   case 1:
                                                       self.label2.text = "\(progress)"
                                                       break
                                                   case 2:
                                                       self.label3.text = "\(progress)"
                                                       break
                                                   case 3:
                                                       self.label4.text = "\(progress)"
                                                       break
                                                   case 4:
                                                       self.label5.text = "\(progress)"
                                                       break
                                                   default:
                                                       self.progressLabel.text = "\(progress)"
                                                       break
                                                   }
                        }
                        
                    }) { (isSuccess, filePath, errorInfo) in
                        if isSuccess {
                            print("下载成功：\(String(describing: filePath))")
                        } else {
                            print("下载失败：\(String(describing: errorInfo))")
                        }
                        sender.isSelected = false
                    }
                } else {
                    print("暂停下载")
                    let taskQueue = CSDownloader.instance.taskQueue
                    if let task = taskQueue[url] as? CSDownloadTask {
                        task.pause()
                    }
        //            let filePath = CSFileHandle.cachePath().appendingPathComponent("u=3349541936,792281887&fm=27&gp=0.jpg")
        //            let _ = CSFileHandle.remove(filePath: filePath)
                }
    }
}

