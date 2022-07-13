// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ICrabShops {
    function addOrders(uint256 _shopId, bytes32 _orderId) external;
}
