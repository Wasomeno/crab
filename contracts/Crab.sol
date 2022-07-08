// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Crab {
    struct MenuOrdered {
        uint256 menuId;
        uint256 menuQuantity;
    }

    struct Order {
        uint256 shopId;
        address user;
        MenuOrdered[] orderedMenus;
        uint256 orderTotal;
        uint256 status;
    }

    mapping(address => bytes32[]) public userToOrders;
    mapping(bytes32 => Order) public orderDetails;

    function makeOrder(
        address _user,
        uint256 _shopId,
        uint256[] calldata _menuId,
        uint256[] calldata _quantity,
        uint256 _total
    ) external payable {
        require(msg.value >= _total, "Wrong value of eth sent");
        uint256 userOrdersLength = userToOrders[_user].length;
        bytes32 orderId = keccak256(abi.encodePacked(_user, userOrdersLength));
        Order storage order = orderDetails[orderId];
        uint256 menuLength = _menuId.length;
        order.shopId = _shopId;
        order.user = _user;
        for (uint256 i; i < menuLength; ++i) {
            uint256 id = _menuId[i];
            uint256 quantity = _quantity[i];
            order.orderedMenus.push(MenuOrdered(id, quantity));
        }
        order.orderTotal = _total;
        order.status = 0;
        userToOrders[_user].push(orderId);
    }

    function acceptOrder(bytes32 _orderId) external {
        orderDetails[_orderId].status = 1;
    }

    function orderOnDelivery(bytes32 _orderId) external {
        orderDetails[_orderId].status = 2;
    }

    function orderArrived(bytes32 _orderId) external {
        orderDetails[_orderId].status = 3;
    }

    receive() external payable {}
}
