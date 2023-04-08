import SwiftUI


class FloatingPanel: NSPanel {
    init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {

        // Not sure if .titled does affect anything here. Kept it because I think it might help with accessibility but I did not test that.
//        super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel, .resizable, .closable, .fullSizeContentView], backing: backing, defer: flag)
        super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel, .closable, .fullSizeContentView], backing: backing, defer: flag)

        // Set this if you want the panel to remember its size/position
        //        self.setFrameAutosaveName("a unique name")

        // Allow the pannel to be on top of almost all other windows
        self.isFloatingPanel = true
        self.level = .floating
        self.isMovable = true
//        self.backgroundColor = .clear
        // Allow the pannel to appear in a fullscreen space
        self.collectionBehavior.insert(.fullScreenAuxiliary)
        self.collectionBehavior.insert(.canJoinAllSpaces)

//		NSWindowCollectionBehaviorCanJoinAllSpaces and NSWindowCollectionBehaviorFullScreenAuxiliary.
        // While we may set a title for the window, don't show it
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = false

        // Since there is no titlebar make the window moveable by click-dragging on the background
        self.isMovableByWindowBackground = true

        // Keep the panel around after closing since I expect the user to open/close it often
        self.isReleasedWhenClosed = true // was false

        // Activate this if you want the window to hide once it is no longer focused
        //        self.hidesOnDeactivate = true

        // Hide the traffic icons (standard close, minimize, maximize buttons)
        self.standardWindowButton(.closeButton)?.isHidden = false
        self.standardWindowButton(.miniaturizeButton)?.isHidden = false
        self.standardWindowButton(.zoomButton)?.isHidden = false


    }

    // `canBecomeKey` and `canBecomeMain` are required so that text inputs inside the panel can receive focus
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}

//Usage
func makePanel(contentView: some View) {
    // Create the window and set the content view.
    let newEntryPanel = FloatingPanel(contentRect: NSRect(x: 60, y: 100, width: 512, height: 80), backing: .buffered, defer: false)

    newEntryPanel.contentView = NSHostingView(rootView: contentView)

    // Shows the panel and makes it active
    newEntryPanel.orderFront(nil)
    newEntryPanel.makeKey()
}
