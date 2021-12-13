// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./HeroFactory.sol";
import "./HeroOwnership.sol";

contract HeroDatabase is HeroFactory, HeroOwnership {
    Hero[] public heroes;

    mapping(uint256 => Hero) tokenToHero;

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId); // Call parent hook

        // nothing to do when a new hero is minted
        if (from == address(0)) {
            return;
        }

        uint8 heroType = tokenToHero[tokenId].heroType;

        require(heroType > 0, "HeroDatabase: Invalid hero.");

        // attempt to transfer a base hero
        if (heroType == 1) {
            require(
                msg.sender == owner(),
                "HeroDatabase: Only contract owner can transfer base heroes!"
            );
        }
    }

    function _pushHero(address owner, Hero memory _heroToMint)
        internal
        returns (uint256)
    {
        // generate a new token
        uint256 _newHeroId = _safeMint(owner);

        // add hero to database
        heroes.push(_heroToMint);

        // connect token and new hero
        tokenToHero[_newHeroId] = _heroToMint;

        // return token
        return _newHeroId;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._afterTokenTransfer(from, to, tokenId); // Call parent hook
    }

    modifier heroExists(uint256 _heroId) {
        require(_heroId < heroes.length, "HeroDatabase: Out of index");
        require(
            heroes[_heroId].creationTime > 0,
            "HeroDatabase: Hero doesn't exist."
        );
        _;
    }

    modifier ownsHero(uint256 _heroId) {
        require(
            msg.sender == ownerOf(_heroId),
            "HeroDatabase: Sender doesn't own this hero. Can't use requested on an foreign hero."
        );
        _;
    }

    modifier doesntOwnHero(uint256 _heroId) {
        require(
            msg.sender != ownerOf(_heroId),
            "HeroDatabase: Sender owns this hero. Can't use requested action on an owned hero."
        );
        _;
    }

    modifier requiredMinLevel(uint32 _level, uint256 _heroId) {
        require(
            heroes[_heroId].level >= _level,
            "HeroDatabase: Hero hasn't reached required level to perform this action."
        );
        _;
    }
}
