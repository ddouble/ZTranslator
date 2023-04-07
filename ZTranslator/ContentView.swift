//
//  ContentView.swift
//  ZTranslator
//
//  Created by Alan on 5/4/23.
//

import SwiftUI
import Cocoa
import MASShortcut


struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
//            let shortcut = MASShortcut(keyCode: kVK_ANSI_X, modifierFlags: NSEvent.ModifierFlags(arrayLiteral: .control, .command))
//            MASShortcutMonitor.shared().register(shortcut, withAction: {
//                print("CTRL+CMD+X keystroke was captured!")
//            })
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
