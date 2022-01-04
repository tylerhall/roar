//
//  BezelWindowController.swift
//  Roar
//
//  Created by Tyler Hall on 12/21/21.
//

import AppKit

class BezelWindowController: NoteWindowController {

    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var appIconView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var bodyLabel: NSTextField!

    override func display(note: Note) {
        window?.backgroundColor = .clear
        window?.ignoresMouseEvents = true
        window?.level = NSWindow.Level.init(Int(CGWindowLevelForKey(CGWindowLevelKey.mainMenuWindow)))

        titleLabel.stringValue = note.title ?? ""
        subtitleLabel.stringValue = note.subtitle ?? ""
        bodyLabel.stringValue = note.body ?? ""
        
        if let appPath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: note.appID)?.path {
            let icon = NSWorkspace.shared.icon(forFile: appPath)
            appIconView.image = icon
        }

        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.45).cgColor
        backgroundView.layer?.cornerRadius = 16

        showWindow(nil)
        window?.center()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.noteWindowDelegte?.didDisplayWindow()
        })
    }

    override func hide() {
        window?.close()
        noteWindowDelegte?.didHideWindow()
    }
}
