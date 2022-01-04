//
//  AppDelegate.swift
//  Roar
//
//  Created by Tyler Hall on 12/20/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var prefsWindowController: PrefsWindowController = { PrefsWindowController(windowNibName: String(describing: PrefsWindowController.self)) }()
    lazy var actionWindowController: ActionWindowController = { ActionWindowController(windowNibName: String(describing: ActionWindowController.self)) }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        bindActionShortcut()
        NCWatcher.shared.setup { success in
            NCWatcher.shared.startWatching()
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == PrefsWindowController.kActionShortcutPref {
            self.bindActionShortcut()
        }
    }

    @IBAction func showPreferencesWindow(_ sender: AnyObject?) {
        prefsWindowController.showWindow(nil)
    }
    
    func bindActionShortcut() {
        MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: PrefsWindowController.kActionShortcutPref)
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: PrefsWindowController.kActionShortcutPref, toAction: {
            NSApp.activate(ignoringOtherApps: true)
            self.actionWindowController.window?.makeKeyAndOrderFront(nil)
            self.actionWindowController.note = NCWatcher.shared.lastNote
        })
    }

    @IBAction func activateNotificationApp(_ sender: AnyObject?) {
        NSApp.hide(nil)
        if let note = NCWatcher.shared.lastNote {
            if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: note.appID) {
                let config = NSWorkspace.OpenConfiguration()
                config.activates = true
                NSWorkspace.shared.openApplication(at: appURL, configuration: config, completionHandler: nil)
            }
        }
    }

    @IBAction func openURLs(_ sender: AnyObject?) {
        NSApp.hide(nil)
        if let note = NCWatcher.shared.lastNote {
            for url in note.urls {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @IBAction func copy2FA(_ sender: AnyObject?) {
        NSApp.hide(nil)

        if let note = NCWatcher.shared.lastNote {
            if let code = note.code {
                NSPasteboard.general.declareTypes([.string], owner: nil)
                NSPasteboard.general.setString(code, forType: .string)
            }
        }
    }

    @IBAction func copyMessage(_ sender: AnyObject?) {
        NSApp.hide(nil)
        if let note = NCWatcher.shared.lastNote {
            let strings = [note.title, note.subtitle, note.body].compactMap { $0 }
            let str = strings.joined(separator: "\n")

            NSPasteboard.general.declareTypes([.string], owner: nil)
            NSPasteboard.general.setString(str, forType: .string)
        }
    }
}
