//
//  AESSmartOffice.swift
//  AESEncreptDecreptDemoSmartOffice
//
//  Created by smartSense on 14/05/18.
//  Copyright © 2018 smartSense. All rights reserved.
//

import UIKit

infix operator >>> : BitwiseShiftPrecedence

func >>> (lhs: Int64, rhs: Int64) -> Int64 {
    return Int64(bitPattern: UInt64(bitPattern: lhs) >> UInt64(rhs))
}

func >>> (lhs: Int32, rhs: Int32) -> Int32 {
    return Int32(bitPattern: UInt32(bitPattern: lhs) >> UInt32(rhs))
}

func >>> (lhs: Int, rhs: Int) -> Int {
    return Int(bitPattern: UInt(bitPattern: lhs) >> UInt(rhs))
}

func +=<T>(left:inout [T], right: T) -> [T]{
    left.append(right)
    return left
}

//print(-7 >>> 16) //->281474976710655


public class AESSmartOffice: NSObject {
    // current round index
    private var actual:Int32 = 0
    
    // number of chars (32 bit)
    private static var Nb:Int32 = 4
    private var Nk:Int32 = 0
    
    // number of rounds for current AES
    private var Nr:Int32 = 0
    
    // state
    private var state:[[[Int32]]] = []
    
    // key stuff
    private var w:[Int32] = []
    private var key:[UInt8] = []
    
    // Initialization vector (only for CBC)
    private var iv:[UInt8] = []
    
    // necessary matrix for AES (sBox + inverted one & rCon)
    private static var sBox:[Int32] = [
        //0     1    2      3     4    5     6     7      8    9     A      B    C     D     E     F
        0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
        0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
        0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
        0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
        0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
        0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
        0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
        0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
        0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
        0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
        0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
        0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
        0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
        0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
        0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
        0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16 ]
    
    private static var rsBox : [Int32] = [
        0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
        0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
        0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
        0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
        0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
        0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
        0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
        0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
        0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
        0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
        0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
        0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
        0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
        0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
        0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
        0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d ]
    
    private static var rCon : [Int32] = [
        0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a,
        0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39,
        0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a,
        0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8,
        0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef,
        0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc,
        0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b,
        0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3,
        0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94,
        0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20,
        0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35,
        0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f,
        0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04,
        0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63,
        0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd,
        0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d ]
    
    
    public override init() {
        super.init()
    }
    
    convenience init(key:[UInt8]) {
        self.init(key: key, iv: [])
    }
    
    convenience init(key:[UInt8], iv:[UInt8]) {
        self.init()
        self.iv = iv
        self.key = [UInt8](repeating: 0, count: key.count)
        
        for i in 0..<key.count {
            self.key[i] = key[i]
        }
        
        // AES standard (4*32) = 128 bits
        AESSmartOffice.Nb = 4
        switch (key.count) {
        // 128 bit key
        case 16:
            Nr = 10
            Nk = 4
            break
        // 192 bit key
        case 24:
            Nr = 12
            Nk = 6
            break
        // 256 bit key
        case 32:
            Nr = 14
            Nk = 8
            break
        default:
            //            throw NSError(domain: "It only supports 128, 192 and 256 bit keys!", code: 1, userInfo: [:])
            //            throw new IllegalArgumentException("It only supports 128, 192 and 256 bit keys!")
            // NOTE:- Show Toast Msg:--
            print("It only supports 128, 192 and 256 bit keys!")
            
        }
        
        // The storage array creation for the states.
        // Only 2 states with 4 rows and AESSmartOffice.Nb columns are required.
        //        state = new Int32[2][4][AESSmartOffice.Nb]
        state = [[[Int32]]](repeating:
            [[Int32]](repeating:
                [Int32](repeating: 0, count: Int(AESSmartOffice.Nb)), count: 4), count: 2)
        
        // The storage vector for the expansion of the key creation.
        //        w = new Int32[AESSmartOffice.Nb * (Nr + 1)]
        w = [Int32](repeating: 0, count: Int(AESSmartOffice.Nb * (self.Nr + 1)))
        
        // Key expansion
        self.expandKey()
    }
    
    // The 128 bits of a state are an XOR offset applied to them with the 128 bits of the key expended.
    // s: state matrix that has AESSmartOffice.Nb columns and 4 rows.
    // Round: A round of the key w to be added.
    // s: returns the addition of the key per round
    
    private func addRoundKey(s: inout [[Int32]], round:Int32){
        for c in 0..<Int(AESSmartOffice.Nb) {
            for r in 0..<4 {
                s[Int(r)][Int(c)] = s[Int(r)][Int(c)] ^ ((w[Int(round * AESSmartOffice.Nb + Int32(c))] << (Int32(r) *  Int32(8))) >>> Int32(24))
            }
        }
    }
    
    // Cipher/Decipher methods
    private func cipher(inVar:[[Int32]], outVar: inout [[Int32]]) {
        for i in 0..<inVar.count {
            for j in 0..<inVar[0].count {
                outVar[i][j] = inVar[i][j]
            }
        }
        actual = 0
        addRoundKey(s: &outVar, round: actual)
        actual = 1
        while actual < Nr {
            subBytes(state: &outVar)
            shiftRows(state: &outVar)
            mixColumns(state: &outVar)
            addRoundKey(s: &outVar, round: actual)
            actual += 1
        }
        subBytes(state: &outVar)
        shiftRows(state: &outVar)
        addRoundKey(s: &outVar, round: actual)
    }
    
    private func decipher(inVar: [[Int32]], outVar: inout [[Int32]]) {
        for i in 0..<inVar.count {
            for j in 0..<inVar.count {
                outVar[i][j] = inVar[i][j]
            }
        }
        actual = Nr
        addRoundKey(s: &outVar, round: actual)
        
        actual = Nr - 1
        while actual > 0 {
            invShiftRows(state: &outVar)
            invSubBytes(state: &outVar)
            addRoundKey(s: &outVar, round: actual)
            invMixColumnas(state: &outVar)
            actual -= 1
        }
        invShiftRows(state: &outVar)
        invSubBytes(state: &outVar)
        addRoundKey(s: &outVar, round: actual)
    }
    
    // Main cipher/decipher helper-methods (for 128-bit plain/cipher text in,
    // and 128-bit cipher/plain text out) produced by the encryption algorithm.
    private func encrypt(text:[UInt8]) -> [UInt8] {
        if (text.count != 16) {
            //            throw new IllegalArgumentException("Only 16-UInt8 blocks can be encrypted")
            print("Only 16-UInt8 blocks can be encrypted")
        }
        var out = [UInt8](repeating: 0, count: text.count)
        
        for i in 0..<Int(AESSmartOffice.Nb) { // columns
            for j in 0..<4 { // rows
                state[0][j][Int(i)] = Int32(Int(text[Int(i) * Int(AESSmartOffice.Nb) + j] & 0xff))
            }
        }
        
        cipher(inVar: state[0], outVar: &state[1])
        for i in 0..<Int(AESSmartOffice.Nb) {
            for j in 0..<4 {
                out[Int(i) * Int(AESSmartOffice.Nb) + j] = (UInt8) (state[1][j][Int(i)] & 0xff)
            }
        }
        return out
    }
    
    private func decrypt(text:[UInt8]) -> [UInt8] {
        if (text.count != 16) {
            //            throw new IllegalArgumentException("Only 16-UInt8 blocks can be encrypted")
            print("Only 16-UInt8 blocks can be encrypted")
        }
        var out = [UInt8](repeating: 0, count: text.count)
        
        for i in 0..<Int(AESSmartOffice.Nb) { // columns
            for j in 0..<4 { // rows
                state[0][j][i] = Int32(text[i * Int(AESSmartOffice.Nb) + j] & 0xff)
            }
        }
        
        decipher(inVar: state[0], outVar: &state[1])
        for i in 0..<Int(AESSmartOffice.Nb) {
            for j in 0..<4 {
                out[i * Int(AESSmartOffice.Nb) + j] = (UInt8) (state[1][j][i] & 0xff)
            }
        }
        return out
        
    }
    
    // Algorithm's general methods
    private func invMixColumnas(state: inout [[Int32]]) {
        var temp0:Int32, temp1:Int32, temp2:Int32, temp3:Int32
        for c in 0..<Int(AESSmartOffice.Nb) {
            temp0 = AESSmartOffice.mult(a: 0x0e, b: state[0][c]) ^ AESSmartOffice.mult(a: 0x0b, b: state[1][c]) ^ AESSmartOffice.mult(a: 0x0d, b: state[2][c]) ^ AESSmartOffice.mult(a: 0x09, b: state[3][c])
            temp1 = AESSmartOffice.mult(a: 0x09, b: state[0][c]) ^ AESSmartOffice.mult(a: 0x0e, b: state[1][c]) ^ AESSmartOffice.mult(a: 0x0b, b: state[2][c]) ^ AESSmartOffice.mult(a: 0x0d, b: state[3][c])
            temp2 = AESSmartOffice.mult(a: 0x0d, b: state[0][c]) ^ AESSmartOffice.mult(a: 0x09, b: state[1][c]) ^ AESSmartOffice.mult(a: 0x0e, b: state[2][c]) ^ AESSmartOffice.mult(a: 0x0b, b: state[3][c])
            temp3 = AESSmartOffice.mult(a: 0x0b, b: state[0][c]) ^ AESSmartOffice.mult(a: 0x0d, b: state[1][c]) ^ AESSmartOffice.mult(a: 0x09, b: state[2][c]) ^ AESSmartOffice.mult(a: 0x0e, b: state[3][c])
            
            state[0][c] = temp0
            state[1][c] = temp1
            state[2][c] = temp2
            state[3][c] = temp3
        }
    }
    
    private func invShiftRows(state: inout [[Int32]]) {
        var temp1:Int32, temp2:Int32, temp3:Int32
        
        // row 1
        temp1 = state[1][Int(AESSmartOffice.Nb) - 1]
        for i in stride(from: Int(AESSmartOffice.Nb) - 1, to: 0, by: -1) {
            state[1][i] = state[1][(i - 1) % Int(AESSmartOffice.Nb)]
        }
        state[1][0] = temp1
        // row 2
        temp1 = state[2][Int(AESSmartOffice.Nb) - 1]
        temp2 = state[2][Int(AESSmartOffice.Nb) - 2]
        for i in stride(from: Int(AESSmartOffice.Nb) - 1, to: 1, by: -1) {
            state[2][i] = state[2][(i - 2) % Int(AESSmartOffice.Nb)]
        }
        state[2][1] = temp1
        state[2][0] = temp2
        // row 3
        temp1 = state[3][Int(AESSmartOffice.Nb) - 3]
        temp2 = state[3][Int(AESSmartOffice.Nb) - 2]
        temp3 = state[3][Int(AESSmartOffice.Nb) - 1]
        for i in stride(from: Int(AESSmartOffice.Nb) - 1, to: 2, by: -1) {
            state[3][i] = state[3][(i - 3) % Int(AESSmartOffice.Nb)]
        }
        state[3][0] = temp1
        state[3][1] = temp2
        state[3][2] = temp3
    }
    
    
    private func invSubBytes(state: inout [[Int32]]) {
        for i in 0..<4 {
            for j in 0..<Int(AESSmartOffice.Nb) {
                state[i][j] = AESSmartOffice.invSubWord(word: state[i][j]) & 0xFF
            }
        }
    }
    
    
    private static func invSubWord(word:Int32) -> Int32 {
        var subWord:Int32 = 0
        for i in stride(from: 24, through: 0, by: -8) {
            let inVar:Int32 = word << (i >>> 24)
            subWord |= rsBox[Int(inVar)] << (24 - i)
        }
        return subWord
    }
    
    private func expandKey() {
        var temp:Int32, i:Int = 0
        while (i < Nk) {
            w[i] = 0x00000000
            w[i] |= Int32(key[4 * i]) << 24
            w[i] |= Int32(key[4 * i + 1]) << 16
            w[i] |= Int32(key[4 * i + 2]) << 8
            w[i] |= Int32(key[4 * i + 3])
            i = i + 1
        }
        i = Int(Nk)
        while (i < Int(AESSmartOffice.Nb) * (Int(Nr) + 1)) {
            temp = w[i - 1]
            if (i % Int(Nk) == 0) {
                // apply an XOR with a constant round rCon.
                temp = AESSmartOffice.subWord(word: Int32(AESSmartOffice.rotWord(word: Int(temp)))) ^ (AESSmartOffice.rCon[i / Int(Nk)] << 24)
            } else if (Nk > 6 && (i % Int(Nk) == 4)) {
                temp = AESSmartOffice.subWord(word: temp)
            } else {
            }
            w[i] = w[i - Int(Nk)] ^ temp
            i = i + 1
        }
    }
    
    private func mixColumns(state: inout [[Int32]]) {
        var temp0:Int32, temp1:Int32, temp2:Int32, temp3:Int32
        for c in 0..<Int(AESSmartOffice.Nb) {
            temp0 = AESSmartOffice.mult(a: 0x02, b: state[0][c]) ^ AESSmartOffice.mult(a: 0x03, b: state[1][c]) ^ state[2][c] ^ state[3][c]
            temp1 = state[0][c] ^ AESSmartOffice.mult(a: 0x02, b: state[1][c]) ^ AESSmartOffice.mult(a: 0x03, b: state[2][c]) ^ state[3][c]
            temp2 = state[0][c] ^ state[1][c] ^ AESSmartOffice.mult(a: 0x02, b: state[2][c]) ^ AESSmartOffice.mult(a: 0x03, b: state[3][c])
            temp3 = AESSmartOffice.mult(a: 0x03, b: state[0][c]) ^ state[1][c] ^ state[2][c] ^ AESSmartOffice.mult(a: 0x02, b: state[3][c])
            
            state[0][c] = temp0
            state[1][c] = temp1
            state[2][c] = temp2
            state[3][c] = temp3
        }
    }
    
    private static func mult(a:Int32, b:Int32) -> Int32 {
        var a = a
        var b = b
        var sum:Int32 = 0
        while (a != 0) { // while it is not 0
            if ((a & 1) != 0) { // check if the first bit is 1
                sum = sum ^ b // add b from the smallest bit
            }
            b = xtime(b: b) // bit shift left mod 0x11b if necessary
            a = a >>> 1 // lowest bit of "a" was used so shift right
        }
        return sum
        
    }
    
    private static func rotWord(word:Int) -> Int {
        //        return Int(Int32(word) << 8) | (Int(word & 0xFF000000) >>> 24)
        return Int(Int32(word) << 8) | ((word & 0xFF000000) >>> 24)
    }
    
    private func shiftRows(state: inout [[Int32]]) {
        var temp1:Int32, temp2:Int32, temp3:Int32
        // row 1
        temp1 = state[1][0]
        for i in 0..<Int(AESSmartOffice.Nb) - 1 {
            state[1][i] = state[1][(i + 1) % Int(AESSmartOffice.Nb)]
        }
        state[1][Int(AESSmartOffice.Nb) - 1] = temp1
        
        // row 2, moves 1-UInt8
        temp1 = state[2][0]
        temp2 = state[2][1]
        for i in 0..<Int(AESSmartOffice.Nb) - 2 {
            state[2][i] = state[2][(i + 2) % Int(AESSmartOffice.Nb)]
        }
        state[2][Int(AESSmartOffice.Nb) - 2] = temp1
        state[2][Int(AESSmartOffice.Nb) - 1] = temp2
        
        // row 3, moves 2-bytes
        temp1 = state[3][0]
        temp2 = state[3][1]
        temp3 = state[3][2]
        for i in 0..<(Int(AESSmartOffice.Nb)-3) {
            state[3][i] = state[3][(i + 3) % Int(AESSmartOffice.Nb)]
        }
        state[3][Int(AESSmartOffice.Nb) - 3] = temp1
        state[3][Int(AESSmartOffice.Nb) - 2] = temp2
        state[3][Int(AESSmartOffice.Nb) - 1] = temp3
    }
    
    private func subBytes(state: inout [[Int32]]) {
        for i in 0..<4 {
            for j in 0..<Int(AESSmartOffice.Nb) {
                state[i][j] = AESSmartOffice.subWord(word: state[i][j]) & 0xFF
            }
        }
    }
    
    private static func subWord(word:Int32) -> Int32 {
        var subWord:Int32 = 0
        for i in stride(from: 24, through: 0, by: -8) {
            let inVar:Int32 = Int32((Int32(word) << i) >>> Int32(24))
            
            print(inVar)
            subWord = subWord + sBox[Int(inVar)] << (24 - i)
        }
        return subWord
    }
    
    private static func xtime(b:Int32) -> Int32 {
        if ((b & 0x80) == 0) {
            return b << 1
        }
        return (b << 1) ^ 0x11b
    }
    
    private static func xor(a:[UInt8], b:[UInt8]) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: min(a.count, b.count))
        for j in 0..<result.count {
            let xor:UInt8 = a[j] ^ b[j]
            result[j] = (UInt8) (0xff & xor)
        }
        return result
    }
    
    // Public methods
    public func ECB_encrypt(text:[UInt8]) -> [UInt8] {
        var out = Data(bytes: text)
        for i in stride(from: 0, to: text.count, by: 16) {
            let arrayCopy:[UInt8] = Array(text[i..<(i+16)])
            out.append(contentsOf: encrypt(text: arrayCopy))
        }
        let outArray:[UInt8] = Array(out.base64EncodedString().utf8)
        return outArray
    }
    
    public func ECB_decrypt(text:[UInt8]) -> [UInt8] {
        var out = Data(bytes: text)
        for i in stride(from: 0, to: text.count, by: 16) {
            let arrayCopy:[UInt8] = Array(text[i..<(i+16)])
            out.append(contentsOf: encrypt(text: arrayCopy))
        }
        let outArray:[UInt8] = Array(out.base64EncodedString().utf8)
        return outArray
    }
    
    public func CBC_encrypt(text:[UInt8]) -> [UInt8]{
        var previousBlock:[UInt8] = []
        var out:[UInt8] = []
        for i in stride(from: 0, to: text.count, by: 16) {
            var part:[UInt8] = Array(text[i..<(i+16)])
            if (previousBlock.count == 0){
                previousBlock = iv
            }
            part = AESSmartOffice.xor(a: previousBlock, b: part)
            previousBlock = encrypt(text: part)
            out += previousBlock
        }
        return out
    }
    
    public func CBC_decrypt(text:[UInt8]) -> [UInt8] {
        var previousBlock:[UInt8] = []
        var out:[UInt8] = []
        for i in stride(from: 0, to: text.count, by: 16) {
            // let part:[UInt8] = Array(text[i..<(i+16)])
            var countableRange = i..<(i+16)
            if (text.count - 1) < i+16{
                countableRange = i..<text.count
            }
            var part:[UInt8] = Array(text[countableRange])
            
            if part.count < 16{
                let padding = [UInt8](repeating: 0, count: 16 - part.count)
                part += padding
            }
            
            var tmp:[UInt8] = decrypt(text: part)
            if previousBlock.count == 0{
                previousBlock = iv
            }
            tmp = AESSmartOffice.xor(a: previousBlock, b: tmp)
            previousBlock = part
            out += tmp
        }
        
        return out
    }
    
    public func fillBlock(text:String) -> String {
        var text = text
        let numOfBytes = text.lengthOfBytes(using: .utf8)
        let spaceNum:Int32 = Int32(numOfBytes % 16 == 0 ? 0 : (16 - numOfBytes % 16))
        for _ in 0..<Int(spaceNum){
            text.append(" ")
        }
        return text
    }
    
    //    public func getKey() -> [UInt8] {
    //        var key = ""
    //        for i in 0..<2{
    //            key += Long.toHexString(Double.doubleToLongBits(Math.random()))
    //        }
    //
    //        return key.getBytes()
    //    }
    
}



