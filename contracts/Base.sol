// SPDX-License-Identifier: GPL-3.0+

pragma solidity >=0.7.0 <0.9.0;

import "./Monetizable.sol";
import "./PseudoRandom.sol";
import "./Configuration.sol";

contract Base is Monetizable, PseudoRandom, Configuration {}
