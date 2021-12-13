// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./WorldActionAdventure.sol";
import "./WorldActionArena.sol";

contract HeroWorld is WorldActionAdventure, WorldActionArena {
    function sendHeroOnAnAdventure(uint256 _heroId, uint8 _difficulty)
        external
    {
        _sendHeroOnAnAdventure(_heroId, _difficulty);
    }

    function completeHeroAdventure(uint256 _heroId)
        external
        returns (bool success)
    {
        success = _completeHeroAdventure(_heroId);
    }

    function sendHeroToArenaFight(uint256 _heroId, uint256 _enemyHeroId)
        external
    {
        _fightInArena(_heroId, _enemyHeroId);
    }

    function completeHeroArenaFight(uint256 _heroId)
        external
        returns (bool success)
    {
        success = _completeArenaFight(_heroId);
    }
}
