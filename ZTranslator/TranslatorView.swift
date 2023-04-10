//
//  ContentView.swift
//  ZTranslator
//
//  Created by Alan on 5/4/23.
//

import SwiftUI
import Cocoa
import MASShortcut

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

struct TranslatorView: View {
    @State var originalText: String = ""
    @State var originalTextFontSize: CGFloat = 36
    @State var text: String = ""
    @State var fontSize: CGFloat = 36
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
