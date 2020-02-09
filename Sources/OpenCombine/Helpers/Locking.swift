//
//  Locking.swift
//  
//
//  Created by Sergej Jaskiewicz on 11.06.2019.
//

#if canImport(COpenCombineHelpers)
import COpenCombineHelpers
#endif

internal typealias OpenCombineUnfairLock = __UnfairLock
internal typealias OpenCombineUnfairRecursiveLock = __UnfairRecursiveLock

extension OpenCombineUnfairRecursiveLock {

    @inlinable
    internal func `do`<Result>(_ body: () throws -> Result) rethrows -> Result {
        lock()
        defer { unlock() }
        return try body()
    }
}
