// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ICrabDrivers {
    function checkRegistered(address _driver)
        external
        view
        returns (bool result);

    function getDriverActiveOrders(address _driver)
        external
        view
        returns (bytes32 order);

    function getDriverPastOrders(address _driver)
        external
        view
        returns (bytes32[] memory orders);

    function addActiveOrder(address _driver, bytes32 _orderId) external;

    function removeActiveOrder(address _driver, bytes32 _orderId) external;
}
