//
//  Logger.swift
//  Veneer
//
//  Created by Chris Conover on 2/12/19.
//  Copyright © 2019 Chris Conover. All rights reserved.
//

import Foundation
import os.log


public protocol LoggerType {

    static func error(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

    static func warning(
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

    public static func warning(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return warning(format, args, file: file, function: function, line: line)
    }

    @available(*, deprecated, message: "use warning instead")
    public static func warn(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return warning(format, args, file: file, function: function, line: line)
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

    public static func warning(
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
        file: String,
        function: String,
        line: Int) {

        if self.logLevel.contains(level) {
            doLog(level, format: format,
                  args: args,
                  file: file,
                  function: function,
                  line: line)
        }
    }

    static func doLog(_ level: LogLevel,
                      format: String,
                      args: [CVarArg],
                      file: String,
                      function: String,
                      line: Int) {
        sinks.forEach {
            $0.doLog(level, format: format, args: args,
                     file: file, function: function, line: line)
        }
    }
    
    public static func add(sink: LoggerSink) { sinks.append(sink) }
    public static var logLevel: LogLevel = .bad
    public static var sinks: [LoggerSink] = [ConsoleLogger()]
}

public struct LogLevel: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let debug = LogLevel(rawValue: 1)
    public static let trace  = LogLevel(rawValue: debug.rawValue << 1)
    public static let info = LogLevel(rawValue: trace.rawValue << 1)
    public static let warn  = LogLevel(rawValue: info.rawValue << 1)
    public static let error = LogLevel(rawValue: warn.rawValue << 1)

    public static let all: LogLevel = [.debug, .trace, .info, .warn, .error]
    public static let verbose: LogLevel = [.trace, .info, .warn, .error]
    public static let informative: LogLevel = [.info, .warn, .error]
    public static let bad: LogLevel = [.warn, .error]
}

public protocol LoggerSink {
    func doLog(_ level: LogLevel, message: String)
    func doLog(_ level: LogLevel,
               format: String, args: [CVarArg],
               file: String,
               function: String,
               line: Int)
}

extension LoggerSink {
    public func doLog(_ level: LogLevel,
               format: String,
               args: [CVarArg],
               file: String,
               function: String,
               line: Int) {
        let preface = formatTimestampFileLineFunction(file: file, line: line, function: function)
        let extendedFormat = preface + format
        let message = !args.isEmpty ? String(format: extendedFormat, arguments: args) : extendedFormat
        doLog(level, message: message)
    }
    
    func formatTimestampFileLineFunction(file: String, line: Int, function: String) -> String {
        let fileName = URL(string: file.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)?
            .lastPathComponent ?? file
        return "\(Date().timeStamp) \(fileName).\(line): \(function) "
    }
}


@available(iOS 10.0, macOS 10.12, tvOS 10.0,  watchOS 3.0, *)
public class OSLogSink: LoggerSink {
    init(subSystem: String = Bundle.main.bundleIdentifier!) {
        log = .init(subsystem: subSystem, category: "main")
    }

    public func doLog(_ level: LogLevel, message: String) {
        os_log("%{public}@", log: log, type: .init(logLevel: level), message)
    }
    
    let log: OSLog
}

@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)
extension OSLogType {
    init(logLevel level: LogLevel) {
        switch level {
        case .debug: self.init(rawValue: OSLogType.debug.rawValue)
        case .info: self.init(rawValue: OSLogType.info.rawValue)
        case .warn: self.init(rawValue: OSLogType.default.rawValue)
        case .error: self.init(rawValue: OSLogType.error.rawValue)
        default: self.init(rawValue: OSLogType.default.rawValue)
        }
    }
}

extension LoggerSink where Self == OSLogSink {
    public static var osLog: LoggerSink { OSLogSink() }
    public static func osLog(subSystem: String = Bundle.main.bundleIdentifier!) -> LoggerSink {
        OSLogSink(subSystem: subSystem)
    }
}

public class NSLogger: LoggerSink {
    public func doLog(_ level: LogLevel, message: String) {
        NSLog(message)
    }
}

extension LoggerSink where Self == NSLogger {
    public static var nsLog: LoggerSink { NSLogger() }
}

public class NSLogvLogger: LoggerSink {
    public func doLog(_ level: LogLevel, message: String) {
        withVaList([]) { NSLogv(message, $0) }
    }
}

extension LoggerSink where Self == NSLogvLogger {
    public static var nsLogv: LoggerSink { NSLogvLogger() }
}

public class ConsoleLogger: LoggerSink {
    public func doLog(_ level: LogLevel, message: String) {
        print(message)
    }
}

extension LoggerSink where Self == ConsoleLogger {
    public static var console: LoggerSink { ConsoleLogger() }
}


extension Date {
    var timeStamp: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "YY-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}

