// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

contract PseudoRandom {
    uint256 randNonce = 0;

    /// @dev _modulus = 100 => returns value from 0 to 99
    function randMod(uint256 _modulus) internal returns (uint256) {
        randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.gaslimit,
                        msg.sender,
                        randNonce
                    )
                )
            ) % _modulus;
    }

    function rand() internal returns (uint256) {
        randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.gaslimit,
                        msg.sender,
                        randNonce
                    )
                )
            );
    }
}
