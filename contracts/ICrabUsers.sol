// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ICrabUsers {
    function checkRegistered(address _user) external view returns (bool result);

    function getUserActiveOrders(address _user)
        external
        view
        returns (bytes32 order);

    function getUserPastOrders(address _user)
        external
        view
        returns (bytes32[] memory orders);

    function addActiveOrder(address _driver, bytes32 _orderId) external;

    function removeActiveOrder(address _driver, bytes32 _orderId) external;
}
