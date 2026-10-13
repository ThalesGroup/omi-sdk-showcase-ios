//
//
// Copyright © 2021 THALES. All rights reserved.
//

//
//  Configuration.swift
//  fido2sample
//
//

// POC - Start
import Foundation

// Fido2 Securelog public key
struct SecureLogPublicKey {
    //Replace this byte array with your own public key modulus.
    static let publicKeyModulus: [CUnsignedChar] = []
    //Replace this byte array with your own public key exponent.
    static let publicKeyExponent: [CUnsignedChar] = []
}

// Fido2 rpId, Replace this value to your own rpId
let rpId: String = "https://genuflecto.github.io"

// 
let appgroupIdentifier: String = "group.com.onewelcome.showcase"
// POC - End
