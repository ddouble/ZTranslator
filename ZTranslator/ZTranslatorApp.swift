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
import Foundation

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

/**
 Get tranlsation result from chatgpt
 - Parameters:
   - messages:
   - completion:
 */
func getOpenAIResponse(messages: [[String: Any]], completion: @escaping (String?, Error?) -> Void) {
    @AppStorage("ZTranslator.openai-api-key")
    var apiKey: String = "YOUR-OPENAI-API-KEY"

    let urlString = "https://api.openai.com/v1/chat/completions"
    let url = URL(string: urlString)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

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
    static let selectedTextChanged = Notification.Name("SelectedTextChanged")
}


@main
class ZTranslatorApp: App {

    var body: some Scene {
        WindowGroup {
            TranslatorView(text: "Translation will be here")
        }

        #if os(macOS)
        Settings {
            ZTranslatorSettings()
        }
        #endif
    }


    required init() {
        let shortcut = MASShortcut(keyCode: kVK_ANSI_X, modifierFlags: [.control, .command])
        MASShortcutMonitor.shared().register(shortcut) {
            let text = getSelectedText()
            let messages: [[String: Any]] = [
                ["role": "user", "content": "translate to japanese：" + (text ?? "")],
//                ["role": "assistant", "content": "Hi there, how can I help you today?"],
//                ["role": "user", "content": "I need help with a problem"],
//                ["role": "assistant", "content": "Sure, what kind of problem are you experiencing?"],
            ]
            getOpenAIResponse(messages: messages) { (response, error) in
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
//            NotificationCenter.default.post(name: .selectedTextChanged, object: text)
        }
    }
}
