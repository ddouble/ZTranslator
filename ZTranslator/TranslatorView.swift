//
//  ContentView.swift
//  ZTranslator
//
//  Created by Alan on 5/4/23.
//

import SwiftUI
import Cocoa
import MASShortcut


struct TranslatorView: View {
    @State var text: String
    var body: some View {
        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
            Text(text).font(
                .system(size: 20, design: .monospaced)
//                    .custom("Verdana", size: 20)
            )
        }
            .padding()
            .onAppear {
                NotificationCenter.default.addObserver(forName: .wakeUp, object: nil, queue: .main) { notification in
                    NSApplication.shared.windows.first?.orderFrontRegardless()
                }

                NotificationCenter.default.addObserver(forName: .selectedTextChanged, object: nil, queue: .main) { notification in
                    if let newText = notification.object as? String {
                        self.text = newText
                    }
                    NSApplication.shared.windows.first?.orderFrontRegardless()
                }
            }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TranslatorView(text: "Hello world")
    }
}
