//
//  Locking.swift
//  
//
//  Created by Sergej Jaskiewicz on 10.12.2019.
//

#if canImport(COpenCombineHelpers)
import COpenCombineHelpers
#endif

import OpenCombine

internal typealias OpenCombineUnfairLock = __UnfairLock
internal typealias OpenCombineUnfairRecursiveLock = __UnfairRecursiveLock
