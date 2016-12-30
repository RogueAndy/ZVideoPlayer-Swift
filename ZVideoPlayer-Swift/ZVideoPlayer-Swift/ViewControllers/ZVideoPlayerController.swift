//
//  ZVideoPlayerController.swift
//  ZVideoPlayer-Swift
//
//  Created by dazhongge on 2016/12/30.
//  Copyright © 2016年 dazhongge. All rights reserved.
//

import UIKit
import Foundation

class ZVideoPlayerController: ZSBaseViewController {

    private var videoPlayerView: ZVideoPlayerView?
    
    override func loadViews() {
        super.loadViews()
        
        let showView = UIButton.init(type: .custom)
        showView.addTarget(self, action: #selector(showAction), for: .touchUpInside)
        showView.backgroundColor = .yellow
        showView.frame = CGRect.init(x: 20, y: 100, width: self.view.frame.size.width - 40, height: 40)
        self.view.addSubview(showView)
        
        let test = UIButton.init(type: .custom)
        test.addTarget(self, action: #selector(testAction), for: .touchUpInside)
        test.backgroundColor = .yellow
        test.frame = CGRect.init(x: 20, y: 300, width: self.view.frame.size.width - 40, height: 40)
        self.view.addSubview(test)
    }
    
    override func loadLayout() {
        super.loadLayout()
        
        self.videoPlayerView?.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.width / 16.0 * 9.0)
    }
    
    @objc private func showAction(sender: UIButton) {
    
        let videoPath = Bundle.main.path(forResource: "ceshivideo", ofType: "mov")! as String
        self.videoPlayerView = ZVideoPlayerView.initWithLocalVideo(filePath: videoPath)
        self.videoPlayerView!.backgroundColor = .black
        
        weak var weakSelf = self
        self.videoPlayerView!.removeViewBlock = {(Void) -> () in
            
            UIView.animate(withDuration: 0.25, animations: {
                weakSelf?.videoPlayerView!.alpha = 0
            }, completion: { (finished) in
                weakSelf?.videoPlayerView!.removeFromSuperview()
                weakSelf?.videoPlayerView = nil
            })
            
        }
        
        self.videoPlayerView!.showViewIn(superView: self.navigationController!.view, animation: true)
        self.loadLayout()
    
    }
    
    @objc private func testAction(sender: UIButton) {
    
        print("-------", self.videoPlayerView as Any)
    
    }

}
