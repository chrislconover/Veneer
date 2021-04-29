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

    static func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

    static func info(
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

    static func log(
        _ level: LogLevel,
        _ format: String,
        _ args: CVarArg...,
        logLevel level: LogLevel,
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

    public static func info(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return info(format, args, file: file, function: function, line: line)
    }

    public static func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        #if DEBUG
        return debug(format, args, file: file, function: function, line: line)
        #endif
    }

    public static func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return trace(format, args, file: file, function: function, line: line)
    }

    public static func log(
        _ level: LogLevel,
        _ format: String,
        _ args: CVarArg...,
        logLevel level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return log(level, format, args, file: file, function: function, line: line)
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
            log(.error, format, args, file: file, function: function, line: line)
        }
    }

    public static func warn(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int) {

        if logLevel.contains(.warn) {
            log(.warn, format, args, file: file, function: function, line: line)
        }
    }

    public static func info(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int = #line) {
        if logLevel.contains(.info) {
            log(.info, format, args, file: file, function: function, line: line)
        }
    }

    public static func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int = #line) {
        if logLevel.contains(.debug) {
            log(.debug, format, args, file: file, function: function, line: line)
        }
    }

    public static func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int = #line) {

        if logLevel.contains(.trace) {
            log(.trace, format, args, file: file, function: function, line: line)
        }
    }

    public static func log(
        _ level: LogLevel,
        _ format: String,
        _ args: CVarArg...,
        logLevel level: LogLevel,
        file: String,
        function: String,
        line: Int) {

        if self.logLevel.contains(level) {
            let fileName = URL(string: file)?.lastPathComponent ?? file
            let preface = formatTimestampFileLineFunction(Date().timeStamp, fileName, line, function)
            let extendedFormat = preface + format
            doLog(extendedFormat, args)
        }
    }


    static func doLog(_ format: String, _ args: [CVarArg]) {
        sinks.forEach { $0.doLog(format, args) }
    }
    
    public static func add(sink: LoggerSink) { sinks.append(sink) }
    public static var logLevel: LogLevel = .important
    public static var formatTimestampFileLineFunction: (String, String, Int, String) -> String = {
        timestamp, file, line, function in "\(Date().timeStamp) \(file).\(line): \(function) "
    }

    static var sinks: [LoggerSink] = [ConsoleLogger()]
}

public struct LogLevel: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let debug = LogLevel(rawValue: 1)
    public static let trace  = LogLevel(rawValue: debug.rawValue << 1)
    public static let info = LogLevel(rawValue: trace.rawValue << 1)
    public static let warn  = LogLevel(rawValue: info.rawValue << 1)
    public static let error = LogLevel(rawValue: warn.rawValue << 1)

    public static let all: LogLevel = [.trace, .info, .debug, .warn, .error]
    public static let important: LogLevel = [.warn, .error]
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

open class AnyLogger: LoggerSink {

    public init(_ sink: @escaping (String, [CVarArg]) -> Void) { self.sink = sink }
    public func doLog(_ format: String, _ args: [CVarArg]) { sink(format, args) }
    private var sink: (String, [CVarArg]) -> Void
}

extension Date {
    var timeStamp: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "YY-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}
