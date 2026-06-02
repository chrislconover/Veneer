//
//  SwiftUI+.swift
//  Veneer
//
//  Created by Chris Conover on 9/5/25.
//

#if os(iOS)

import SwiftUI

@available(iOS 13.0, *)
public extension View {
    func trace(_ format: String,
               _ args: CVarArg...,
               file: String = #file,
               function: String = #function,
               line: Int = #line) -> some View {
        Logger.trace(format, args, file: file, function: function, line: line)
        return EmptyView()
    }
}

@available(iOS 14.0, *)
public extension Scene {
    func trace(_ format: String,
               _ args: CVarArg...,
               file: String = #file,
               function: String = #function,
               line: Int = #line) -> some View {
        Logger.trace(format, args, file: file, function: function, line: line)
        return EmptyView()
    }
}

@available(iOS 13.0, *)
public extension ViewModifier {
    func trace(_ format: String,
               _ args: CVarArg...,
               file: String = #file,
               function: String = #function,
               line: Int = #line) -> some View {
        Logger.trace(format, args, file: file, function: function, line: line)
        return EmptyView()
    }
}


@available(iOS 14.0, *)
public extension App {
    func trace(_ format: String,
               _ args: CVarArg...,
               file: String = #file,
               function: String = #function,
               line: Int = #line) -> some View {
        Logger.trace(format, args, file: file, function: function, line: line)
        return EmptyView()
    }
}

#endif
