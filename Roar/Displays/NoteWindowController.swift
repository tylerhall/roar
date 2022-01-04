//
//  NoteWindowController.swift
//  Roar
//
//  Created by Tyler Hall on 12/21/21.
//

import AppKit

protocol NoteWindowControllerDelegate {
    func didDisplayWindow()
    func didHideWindow()
}

class NoteWindowController: NSWindowController {

    var noteWindowDelegte: NoteWindowControllerDelegate?

    func display(note: Note) {
        
    }
    
    func hide() {
        
    }
}
