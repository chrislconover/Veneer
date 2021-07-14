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
    public static var logLevel: LogLevel = .important
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

    public static let all: LogLevel = [.trace, .info, .debug, .warn, .error]
    public static let important: LogLevel = [.warn, .error]
}

public protocol LoggerSink {
    func doLog(_ level: LogLevel, message: String)
    func doLog(_ level: LogLevel,
               format: String, args: [CVarArg],
               file: String,
               function: String,
               line: Int)
}

private func formatTimestampFileLineFunction(file: String, line: Int, function: String) -> String {
    let fileName = URL(string: file.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)?
        .lastPathComponent ?? file
    return "\(Date().timeStamp) \(fileName).\(line): \(function) "
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
        doLog(level, message: String(format: extendedFormat, arguments: args))
    }
}


@available(iOS 10.0, macOS 10.12, tvOS 10.0,  watchOS 3.0, *)
public class OSLogSink: LoggerSink {
    public init() {}
    public func doLog(_ level: LogLevel, message: String) {
        os_log("%@", log: .default, type: .init(logLevel: level), message)
    }
    
    public func doLog(_ level: LogLevel,
               format: String,
               args: [CVarArg],
               file: String,
               function: String,
               line: Int) {
        let fileName = URL(string: file.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)?
            .lastPathComponent ?? file
        let message = String(format: "\(fileName).\(line): \(function) \(format)", arguments: args)
        doLog(level, message: message)
    }
}

@available(iOS 10.0, macOS 10.12, tvOS 10.0,  watchOS 3.0, *)
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


open class NSLogger: LoggerSink {
    public func doLog(_ level: LogLevel, message: String) {
        NSLog(message)
    }
}


open class NSLogvLogger: LoggerSink {
    public func doLog(_ level: LogLevel, message: String) {
        withVaList([]) { NSLogv(message, $0) }
    }
}

open class ConsoleLogger: LoggerSink {
    public func doLog(_ level: LogLevel, message: String) {
        print(message)
    }
}

open class AnyLogger: LoggerSink {
    public func doLog(_ level: LogLevel, message: String) {
        fatalError()
    }
    
    public func doLog(_ level: LogLevel,
                      format: String,
                      args: [CVarArg],
                      file: String,
                      function: String,
                      line: Int) {
        let fileName = URL(string: file.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)?
            .lastPathComponent ?? file
        sink(level, format, args, fileName, function, line)
    }

    public init(_ sink: @escaping (LogLevel, String, [CVarArg], String, String, Int) -> Void) {
        self.sink = sink
    }
    
    private var sink: (LogLevel, String, [CVarArg], String, String, Int) -> Void
}

extension Date {
    var timeStamp: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "YY-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}

