// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

contract HeroFactory {
    uint256 private dnaDigits = 16;
    // To make sure our Hero's DNA is only 16 characters, let's make another uint equal to 10^16. That way we can later use the modulus operator % to shorten an integer to 16 digits.
    uint256 private dnaModulus = 10**dnaDigits;

    struct Hero {
        string name;
        uint8 heroType; // 0 => invalid hero
        string metadataUri;
        uint64 creationTime;
        uint32 level;
        uint32 currentExperience;
        uint32 nextLevelExperience;
        uint256 dna;
    }

    function _createHero(
        string memory _name,
        string memory metadataUri,
        uint256 _dna
    ) internal view returns (Hero memory) {
        // custom
        return
            Hero(
                _name,
                99,
                metadataUri,
                uint64(block.timestamp),
                1,
                0,
                1500,
                _dna
            );
    }

    function _createRandomHero(string memory _name, string memory metadataUri)
        internal
        view
        returns (Hero memory)
    {
        return
            Hero(
                _name,
                1, // base
                metadataUri,
                uint64(block.timestamp),
                1,
                0,
                1500,
                _generateRandomDna(_name)
            );
    }

    // newDna = newDna - newDna % 100 + 99; // 334455 - (334455 % 100) => 334455 - 55 => 334400 + 99 => 334499
    function _generateRandomDna(string memory _name)
        private
        view
        returns (uint256)
    {
        // 256-bit hexadecimal number convertet to an uint256 which is max 16 digits long
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.gaslimit,
                    msg.sender,
                    _name
                )
            )
        ); // ensures a different dna for the same name (twice a Arthur hero)
        return rand % dnaModulus;
    }
}
