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
import AppKit

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
//    print(s)
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
//                print(selectRect)
            }
        }
    }
}

/**
 Get selected text from any running App by clipboard
 - Parameter completion:
 */
func getSelectedTextByClipboard(completion: @escaping (String?) -> Void) {
    // store the original text to clipboard
    let originalTextInClipboard = getClipboardText() ?? ""

    sendGlobalCopyShortcut()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // wait 0.05s for copy.
        let clipboardText = getClipboardText() ?? ""
//        print(clipboardText)
        completion(clipboardText)

        // restore the original text to clipboard
        putTextToClipboard(text: originalTextInClipboard)
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

/**
 Send CTRL+C COPY shortcut to system, it can put current selected text to clipboard
 */
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

/**
 Get selected text from any running App
 - Parameter completion:
 */
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
 Get translation result from chatgpt
 - Parameters:
   - text:
   - completion:
 */
func getOpenAIResponse(text: String, completion: @escaping ((originalLang: String, text: String, error: String?)) -> Void) {
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

    var jsonText = ""
    do {
        let jsonData = try JSONEncoder().encode(text)
        jsonText = String(data: jsonData, encoding: .utf8)!
//        print(jsonText)
    } catch {
        completion(("", "", "Error: \(error.localizedDescription)"))
    }

    let messages: [[String: Any]] = [
        ["role": "system", "content": "translate the 'content' value to \(toLang), and fill the 'original-lang' value as IETF language tags, return as JSON format without explanation"],
//        ["role": "system", "content": "translate to " + toLang],
        ["role": "user", "content": "{\"original-lang\":\"\", \"content\": \"\(jsonText)\"}"],
//                ["role": "assistant", "content": "Hi there, how can I help you today?"],
//                ["role": "user", "content": "I need help with a problem"],
//                ["role": "assistant", "content": "Sure, what kind of problem are you experiencing?"],
    ]

    let parameters: [String: Any] = [
        "model": "gpt-3.5-turbo",
        "messages": messages,
        "temperature": 0.3,
        "max_tokens": 1000
    ]
    request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)


    func parseAssistantReply(jsonString: String) -> (originalLang: String, text: String, error: String?) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return ("", jsonString, "Invalid JSON data")
        }

        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                let originalLang = jsonObject["original-lang"] as? String ?? ""
                let text = jsonObject["content"] as? String ?? ""
                return (originalLang, text, nil)
            } else {
                return ("", jsonString, "JSON data is not a dictionary")
            }
        } catch let error {
            return ("", jsonString, nil)
        }
    }

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(("", "", error.localizedDescription))
            return
        }
        guard let data = data else {
            completion(("", "", "Unknown error"))
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let error = json?["error"] as? [String: Any] {
                let message = error["message"] as? String ?? "Unknown error"
                let type = error["type"] as? String ?? ""
                let error = NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "\(type): \(message)"])
                completion(("", "", error.localizedDescription))
            } else {
                let choices = json?["choices"] as? [[String: Any]]
                let message = choices?.first?["message"] as? [String: Any]
                let text = message?["content"] as? String
                completion(parseAssistantReply(jsonString: text ?? ""))
            }
        } catch {
            completion(("", "", error.localizedDescription))
        }
    }
    task.resume()
}


/**
 resize a rect from its center by x, y amount

 - Parameters:
   - rect:
   - xAmount:
   - yAmount:
 */
func resizeRectFromCenter(_ rect: inout NSRect, xAmount: CGFloat, yAmount: CGFloat) {
    rect.origin.x -= xAmount / 2
    rect.origin.y -= yAmount / 2
    rect.size.width += xAmount
    rect.size.height += yAmount
}

/**
 Get usable area of screen
 - Returns:
 */
func getScreenViewportRect() -> NSRect {
    // Get the primary screen
    let screen = NSScreen.main
    // Get the screen size and bounds
//    let screenSize = screen?.frame
    let screenBounds = screen?.visibleFrame

    // Get the height of the menu bar
    let menuBarHeight = NSApplication.shared.mainMenu?.menuBarHeight ?? 0.0
    // Get the height of the title bar
    let titleBarHeight = NSWindow.contentRect(forFrameRect: NSMakeRect(0, 0, 100, 100), styleMask: [.titled]).height
    // Get the usable height
    let usableHeight = screenBounds?.height ?? 0.0 - menuBarHeight - titleBarHeight

    // Check if there is a bottom docker
    if let bottomDocker = NSApplication.shared.windows.last(where: { $0.isVisible && $0.isFloatingPanel }) {
        // Get the height of the bottom docker
        let dockerHeight = bottomDocker.frame.height
        // Subtract the docker height from the usable height
        return NSMakeRect(screenBounds?.origin.x ?? 0.0, screenBounds?.origin.y ?? 0.0, screenBounds?.width ?? 0.0, usableHeight - dockerHeight)
    } else {
        // If there is no bottom docker, use the usable height as is
        return NSMakeRect(screenBounds?.origin.x ?? 0.0, screenBounds?.origin.y ?? 0.0, screenBounds?.width ?? 0.0, usableHeight)
    }
}

/**
 Calculate the new position of a popup floating panel so that it can be within the viewport of screen
 - Parameters:
   - newPosition:
   - popupRect:
   - viewportRect:
 - Returns:
 */
func calculatePopupPosition(newPosition: NSPoint, popupRect: NSRect, viewportRect: NSRect) -> NSPoint {
    var adjustedPosition = newPosition

    // Check if the popup is going off the right edge of the viewport
    let rightEdge = newPosition.x + popupRect.width
    if rightEdge > viewportRect.maxX {
        adjustedPosition.x = viewportRect.maxX - popupRect.width
    }

    // Check if the popup is going off the left edge of the viewport
    if newPosition.x < viewportRect.minX {
        adjustedPosition.x = viewportRect.minX
    }

    // Check if the popup is going off the top edge of the viewport
    let topEdge = newPosition.y + popupRect.height
    if topEdge > viewportRect.maxY {
        adjustedPosition.y = viewportRect.maxY - popupRect.height
    }

    // Check if the popup is going off the bottom edge of the viewport
    if newPosition.y < viewportRect.minY {
        adjustedPosition.y = viewportRect.minY
    }

    return adjustedPosition
}

/**
 Request accessibility permission and navigate user to setup it
 */
func requestAccessibilityPermission() {
    if !AXIsProcessTrusted() {
        let alert = NSAlert()
        alert.messageText = "Please enable accessibility permissions"
        alert.informativeText = "This app requires accessibility permissions to function properly. Please go to System Preferences > Security & Privacy > Privacy > Accessibility and add this app to the list of allowed apps."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Open System Preferences")
        let result = alert.runModal()
        if result == .alertSecondButtonReturn {
            let prefURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(prefURL)
        }
    }
}


extension Notification.Name {
    static let wakeUp = Notification.Name("WakeUp")
    static let selectedTextChanged = Notification.Name("SelectedTextChanged")
    static let closeTranslatorPopup = Notification.Name("CloseTranslatorPopup")

}


@main
class ZTranslatorApp: App {
    private var translatorPopup: FloatingPanel?
    private var translatorPopupTimer: Timer?

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

    /**
     report to caller if mouse point is in a specific area

     - Parameters:
       - callback:
     - Returns:
     */
    func monitorMousePositionInTranslatorView(callback: @escaping (Bool) -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            let point = NSEvent.mouseLocation

            if let popup = self.translatorPopup {
                var area = popup.frame
                resizeRectFromCenter(&area, xAmount: 40, yAmount: 80)

                let mouseIsOut = !area.contains(point)
                callback(mouseIsOut)
                if mouseIsOut {
                    timer.invalidate()
//            print("Point is out of area, stopping timer")
                } else {
//            print("Point is within area")
                }

            }
        }
        return timer
    }

    func showTranslatorPopup() {
        if self.translatorPopupTimer != nil && self.translatorPopupTimer?.isValid == true {
            self.translatorPopupTimer?.invalidate()
        }

        // Shows the translator popup and makes it topmost
        if self.translatorPopup == nil {
            self.translatorPopup = FloatingPanel(contentRect: NSRect(x: 1000, y: 100, width: 800, height: 500), backing: .buffered, defer: false)
            self.translatorPopup?.contentView = NSHostingView(rootView: TranslatorView(text: "..."))
        }

        if let popup = self.translatorPopup {
            let mouseLocation = NSEvent.mouseLocation

            // move popup to current mouse position
            var popupPosition = NSPoint(
                x: mouseLocation.x + 10,
                y: mouseLocation.y - 20 - popup.frame.size.height
            )
            popupPosition = calculatePopupPosition(newPosition: popupPosition, popupRect: popup.frame, viewportRect: getScreenViewportRect())

            popup.setFrameOrigin(popupPosition)
            popup.orderFront(nil)
//            print("1 visible:", popup.isVisible)

            var area = popup.frame
            resizeRectFromCenter(&area, xAmount: 40, yAmount: 80)
            self.translatorPopupTimer = self.monitorMousePositionInTranslatorView() { (mouseIsOut) in
                if (mouseIsOut) {
//                    print("hide")
                    popup.orderOut(nil)
//                    print("2 visible:", popup.isVisible)
                }
            }
        }
    }

    required init() {
        requestAccessibilityPermission()

        let shortcut = MASShortcut(keyCode: kVK_ANSI_X, modifierFlags: [.control, .command])
        MASShortcutMonitor.shared().register(shortcut) {

            getSelectedText() { (selectedText) in
                let text = selectedText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                self.showTranslatorPopup()

                NotificationCenter.default.post(name: .wakeUp, object: text)

                getOpenAIResponse(text: text) { (response: (originalLang: String, text: String, error: String?)) in
                    NotificationCenter.default.post(name: .selectedTextChanged, object: response)

//                    if let error = error {
//                        print("Error: \(error)")
//                        NotificationCenter.default.post(name: .selectedTextChanged, object: error)
//                    } else if let response = response {
////                        print("Response: \(response)")
//                        NotificationCenter.default.post(name: .selectedTextChanged, object: response)
//                    } else {
////                        print("No response")
//                        NotificationCenter.default.post(name: .selectedTextChanged, object: "No response")
//                    }
                }
            }
        }
    }
}
