//
//  ActionWindowController.swift
//  Roar
//
//  Created by Tyler Hall on 1/3/22.
//

import Cocoa

class ActionWindowController: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var codeLabel: NSTextField!
    @IBOutlet weak var urlLabel: NSTextField!
    @IBOutlet weak var appLabel: NSTextField!
    @IBOutlet weak var copyLabel: NSTextField!

    var note: Note? {
        didSet {
            if let note = note {
                codeLabel.textColor = (note.code != nil) ? .labelColor : .tertiaryLabelColor
                urlLabel.textColor = (note.urls.count > 0) ? .labelColor : .tertiaryLabelColor
                appLabel.textColor = .labelColor
                copyLabel.textColor = .labelColor
            } else {
                codeLabel.textColor = .tertiaryLabelColor
                urlLabel.textColor = .tertiaryLabelColor
                appLabel.textColor = .tertiaryLabelColor
                copyLabel.textColor = .tertiaryLabelColor
            }
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.hide(nil)
    }
}
