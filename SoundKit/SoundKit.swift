//
//  SoundKit.swift
//  SoundKit
//
//  Created by John Zeglarski on 5/20/19.
//  Copyright © 2019 John Zeglarski. All rights reserved.
//

import Foundation
import AVFoundation

public class SoundManager {
    
    // MARK: - Properties
    // ------------------------------------------------------------
    
    /// A Boolean property that indicates whether the manager allows sound effects.
    public var allowsSound: Bool = true
    /// A Boolean property that indicates whether the manager allows background music.
    public var allowsMusic: Bool = true {
        didSet {
            if allowsMusic {
                // TODO: Verify 'Resume Music' behavior here.
                musicEnabled()
            }
            else { musicDisabled() }
        }
    }
    
    /**
     The volume to play sound effects at.
     
     This property is restricted to the range 0 to 1. The default value is `1.0`.
     
     Attempting to set this property to a value greater than 1 will result in the property being set to 1.
     
     Attempting to set this property to a value less than 0 will result in the property being set to 0.
     */
    public var soundVolume: Float = 1.0 {
        didSet {
            if (soundVolume > 1.0) { soundVolume = 1.0 }
            else if (soundVolume < 0.0) { soundVolume = 0.0 }
        }
    }
    /**
     The volume to play background music at.
     
     This property is restricted to the range 0 to 1. The default value is `0.5`.
     
     Attempting to set this property to a value greater than 1 will result in the property being set to 1.
     
     Attempting to set this property to a value less than 0 will result in the property being set to 0.
     */
    public var musicVolume: Float = 0.5 {
        didSet {
            if (musicVolume > 1.0) { musicVolume = 1.0 }
            else if (musicVolume < 0.0) { musicVolume = 0.0 }
        }
    }
        
    // Music/Sound Players
    private var musicPlayer: AVAudioPlayer?
    private var soundPlayer: AVAudioPlayer?
    
    private let soundKitDispatchGroup = DispatchGroup()
    
    
    // MARK: -
    // ------------------------------------------------------------
    
    /**
     Initializes a new SoundManager.
     */
    public init() {
        if isListeningToAudio() {
            allowsMusic = false
        }
    }
    
    // MARK: - Public Methods
    // ------------------------------------------------------------
    
    /**
     Returns a Boolean value that indicates whether another application is currently playing audio.
     - returns: True if another application is already playing audio; otherwise false.
     */
    public func isListeningToAudio() -> Bool {
        return AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
    }
    
    /**
     Returns a Boolean value that indicates whether the app is currently plaing background music.
     - returns: True if the app is currently playing background music; otherwise false.
     */
    public func isPlayingMusic() -> Bool {
        return (musicPlayer?.isPlaying ?? false)
    }
    
    /**
     Returns a Boolean value that indicates whether the app is currently playing a sound effect.
     - returns: True if the app is currently playing a sound effect; otherwise false.
     */
    public func isPlayingSound() -> Bool {
        return (soundPlayer?.isPlaying ?? false)
    }
    
    /**
     Plays a sound effect.
     - Note: Sound effects should be short and limited to under 5 seconds.
     - parameter fileNamed: The name of sound to play.
     */
    public func playSound(fileNamed: String) {
        let rawUrl = Bundle.main.url(forResource: "", withExtension: nil)
        guard let url = rawUrl else { fatalError("ERROR: Could not find file: \(fileNamed)") }
        playSound(url: url)
    }
    
    /**
     Plays a sound effect.
     - Note: Sound effects should be short and limited to under 5 seconds.
     - parameter url: The URL of sound to play.
     */
    public func playSound(url: URL) {
        guard allowsSound else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // FIXME: Consider replacing with secondaryAudioShouldBeSilencedHint
        if audioSession.isOtherAudioPlaying {
            _ = try? audioSession.setActive(true, options: [])
        }
        
        // FIXME: Needs a better way of handling multiple audio streams
        if (soundPlayer != nil) { stopSound() }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.numberOfLoops = 0
            soundPlayer?.volume = soundVolume
            soundPlayer?.play()
        }
        catch let error as NSError {
            NSLog("ERROR: %@", error.description)
            print(error.description)
        }
        print("Sound Playing: \(url)")
    }
    
    /// Stops the currently playing sound effect.
    public func stopSound() {
        soundPlayer?.stop()
        soundPlayer = nil
    }
    
    /**
     Plays backgroundMusic.
     - parameter fileNamed: The name of the background music to play.
     - parameter fadeDuration: The length of time in seconds to crossfade to the given music.
     If music is currently playing, this will fadeout the current music and fade in the new music.
     If the requested music is currently playing, this method does nothing.
     */
    public func playMusic(fileNamed: String, fadeDuration: TimeInterval) {
        let rawUrl = Bundle.main.url(forResource: fileNamed, withExtension: nil)
        guard let url = rawUrl else { fatalError("ERROR: Could not find file: \(fileNamed)") }
        playMusic(url: url, fadeDuration: fadeDuration)
    }
    
    /**
     Plays backgroundMusic.
     - parameter url: The URL of the background music to play.
     - parameter fadeDuration: The length of time in seconds to crossfade to the given music.
     If music is currently playing, this will fadeout the current music and fade in the new music.
     If the requested music is currently playing, this method does nothing.
     */
    public func playMusic(url: URL, fadeDuration: TimeInterval) {
        if isPlaying(url: url) {
            soundKitDispatchGroup.enter()
            print("Dispatch Queue Entered")
            
            DispatchQueue.main.async {
                print("Dispatch Queue Running")
                self.fadeMusicOut(withDuration: (fadeDuration / 2))
            }
            
            soundKitDispatchGroup.notify(queue: .main) {
                print("Dispatch Queue Notified")
                self.fadeMusicIn(url: url, withDuration: (fadeDuration / 2))
            }
        }
        print("Now Playing: \(url)")
    }
    
    /// Stops the currently playing background music.
    public func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }
    
    
    // MARK: - Private Methods
    // ------------------------------------------------------------
    
    private func musicEnabled() {
        // TODO: Implement this method.
    }
    
    private func musicDisabled() {
        // TODO: Implement this method.
    }
    
    /**
     Returns a Boolean value that indicates whether the currently playing background music matches that of the given url.
     - parameter url: The url of the music to check against.
     - returns: True if the given url matches the url of the background music currently playing.
     */
    private func isPlaying(url: URL) -> Bool {
        return (musicPlayer?.url == url)
    }
    
    /**
     Fades in backgroundMusic.
     - parameter url: The URL of the background music to play.
     - parameter fadeDuration: The length of time in seconds to fade in the music.
     */
    private func fadeMusicIn(url: URL, withDuration: TimeInterval) {
        guard allowsMusic else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // FIXME: Consider replacing with secondaryAudioShouldBeSilencedHint
        if audioSession.isOtherAudioPlaying {
            _ = try? audioSession.setActive(true, options: [])
        }
        
        // FIXME: Needs a better way of handling multiple audio streams
        if (musicPlayer != nil) { stopMusic() }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = 0.0
            musicPlayer?.play()
            musicPlayer?.setVolume(musicVolume, fadeDuration: withDuration)
        }
        catch let error as NSError { NSLog("ERROR: %@", error.description)
            print(error.description)
        }
        print("Music Playing: \(url)")
    }
    
    /**
     Fades out backgroundMusic.
     - parameter fadeDuration: The length of time in seconds to fade out the music.
     */
    private func fadeMusicOut(withDuration: TimeInterval) {
        musicPlayer?.setVolume(0.0, fadeDuration: withDuration)
        Timer.scheduledTimer(timeInterval: withDuration, target: self, selector: #selector(endMusic), userInfo: nil, repeats: false)
    }
    
    /// Stops the currently playing background music.
    @objc private func endMusic() {
        stopMusic()
        soundKitDispatchGroup.leave()
    }

}
