// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./CrabShops.sol";

interface ICrabShops {
    function addOrders(uint256 _shopId, bytes32 _orderId) external;
}
