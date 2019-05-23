//
//  SoundKitTests.swift
//  SoundKitTests
//
//  Created by John Zeglarski on 5/20/19.
//  Copyright © 2019 John Zeglarski. All rights reserved.
//

import XCTest
@testable import SoundKit

class SoundKitTests: XCTestCase {
    
    // MARK: - Method Teardown
    // ------------------------------------------------------------
    
    var soundManager: SoundManager!
    var testBundle: Bundle!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        soundManager = SoundManager()
        testBundle = Bundle(for: type(of: self))

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        soundManager.stopSound()
        soundManager.stopMusic()
        soundManager = nil
        super.tearDown()
    }

    // MARK: - Test Methods
    // ------------------------------------------------------------
    
    func testAllows() {
        XCTAssertTrue(soundManager.allowsSound)
        XCTAssertTrue(soundManager.allowsMusic)
        
        soundManager.allowsSound = false
        soundManager.allowsMusic = false
        
        XCTAssertFalse(soundManager.allowsSound)
        XCTAssertFalse(soundManager.allowsMusic)
    }
    
    func testplaySound() {
        let url = testBundle.url(forResource: "songA.m4a", withExtension: nil)
        XCTAssertNotNil(url)
        
        measure {
            XCTAssertFalse(soundManager.isPlayingSound())
            soundManager.playSound(url: url!)
            XCTAssertTrue(soundManager.isPlayingSound())
        }
    }

}
