//
//  PlaySoundsViewController.swift
//  Pick Your Pitch
//
//  Created by Udacity on 1/5/15.
//  Copyright (c) 2014 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    let SliderValueKey = "Slider Value Key"
    
    var audioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true

        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
        // Retrieve the slider location
        sliderView.value = NSUserDefaults.standardUserDefaults().floatForKey(SliderValueKey)
        
        setUserInterfaceToPlayMode(false)
    }
    
    func setUserInterfaceToPlayMode(isPlayMode: Bool) {
        startButton.hidden = isPlayMode
        stopButton.hidden = !isPlayMode
        sliderView.enabled = !isPlayMode
    }

    @IBAction func playAudio(sender: UIButton) {
        
        // Get the pitch from the slider
        let pitch = sliderView.value
        
        // Play the sound
        playAudioWithVariablePitch(pitch)
        
        // Set the UI
        setUserInterfaceToPlayMode(true)
        
        // Save the slider location
        NSUserDefaults.standardUserDefaults().setFloat(sliderView.value, forKey: SliderValueKey)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playAudioWithVariablePitch(pitch: Float){
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {
            // When the audio completes, set the user interface on the main thread
            dispatch_async(dispatch_get_main_queue()) {self.setUserInterfaceToPlayMode(false) }
        }
        
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    @IBAction func sliderDidMove(sender: UISlider) {
        // Do nothing?
        println("Slider vaue: \(sliderView.value)")
    }
}
