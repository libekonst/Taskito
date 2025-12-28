//
//  AudioIndication.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 3/8/24.
//

import AVFAudio
import Foundation

/// Audio resource identifiers
enum AudioResources {
    static let timerFinished = "timer-finished"
    static let mp3Extension = "mp3"
}

class AudioIndication {
    private var audioPlayer: AVAudioPlayer!

    init() {
        guard let soundURL = Bundle.main.url(
            forResource: AudioResources.timerFinished,
            withExtension: AudioResources.mp3Extension
        ) else {
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
