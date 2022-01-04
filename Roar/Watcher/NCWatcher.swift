//
//  NCWatcher.swift
//  Roar
//
//  Created by Tyler Hall on 12/20/21.
//

import Foundation
import FMDB

struct Note {
    var title: String?
    var subtitle: String?
    var body: String?
    var date: Date
    var appID: String

    enum DisplayStyle: Int {
        case MusicVideo = 0
        case Bezel = 1
        case Winamp = 2
        case iTunesWidget = 3
        case Macintosh = 4
    }

    var defaultDisplayStyle: DisplayStyle {
        return DisplayStyle(rawValue: UserDefaults.standard.integer(forKey: "noteDisplayStyle")) ?? .MusicVideo
    }
    
    var code: String? {
        let strings = [title, subtitle, body].compactMap { $0 }
        let str = strings.joined(separator: "\n")

        guard let regex = try? NSRegularExpression(pattern: "[0-9]{4,8}", options: [.dotMatchesLineSeparators]) else { return nil }
        let nsString = str as NSString
        let matches = regex.matches(in: str, options: [.withoutAnchoringBounds], range: NSMakeRange(0, nsString.length))
        if let first = matches.first {
            let code = nsString.substring(with: first.range)
            return code
        }

        return nil
    }
    
    var urls: [URL] {
        var urls = [URL]()
        
        let strings = [title, subtitle, body].compactMap { $0 }
        let str = strings.joined(separator: "\n")

        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count))
        for match in matches {
            guard let range = Range(match.range, in: str) else { continue }
            let urlStr = String(str[range])
            if let url = URL(string: urlStr) {
                urls.append(url)
            }
        }
        return urls
    }
}

class NCWatcher {

    static let shared = NCWatcher()

    var databaseURL: URL?
    var db: FMDatabase!

    let opQueue = OperationQueue()

    var cutoffDate = Date()
    var timer: Timer?
    
    var lastNote: Note?

    func setup(_ completion: ((Bool) -> ())? = nil) {
        opQueue.maxConcurrentOperationCount = 1
        
        Pipette.execute(URL(fileURLWithPath: "/usr/bin/getconf"), args: ["DARWIN_USER_DIR"], text: nil) { [weak self] stdout, _ in
            guard let self = self else { completion?(false); return }
            if let userPath = stdout?.trimmingCharacters(in: .whitespacesAndNewlines) {
                var url = URL(fileURLWithPath: userPath)
                url.appendPathComponent("com.apple.notificationcenter")
                url.appendPathComponent("db2")
                url.appendPathComponent("db")
                if FileManager.default.isReadableFile(atPath: url.path) {
                    self.databaseURL = url
                    let success = self.openDatabase()
                    completion?(success)
                } else {
                    completion?(false)
                }
            } else {
                completion?(false)
            }
        }
    }

    func startWatching() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.fetchNewNotifications()
        })
    }

    func openDatabase() -> Bool {
        guard let url = databaseURL else { return false }
        guard FileManager.default.isReadableFile(atPath: url.path) else { return false }

        db = FMDatabase(url: url)
        return db.open()
    }

    func fetchNewNotifications() {
        var notes = [Note]()

        do {
            let results = try db.executeQuery("SELECT app.identifier as app_name, record.delivered_date as delivered_date, record.data as notification_content FROM app INNER JOIN record ON app.app_id=record.app_id;", values: nil)
            while results.next() {
                guard let appName = results.string(forColumn: "app_name") else { continue }
                let deliveredTimestamp = results.double(forColumn: "delivered_date")
                guard deliveredTimestamp > 0 else { continue }
                let deliveredDate = Date(timeIntervalSinceReferenceDate: deliveredTimestamp)
                guard let data = results.data(forColumn: "notification_content") else { continue }
                if let note = parseNote(appName: appName, date: deliveredDate, data: data) {
                    if note.date > cutoffDate {
                        notes.append(note)
                    }
                }
            }
        } catch {
            
        }

        for note in notes {
            if note.date > cutoffDate {
                cutoffDate = note.date
            }

            let op = NoteDisplayOperation(note: note)
            opQueue.addOperation(op)
        }
    }

    func parseNote(appName: String, date: Date, data: Data) -> Note? {
        var tempURL: URL?
        defer {
            if let url = tempURL {
                try? FileManager.default.removeItem(at: url)
            }
        }

        tempURL = data.writeToTempFile()

        guard let tempURL = tempURL else { return nil }
        guard let dict = try? NSDictionary(contentsOf: tempURL, error: ()) else { return nil }

        guard let bundleID = dict.value(forKey: "app") as? String else { return nil }
        guard let req = dict.value(forKey: "req") as? NSDictionary else { return nil }
        let body = req.value(forKey: "body") as? String
        let title = req.value(forKey: "titl") as? String
        let subtitle = req.value(forKey: "subt") as? String

        let note = Note(title: title, subtitle: subtitle, body: body, date: date, appID: bundleID)
        return note
    }
}
