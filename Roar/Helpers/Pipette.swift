//
//  Pipette.swift
//  TextBuddy
//
//  Created by Tyler Hall on 1/23/21.
//

import Foundation

class Pipette {

    static let shared = Pipette()

    class func execute(_ cmd: URL, args: [String]?, text: String?, completion: @escaping (String?, Int?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let textData = text?.data(using: .utf8) ?? Data()

            let sh = Process()
            sh.launchPath = cmd.path
            sh.arguments = args ?? []

            let outPipe = Pipe()
            sh.standardOutput = outPipe
            let outHandle = outPipe.fileHandleForReading
            
            let inPipe = Pipe()
            sh.standardInput = inPipe
            let inHandle = inPipe.fileHandleForWriting
            inHandle.write(textData)
            try? inHandle.close()

            sh.terminationHandler = { process in
                var data = Data()
                var chunk = outHandle.readDataToEndOfFile()
                data.append(chunk)
                while !chunk.isEmpty {
                    chunk = outHandle.readDataToEndOfFile()
                    data.append(chunk)
                }

                DispatchQueue.main.async {
                    completion(String(data: data, encoding: .utf8), Int(sh.terminationStatus))
                }
            }

            sh.launch()
        }
    }

    class func executeRawString(_ cmd: String, text: String?, completion: @escaping (String?, Int?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let textData = text?.data(using: .utf8) ?? Data()

            let sh = Process()
            sh.launchPath = "/bin/bash"
            sh.arguments = ["-c", cmd]

            let outPipe = Pipe()
            sh.standardOutput = outPipe
            let outHandle = outPipe.fileHandleForReading
            
            let inPipe = Pipe()
            sh.standardInput = inPipe
            let inHandle = inPipe.fileHandleForWriting
            inHandle.write(textData)
            try? inHandle.close()

            sh.terminationHandler = { process in
                var data = Data()
                var chunk = outHandle.readDataToEndOfFile()
                data.append(chunk)
                while !chunk.isEmpty {
                    chunk = outHandle.readDataToEndOfFile()
                    data.append(chunk)
                }

                DispatchQueue.main.async {
                    completion(String(data: data, encoding: .utf8), Int(sh.terminationStatus))
                }
            }

            sh.launch()
        }
    }
}
