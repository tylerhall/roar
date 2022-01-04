//
//  iTunesWidgetWindowController.swift
//  Roar
//
//  Created by Tyler Hall on 1/3/22.
//

import Cocoa

class iTunesWidgetWindowController: NoteWindowController {

    @IBOutlet weak var maskView: NSView!

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var bodyLabel: NSTextField!
    
    @IBOutlet weak var titleLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var bodyLabelConstraint: NSLayoutConstraint!

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

        let shape = CAShapeLayer()
        shape.path = CGPath(ellipseIn: maskView.bounds, transform: nil)
        maskView.wantsLayer = true
        maskView.layer?.mask = shape
        maskView.layer?.masksToBounds = true

        animateLabels()
    }

    func animateLabels() {
        var maxWidth = max(titleLabel.bounds.width, subtitleLabel.bounds.width)
        maxWidth = max(maxWidth, bodyLabel.bounds.width)

        titleLabelConstraint.constant = -maxWidth
        subtitleLabelConstraint.constant = -maxWidth
        bodyLabelConstraint.constant = -maxWidth

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
