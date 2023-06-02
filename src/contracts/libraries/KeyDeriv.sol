// SPDX-License-Identifier: MIT

// Ported to solidity 0.8.17 and modified from scrypt.sol
// https://github.com/ethereum/dapp-bin/blob/master/scrypt/scrypt.sol

// The MIT License (MIT)

// Copyright (c) 2014

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

pragma solidity ^0.8.17;

import './Sha1.sol';
import './Sha512.sol';

library KeyDeriv {
    function hmacsha1(bytes memory key, bytes memory message) internal pure returns (bytes memory) {
        bytes32 keyl;
        bytes32 keyr;
        uint i;
        if (key.length > 64) {
            keyl = Sha1.hash(key);
        } else {
            for (i = 0; i < key.length && i < 32; i++) keyl |= bytes32(uint8(key[i]) * 2 ** (8 * (31 - i)));
            for (i = 32; i < key.length && i < 64; i++) keyr |= bytes32(uint8(key[i]) * 2 ** (8 * (63 - i)));
        }
        bytes32 threesix = 0x3636363636363636363636363636363636363636363636363636363636363636;
        bytes32 fivec = 0x5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;
        return
            abi.encodePacked(
                Sha1.hash(
                    abi.encodePacked(
                        fivec ^ keyl,
                        fivec ^ keyr,
                        Sha1.hash(abi.encodePacked(threesix ^ keyl, threesix ^ keyr, message))
                    )
                )
            );
    }

    function hmacsha256(bytes memory key, bytes memory message) internal pure returns (bytes memory) {
        bytes32 keyl;
        bytes32 keyr;
        uint i;
        if (key.length > 64) {
            keyl = sha256(key);
        } else {
            for (i = 0; i < key.length && i < 32; i++) keyl |= bytes32(uint8(key[i]) * 2 ** (8 * (31 - i)));
            for (i = 32; i < key.length && i < 64; i++) keyr |= bytes32(uint8(key[i]) * 2 ** (8 * (63 - i)));
        }
        bytes32 threesix = 0x3636363636363636363636363636363636363636363636363636363636363636;
        bytes32 fivec = 0x5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;
        return
            abi.encode(
                sha256(
                    abi.encodePacked(
                        fivec ^ keyl,
                        fivec ^ keyr,
                        sha256(abi.encodePacked(threesix ^ keyl, threesix ^ keyr, message))
                    )
                )
            );
    }

    /// PBKDF2 restricted to c=1, hash = hmacsha256 and dklen being a multiple of 32 not larger than 128
    function pbkdf2(bytes calldata key, bytes calldata salt, uint dklen) internal pure returns (bytes32[4] memory r) {
        bytes memory message = new bytes(salt.length + 4);
        for (uint i = 0; i < salt.length; i++) message[i] = salt[i];
        for (uint i = 0; i * 32 < dklen; i++) {
            message[message.length - 1] = bytes1(uint8(i + 1));
            r[i] = bytes32(hmacsha256(key, message));
        }
    }

    function concat(uint64[8] memory data, uint256 start) internal pure returns (bytes32) {
        bytes32 result;
        uint64 d1 = data[start];
        uint64 d2 = data[start + 1];
        uint64 d3 = data[start + 2];
        uint64 d4 = data[start + 3];

        assembly {
            mstore(add(result, 8), d1)
            mstore(add(result, 16), d2)
            mstore(add(result, 24), d3)
            mstore(add(result, 32), d4)
        }
        return result;
    }
}
