//
//  ViewController.swift
//  SkooveCodingChallenge
//
//  Created by Maryam on 5/20/22.
//

import UIKit
import AVFoundation

enum FirstAudio: String, CaseIterable {
    case A1, A2, A3
}

enum SideAudio: String, CaseIterable {
    case B1, B2, B3
}

class Main: UIViewController {

    @IBOutlet weak var playButton: UIButton?
    @IBOutlet weak var firstImage: UIImageView?
    @IBOutlet weak var sideImage: UIImageView?
    @IBOutlet weak var progressSliderA1: CustomSlider?
    @IBOutlet weak var progressSliderA2: CustomSlider?
    @IBOutlet weak var forwardFirstAudio: UIImageView?
    @IBOutlet weak var forwardSideAudio: UIImageView?
    @IBOutlet weak var MTILabel: UILabel?
    @IBOutlet weak var barStroke: UIView?
    @IBOutlet weak var barView: UIView?
    @IBOutlet weak var beatStroke: UIView?
    @IBOutlet weak var beatView: UIView?

    var completeDuration:Float = 0.0
    var audioPlayerA1 = AVAudioPlayer()
    var audioPlayerA2 = AVAudioPlayer()
    var audioPlayerExist: Bool = false
    var displayLink : CADisplayLink! = nil
    var firstAudio: FirstAudio = .A1 {
        willSet {
            switch firstAudio {
            case .A1:
                firstImage?.image = UIImage(named:"A1")
                sideImage?.image = UIImage(named:"B1")
            case .A2:
                firstImage?.image = UIImage(named:"A2")
                sideImage?.image = UIImage(named:"B2")
            case .A3:
                firstImage?.image = UIImage(named:"A3")
            }
        }
    }
    var sideAudio: SideAudio = .B1 {
        willSet {
            switch sideAudio {
            case .B1:
                sideImage?.image = UIImage(named:"B1")
            case .B2:
                sideImage?.image = UIImage(named:"B2")
            case .B3:
                firstImage?.image = UIImage(named:"B3")
            }
        }
    }
    var isQueued: Bool = false
    weak var timer: Timer?
    var bar: Int = 0 {
        didSet {
            MTILabel?.text = "\(bar):\(beat):\(sixteenths)"
        }
    }
    var beat: Int = 0 {
        didSet {
            MTILabel?.text = "\(bar):\(beat):\(sixteenths)"
        }
    }
    var sixteenths: Int = 0 {
        didSet {
            MTILabel?.text = "\(bar):\(beat):\(sixteenths)"
        }
    }
    var isForwardPressed: Bool = false {
        didSet {
            let firstForwardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(firstAudioForwardHandler(tapGestureRecognizer:)))
            let secondForwardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(secondAudioForwardHandler(tapGestureRecognizer:)))
            if isForwardPressed {
                forwardFirstAudio?.removeGestureRecognizer(firstForwardGestureRecognizer)
                forwardSideAudio?.removeGestureRecognizer(secondForwardGestureRecognizer)
                forwardFirstAudio?.alpha = 0.5
                forwardSideAudio?.alpha = 0.5
            } else {
                forwardFirstAudio?.addGestureRecognizer(firstForwardGestureRecognizer)
                forwardSideAudio?.addGestureRecognizer(secondForwardGestureRecognizer)
                forwardFirstAudio?.alpha = 1
                forwardSideAudio?.alpha = 1
            }
        }
    }
    var isPlaying = false {
        willSet {
            var playImage = UIImage()
            if isPlaying {
                audioPlayerA1.play()
                audioPlayerA2.play()
                playImage = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)) ?? UIImage()
                startTimer()
            } else {
                audioPlayerA1.pause()
                audioPlayerA2.pause()
                playImage = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)) ?? UIImage()
                stopTimer()
            }
            playButton?.setImage(playImage, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressSliderA1?.isUserInteractionEnabled = false
        self.progressSliderA2?.isUserInteractionEnabled = false
        playButton?.addCornerRadius(rad: (playButton?.frame.height ?? 1) / 2)
        barStroke?.addCornerRadius(rad: (barStroke?.frame.height ?? 1) / 2)
        barView?.addCornerRadius(rad: (barView?.frame.height ?? 1) / 2)
        beatStroke?.addCornerRadius(rad: (beatStroke?.frame.height ?? 1) / 2)
        beatView?.addCornerRadius(rad: (beatView?.frame.height ?? 1) / 2)
        addLongPressGestureOnPlayButton()
        isForwardPressed = false
        MTILabel?.text = "\(bar):\(beat):\(sixteenths)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    deinit {
        stopTimer()
    }
    
    @objc func firstAudioForwardHandler(tapGestureRecognizer: UITapGestureRecognizer) {
        firstAudio.next()
        isForwardPressed = true
        audioPlayerA1.numberOfLoops = 0
        audioPlayerA2.numberOfLoops = 0
//        setPlayerAudio()
//        switch firstAudio {
//        case .A1:
//            firstAudio.next()
//            break
//        case .A2:
//            firstAudio = FirstAudio.A2.next()
//            break
//        case .A3:
//            firstAudio = FirstAudio.A3.next()
//            break
//        default:
//            break
//        }
        
    }
    
    @objc func secondAudioForwardHandler(tapGestureRecognizer: UITapGestureRecognizer) {
        sideAudio.next()
        isForwardPressed = true
        audioPlayerA1.numberOfLoops = 0
        audioPlayerA2.numberOfLoops = 0
    }
    
    private func setViewRoundCorners() {
        playButton?.layer.masksToBounds = false
        playButton?.layer.cornerRadius = (playButton?.frame.height ?? 1) / 2
        playButton?.clipsToBounds = true
    }
    
    func addLongPressGestureOnPlayButton(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = 2.0
        playButton?.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            resetPlayer()
        }
    }
    
    func resetPlayer() {
        audioPlayerA1.stop()
        audioPlayerA2.stop()
        progressSliderA1?.value = 0
        progressSliderA1?.value = 0
        isPlaying = false
        displayLink.invalidate()
        bar = 0
        beat = 0
        sixteenths = 0
    }
    
//    func setAudioPlayer(){
//        if !self.audioPlayerExist {
//            audioPlayerExist = true;
//            setPlayerAudio()
//            audioPlayerA1?.delegate = self
//            audioPlayerA2?.delegate = self
//        }
//    }
    
    func setPlayerAudio() {
        
        guard let url1 = Bundle.main.url(forResource: firstAudio.rawValue, withExtension: "wav") else { return }
        guard let url2 = Bundle.main.url(forResource: sideAudio.rawValue, withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayerA1 = try AVAudioPlayer(contentsOf: url1, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayerA2 = try AVAudioPlayer(contentsOf: url2, fileTypeHint: AVFileType.mp3.rawValue)
            if !audioPlayerExist {
                audioPlayerExist = true
                audioPlayerA1.delegate = self
                audioPlayerA2.delegate = self
            }
            progressSliderA1?.maximumValue = Float(audioPlayerA1.duration)
            progressSliderA2?.maximumValue = Float(audioPlayerA2.duration)
            audioPlayerA1.numberOfLoops = -1
            audioPlayerA2.numberOfLoops = -1
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func playback(_ sender:UIButton){
        sender.isUserInteractionEnabled = false
        if audioPlayerA1.isPlaying || audioPlayerA2.isPlaying {
            isPlaying = false
        } else {
            if (audioPlayerA1.currentTime == 0) || (audioPlayerA2.currentTime == 0) {
                setPlayerAudio()
            }
            isPlaying = true
            displayLink = CADisplayLink(target: self, selector: (#selector(self.setSliderProgress)))
            displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
//            currentValueA1 = ( currentDurationInSecA1 > completeDuration ) ? completeDuration : currentDurationInSecA1
//            currentValueA2 = ( currentDurationInSecA2 > completeDuration ) ? completeDuration : currentDurationInSecA2
        }
        sender.isUserInteractionEnabled = true
//        durationLabel.text = Double(currentValue).secondsToString()
//        self.delegate?.setProgressSliderValue(self.progressSlider.value)
//        self.setPlayerState(false)
//        GISTUtility.delay((UIDevice.current.hasNotch) ? 0.5 : 1.0) {
//            self.delegate?.progressSliderTouchedUp(self.progressSlider)
//            self.setPlayerState(true)
//        }
    }
    
    
    @objc func setSliderProgress(){
        let currentValueA1 = ( audioPlayerA1.currentTime > audioPlayerA1.duration ) ? audioPlayerA1.duration : audioPlayerA1.currentTime
        let currentValueA2 = ( audioPlayerA2.currentTime > audioPlayerA2.duration ) ? audioPlayerA2.duration : audioPlayerA2.currentTime
        if (currentValueA1 == 0) || (currentValueA2 == 0) {
            isForwardPressed = false
            isPlaying = true
        }
        let progress1 = (Float(currentValueA1 ) * 100) / (Float(audioPlayerA1.duration ))
        let progress2 = (Float(currentValueA2 ) * 100) / (Float(audioPlayerA2.duration ))
        UIView.animate(withDuration: 0.1, animations: {
            self.progressSliderA1?.setValue(progress1, animated:true)
            self.progressSliderA2?.setValue(progress2, animated:true)
        })
    }
    
    func calculateMTI() {
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1172, repeats: true) { [weak self] _ in
            if self?.sixteenths ?? 0 < 3 {
                self?.sixteenths += 1
            } else if self?.beat ?? 0 < 3 {
                self?.beatView?.blink()
                self?.beat += 1
                self?.sixteenths = 0
            } else {
                self?.barView?.blink()
                self?.bar += 1
                self?.beat = 0
                self?.sixteenths = 0
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }

}

extension Main: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

        if flag {
            setPlayerAudio()
            isPlaying = flag
        }
    }
    
}


