// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/security/ReentrancyGuard.sol";

contract Monetizable is Ownable, ReentrancyGuard {
    uint256 maxPaymentFeeForAnyAction = 1 ether;
    uint256 internal _baseFee = 0.00000001 ether; // starting point for further adjustments

    function setBaseFee(uint256 baseFee) external onlyOwner {
        _baseFee = baseFee;
    }

    modifier providesFee(uint256 fee) {
        require(msg.value == fee, "Monetizable: Submited fee doesn't match.");
        _;
    }

    function withdraw() external onlyOwner nonReentrant {
        require(
            address(this).balance > 0,
            "Monetizable: No funds on the contract available"
        );

        payable(owner()).transfer(address(this).balance);
    }
}
