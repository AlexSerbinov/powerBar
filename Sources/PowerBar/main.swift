import Cocoa
import SwiftUI

// Main application entry point
class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon and make this a menu bar only app
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize menu bar controller
        menuBarController = MenuBarController()
        menuBarController?.setup()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        menuBarController?.cleanup()
    }
}

// Application entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run() 