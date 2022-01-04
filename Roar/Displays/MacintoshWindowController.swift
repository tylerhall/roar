//
//  MacintoshWindowController.swift
//  Roar
//
//  Created by Tyler Hall on 1/3/22.
//

import Cocoa

class MacintoshWindowController: NoteWindowController {
    
    @IBOutlet weak var appLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var bodyLabel: NSTextField!

    override func display(note: Note) {
        guard let screen = NSScreen.main else { return }

        window?.backgroundColor = .clear
        window?.ignoresMouseEvents = true
        window?.level = NSWindow.Level.init(Int(CGWindowLevelForKey(CGWindowLevelKey.mainMenuWindow)))

        let font0 = NSFont(name: "ChicagoIllinois", size: 9)
        appLabel.font = font0
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: note.appID) {
            let appName = url.deletingPathExtension().lastPathComponent
            appLabel.stringValue = appName
        } else {
            appLabel.stringValue = "Notification"
        }

        let font1 = NSFont(name: "ChicagoIllinois", size: 13)
        titleLabel.font = font1

        let font2 = NSFont(name: "ChicagoIllinois", size: 11)
        subtitleLabel.font = font2
        bodyLabel.font = font2

        titleLabel.stringValue = note.title ?? ""

        if let subtitle = note.subtitle {
            subtitleLabel.stringValue = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }

        if let body = note.body {
            bodyLabel.stringValue = body
            bodyLabel.isHidden = false
        } else {
            bodyLabel.isHidden = true
        }

        showWindow(nil)
        let width = window?.frame.size.width ?? 0
        let height = window?.frame.size.height ?? 0
        window?.setFrameOrigin(NSPoint(x: screen.frame.size.width, y: screen.frame.size.height - height - 35))

        let destOrigin = NSPoint(x: screen.frame.size.width - width - 20, y: screen.frame.size.height - height - 35)
        window?.setFrame(NSRect(origin: destOrigin, size: CGSize(width: width, height: height)), display: true, animate: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.noteWindowDelegte?.didDisplayWindow()
        })
    }

    override func hide() {
        guard let screen = NSScreen.main else { return }

        let width = window?.frame.size.width ?? 0
        let height = window?.frame.size.height ?? 0
        let destOrigin = NSPoint(x: screen.frame.size.width, y: screen.frame.size.height - height - 35)
        window?.setFrame(NSRect(origin: destOrigin, size: CGSize(width: width, height: height)), display: true, animate: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.window?.close()
            self.noteWindowDelegte?.didHideWindow()
        })
    }
}
