// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./OpenZeppelin/token/ERC721/ERC721.sol";
import "./ERC721HeroEnumerable.sol";

import "./OpenZeppelin/utils/Counters.sol";

import "./Base.sol";

contract HeroOwnership is Base, ERC721, ERC721HeroEnumerable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("CryptoHeroes", "CRHS") {}

    function _safeMint(address to) internal returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(to, tokenId);

        return tokenId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721HeroEnumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721HeroEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
