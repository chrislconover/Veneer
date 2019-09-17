//
//  Logger.swift
//  Veneer
//
//  Created by Chris Conover on 2/12/19.
//  Copyright © 2019 Chris Conover. All rights reserved.
//

import Foundation


public protocol LoggerType {

    func legacyError(_ format: String,
                                 file: String,
                                 function: String,
                                 line: Int)

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

    public func legacyError(_ format: String,
                                 file: String = URL(string: #file)?.lastPathComponent ?? #file,
                                 function: String = #function,
                                 line: Int = #line) {
        return legacyError(format, file: file, function: function, line: line)
    }

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
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {
        return warn(format, args, file: file, function: function, line: line)
    }


    public static func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {
        return trace(format, args, file: file, function: function, line: line)
    }

    public static func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {
        return debug(format, args, file: file, function: function, line: line)
    }

    public static func log(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {
        return log(format, args, file: file, function: function, line: line)
    }
}


open class Logger: NSObject, LoggerType {

    public static func legacyError(_ format: String,
                                   file: String = URL(string: #file)?.lastPathComponent ?? #file,
                                   function: String = #function,
                                   line: Int = #line) {
        let extendedArgs = [CVarArg]()
        let extendedFormat = "[%d]\t ERROR " + format
        withVaList(extendedArgs) { logger.doLog(extendedFormat, $0) }
    }

    public static func error(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int) {

        log(format, args, file: file, function: function, line: line)
    }

    public static func warn(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int) {

        log(format, args, file: file, function: function, line: line)
    }

    public static func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {

        debug(format, args, file: file, function: function, line: line)
    }

    public static func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {

        #if DEBUG
        log(format, args, file: file, function: function, line: line)
        #endif
    }

    public static func log(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {

        let extendedFormat = "%@: %@ @%d\t " + format
        let extendedArgs : [CVarArg] = [ file, function, line ] + args
        withVaList(extendedArgs) { logger.doLog(extendedFormat, $0) }
    }

    static var logger: LoggerSink = ConsoleLogger()
}


public protocol LoggerSink {
    func doLog(_ format: String, _ args: CVaListPointer)
}

open class ConsoleLogger: LoggerSink {
    public func doLog(_ format: String, _ args: CVaListPointer) {
        NSLogv(format, args)
    }
}
