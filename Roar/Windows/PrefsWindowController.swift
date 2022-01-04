//
//  PrefsWindowController.swift
//  Roar
//
//  Created by Tyler Hall on 1/3/22.
//

import Cocoa

class PrefsWindowController: NSWindowController {
    
    static let kActionShortcutPref = "kActionShortcutPref"
    
    @IBOutlet weak var actionShortcutView: MASShortcutView!

    override func windowDidLoad() {
        super.windowDidLoad()
        actionShortcutView.associatedUserDefaultsKey = PrefsWindowController.kActionShortcutPref
    }
    
    @IBAction func showNotificationPreview(_ sender: AnyObject?) {
        let note = Note(title: "Test Notification", subtitle: "This is the subtitle", body: "The quick lazy apple jumped over the brown zune.", date: Date(), appID: "com.apple.Music")
        let op = NoteDisplayOperation(note: note)
        NCWatcher.shared.opQueue.addOperation(op)
    }
}
