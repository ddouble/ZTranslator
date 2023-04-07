//
//  ZTranslatorApp.swift
//  ZTranslator
//
//

import SwiftUI
import Cocoa
import MASShortcut

/**
 Get selected text from any running App
 - Returns:
 */
func getSelectedText() -> String? {
    let systemWideElement = AXUIElementCreateSystemWide()
    var focusedApp: AnyObject?
    let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedApplicationAttribute as CFString, &focusedApp)

    if error != .success {
        return nil
    }

    var focusedElement: AnyObject?
    if AXUIElementCopyAttributeValue(focusedApp as! AXUIElement, kAXFocusedUIElementAttribute as CFString, &focusedElement) != .success {
        return nil
    }

    var selectedTextValue: AnyObject?
    if AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedTextValue) != .success {
        return nil
    }

    return selectedTextValue as? String
}


/**
 this function DOESN'T WORK

 Get selected text from any running App,
 - Returns:
 */
func getSelectedText2() -> String? {
    guard let textView = NSApplication.shared.keyWindow?.firstResponder as? NSTextView,
          let selectedRange = textView.selectedRanges.first as? NSRange,
          let selectedText = textView.textStorage?.string,
          let range = Range(selectedRange, in: selectedText)
    else {
        return ""
    }
    return String(selectedText[range])
}

@main
struct ZTranslatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }


    init() {
        let shortcut = MASShortcut(keyCode: kVK_ANSI_X, modifierFlags: [.control, .command])
        MASShortcutMonitor.shared().register(shortcut) {
//            print("CTRL+CMD+X pressed")

            // Trigger the global copy command
//            NSPasteboard.general.clearContents()
//            NSPasteboard.general.setString("Text to copy", forType: .string)

            // get clipboard text
//            let pasteboard = NSPasteboard.general
//            let selectedText = pasteboard.string(forType: .string)
//            let selectedText = getSelectedText2()
            let selectedText = getSelectedText()
//            print(selectedText ?? "")

        }
    }
}
