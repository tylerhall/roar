//
//  MusicVideoWindowController.swift
//  Roar
//
//  Created by Tyler Hall on 12/20/21.
//

import AppKit

class MusicVideoWindowController: NoteWindowController {

    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var appIconView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var bodyLabel: NSTextField!
    @IBOutlet weak var windowWidthConstraint: NSLayoutConstraint!

    override func display(note: Note) {
        guard let screen = NSScreen.main else { return }

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

        windowWidthConstraint.constant = screen.frame.size.width
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.45).cgColor

        showWindow(nil)
        let height = window?.frame.size.height ?? 0
        window?.setFrameOrigin(CGPoint(x: 0, y: -height))

        let rect = NSRect(origin: .zero, size: CGSize(width: windowWidthConstraint.constant, height: height))
        window?.setFrame(rect, display: true, animate: true)

        let duration = window?.animationResizeTime(rect) ?? 1
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
            self.noteWindowDelegte?.didDisplayWindow()
        })
    }

    override func hide() {
        let height = window?.frame.size.height ?? 0
        let rect = NSRect(origin: .zero, size: CGSize(width: windowWidthConstraint.constant, height: -height))
        window?.setFrame(rect, display: true, animate: true)

        let duration = window?.animationResizeTime(rect) ?? 1
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
            self.noteWindowDelegte?.didHideWindow()
        })
    }
}

class MusicVideoWindow: NSWindow {

}
