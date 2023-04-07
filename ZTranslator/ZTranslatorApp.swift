//
//  ZTranslatorApp.swift
//  ZTranslator
//
//  In order to capture global keyboard shortcut and get selected text from any running App window, you have to add give
//  Accessibility permission to the ZTranslator App
//  1. Open Setting -> Privacy & Security -> Accessibility
//  2. Add the ZTranslator App or Xcode or AppCode or Terminal as per your using case to the Accessibility allowed list
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

/**
 get clipboard text
 - Returns:
 */
func getClipboardText() -> String? {
    let pasteboard = NSPasteboard.general
    let text = pasteboard.string(forType: .string)
    return text
}

/**
 Send text to clipboard
 */
func sendTextToClipboard() {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString("Text to copy", forType: .string)
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


//            let selectedText = getSelectedText2()
            let selectedText = getSelectedText()
            print(selectedText ?? "")

        }
    }
}
