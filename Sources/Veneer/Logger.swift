//
//  Logger.swift
//  Veneer
//
//  Created by Chris Conover on 2/12/19.
//  Copyright © 2019 Chris Conover. All rights reserved.
//

import Foundation


public protocol LoggerType {

    static func error(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

    static func warn(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

    static func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

    static func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

    static func log(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

}

extension LoggerType {

    public static func error(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return error(format, args, file: file, function: function, line: line)
    }

    public static func warn(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return warn(format, args, file: file, function: function, line: line)
    }


    public static func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return trace(format, args, file: file, function: function, line: line)
    }

    public static func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return debug(format, args, file: file, function: function, line: line)
    }

    public static func log(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return log(format, args, file: file, function: function, line: line)
    }
}


open class Logger: NSObject, LoggerType {

    public static func error(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int) {

        if logLevel.contains(.error) {
            log(format, args, file: file, function: function, line: line)
        }
    }

    public static func warn(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int) {

        if logLevel.contains(.warn) {
            log(format, args, file: file, function: function, line: line)
        }
    }

    public static func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int = #line) {

        if logLevel.contains(.trace) {
            log(format, args, file: file, function: function, line: line)
        }
    }

    public static func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int = #line) {
        if logLevel.contains(.debug) {
            log(format, args, file: file, function: function, line: line)
        }
    }

    public static func log(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int) {

        let fileName = URL(string: file)?.lastPathComponent ?? file
        let extendedFormat = "\(fileName).\(line): \(function) " + format
        logger.doLog(extendedFormat, args)
    }



    static var logger: LoggerSink = ConsoleLogger()
    public static var logLevel: LogLevel = .important
}

public struct LogLevel: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let debug    = LogLevel(rawValue: 1 << 0)
    public static let trace  = LogLevel(rawValue: 1 << 1)
    public static let warn   = LogLevel(rawValue: 1 << 2)
    public static let error   = LogLevel(rawValue: 1 << 3)

    public static let verbose: LogLevel = [.debug, .trace]
    public static let all: LogLevel = [.debug, .trace, .warn, .error]
    public static let important: LogLevel = [.error]
}

public protocol LoggerSink {
    func doLog(_ format: String, _ args: [CVarArg])
}


open class NSLogger: LoggerSink {

    public func doLog(_ format: String, _ args: [CVarArg]) {
        NSLog(format, args)
    }
}


open class NSLogvLogger: LoggerSink {
    public func doLog(_ format: String, _ args: CVaListPointer) {
        NSLogv(format, args)
    }

    public func doLog(_ format: String, _ args: [CVarArg]) {
        withVaList(args) { doLog(format, $0) }
    }
}

open class ConsoleLogger: LoggerSink {

    public func doLog(_ format: String, _ args: [CVarArg]) {
        print(String(format: format, args))
    }
}

