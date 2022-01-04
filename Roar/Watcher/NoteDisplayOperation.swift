//
//  NoteDisplayOperation.swift
//  Roar
//
//  Created by Tyler Hall on 12/21/21.
//

import Foundation

class NoteDisplayOperation: AsyncOperation, NoteWindowControllerDelegate {

    var note: Note
    var wc: NoteWindowController?

    init(note: Note) {
        self.note = note
    }

    override func main() {
        NCWatcher.shared.lastNote = note
        
        DispatchQueue.main.async {
            switch self.note.defaultDisplayStyle {
            case .MusicVideo:
                self.wc = MusicVideoWindowController(windowNibName: String(describing: MusicVideoWindowController.self))
            case .Bezel:
                self.wc = BezelWindowController(windowNibName: String(describing: BezelWindowController.self))
            case .Winamp:
                self.wc = WinampWindowController(windowNibName: String(describing: WinampWindowController.self))
            case .iTunesWidget:
                self.wc = iTunesWidgetWindowController(windowNibName: String(describing: iTunesWidgetWindowController.self))
            case .Macintosh:
                self.wc = MacintoshWindowController(windowNibName: String(describing: MacintoshWindowController.self))
            }

            self.wc?.noteWindowDelegte = self
            self.wc?.display(note: self.note)
        }
    }

    func didDisplayWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.wc?.hide()
        })
    }
    
    func didHideWindow() {
        finish()
    }
}
