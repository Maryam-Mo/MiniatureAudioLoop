//
//  SkooveCodingChallengeTests.swift
//  SkooveCodingChallengeTests
//
//  Created by Maryam on 5/30/22.
//

import XCTest

@testable import SkooveCodingChallenge

class SkooveCodingChallengeTests: XCTestCase {

    var sut: Main!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = Main()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
    
    func testNextOnFirstAudioEnum() {
        
        sut.firstAudio = FirstAudio.A1
        
        sut.firstAudio.next()

        XCTAssertEqual(sut.firstAudio, .A2, "forward song doesn't work properly")
        
        
        sut.firstAudio.next()

        XCTAssertEqual(sut.firstAudio, .A3, "forward song doesn't work properly")
        
    }
    
    func testNextOnLastSongOfFirstAudioIsFirstSong() {
        sut.firstAudio = FirstAudio.A3

        sut.firstAudio.next()

        XCTAssertEqual(sut.firstAudio, .A1, "forward last song doesn't work properly")
    }
    
    func testPlayButton() {
        
        let button = UIButton()

        sut.playback(button)

        XCTAssertEqual(sut.isPlaying, true, "Play button doesn't work properly")
        
        sut.playback(button)
        
        XCTAssertEqual(sut.audioPlayerA1.isPlaying, true , "Play button doesn't work properly")
        
        XCTAssertEqual(sut.playButton?.currentImage, UIImage(named: "pause.fill"), "Play button's image doesn't set properly")
        
        
        sut.playback(button)

        XCTAssertEqual(sut.isPlaying, false , "Play button doesn't work properly")
        
    }
    
    func testResetPlayer() {
        
        sut.playback(UIButton())
        
        sut.resetPlayer()
        
        XCTAssertEqual(sut.audioPlayerA1.isPlaying, false , "reset button doesn't work properly(AudioPlayer1 didn't stop)!")
        
        XCTAssertEqual(sut.audioPlayerA2.isPlaying, false , "reset button doesn't work properly(AudioPlayer2 didn't stop)!")
        
        XCTAssertEqual(sut.audioPlayerA1.currentTime, 0 , "reset button doesn't work properly(current time didn't set to 0)!")
        
        XCTAssertEqual(sut.bar, 0 , "reset button doesn't work properly(bar didn't get reset)!")
        
        XCTAssertEqual(sut.beat, 0 , "reset button doesn't work properly(beat didn't get reset)!")

        XCTAssertEqual(sut.sixteenths, 0 , "reset button doesn't work properly(sixteenths didn't get reset)!")
        
    }
    

}
