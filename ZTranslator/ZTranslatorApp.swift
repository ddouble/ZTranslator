//
//  ZTranslatorApp.swift
//  ZTranslator
//
//  In order to capture global keyboard shortcut and get selected text from any running App window, you have to give
//  Accessibility permission to the ZTranslator App
//  1. Open Setting -> Privacy & Security -> Accessibility
//  2. Add the ZTranslator App or Xcode or AppCode or Terminal as per your using case to the Accessibility allowed list
//

import SwiftUI
import Cocoa
import MASShortcut
import Foundation

/**
 Get selected text from any running App
 - Returns:
 */
func getSelectedTextByApi() -> String? {
    let systemWideElement = AXUIElementCreateSystemWide()
    var focusedApp: AnyObject?
    let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedApplicationAttribute as CFString, &focusedApp)

    if error != .success {
        return nil
    }

    var focusedElement: AnyObject?
//    if AXUIElementCopyAttributeValue(focusedApp as! AXUIElement, kAXFocusedUIElementAttribute as CFString, &focusedElement) != .success {
//        return nil
//    }
    if AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement) != .success {
        return nil
    }

    var selectedTextValue: AnyObject?
    if AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedTextValue) != .success {
        return nil
    }

    return selectedTextValue as? String
}


/**
 Another way to get selected text from any running App
 - Returns:
 */
func getSelectedText2() -> String? {
    let systemWideElement = AXUIElementCreateSystemWide()
    var focusedApp: AnyObject?
    let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedApplicationAttribute as CFString, &focusedApp)

    if error != .success {
        return nil
    }

    var focusedElement: AnyObject?
    if AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement) != .success {
        return nil
    }

    // Get the selected text range
    var selectedRange: AnyObject?
    let error2 = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRange)
    guard error2 == .success else {
        return nil
    }

    // Get the selected text using the selected range
    var selectedText: AnyObject?
    let error3 = AXUIElementCopyParameterizedAttributeValue(focusedElement as! AXUIElement, kAXStringForRangeParameterizedAttribute as CFString, selectedRange as CFTypeRef, &selectedText)
    guard error3 == .success else {
        return nil
    }

    let s = selectedText as! String
    print(s)
    return s

}


func getSelectedTextRect() {
    let systemWideElement = AXUIElementCreateSystemWide()
    var focusedElement: AnyObject?

    let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
    if (error != .success) {
        print("Couldn't get the focused element. Probably a webkit application")
    } else {
        var selectedRangeValue: AnyObject?
        let selectedRangeError = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue)
        if (selectedRangeError == .success) {
            var selectedRange: CFRange?
            AXValueGetValue(selectedRangeValue as! AXValue, AXValueType(rawValue: kAXValueCFRangeType)!, &selectedRange)
            var selectRect = CGRect()
            var selectBounds: AnyObject?
            let selectedBoundsError = AXUIElementCopyParameterizedAttributeValue(focusedElement as! AXUIElement, kAXBoundsForRangeParameterizedAttribute as CFString, selectedRangeValue!, &selectBounds)
            if (selectedBoundsError == .success) {
                AXValueGetValue(selectBounds as! AXValue, .cgRect, &selectRect)
                //do whatever you want with your selectRect
                print(selectRect)
            }
        }
    }
}


func getSelectedTextByClipboard(completion: @escaping (String?) -> Void) {
    sendGlobalCopyShortcut()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // wait 0.05s for copy.
        let clipboardText = getClipboardText() ?? ""
//        print(clipboardText)
        completion(clipboardText)
    }
}


func sendCopyCommand2() {
//    let pasteBoard = NSPasteboard.general
    let keyDownEvent = NSEvent.keyEvent(with: .keyDown, location: NSPoint(), modifierFlags: [.control], timestamp: 0, windowNumber: 0, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: 8)
    let keyUpEvent = NSEvent.keyEvent(with: .keyUp, location: NSPoint(), modifierFlags: [.control], timestamp: 0, windowNumber: 0, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: 8)

//    pasteBoard.clearContents()
//    pasteBoard.writeObjects([""]) // This will copy an empty string to the clipboard
    NSApplication.shared.sendEvent(keyDownEvent!)
    NSApplication.shared.sendEvent(keyUpEvent!)
}

func sendGlobalCopyShortcut() {

    func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
        let eventSource = CGEventSource(stateID: .hidSystemState)
        return [
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
            CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
        ]
    }

    let tapLocation = CGEventTapLocation.cghidEventTap
    let events = keyEvents(forPressAndReleaseVirtualKey: kVK_ANSI_C)

    events.forEach {
        $0.flags = .maskCommand
        $0.post(tap: tapLocation)
    }
}

func getSelectedText(completion: @escaping (String?) -> Void) {
    let text = getSelectedTextByApi() ?? ""
    if (text.isEmpty) {
        getSelectedTextByClipboard(completion: completion)
        return
    }

    completion(text)
}

/**
 An extension to get selected text from any running App

 Usage:
    AXUIElement.focusedElement?.selectedText

 */
extension AXUIElement {
    static var focusedElement: AXUIElement? {
        systemWide.element(for: kAXFocusedUIElementAttribute)
    }

    var selectedText: String? {
        rawValue(for: kAXSelectedTextAttribute) as? String
    }

    private static var systemWide = AXUIElementCreateSystemWide()

    private func element(for attribute: String) -> AXUIElement? {
        guard let rawValue = rawValue(for: attribute), CFGetTypeID(rawValue) == AXUIElementGetTypeID() else {
            return nil
        }
        return (rawValue as! AXUIElement)
    }

    private func rawValue(for attribute: String) -> AnyObject? {
        var rawValue: AnyObject?
        let error = AXUIElementCopyAttributeValue(self, attribute as CFString, &rawValue)
        return error == .success ? rawValue : nil
    }
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
func putTextToClipboard(text: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(text, forType: .string)
}

/**
 Bring a window to front by its title
 */
func bringWindowToFront(windowTitle: String) {
    let windows = NSApplication.shared.windows
    if let windowToBringToFront = windows.first(where: { $0.title == windowTitle }) {
        windowToBringToFront.orderFrontRegardless()
    }
}

/**
 Get tranlsation result from chatgpt
 - Parameters:
   - text:
   - completion:
 */
func getOpenAIResponse(text: String, completion: @escaping (String?, Error?) -> Void) {
    @AppStorage("ZTranslator.openai-api-key")
    var apiKey: String = "YOUR-OPENAI-API-KEY"

    @AppStorage("ZTranslator.to-lang")
    var toLang: String = "japanese"

    let urlString = "https://api.openai.com/v1/chat/completions"
    let url = URL(string: urlString)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

    let messages: [[String: Any]] = [
        ["role": "system", "content": "translate to " + toLang],
        ["role": "user", "content": text],
//                ["role": "assistant", "content": "Hi there, how can I help you today?"],
//                ["role": "user", "content": "I need help with a problem"],
//                ["role": "assistant", "content": "Sure, what kind of problem are you experiencing?"],
    ]

    let parameters: [String: Any] = [
        "model": "gpt-3.5-turbo",
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 1000
    ]
    request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(nil, error)
            return
        }
        guard let data = data else {
            completion(nil, nil)
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let error = json?["error"] as? [String: Any] {
                let message = error["message"] as? String ?? "Unknown error"
                let type = error["type"] as? String ?? ""
                let error = NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "\(type): \(message)"])
                completion(nil, error)
            } else {
                let choices = json?["choices"] as? [[String: Any]]
                let message = choices?.first?["message"] as? [String: Any]
                let text = message?["content"] as? String
                completion(text, nil)
            }
        } catch {
            completion(nil, error)
        }
    }
    task.resume()
}


extension Notification.Name {
    static let wakeUp = Notification.Name("WakeUp")
    static let selectedTextChanged = Notification.Name("SelectedTextChanged")
    static let closeTranslatorPopup = Notification.Name("CloseTranslatorPopup")

}


@main
class ZTranslatorApp: App {
    private var translatorPopup: FloatingPanel?
    private var popupTimer: Timer?

    var body: some Scene {
//        WindowGroup {
//            TranslatorView(text: "Translation will be here")
//        }

        #if os(macOS)
        Settings {
            ZTranslatorSettings()
        }
        #endif
    }


    required init() {
        let shortcut = MASShortcut(keyCode: kVK_ANSI_X, modifierFlags: [.control, .command])
        MASShortcutMonitor.shared().register(shortcut) {
            // Shows the translator popup and makes it topmost
            if self.popupTimer != nil {
                self.popupTimer?.invalidate()
            }
            if self.translatorPopup == nil {
                self.translatorPopup = FloatingPanel(contentRect: NSRect(x: 1000, y: 100, width: 800, height: 300), backing: .buffered, defer: false)
                self.translatorPopup?.contentView = NSHostingView(rootView: TranslatorView(text: "Translation will be here"))
            }
            self.translatorPopup?.orderFrontRegardless()

            let timeoutSeconds = 5.0
            self.popupTimer = Timer.scheduledTimer(withTimeInterval: timeoutSeconds, repeats: false) { (_) in
                if (self.translatorPopup != nil) {
                    self.translatorPopup?.orderOut(nil)
                }
            }

            getSelectedText() { (text) in

                NotificationCenter.default.post(name: .wakeUp, object: nil)

                getOpenAIResponse(text: text ?? "") { (response, error) in
                    if let error = error {
                        print("Error: \(error)")
                        NotificationCenter.default.post(name: .selectedTextChanged, object: error)
                    } else if let response = response {
                        print("Response: \(response)")
                        NotificationCenter.default.post(name: .selectedTextChanged, object: response)
                    } else {
                        print("No response")
                        NotificationCenter.default.post(name: .selectedTextChanged, object: "No response")
                    }
                }
            }
        }
    }
}
