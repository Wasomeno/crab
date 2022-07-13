// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ICrabUsers.sol";
import "./ICrabShops.sol";
import "./ICrabDrivers.sol";

contract Crab {
    struct MenuOrdered {
        uint256 menuId;
        uint256 menuQuantity;
    }

    struct Order {
        uint256 shopId;
        address driver;
        address user;
        MenuOrdered[] orderedMenus;
        uint256 priceTotal;
        uint256 status;
        uint256 timeStamp;
    }

    mapping(bytes32 => Order) public orderDetails;

    ICrabShops private shopInterface;
    ICrabUsers private userInterface;
    ICrabDrivers private driverInterface;

    constructor(
        address _crabUser,
        address _crabShop,
        address _crabDriver
    ) {
        shopInterface = ICrabShops(_crabShop);
        userInterface = ICrabUsers(_crabUser);
        driverInterface = ICrabDrivers(_crabDriver);
    }

    modifier userOnly(address _user) {
        bool result = userInterface.checkRegistered(_user);
        require(result, "Not a registered user");
        _;
    }

    modifier driverOnly(address _driver) {
        bool result = driverInterface.checkRegistered(_driver);
        require(result, "Not a registered driver");
        _;
    }

    function makeOrder(
        address _user,
        uint256 _shopId,
        uint256[] calldata _menuId,
        uint256[] calldata _quantity,
        uint256 _total
    ) external payable userOnly(_user) {
        require(msg.value >= _total, "Wrong value of eth sent");
        bytes32[] memory pastOrders = userInterface.getUserPastOrders(_user);
        bytes32 orderId = keccak256(abi.encodePacked(_user, pastOrders.length));
        Order storage order = orderDetails[orderId];
        uint256 menuLength = _menuId.length;
        order.shopId = _shopId;
        order.driver = address(0);
        order.user = _user;
        for (uint256 i; i < menuLength; ++i) {
            uint256 id = _menuId[i];
            uint256 quantity = _quantity[i];
            order.orderedMenus.push(MenuOrdered(id, quantity));
        }
        order.priceTotal = _total;
        order.status = 0;
        shopInterface.addOrders(_shopId, orderId);
        userInterface.addActiveOrder(_user, orderId);
    }

    function acceptOrder(address _driver, bytes32 _orderId)
        external
        driverOnly(_driver)
    {
        uint256 status = orderDetails[_orderId].status;
        address taken = orderDetails[_orderId].driver;
        bytes32 order = driverInterface.getDriverActiveOrders(_driver);
        require(status == 0, "Wrong status");
        require(taken == address(0), "Order taken by other driver");
        require(order == 0, "You've taken another order");
        orderDetails[_orderId].driver = _driver;
        orderDetails[_orderId].status = 1;
        driverInterface.addActiveOrder(_driver, _orderId);
    }

    function orderOnDelivery(address _driver, bytes32 _orderId)
        external
        driverOnly(_driver)
    {
        uint256 status = orderDetails[_orderId].status;
        address driver = orderDetails[_orderId].driver;
        require(driver == _driver, "You're not the driver");
        require(status == 1, "Wrong status");
        orderDetails[_orderId].status = 2;
    }

    function orderArrived(address _driver, bytes32 _orderId)
        external
        driverOnly(_driver)
    {
        uint256 price = orderDetails[_orderId].priceTotal;
        uint256 reward = ((price - 3) * 1 ether) / 1000;
        uint256 status = orderDetails[_orderId].status;
        address driver = orderDetails[_orderId].driver;
        require(driver == _driver, "You're not the driver");
        require(status == 2, "Wrong Status");
        orderDetails[_orderId].status = 3;
        driverInterface.removeActiveOrder(_driver, _orderId);
        (bool sent, ) = _driver.call{value: reward}("");
        require(sent, "Failed to send eth");
    }

    receive() external payable {}
}
