// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./WorldBase.sol";

contract WorldActionAdventure is WorldBase {
    uint16 constant WorldActionAdventureActionType = 1;

    uint8[10] public worldActionAdventureSuccessProbabilities = [
        uint8(90), // 0 | Easy
        uint8(80), // 1 |
        uint8(70), // 2 |
        uint8(60), // 3
        uint8(50), // 4
        uint8(40), // 5
        uint8(30), // 6
        uint8(20), // 7
        uint8(10), // 8
        uint8(5) // 9
    ];

    struct HeroAdventureAction {
        uint8 difficulty;
        bool exists;
    }

    mapping(uint256 => HeroAdventureAction) ongoingHeroAdventures;

    event HeroAdventureStarted(
        uint256 heroId,
        uint256 difficulty,
        uint256 nextReadyTime
    );

    event HeroAdventureCompleted(uint256 heroId, bool success);

    function _sendHeroOnAnAdventure(uint256 _heroId, uint8 _difficulty)
        internal
        heroExists(_heroId)
        ownsHero(_heroId)
        heroAvailableForWorldAction(_heroId)
    {
        require(
            ongoingHeroAdventures[_heroId].exists == false,
            "HeroWorldActionAdventure: Hero is already on an adventure."
        );
        require(
            _difficulty > 0 &&
                _difficulty <= worldActionAdventureSuccessProbabilities.length,
            "HeroWorldActionAdventure: Invalid difficulty selected. Out of range."
        );

        Hero storage currentHero = heroes[_heroId];

        uint64 nextReadyTime;
        (nextReadyTime) = _setWorldActionCooldownTime(
            _heroId,
            WorldActionAdventureActionType,
            (5 minutes) * _difficulty * currentHero.level
        );

        ongoingHeroAdventures[_heroId] = HeroAdventureAction(_difficulty, true);

        emit HeroAdventureStarted(_heroId, _difficulty, nextReadyTime);
    }

    function _completeHeroAdventure(uint256 _heroId)
        internal
        heroExists(_heroId)
        ownsHero(_heroId)
        returns (bool success)
    {
        require(
            heroActionCooldowns[_heroId].actionType ==
                WorldActionAdventureActionType,
            "HeroWorldActionAdventure: Hero is doing something, but he is definitely not on an adventure!"
        );

        require(
            heroActionCooldowns[_heroId].cooldownTimestamp <=
                uint64(block.timestamp),
            "HeroWorldActionAdventure: Hero is still on his mighty journey for epic loot."
        );

        require(
            ongoingHeroAdventures[_heroId].exists == true,
            "HeroWorldActionAdventure: Hero is not on an adventure."
        );

        _setWorldActionDone(_heroId);

        Hero storage currentHero = heroes[_heroId];

        uint256 rand = randMod(100);
        uint256 difficulty = ongoingHeroAdventures[_heroId].difficulty;
        uint256 probability = worldActionAdventureSuccessProbabilities[
            difficulty - 1
        ];

        if (rand <= probability) {
            uint256 baseXp = 500 * difficulty * currentHero.level;
            uint256 reducedXp = (baseXp / 100) * (100 - probability);
            currentHero.currentExperience += uint32(reducedXp);

            success = true;
        }

        _levelUpHero(_heroId);

        emit HeroAdventureCompleted(_heroId, success);

        ongoingHeroAdventures[_heroId].exists = false;
    }
}
