//
//  ZVideoPlayerView.swift
//  ZVideoPlayer-Swift
//
//  Created by dazhongge on 2016/12/30.
//  Copyright © 2016年 dazhongge. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

typealias removeView = (Void) -> ()

class ZVideoPlayerView: UIView {
    
    /// 控制视频，开始播放或者暂停播放
    public var isPlay: Bool = false
    public var removeViewBlock: removeView!
    
    private let zvideo_timer_move_distance = 0.5 // 由于 slider 的值是根据视频的时间来设置，所以，时间循环调用 slider 自动滚动的间隔，也表示着每次间隔 slider 移动的距离
    private var closeButton: UIButton! // 关闭按钮
    private var playButton: UIButton? // 播放按钮放在中间位置
    private var stopButton: UIButton! // 暂停按钮
    private var screenButton: UIButton! // 展开或者缩小全屏按钮
    private var slider: UISlider! // 滑动条
    private var player: AVPlayer! // 视频播放对象
    private var playLayer: AVPlayerLayer! // 视频播放对象所在的layer层
    private var playerItem: AVPlayerItem! //获取视频信息，当前时间以及总时间之类的信息
    private var urlString: String! {
    
        willSet(urlstring) {
        
            self.urlString = urlstring
            
            self.loadInit()
            self.loadViews()
            self.loadLayout()
            self.loadInitStatus()
        
        }
    
    }
    private var topView: UIView! // 顶部的透明层
    private var bottomView: UIView! // 底部的透明层
    private var sliderTimer: Timer! // 根据视频的时间设置自动跟新 slider 值的一个定时器
    private var countSliderFloat: Float! // 累计叠加 slider 的当前的value值，用于计算 slider 已经滑动的长度
    private var videoTotalTime: Float! // 计算视频的总时间
    private var beforeFrame: CGRect! // 记录 view 上次的 frame
    private var isPlayButton: Bool! = false {
    
        willSet(isplaybutton) {
        
            self.isPlayButton = isplaybutton
            if self.isPlayButton == true {
                self.player.play()
                return
            }
            
            self.player.pause()
        
        }
    
    }
    private var isFullScreen: Bool! = false
    
    // MARK: - 初始化对象
    
    class func initWithLocalVideo(filePath: String) -> ZVideoPlayerView {
        
        assert(!filePath.isEmpty, "------------ filePath can't be nil or ''")
        let video = ZVideoPlayerView()
        video.urlString = filePath
        return video
    
    }
    
    class func initWithOnlineVideo(fileUrl: String) -> ZVideoPlayerView {
    
        assert(!fileUrl.isEmpty, "------------ fileUrl can't be nil or ''")
        let video = ZVideoPlayerView()
        video.urlString = fileUrl
        return video
        
    }
    
    // MARK: - 外部可调用的公用方法
    
    public func showViewIn(superView: UIView, animation: Bool) {
        
        if animation == false {
            
            superView.addSubview(self)
            return
            
        }
        
        self.alpha = 0
        superView.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        
    }
    
    // MARK: - 属性的 set get 方法(when urlString != nil(and not ''), it's time to init subViews)
    
    private func getPlayButton() {
    
        if self.playButton == nil {
        
            self.playButton = UIButton.init(type: .custom)
            self.playButton!.setImage(UIImage.init(named: "player"), for: .normal)
            self.playButton!.addTarget(self, action: #selector(replayAction), for: .touchUpInside)
            self.playButton!.frame = CGRect.init(x: 0, y: 0, width: 80, height: 80)
            self.playButton!.center = CGPoint.init(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
            self.isPlayButton = true
            self.addSubview(self.playButton!)
        
        }
    
    }
    
    // MARK: - 构建界面以及布局(init some base datas and subViews)
    
    private func loadInit() {
    
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapVideo))
        self.addGestureRecognizer(tap)
    
    }
    
    private func loadViews() {
    
        if self.urlString.hasSuffix("http") {
        
            self.loadOnlineVideo()
        
        } else {
        
            self.loadLocalVideo()
        
        }
        
        /****************************************** 组装 topView 部分 ******************************************/
        
        self.topView = UIView.init(frame: .zero)
        self.topView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.topView.isUserInteractionEnabled = true
        self.addSubview(self.topView)
        
        self.closeButton = UIButton.init(type: .custom)
        self.closeButton.setImage(UIImage.init(named: "close"), for: .normal)
        self.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        self.topView.addSubview(self.closeButton)
    
        /****************************************** 组装 topView 部分 ******************************************/
        
        
        
        /****************************************** 组装 bottomView 部分 ******************************************/
        
        self.bottomView = UIView.init(frame: .zero)
        self.bottomView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.bottomView.isUserInteractionEnabled = true
        self.addSubview(self.bottomView)
        
        self.slider = UISlider.init(frame: .zero)
        self.slider.setThumbImage(UIImage.init(named: "movepoint"), for: .normal)
        self.videoTotalTime = Float(CMTimeGetSeconds(self.playerItem.asset.duration))
        self.slider.maximumValue = self.videoTotalTime
        self.slider.isContinuous = true
        self.slider.addTarget(self, action: #selector(sliderBegan), for: .touchDown)
        self.slider.addTarget(self, action: #selector(sliderEnd), for: .touchUpInside)
        self.bottomView.addSubview(self.slider)
        
        self.stopButton = UIButton.init(type: .custom)
        self.stopButton.setImage(UIImage.init(named: "pause"), for: .normal)
        self.stopButton.addTarget(self, action: #selector(stopAction), for: .touchUpInside)
        self.bottomView.addSubview(self.stopButton)
        
        self.screenButton = UIButton.init(type: .custom)
        self.screenButton.setImage(UIImage.init(named: "screen"), for: .normal)
        self.screenButton.addTarget(self, action: #selector(fullScreenAction), for: .touchUpInside)
        self.bottomView.addSubview(self.screenButton)
        
        /****************************************** 组装 bottomView 部分 ******************************************/
        
    }
    
    private func loadLayout() {
    
        let blackViewHeight = self.bounds.size.height / 6.0
        self.playLayer.frame = self.bounds
        self.playButton?.center = CGPoint.init(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        
        /****************************************** 组装 topView 部分 ******************************************/
        
        self.topView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: blackViewHeight)
        self.closeButton.frame = CGRect.init(x: self.topView.frame.size.width - 35, y: (self.topView.frame.size.height - self.topView.frame.size.height / 2.0) / 2.0, width: self.topView.frame.size.height / 2.0, height: self.topView.frame.size.height / 2.0)
        
        /****************************************** 组装 topView 部分 ******************************************/
        
        /****************************************** 组装 bottomView 部分 ******************************************/
        
        self.bottomView.frame = CGRect.init(x: 0, y: self.bounds.size.height - blackViewHeight, width: self.bounds.size.width, height: blackViewHeight)
        self.slider.frame = CGRect.init(x: 40, y: 10, width: self.bottomView.frame.size.width - 80, height: self.bottomView.frame.size.height - 20)
        self.stopButton.frame = CGRect.init(x: (40 - self.bottomView.frame.size.height / 2.0) / 2.0, y: (self.bottomView.frame.size.height - self.bottomView.frame.size.height / 2.0) / 2.0, width: self.bottomView.frame.size.height / 2.0, height: self.bottomView.frame.size.height / 2.0)
        self.screenButton.frame = CGRect.init(x: self.slider.frame.origin.x + self.slider.frame.size.width + 5, y: (self.bottomView.frame.size.height - self.bottomView.frame.size.height / 2.0) / 2.0, width: self.bottomView.frame.size.height / 2.0, height: self.bottomView.frame.size.height / 2.0)
        
        /****************************************** 组装 bottomView 部分 ******************************************/
    
    }
    
    private func loadInitStatus() {
    
        self.bottomView.alpha = 0
        self.topView.alpha = 0
        self.playButton?.alpha = 1
        self.bottomView.isHidden = true
        self.topView.isHidden = true
        self.playButton?.isHidden = false
        self.isPlayButton = true
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.loadLayout()
    }
    
    // MARK: - 在线视频生成代码(AVPlayerItem 用户获取视频信息，当前时间以及总时间)
    
    private func loadOnlineVideo() {
    
        let movieAsset = AVURLAsset.init(url: NSURL.init(fileURLWithPath: self.urlString) as URL)
        self.playerItem = AVPlayerItem.init(asset: movieAsset)
        self.player = AVPlayer.init(playerItem: self.playerItem)
        self.playLayer = AVPlayerLayer.init(player: self.player)
        self.layer.addSublayer(self.playLayer)
    
    }
    
    // MARK: - 本地视频生成代码
    
    private func loadLocalVideo() {
    
        self.playerItem = AVPlayerItem.init(url: NSURL.init(fileURLWithPath: self.urlString) as URL)
        self.player = AVPlayer.init(playerItem: self.playerItem)
        self.playLayer = AVPlayerLayer.init(player: self.player)
        self.layer.addSublayer(self.playLayer)
    
    }
    
    // MARK: - selector action
    
    @objc private func fullScreenAction(sender: UIButton) {
    
        if self.isFullScreen == true {
        
            UIView.animate(withDuration: 0.25, animations: { 
                self.transform = .identity
            }, completion: { (finished) in
                self.screenButton.setImage(UIImage.init(named: "screen"), for: .normal)
                self.isFullScreen = false
            })
            
            return
        
        }
        
        self.beforeFrame = self.frame
        
        UIView.animate(withDuration: 0.25, animations: { 
            self.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI_2))
        }) { (finished) in
            self.screenButton.setImage(UIImage.init(named: "scale"), for: .normal)
            self.isFullScreen = true
        }
    
    }
    
    @objc private func sliderBegan(sender: UIButton) {
    
        self.player.pause()
        self.sliderTimer.invalidate()
        self.sliderTimer = nil
    
    }
    
    @objc private func sliderEnd(sender: UIButton) {
    
        self.player.seek(to: CMTime.init(value: CMTimeValue(self.slider.value), timescale: 1))
        self.countSliderFloat = self.slider.value
        self.sliderTimer = Timer.scheduledTimer(timeInterval: self.zvideo_timer_move_distance, target: self, selector: #selector(countSlider), userInfo: nil, repeats: true)
        self.player.play()
        
    }

    @objc private func countSlider(timer: Timer) {
    
        if self.countSliderFloat > self.videoTotalTime {
        
            self.sliderTimer.invalidate()
            return
        
        }
        
        self.slider.setValue(self.countSliderFloat, animated: true)
        self.countSliderFloat = Float(self.zvideo_timer_move_distance) + self.countSliderFloat
     
    }
    
    @objc private func stopAction(sender: UIButton) {
    
        self.player.pause()
        self.sliderTimer.invalidate()
        self.sliderTimer = nil
        self.afterStop()
    
    }
    
    @objc private func replayAction(sender: UIButton) {
    
        self.player.play()
        self.sliderTimer = Timer.scheduledTimer(timeInterval: self.zvideo_timer_move_distance, target: self, selector: #selector(countSlider), userInfo: nil, repeats: true)
        self.afterPlay()
    
    }
    
    @objc private func tapVideo(gesture: UITapGestureRecognizer) {
    
        if self.isPlayButton == true {
        
            return
        
        }
        
        if self.bottomView.isHidden == true {
        
            self.bottomView.isHidden = false
            self.topView.isHidden = false
            UIView.animate(withDuration: 0.25, animations: { 
                self.bottomView.alpha = 1
                self.topView.alpha = 1
            })
            return
        
        }
        
        UIView.animate(withDuration: 0.25, animations: { 
            self.bottomView.alpha = 0
            self.topView.alpha = 0
        }) { (finished) in
            self.bottomView.isHidden = true
            self.topView.isHidden = true
        }
    
    }
    
    @objc private func closeAction(sender: UIButton) {
    
        if self.removeViewBlock != nil {
        
            self.removeViewBlock()
        
        }
    
    }
    
    // MARK: - 点击暂停之后的变化
    
    private func afterStop() {
    
        self.playButton?.alpha = 0
        UIView.animate(withDuration: 0.25) { 
            self.playButton?.alpha = 1
        }
    
    }
    
    // MARK: - 点击继续播放之后的变化
    
    private func afterPlay() {
    
        UIView.animate(withDuration: 0.25, animations: { 
            self.playButton?.alpha = 0
        }) { (finished) in
            self.playButton?.removeFromSuperview()
            self.playButton = nil
            self.isPlayButton = false
        }
    
    }
    
    
}
