//
//  BezelWindowController.swift
//  Roar
//
//  Created by Tyler Hall on 12/21/21.
//

import AppKit
import AVKit

class WinampWindowController: NoteWindowController {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var bodyLabel: NSTextField!
    @IBOutlet weak var playerView: AVPlayerView!

    @IBOutlet weak var titleLabelConstraint: NSLayoutConstraint!

    override func display(note: Note) {
        guard let screen = NSScreen.main else { return }

        window?.backgroundColor = .clear
        window?.ignoresMouseEvents = true
        window?.level = NSWindow.Level.init(Int(CGWindowLevelForKey(CGWindowLevelKey.mainMenuWindow)))

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

        let playerItem = AVPlayerItem(url: Bundle.main.url(forResource: "winamp", withExtension: "mp4")!)
        let player = AVPlayer(playerItem: playerItem)
        playerView.player = player
        player.play()

        animateLabels()
    }

    func animateLabels() {
        titleLabelConstraint.constant = -titleLabel.bounds.width

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 7
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: .linear)
            self.window?.contentView?.updateConstraints()
            self.window?.contentView?.layoutSubtreeIfNeeded()
        }
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
