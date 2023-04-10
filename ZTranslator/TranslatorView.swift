//
//  ContentView.swift
//  ZTranslator
//
//  Created by Alan on 5/4/23.
//

import SwiftUI
import Cocoa
import MASShortcut
import AVFoundation

func getFontSize(for text: String, minimumSize minSize: CGFloat, maximumSize maxSize: CGFloat, minLengthThreshold: Int = 10, maxLengthThreshold: Int = 200) -> CGFloat {
    let length = text.count
    print(length, minSize, maxSize, minLengthThreshold, maxLengthThreshold)
    if length < minLengthThreshold {
        return maxSize
    } else if length > maxLengthThreshold {
        return minSize
    } else {
        let fontRatio = (CGFloat(length) - CGFloat(minLengthThreshold)) / (CGFloat(maxLengthThreshold) - CGFloat(minLengthThreshold))
        print(fontRatio, Int(maxSize - fontRatio * (maxSize - minSize)))
        return CGFloat(Int(maxSize - fontRatio * (maxSize - minSize)))
    }
}

/**
 Read text by text-to-speech
 - Parameters:
   - synthesizer:
   - text:
 */
func speak(synthesizer: AVSpeechSynthesizer, text: String) {
    if synthesizer.isSpeaking {
        synthesizer.stopSpeaking(at: .immediate)
    }

    let voices = AVSpeechSynthesisVoice.speechVoices()
    for voice in voices {
        print("\(voice.language) - \(voice.name)")
    }

    let utterance = AVSpeechUtterance(string: text)
    let voice = AVSpeechSynthesisVoice(identifier: "com.apple.speech.synthesis.voice.Kate")
    utterance.rate = 0.5
    utterance.pitchMultiplier = 0.8
    utterance.postUtteranceDelay = 0.2
    utterance.volume = 0.8
    utterance.voice = voice
    synthesizer.speak(utterance)

}

struct TranslatorView: View {
    @State var originalText: String = ""
    @State var originalTextFontSize: CGFloat = 36
    @State var text: String = ""
    @State var fontSize: CGFloat = 36

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            ScrollView {
                Text(originalText).font(
                        .system(size: originalTextFontSize, design: .monospaced)
//                    .custom("Verdana", size: 20)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(CGFloat(22))
                    .lineSpacing(CGFloat(0.2 * originalTextFontSize))
//                    .multilineTextAlignment(.leading)

            }
                .frame(minWidth: 800)
            ScrollView {
                Text(text).font(
                        .system(size: fontSize, design: .monospaced)
//                    .custom("Verdana", size: 20)
                    ).frame(maxWidth: .infinity, alignment: .leading)
                    .padding(CGFloat(22))
                    .lineSpacing(CGFloat(0.2 * fontSize))
            }
                .frame(minWidth: 800)
        }
            .onAppear() {
                NotificationCenter.default.addObserver(forName: .wakeUp, object: nil, queue: .main) { notification in
                    if let newOriginalText = notification.object as? String {
                        self.fontSize = 36
                        self.originalTextFontSize = getFontSize(for: newOriginalText, minimumSize: 22, maximumSize: 36, minLengthThreshold: 20)
                        self.originalText = newOriginalText
                        self.text = "..."

                        speak(synthesizer: synthesizer, text: originalText)
                    }
//                    NSApplication.shared.windows.first?.orderFrontRegardless()
                }

                NotificationCenter.default.addObserver(forName: .selectedTextChanged, object: nil, queue: .main) { notification in
                    if let newText = notification.object as? String {
                        self.fontSize = getFontSize(for: newText, minimumSize: 26, maximumSize: 36)
                        self.text = newText
                    }
//                    NSApplication.shared.windows.first?.orderFrontRegardless()
                }
            }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TranslatorView(text: "Hello world")
    }
}
