//
//  Logger.swift
//  Veneer
//
//  Created by Chris Conover on 2/12/19.
//  Copyright © 2019 Chris Conover. All rights reserved.
//

import Foundation


public protocol Logger {

    func legacyError(_ format: String,
                                 file: String,
                                 function: String,
                                 line: Int)

    func error(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

    func warn(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)


    func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

    func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

    func log(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int)

}

extension Logger {

    public func legacyError(_ format: String,
                                 file: String = URL(string: #file)?.lastPathComponent ?? #file,
                                 function: String = #function,
                                 line: Int = #line) {
        return legacyError(format, file: file, function: function, line: line)
    }

    public func error(
        _ format: String,
        _ args: CVarArg...,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {
        return error(format, args, file: file, function: function, line: line)
    }

    public func warn(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {
        return warn(format, args, file: file, function: function, line: line)
    }


    public func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {
        return trace(format, args, file: file, function: function, line: line)
    }

    public func debug(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {
        return debug(format, args, file: file, function: function, line: line)
    }

    public func log(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {
        return log(format, args, file: file, function: function, line: line)
    }
}

extension Logger {
    public func route(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {

//        log(format, args, file: file, function: function, line: line)
    }
}


open class DefaultLogger: NSObject {

    public static func legacyError(_ format: String,
                                 file: String,
                                 function: String,
                                 line: Int) {
        let extendedArgs = [CVarArg]()
        let extendedFormat = "[%d]\t ERROR " + format
        withVaList(extendedArgs) { doLog(extendedFormat, $0) }
    }

    public static func error(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String = #function,
        line: Int) {

        log(format, args, file: file, function: function, line: line)
    }


    public static func warn(
        _ format: String,
        _ args: CVarArg...,
        file: String = URL(string: #file)?.lastPathComponent ?? #file,
        function: String = #function,
        line: Int = #line) {
        log(format, args, file: file, function: function, line: line)
    }


    public static func trace(
        _ format: String,
        _ args: CVarArg...,
        file: String,
        function: String,
        line: Int) {

        #if DEBUG
        log(format, args, file: file, function: function, line: line)
        #endif
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
        file: String,
        function: String,
        line: Int) {

        let extendedFormat = "%@: %@ @%d\t " + format
        let extendedArgs : [CVarArg] = [ file, function, line ] + args
        withVaList(extendedArgs) { doLog(extendedFormat, $0) }
    }

    fileprivate static func doLog(_ format: String, _ args: CVaListPointer) {
        NSLogv(format, args)
    }
}
