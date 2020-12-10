//
//  CryptoSwift
//
//  Copyright (C) 2014-2018 Marcin Krzyżanowski <marcin@krzyzanowskim.com>
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

typealias PowImpl =  (Double, Double) -> Double
typealias CeilImpl =  (Double) -> Double

#if canImport(Darwin)
import Darwin

let pow: PowImpl = Darwin.pow
let ceil: CeilImpl = Darwin.ceil

#elseif canImport(Glibc)
import Glibc
let pow: PowImpl = Glibc.pow
let ceil: CeilImpl = Glibc.ceil
#elseif canImport(ucrt)
import ucrt
let pow: PowImpl = ucrt.pow
let ceil: CeilImpl = ucrt.ceil
#else
let pow: PowImpl = { (lhs: Double, rhs: Double) -> Double in
    fatalError("not yet impl")
}
let ceil: CeilImpl = { (value: Double) -> Double in
    fatalError("not yet impl")
}
#endif

