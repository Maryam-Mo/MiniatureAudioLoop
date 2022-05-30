//
//  ViewController.swift
//  SkooveCodingChallenge
//
//  Created by Maryam on 5/20/22.
//

import UIKit
import AVFoundation

enum FirstAudio: String, CaseIterable {
    case A1 = "A1", A2 = "A2", A3 = "A3"
}

enum SideAudio: String, CaseIterable {
    case B1 = "B1", B2 = "B2", B3 = "B3"
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
    @IBOutlet weak var microLoopImage: UIImageView?

    var completeDuration:Float = 0.0
    var audioPlayerA1 = AVAudioPlayer()
    var audioPlayerA2 = AVAudioPlayer()
    var audioPlayerExist: Bool = false
    var displayLink : CADisplayLink! = nil
    var isMicroLoop: Bool = false
    var isBetween0And2: Bool = false
    var isBetween2And4: Bool = false
    var isBetween4And6: Bool = false
    var isBetween6And8: Bool = false
    var firstAudio: FirstAudio = FirstAudio.A1 {
        didSet {
            switch firstAudio {
            case .A1:
                firstImage?.image = UIImage(named:"A1")
            case .A2:
                firstImage?.image = UIImage(named:"A2")
            case .A3:
                firstImage?.image = UIImage(named:"A3")
            }
        }
    }
    var sideAudio: SideAudio = SideAudio.B1 {
        didSet {
            switch sideAudio {
            case .B1:
                sideImage?.image = UIImage(named:"B1")
            case .B2:
                sideImage?.image = UIImage(named:"B2")
            case .B3:
                sideImage?.image = UIImage(named:"B3")
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
    var isFirstForwardPressed: Bool = false {
        didSet {
            let firstForwardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(firstAudioForwardHandler(tapGestureRecognizer:)))
            if isFirstForwardPressed {
                forwardFirstAudio?.removeGestureRecognizer(firstForwardGestureRecognizer)
                forwardFirstAudio?.alpha = 0.3
            } else {
                forwardFirstAudio?.addGestureRecognizer(firstForwardGestureRecognizer)
                forwardFirstAudio?.alpha = 1
            }
        }
    }
    var isSideForwardPressed: Bool = false {
        didSet {
            let sideForwardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sideAudioForwardHandler(tapGestureRecognizer:)))
            if isSideForwardPressed {
                forwardSideAudio?.removeGestureRecognizer(sideForwardGestureRecognizer)
                forwardSideAudio?.alpha = 0.3
            } else {
                forwardSideAudio?.addGestureRecognizer(sideForwardGestureRecognizer)
                forwardSideAudio?.alpha = 1
            }
        }
    }
    var isPlaying = false {
        willSet {
            let microLoopGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(microLoopHandler(tapGestureRecognizer:)))
            if isPlaying {
                handlePlayState(microLoopGestureRecognizer)
            } else {
                handlePauseState(microLoopGestureRecognizer)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
    }

    deinit {
        pauseTimer()
    }
    
    @objc func firstAudioForwardHandler(tapGestureRecognizer: UITapGestureRecognizer) {
        isFirstForwardPressed = true
        audioPlayerA1.numberOfLoops = 0
        audioPlayerA2.numberOfLoops = 0
    }
    
    @objc func sideAudioForwardHandler(tapGestureRecognizer: UITapGestureRecognizer) {
        isSideForwardPressed = true
        audioPlayerA1.numberOfLoops = 0
        audioPlayerA2.numberOfLoops = 0
    }
    
    @objc func microLoopHandler(tapGestureRecognizer: UITapGestureRecognizer) {
        isMicroLoop = !isMicroLoop
    }
    
    private func setupComponents() {
        addCornerRadius()
        progressSliderA1?.isUserInteractionEnabled = false
        progressSliderA2?.isUserInteractionEnabled = false
        addLongPressGestureOnPlayButton()
        isFirstForwardPressed = false
        isSideForwardPressed = false
        firstAudio = FirstAudio.A1
        sideAudio = SideAudio.B1
        MTILabel?.text = "\(bar):\(beat):\(sixteenths)"
    }
    
    private func addCornerRadius() {
        playButton?.addCornerRadius(rad: (playButton?.frame.height ?? 1) / 2)
        barStroke?.addCornerRadius(rad: (barStroke?.frame.height ?? 1) / 2)
        barView?.addCornerRadius(rad: (barView?.frame.height ?? 1) / 2)
        beatStroke?.addCornerRadius(rad: (beatStroke?.frame.height ?? 1) / 2)
        beatView?.addCornerRadius(rad: (beatView?.frame.height ?? 1) / 2)
    }
    
    private func handlePlayState(_ microLoopGestureRecognizer: UITapGestureRecognizer) {
        var pauseImage = UIImage()
        pauseImage = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)) ?? UIImage()
        playButton?.setImage(pauseImage, for: .normal)
        startTimer()
        audioPlayerA1.play()
        audioPlayerA2.play()
        microLoopImage?.addGestureRecognizer(microLoopGestureRecognizer)
        microLoopImage?.alpha = 1
    }
    
    private func handlePauseState(_ microLoopGestureRecognizer: UITapGestureRecognizer) {
        audioPlayerA1.pause()
        audioPlayerA2.pause()
        var playImage = UIImage()
        playImage = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)) ?? UIImage()
        playButton?.setImage(playImage, for: .normal)
        pauseTimer()
        microLoopImage?.removeGestureRecognizer(microLoopGestureRecognizer)
        microLoopImage?.alpha = 0.3
    }
    
    private func addLongPressGestureOnPlayButton(){
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
        isPlaying = false
        audioPlayerA1.stop()
        audioPlayerA2.stop()
        audioPlayerA1.currentTime = 0
        audioPlayerA2.currentTime = 0
        progressSliderA1?.value = 0
        progressSliderA2?.value = 0
        displayLink.invalidate()
        timer?.invalidate()
        bar = 0
        beat = 0
        sixteenths = 0
        var playImage = UIImage()
        playImage = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)) ?? UIImage()
        playButton?.setImage(playImage, for: .normal)
    }
    
    private func setPlayerAudio() {
        
        guard let url1 = Bundle.main.url(forResource: firstAudio.rawValue, withExtension: "wav") else { return }
        guard let url2 = Bundle.main.url(forResource: sideAudio.rawValue, withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayerA1 = try AVAudioPlayer(contentsOf: url1, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayerA2 = try AVAudioPlayer(contentsOf: url2, fileTypeHint: AVFileType.mp3.rawValue)
            
            initializeAudioPlayers()
            setupAudioPlayers()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func initializeAudioPlayers(){
        if !audioPlayerExist {
            audioPlayerExist = true
            audioPlayerA1.delegate = self
            audioPlayerA2.delegate = self
        }
    }
    
    private func setupAudioPlayers() {
        progressSliderA1?.maximumValue = Float(audioPlayerA1.duration)
        progressSliderA2?.maximumValue = Float(audioPlayerA2.duration)
        progressSliderA1?.minimumValue = 0.0
        progressSliderA2?.minimumValue = 0.0
        audioPlayerA1.numberOfLoops = -1
        audioPlayerA2.numberOfLoops = -1
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
        }
        sender.isUserInteractionEnabled = true
    }
    
    
    @objc func setSliderProgress(){
        let currentValueA1 = ( audioPlayerA1.currentTime > audioPlayerA1.duration ) ? audioPlayerA1.duration : audioPlayerA1.currentTime
        let currentValueA2 = ( audioPlayerA2.currentTime > audioPlayerA2.duration ) ? audioPlayerA2.duration : audioPlayerA2.currentTime
        if (currentValueA1 == 0) || (currentValueA2 == 0)  {
            handleNextSong()
            isPlaying = true
        }
        let progress1 = Float(currentValueA1)
        let progress2 = Float(currentValueA2)
        UIView.animate(withDuration: 0.1, animations: {
            self.progressSliderA1?.setValue(progress1, animated:true)
            self.progressSliderA2?.setValue(progress2, animated:true)
        })
    }
    
    private func handleNextSong() {
        if isFirstForwardPressed {
            firstAudio.next()
            setPlayerAudio()
            isFirstForwardPressed = false
        }
        if isSideForwardPressed {
            sideAudio.next()
            setPlayerAudio()
            isSideForwardPressed = false
        }
    }
    
    private func startTimer() {
        // The audio file includes 8 musical bars and each bar is equal to 4 beats, now we need to multiply the number of measures by the number of beats per measure(8 * 4 = 32)
        let _bar = 8
        let _beatsPerBar = 4
        let _beatsNumber = _bar * _beatsPerBar
        // BPM => 32 * 4 = 128
        let _beatsPerMinute = _beatsNumber * 4
        // Length of 1 beat in 128 BPM: 0.4688 second = 469 msec
        let sixteenthNotesLength = 0.4688 * 1/4
        // As sixteenth notes are equal to ¼ of a count => 0.4688 * 1/4 = 0.1172
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(sixteenthNotesLength), repeats: true) { [weak self] _ in
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
            self?.handleMicroLoop()
        }
    }
    
    private func handleMicroLoop() {
        if isMicroLoop == true {
            let divider: Int = bar / 8
            let remainder = (Int(floor(Double(bar) / 2.0) * 2)) % 8
            if remainder >= 0 && remainder < 2 {
                isBetween0And2 = true
            } else if remainder >= 2 && remainder < 4 {
                isBetween2And4 = true
            } else if remainder >= 4 && remainder < 6 {
                isBetween4And6 = true
            } else if remainder >= 6 && remainder <= 8{
                isBetween6And8 = true
            }
            if (isBetween0And2 == true && remainder == 2) {
                loopSelectedSegment(segment: 0, divider: divider)
            } else if isBetween2And4 == true && remainder == 4 {
                loopSelectedSegment(segment: 2, divider: divider)
            } else if isBetween4And6 == true && remainder == 6 {
                loopSelectedSegment(segment: 4, divider: divider)
            } else if isBetween4And6 == true && remainder == 8 {
                loopSelectedSegment(segment: 6, divider: divider)
            }
        } else {
            isBetween0And2 = false
            isBetween2And4 = false
            isBetween4And6 = false
            isBetween6And8 = false
        }
    }
    
    private func loopSelectedSegment(segment: Int, divider: Int) {
        audioPlayerA1.currentTime = TimeInterval(segment)
        audioPlayerA2.currentTime = TimeInterval(segment)
        bar = divider == 0 ? segment : segment + (divider * 8)
        sixteenths = 0
        beat = 0
    }
    
    private func pauseTimer() {
        timer?.invalidate()
    }

}

extension Main: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

        if flag {
            handleNextSong()
            isPlaying = flag
        }
    }
    
}


