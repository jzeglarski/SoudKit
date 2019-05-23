//
//  ViewController.swift
//  SoundKitExample
//
//  Created by John Zeglarski on 5/20/19.
//  Copyright © 2019 John Zeglarski. All rights reserved.
//

import UIKit
import SoundKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    // ------------------------------------------------------------
    
    var soundManager: SoundManager?

    @IBOutlet weak var songPicker: UISegmentedControl!
    
    // MARK: - Public Methods
    // ------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Retreives global Sound Manager.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        soundManager = appDelegate.soundManager
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    // MARK: - Public Methods
    // ------------------------------------------------------------
    
    @IBAction func newSongPicked(_ sender: Any) {
        let songList = ["songA.m4a", "songA.m4a"]
        let chosenSong = songList[songPicker.selectedSegmentIndex]
        
        soundManager?.playMusic(fileNamed: chosenSong, fadeDuration: 2.0)
        
        //soundManager?.playSound(fileNamed: "TapSound")
    }
    
}

