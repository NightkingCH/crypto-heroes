// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./HeroStore.sol";

abstract contract WorldBase is HeroStore {
    uint16 constant WorldActionDoneActionType = 0;

    uint32[15] public worldActionCooldowns = [
        uint32(0 seconds), // 0
        uint32(1 minutes), // 1
        uint32(2 minutes), // 2
        uint32(5 minutes), // 3
        uint32(10 minutes), // 4
        uint32(30 minutes), // 5
        uint32(1 hours), // 6
        uint32(2 hours), // 7
        uint32(4 hours), // 8
        uint32(8 hours), // 9
        uint32(16 hours), // 10
        uint32(1 days), // 11
        uint32(2 days), // 12
        uint32(4 days), // 13
        uint32(7 days) // 14
    ];

    struct WorldAction {
        uint16 actionType;
        uint64 cooldownTimestamp;
    }

    mapping(uint256 => WorldAction) heroActionCooldowns;

    function _setWorldActionCooldownTime(
        uint256 _heroId,
        uint16 actionType,
        uint32 cooldownTime
    ) internal returns (uint64 cooldownTimestamp) {
        cooldownTimestamp = uint64(block.timestamp + cooldownTime);

        heroActionCooldowns[_heroId] = WorldAction(
            actionType,
            cooldownTimestamp
        );
    }

    function _setWorldActionDone(uint256 _heroId) internal {
        // set to done action and current stamp for "now"
        WorldAction storage currentCooldown = heroActionCooldowns[_heroId];

        currentCooldown.actionType = WorldBase.WorldActionDoneActionType;
        currentCooldown.cooldownTimestamp = uint64(block.timestamp); // now
    }

    function getCurrentWorldActionForHero(uint256 _heroId)
        external
        view
        heroExists(_heroId)
        returns (WorldAction memory)
    {
        return heroActionCooldowns[_heroId];
    }

    function completeHeroWorldActionCooldown(uint256 _heroId)
        external
        payable
        heroExists(_heroId)
        ownsHero(_heroId)
    {
        require(
            heroActionCooldowns[_heroId].actionType !=
                WorldBase.WorldActionDoneActionType,
            "HeroWorldActions: No ongoing actions to complete."
        );

        uint64 timeLeft = heroActionCooldowns[_heroId].cooldownTimestamp -
            uint64(block.timestamp); // seconds left
        uint256 requiredFee = timeLeft * _baseFee;

        require(
            msg.value >= requiredFee,
            "HeroWorldActions: Not enough fee provided"
        );

        // set to done action and current stamp for "now"
        WorldAction storage currentCooldown = heroActionCooldowns[_heroId];

        currentCooldown.cooldownTimestamp = uint64(block.timestamp); // now

        // refund not used fee
        uint256 notUsedFee = msg.value - requiredFee;

        if (notUsedFee > 0) {
            payable(msg.sender).transfer(notUsedFee);
        }
    }

    function getCompleteHeroWorldActionCooldownEstimatedFee(uint256 _heroId)
        external
        view
        heroExists(_heroId)
        ownsHero(_heroId)
        returns (uint256 estimatedFeeToPay)
    {
        uint64 timeLeft = heroActionCooldowns[_heroId].cooldownTimestamp -
            uint64(block.timestamp); // seconds left

        require(timeLeft > 0);

        estimatedFeeToPay = timeLeft * _baseFee; // to remove a 24h cooldown a user has to pay about 4$ (4146 USD / ETH)

        if (estimatedFeeToPay > maxPaymentFeeForAnyAction) {
            estimatedFeeToPay = maxPaymentFeeForAnyAction;
        }
    }

    modifier heroAvailableForWorldAction(uint256 _heroId) {
        require(
            heroActionCooldowns[_heroId].actionType ==
                WorldBase.WorldActionDoneActionType,
            "HeroWorldAction: Finish outstanding action first."
        );

        require(
            heroActionCooldowns[_heroId].cooldownTimestamp <=
                uint64(block.timestamp),
            "HeroWorldAction: Hero is on global cooldown."
        );
        _;
    }
}
