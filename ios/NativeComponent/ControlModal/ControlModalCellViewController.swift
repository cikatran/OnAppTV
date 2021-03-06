//
//  ControlModalCellViewController.swift
//  OnAppTV
//
//  Created by Chuong Huynh on 5/11/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import UIKit
import STBAPI

class ControlModalCellViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressWidth: NSLayoutConstraint!
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet var onTVButtonView: UIView!
    
    @IBOutlet weak var blurImage: UIImageView!
    @IBOutlet weak var progressImage: UIImageView!
    @IBOutlet weak var channelImage: UIImageView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var orientationButton: UIButton!
    @IBOutlet weak var redBar: UIView!
    @IBOutlet weak var playOverButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var fastforwardButton: UIButton!
    @IBOutlet weak var onTVLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var captionButton: UIButton!
    
    public var onClosePress = {}
    public var onDetailPress = {}
    public var onVolumeChanged: ((Float)->Void)? = nil
    public var onPlayMedia: (()->Void)? = nil
    public var onAlert: ((String)->Void)? = nil
    public var onShare: (()->Void)? = nil
    public var onBookmark: (()->Void)? = nil
    public var onFavorite: (()->Void)? = nil
    public var playNext: (()->Void)? = nil
    weak var data: ControlModalData?
    var onTVLabelColor: UIColor = .white
    var onTVDarkerLabelColor: UIColor = .darkGray
    
    var needUpdateAll = true
    var isDragging = false
    
    public var isSTBConnected: Bool = true {
        didSet {
            updateSTBConnectedState()
        }
    }
    
    public func configWithData(_ data: ControlModalData) {
        
        self.data = data
        if let imageURL = URL(string: data.imageURL) {
            blurImage.kf.setImage(with: imageURL)
            progressImage.kf.setImage(with: imageURL)
        }
        
        titleLabel.text = data.title
        genresLabel.text = data.genres
        
        if let logoUrl = URL(string: data.logoImage) {
            channelImage.kf.setImage(with: logoUrl)
        } else {
            channelImage.kf.setImage(with: nil)
        }
        
        self.data?.delegate = self
        self.progressChanged(controlModalData: data)
        needUpdateAll = false
        self.playStateChanged(controlModalData: data)
        needUpdateAll = true
        showHideComponents()
    }
    
    func commonInit() {
        
        setUpVolumeSlider()
        
        onTVButtonView.layer.cornerRadius = 21
        onTVButtonView.clipsToBounds = true
        onTVLabelColor = onTVLabel.textColor
        blurImage.clipsToBounds = true
        progressImage.clipsToBounds = true
        redBar.isHidden = true
    }
    
    func setUpVolumeSlider() {
        
        volumeSlider.setThumbImage(UIImage(named: "ic_thumb_slider")?.imageWithInsets(insets: UIEdgeInsetsMake(3, 0, 0, 0)), for: .normal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sliderTapped(gestureRecognizer:)))
        self.volumeSlider.addGestureRecognizer(tapGestureRecognizer)
    }

}

extension ControlModalCellViewController {
    
    func showHideComponents() {
        if (data?.isLive ?? false) {
            // Show logo channel + red line
            channelImage.isHidden = false
            redBar.isHidden = true
            // Hide orientation button
            orientationButton.isHidden = true
        } else {
            // Show orientation button
            orientationButton.isHidden = false
            // Hide logo channel + red line
            channelImage.isHidden = true
            redBar.isHidden = true
        }
    }
    
    func updateLabelsWith(_ newCurrentTime: Double) {
        
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        var totalTime: Double = 0
        if (data?.isLive ?? false) {
            formatter.allowedUnits = [.hour, .minute]
            let startTimeInterval = (data?.startTime.timeIntervalSince1970 ?? 0)
            let endTimeInterval = (data?.endTime.timeIntervalSince1970 ?? 0)
            totalTime = endTimeInterval - startTimeInterval
        } else {
            totalTime = data?.durationInSeconds ?? 0
            if totalTime > 3600 {
                formatter.allowedUnits = [.hour, .minute, .second]
            } else {
                formatter.allowedUnits = [.minute, .second]
            }
        }
        startTimeLabel.text = formatter.string(from: newCurrentTime)
        endTimeLabel.text = "-\(formatter.string(from: totalTime - newCurrentTime) ?? "")"
    }
    
    func updateSTBConnectedState() {
        if (!isSTBConnected) {
            data?.playState = .disconnect
        }
    }
}

extension ControlModalCell {
    
    func seekTo(_ currentTime: Double, callback:@escaping (Bool)-> Void) {
        Api.shared().hIG_PlayMediaSetPosition(withPosition: Int32(currentTime)) { (isSuccess, error) in
            if (!isSuccess) {
                print(error ?? "")
            }
            callback(isSuccess)
        }
    }
}

// MARK: - Gestures
extension ControlModalCellViewController {
    
    func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.volumeView)
        
        let positionOfSlider: CGPoint = volumeSlider.frame.origin
        let widthOfSlider: CGFloat = volumeSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(volumeSlider.maximumValue) / widthOfSlider)
        
        volumeSlider.setValue(Float(newValue), animated: true)
        self.volumeSliderChanged(volumeSlider)
    }
    
    public func changeProgressView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: progressView)
        let newWidth = translation.x + progressWidth.constant
        // TODO: - Check more for live video and isPlaying
        if (data?.isLive ?? false) {
            
        } else {
            let playState = (data?.playState ?? .notPlayed)
            if (newWidth >= 0 && newWidth <= progressView.frame.width &&  (playState == .currentPlaying || playState == .pause)) {
                progressWidth.constant = progressWidth.constant + translation.x
                let durationInSeconds = data?.durationInSeconds ?? 0
                let progress = progressWidth.constant / progressView.frame.width
                let currentTime = Double(progress) * durationInSeconds
                updateLabelsWith(currentTime)
            }
        }
        isDragging = true
        sender.setTranslation(.zero, in: self.progressView)
    }
    
    public func doneDraggingProgressView() {
        if (data?.isLive ?? false) {
            
        } else {
            let durationInSeconds = data?.durationInSeconds ?? 0
            let progress = progressWidth.constant / progressImage.frame.width
            let currentTime = Double(progress) * durationInSeconds
            self.seekTo(currentTime) { (isSuccess) in
                if (isSuccess) {
                    self.data?.currentProgress = currentTime/(self.data?.durationInSeconds ?? 1)
                }
            }
        }
        isDragging = false
    }
    
    public func changeVolume(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: progressView)
        let newVolume = (translation.x + volumeSlider.frame.width * CGFloat(volumeSlider.value)) / (volumeSlider.frame.width)
        if (newVolume >= 0 && newVolume <= 1) {
            volumeSlider.value = Float(newVolume)
            self.volumeSliderChanged(volumeSlider)
        }
        sender.setTranslation(.zero, in: self.progressView)
    }
}

// MARK: - ControlModalDataDelegate
extension ControlModalCellViewController: ControlModalDataDelegate {
    
    func progressChanged(controlModalData: ControlModalData) {
        // Update progress view
        if (isDragging) {
            return
        }
        progressWidth.constant = CGFloat((data?.currentProgress ?? 0))*self.progressImage.frame.width
        
        // Update label
        if (data?.isLive ?? false) {
            let startTimeInterval = (data?.startTime.timeIntervalSince1970 ?? 0)
            let endTimeInterval = (data?.endTime.timeIntervalSince1970 ?? 0)
            let totalTime = endTimeInterval - startTimeInterval
            updateLabelsWith((data?.currentProgress ?? 0) * totalTime)
        } else {
            let totalTime = data?.durationInSeconds ?? 0
            updateLabelsWith((data?.currentProgress ?? 0) * totalTime)
        }
    }
    
    func playReachEnd(controlModalData: ControlModalData) {
        data?.playState = .pause
        playNext?()
    }
    
    func playStateChanged(controlModalData: ControlModalData) {
        if (data?.isLive ?? false) {
            onTVButtonView.isHidden = false
            playbackButton.setImage(nil, for: .normal)
            let playState = data?.playState ?? .notPlayed
            if (playState == .notPlayed) {
                // normal color
                onTVLabel.textColor = onTVLabelColor
            } else if (playState == .currentPlaying) {
                // more dark color
                onTVLabel.textColor = onTVDarkerLabelColor
                if (needUpdateAll) {
                    self.onPlayMedia?()
                }
            } else {
                onTVLabel.textColor = onTVDarkerLabelColor
                playOverButton.isEnabled = false
                rewindButton.isEnabled = false
                fastforwardButton.isEnabled = false
                playbackButton.isEnabled = false
                bookmarkButton.isEnabled = false
                captionButton.isEnabled = false
            }
        } else {
            onTVButtonView.isHidden = true
            let playState = data?.playState ?? .notPlayed
            if (playState ==  .pause) {
                self.playbackButton.setImage(UIImage(named: "ic_play_with_border"), for: .normal)
                playOverButton.isEnabled = true
                rewindButton.isEnabled = true
                fastforwardButton.isEnabled = true
            } else if (playState == .notPlayed) {
                self.playbackButton.setImage(UIImage(named: "ic_play_with_border"), for: .normal)
                playOverButton.isEnabled = false
                rewindButton.isEnabled = false
                fastforwardButton.isEnabled = false
            } else if (playState == .currentPlaying) {
                self.playbackButton.setImage(UIImage(named: "ic_pause"), for: .normal)
                if (needUpdateAll) {
                    self.onPlayMedia?()
                }
                playOverButton.isEnabled = true
                rewindButton.isEnabled = true
                fastforwardButton.isEnabled = true
            } else {
                playOverButton.isEnabled = false
                rewindButton.isEnabled = false
                fastforwardButton.isEnabled = false
                playbackButton.isEnabled = false
                bookmarkButton.isEnabled = false
                captionButton.isEnabled = false
                volumeSlider.isEnabled = false
            }
        }
    }
}

// MARK: - Actions
extension ControlModalCellViewController {
    
    @IBAction func dismissButtonTouched(_ sender: UIButton) {
        onClosePress()
    }
    
    @IBAction func changeOrientationTouched(_ sender: UIButton) {
        onAlert?("Rotate your device to watch on the phone!")
    }
    
    @IBAction func onShareTouched(_ sender: UIButton) {
        onShare?()
    }
    
    @IBAction func onRewindTouched(_ sender: UIButton) {
        if (data?.isLive ?? false) {
            // TODO: - Rewind for live
        } else {
            var currentTime = (data?.currentProgress ?? 0) * (data?.durationInSeconds ?? 0)
            currentTime = max(currentTime-10,0)
            self.seekTo(currentTime) { (isSuccess) in
                if (isSuccess) {
                    self.data?.currentProgress = currentTime/(self.data?.durationInSeconds ?? 1)
                }
            }
        }
    }
    
    @IBAction func onFastForwardTouched(_ sender: UIButton) {
        if (data?.isLive ?? false) {
            // TODO: - Fastforward for live
        } else {
            let durationInSeconds = data?.durationInSeconds ?? 0
            var currentTime = (data?.currentProgress ?? 0) * durationInSeconds
            currentTime = min(currentTime+10,durationInSeconds)
            self.seekTo(currentTime) { (isSuccess) in
                if (isSuccess) {
                    self.data?.currentProgress = currentTime/(self.data?.durationInSeconds ?? 1)
                }
            }
        }
    }
    
    @IBAction func onPlayOverTouched(_ sender: UIButton) {
        
        data?.getVideoUrl(callback: { (url) in
            Api.shared().hIG_PlayMediaStart(withPlayPosition: 0, uRL: url) { (isSuccess, error) in
                if !isSuccess {
                    print(error ?? "")
                } else {
                    self.data?.currentProgress = 0
                }
            }
        })
    }
    
    @IBAction func infoButtonTouched(_ sender: UIButton) {
        onDetailPress()
    }
    
    @IBAction func bookmarkButtonTouched(_ sender: UIButton) {
        onBookmark?()
    }
    
    @IBAction func favoriteButtonTouched(_ sender: UIButton) {
        onFavorite?()
    }
    
    @IBAction func volumeSliderChanged(_ sender: UISlider) {
        Api.shared().hIG_SetVolume(Int32(sender.value * 100)) { (isSuccess, message) in
            if (!isSuccess) {
                print(message ?? "")
            }
        }
        self.onVolumeChanged?(sender.value)
    }
    
    @IBAction func playBackButtonTouched(_ sender: UIButton) {
        
        if (data?.isLive ?? false) {
            let playState = data?.playState ?? .notPlayed
            if (playState == .notPlayed) {
                Api.shared().hIG_SetZap(withLCN: Int32(self.data?.lcn ?? 0)) { (isSuccess, message) in
                    if (!isSuccess) {
                        print(message ?? "")
                    } else {
                        self.data?.playState = .currentPlaying
                    }
                }
            }
        } else {
            let playState = data?.playState ?? .notPlayed
            if (playState ==  .pause) {
                Api.shared().hIG_PlayMediaResume { (isSuccess, error) in
                    if !isSuccess {
                        print(error ?? "")
                    } else {
                        self.data?.playState = .currentPlaying
                    }
                }
            } else if (playState == .notPlayed) {
                data?.getVideoUrl(callback: { (url) in
                    Api.shared().hIG_PlayMediaStart(withPlayPosition: 0, uRL: url) { (isSuccess, error) in
                        if !isSuccess {
                            print(error ?? "")
                        } else {
                            self.data?.playState = .currentPlaying
                        }
                    }
                })
            } else {
                Api.shared().hIG_PlayMediaPause({ (isSuccess, error) in
                    if !isSuccess {
                        print(error ?? "")
                    } else {
                        self.data?.playState = .pause
                    }
                })
            }
        }
        
    }
}

