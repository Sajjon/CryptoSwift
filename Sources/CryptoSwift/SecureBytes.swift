//
//  CryptoSwift
//
//  Copyright (C) 2014-2017 Marcin Krzyżanowski <marcin@krzyzanowskim.com>
//  This software is provided 'as-is', without any express or implied warranty.
//
//  In no event will the authors be held liable for any damages arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
//
//  - The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation is required.
//  - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
//  - This notice may not be removed or altered from any source or binary distribution.
//


//https://linux.die.net/man/2/mlock

typealias MemoryLockImpl = (_ address: UnsafeRawPointer?, _ length: Int) -> Int32
typealias MemoryUnlockImpl = (_ address: UnsafeRawPointer?, _ length: Int) -> Int32

#if canImport(Darwin)
import Darwin

let lockMemory: MemoryLockImpl = Darwin.mlock
let unlockMemory: MemoryUnlockImpl = Darwin.munlock

#elseif canImport(Glibc)
import Glibc

let lockMemory: MemoryLockImpl = Glibc.mlock
let unlockMemory: MemoryUnlockImpl = Glibc.munlock
#elseif canImport(WinSDK)
import WinSDK

let lockMemory: MemoryLockImpl = { (address: UnsafeRawPointer?,  length: Int) -> Int32 in
    VirtualLock(UnsafeMutableRawPointer(mutating: address), SIZE_T(length))
}

let unlockMemory: MemoryUnlockImpl = { (address: UnsafeRawPointer?,  length: Int) -> Int32 in
    VirtualUnlock(UnsafeMutableRawPointer(mutating: address), SIZE_T(length))
}

#elseif canImport(WASILibc)
import WASILibc

func wasiNotImplementedWarning() {
    
    let msg = """
    ⚠️ WARNING! Potential unsafe use of `CryptoSwift.SecureBytes` ⚠️
    WASILibc found but `mman.h` has not been compiled for WASILibc
    See SwiftWasm issue: https://github.com/swiftwasm/swift/issues/2315
    No locking/unlocking of sensitive memory in SecureBytes is being performed.
    """
    
    print(msg)
}

let lockMemory: MemoryLockImpl = { (address: UnsafeRawPointer?,  length: Int) -> Int32 in
    /* Nothing to do */
    wasiNotImplementedWarning()
    return 0
}

let unlockMemory: MemoryUnlockImpl = { (address: UnsafeRawPointer?,  length: Int) -> Int32 in
    /* Nothing to do */
    wasiNotImplementedWarning()
    return 0
}

#endif

typealias Key = SecureBytes

///  Keeps bytes in memory. Because this is class, bytes are not copied
///  and memory area is locked as long as referenced, then unlocked on deinit
final class SecureBytes {
  private let bytes: Array<UInt8>
  let count: Int

  init(bytes: Array<UInt8>) {
    self.bytes = bytes
    self.count = bytes.count
    self.bytes.withUnsafeBufferPointer { (pointer) -> Void in
        _ = lockMemory(pointer.baseAddress, pointer.count)
    }
  }

  deinit {
    self.bytes.withUnsafeBufferPointer { (pointer) -> Void in
        _ = unlockMemory(pointer.baseAddress, pointer.count)
    }
  }
}

extension SecureBytes: Collection {
  typealias Index = Int

  var endIndex: Int {
    self.bytes.endIndex
  }

  var startIndex: Int {
    self.bytes.startIndex
  }

  subscript(position: Index) -> UInt8 {
    self.bytes[position]
  }

  subscript(bounds: Range<Index>) -> ArraySlice<UInt8> {
    self.bytes[bounds]
  }

  func formIndex(after i: inout Int) {
    self.bytes.formIndex(after: &i)
  }

  func index(after i: Int) -> Int {
    self.bytes.index(after: i)
  }
}

extension SecureBytes: ExpressibleByArrayLiteral {
  public convenience init(arrayLiteral elements: UInt8...) {
    self.init(bytes: elements)
  }
}
