// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./WorldBase.sol";

contract WorldActionArena is WorldBase {
    uint16 constant WorldActionArenaActionType = 2;

    struct HeroArenaFightAction {
        uint256 enemyHeroId;
        bool exists;
    }

    mapping(uint256 => HeroArenaFightAction) ongoingArenaFights;

    event HeroArenaFightStarted(
        uint256 heroId,
        uint256 enemyHeroId,
        uint256 nextReadyTime
    );

    event HeroArenaFightCompleted(
        uint256 heroId,
        uint256 enemyHeroId,
        bool success
    );

    function _fightInArena(uint256 _heroId, uint256 _enemyHeroId)
        internal
        heroExists(_heroId)
        heroExists(_enemyHeroId)
        ownsHero(_heroId)
        requiredMinLevel(5, _heroId)
        heroAvailableForWorldAction(_heroId)
    {
        require(
            _heroId != _enemyHeroId,
            "HeroWorldActionArena: Nice try but a hero can't fight himself!"
        );

        require(
            ongoingArenaFights[_heroId].exists == false,
            "HeroWorldActionArena: Hero is still fighting for his life."
        );

        uint64 nextReadyTime;
        (nextReadyTime) = _setWorldActionCooldownTime(
            _heroId,
            WorldActionArenaActionType,
            worldActionCooldowns[6]
        );

        emit HeroArenaFightStarted(_heroId, _enemyHeroId, nextReadyTime);
    }

    function _completeArenaFight(uint256 _heroId)
        internal
        heroExists(_heroId)
        ownsHero(_heroId)
        returns (bool success)
    {
        require(
            heroActionCooldowns[_heroId].actionType ==
                WorldActionArenaActionType,
            "HeroWorldActionArena: Hero is doing something, but he is definitely not fighting!"
        );

        require(
            heroActionCooldowns[_heroId].cooldownTimestamp <=
                uint64(block.timestamp),
            "HeroWorldActionArena: Hero is still fighting for his life."
        );

        require(
            ongoingArenaFights[_heroId].exists == true,
            "HeroWorldActionArena: Hero is not fighting in the arena."
        );

        _setWorldActionDone(_heroId);

        Hero storage currentHero = heroes[_heroId];
        Hero storage enemyHero = heroes[
            ongoingArenaFights[_heroId].enemyHeroId
        ];

        uint256 rand = randMod(100);
        uint256 probability = (currentHero.level / enemyHero.level) * 50;

        if (rand <= probability) {
            uint256 baseXp = 1000 * enemyHero.level;
            uint256 reducedXp = (baseXp / 100) * (100 - probability);
            currentHero.currentExperience += uint32(reducedXp);

            success = true;
        }

        _levelUpHero(_heroId);

        emit HeroArenaFightCompleted(
            _heroId,
            ongoingArenaFights[_heroId].enemyHeroId,
            success
        );

        ongoingArenaFights[_heroId].exists = false;
    }
}
