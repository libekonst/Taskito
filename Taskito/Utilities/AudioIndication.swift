//
//  AudioIndication.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 3/8/24.
//

import AVFAudio
import Foundation

class AudioIndication {
    private var audioPlayer: AVAudioPlayer!

    init() {
        let fileName = "timer-finished"
        guard let soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("ERROR: Unable to find sound file in bundle")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = 2
        } catch {
            print(error.localizedDescription)
        }
    }

    func play() {
        audioPlayer?.play()
    }
}
