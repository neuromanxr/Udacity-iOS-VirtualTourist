//
//  RecordSoundsViewController.swift
//  Pick Your Pitch
//
//  Created by Udacity on 1/5/15.
//  Copyright (c) 2014 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var shouldSegueToSoundPlayer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSFileManager.defaultManager().fileExistsAtPath(audioFileURL().path!) {
            shouldSegueToSoundPlayer = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //Hide the stop button
        stopButton.hidden = true
        recordButton.enabled = true
        
        // If the audio file was found in viewDidLoad, then segue to the sound player
        if shouldSegueToSoundPlayer {
            shouldSegueToSoundPlayer = false
            recordedAudio = RecordedAudio(filePathUrl: audioFileURL(), title: audioFileURL().lastPathComponent)
            self.performSegueWithIdentifier("stopRecording", sender: self)
        }
    }

    @IBAction func recordAudio(sender: UIButton) {
        // Update the UI
        stopButton.hidden = false
        recordingInProgress.hidden = false
        recordButton.enabled = false
        
        // Setup audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)

        // Initialize and prepare the recorder
        audioRecorder = AVAudioRecorder(URL: audioFileURL(), settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true;
        audioRecorder.prepareToRecord()

        audioRecorder.record()
    }
    
    // Returns a URL to the audio file
    func audioFileURL() ->  NSURL {
        let filename = "usersVoice.wav"
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let pathArray = [dirPath, filename]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
        
        return fileURL
    }

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {

        if flag {
            let path = audioFileURL()
            recordedAudio = RecordedAudio(filePathUrl: path, title: path.pathExtension)
            self.performSegueWithIdentifier("stopRecording", sender: self)
        } else {
            println("Recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "stopRecording" {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = recordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        recordingInProgress.hidden = true
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance();
        audioSession.setActive(false, error: nil)
        
        // This function stops the audio. We will then wait to hear back from the recorder, 
        // through the audioRecorderDidFinishRecording method
    }
}

