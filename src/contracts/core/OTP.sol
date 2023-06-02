// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import '../interfaces/IHMACOTP.sol';
import '@oasisprotocol/sapphire-contracts/contracts/Sapphire.sol';
import '../libraries/KeyDeriv.sol';

contract HMACOTP is IHMACOTP {
    enum Type {
        HOTP,
        TOTP,
        BOTP
    }

    enum Digits {
        Six,
        Eight
    }

    enum Algorithm {
        SHA1,
        SHA256
    }

    struct Meta {
        Type otpType;
        Algorithm algorithm;
        Digits digits;
        bool locked;
        address owner;
        uint256 nonce;
        uint256 timeout;
    }

    // @dev: This mapping stores the sender's number of OTP secrets created.
    mapping(address => uint256) private metanonce;

    // @dev: This mapping stores the OTP secrets.
    mapping(bytes => string) private seed;

    // @dev: This mapping stores the otp's metadata.
    mapping(bytes => Meta) public meta;

    // @dev: This function is called by the sender to verify a OTP code.
    function verify(address _owner, uint256 _metanonce, uint256 _code) external returns (bool) {
        bytes memory metaKey = abi.encodePacked(_owner, _metanonce);

        Meta memory _meta = meta[metaKey];
        uint256 nonce;
        if (_meta.otpType == Type.HOTP) {
            nonce = _meta.nonce;
        }
        if (_meta.otpType == Type.TOTP) {
            nonce = block.timestamp / _meta.timeout;
        }
        if (_meta.otpType == Type.BOTP) {
            nonce = block.number / _meta.timeout; // timeout is used as a block interval
        }

        uint256 code = _meta.algorithm == Algorithm.SHA1
            ? getHOTP1(seed[metaKey], nonce)
            : getHOTP256(seed[metaKey], nonce);
        code = toDigits(code, _meta.digits == Digits.Six ? 6 : 8);
        bool result = code == _code;
        if (result && _meta.otpType == Type.HOTP) {
            meta[metaKey].nonce++;
        }
        return result;
    }

    // @dev: This function is called by the sender to generate a secret.
    //       The sender can provide a password to generate the secret.
    function generateSecret(
        Type _type,
        Algorithm _algorithm,
        Digits _digits,
        uint256 _timeout,
        string memory _password
    ) external returns (bool) {
        bytes memory metaKey = abi.encodePacked(msg.sender, metanonce[msg.sender]);
        seed[metaKey] = toHex(Sapphire.randomBytes(16, bytes(_password)));
        meta[metaKey] = Meta(_type, _algorithm, _digits, false, msg.sender, 0, _timeout);
        metanonce[msg.sender]++;
        return true;
    }

    // @dev: This function is called by the sender to retrieve the secret after generating it.
    function getSecret(uint256 _metanonce) external view returns (string memory) {
        bytes memory metaKey = abi.encodePacked(msg.sender, _metanonce);
        require(meta[metaKey].owner == msg.sender, '!owner');
        require(!meta[metaKey].locked, '!locked');
        return seed[metaKey];
    }

    // @dev: This function is called by the sender to lock the secret if he decides to do so.
    //       When the secret has been locked, the sender can no longer retrieve it with getSecret.
    function lockSecret(uint256 _metanonce) external {
        bytes memory metaKey = abi.encodePacked(msg.sender, _metanonce);
        require(meta[metaKey].owner == msg.sender, '!owner');
        meta[metaKey].locked = true;
    }

    // @dev: This function is called by the contract to generate a HOTP and compare it to the sender's input.
    //       This function uses the HMACSHA1 algorithm to derive the code.
    //       This is done to verify that the sender has the correct OTP code.
    function getHOTP1(string storage secret, uint256 nonce) internal pure returns (uint256) {
        bytes memory hash = KeyDeriv.hmacsha1(bytes(secret), abi.encodePacked(bytes8(uint64(nonce))));
        return truncate(hash);
    }

    // @dev: This function is called by the contract to generate a HOTP and compare it to the sender's input.
    //       This function uses the HMACSHA256 algorithm to derive the code.
    //       This is done to verify that the sender has the correct OTP code.
    function getHOTP256(string storage secret, uint256 nonce) internal pure returns (uint256) {
        bytes memory hash = KeyDeriv.hmacsha256(bytes(secret), abi.encodePacked(bytes8(uint64(nonce))));
        return truncate(hash);
    }

    // @dev: truncate algorithm  as specified by RFC 4226 5.3
    function truncate(bytes memory hash) internal pure returns (uint256) {
        uint8 offset = uint8(hash[hash.length - 1]) & 15;
        return
            ((uint(uint8(hash[offset])) & 127) << 24) |
            ((uint(uint8(hash[offset + 1])) & 255) << 16) |
            ((uint(uint8(hash[offset + 2])) & 255) << 8) |
            (uint(uint8(hash[offset + 3])) & 255);
    }

    // @dev: simple internal function to get the totp nonce based on the timestamp
    function getNonce(uint256 _timeout) internal view returns (uint256) {
        return block.timestamp / _timeout;
    }

    // @dev: simple internal function to shorten a uint256 to a specified number of digits
    function toDigits(uint256 _input, uint256 _digits) internal pure returns (uint256 output) {
        return _input % 10 ** _digits;
    }

    // @dev: simple internal function to convert bytes to hex
    function toHex(bytes memory buffer) public pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = '0123456789abcdef';

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(converted);
    }
}
