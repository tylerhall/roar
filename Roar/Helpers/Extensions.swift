//
//  Extensions.swift
//  Roar
//
//  Created by Tyler Hall on 12/21/21.
//

import Foundation

extension Data {
    func writeToTempFile() -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try self.write(to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }
}
