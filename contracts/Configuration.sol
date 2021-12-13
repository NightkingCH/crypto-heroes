// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/security/ReentrancyGuard.sol";

contract Configuration is Ownable {
    string internal _baseHeroMetadataUri = "";

    function setBaseMetadata(string memory baseHeroMetadataUri)
        external
        onlyOwner
    {
        _baseHeroMetadataUri = baseHeroMetadataUri;
    }
}
