// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./HeroDatabase.sol";

contract HeroStore is HeroDatabase {
    event NewHeroCreated(uint256 heroId, string name, uint256 dna);
    event HeroGainedLevel(uint256 heroId, uint256 newLevel);

    function createNewHero(
        string memory _name,
        string memory metadataUri,
        uint256 _dna
    ) public onlyOwner returns (uint256) {
        Hero memory newHero = _createHero(_name, metadataUri, _dna);

        uint256 heroId = _pushHero(msg.sender, newHero);

        emit NewHeroCreated(heroId, _name, _dna);

        return heroId;
    }

    function createBaseHero(string memory _name) public returns (uint256) {
        // check if any base heroes are present => only if caller lost the base hero (for whatever reason) we allow to generate a new one.
        uint256[] memory tokensOfCaller = tokenListOfOwner(msg.sender);

        for (uint256 i = 0; i < tokensOfCaller.length; i++) {
            Hero memory heroToCheck = tokenToHero[tokensOfCaller[i]];

            require(
                heroToCheck.heroType != 1,
                "HeroStore: Only one base hero per wallet is allowed!"
            );
        }

        Hero memory newHero = _createRandomHero(_name, _baseHeroMetadataUri);

        uint256 heroId = _pushHero(msg.sender, newHero);

        emit NewHeroCreated(heroId, _name, newHero.dna);

        return heroId;
    }

    function setNewName(uint256 _heroId, string calldata _name)
        external
        payable
        ownsHero(_heroId)
        requiredMinLevel(2, _heroId)
    {
        heroes[_heroId].name = _name;
    }

    function _levelUpHero(uint256 _heroId) internal {
        Hero storage hero = heroes[_heroId];

        while (hero.currentExperience >= hero.nextLevelExperience) {
            hero.level++;

            hero.nextLevelExperience += uint32(
                uint256(hero.level) * uint256(1000) * (uint256(3) / uint256(2)) // 1.5
            );

            emit HeroGainedLevel(_heroId, hero.level);
        }

        heroes[_heroId] = hero;
    }

    function getHero(uint256 heroId) external view returns (Hero memory) {
        require(
            heroId < heroes.length,
            "HeroStore: Out of index. This hero doesn't exist."
        );
        return heroes[heroId];
    }

    function getHeroesFromOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        return tokenListOfOwner(_owner);
    }
}
