// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract CrabShops {
    struct Shop {
        bytes32 shopName;
        address owner;
    }

    struct Menu {
        bytes32 menuName;
        uint256 menuPrice;
        uint256 menuStock;
    }

    mapping(uint256 => bytes32[]) public shopToOrders;
    mapping(uint256 => uint256[]) public districtShops;
    mapping(uint256 => Shop) public shopDetails;
    mapping(uint256 => bytes32) public shopDataHash;
    mapping(uint256 => mapping(uint256 => Menu)) public shopMenus;

    function createShop(
        bytes32 _dataHash,
        bytes32 _name,
        uint256[] calldata _menuId,
        bytes32[] calldata _menuName,
        uint256[] calldata _menuPrice,
        uint256[] calldata _menuStock,
        uint256 _district
    ) external {
        uint256 shopId = _district + districtShops[_district].length;
        uint256 menusLength = _menuId.length;
        districtShops[_district].push(shopId);
        Shop storage shop = shopDetails[shopId];
        shop.shopName = _name;
        for (uint256 i; i < menusLength; ++i) {
            uint256 menuId = _menuId[i];
            bytes32 menuName = _menuName[i];
            uint256 menuPrice = _menuPrice[i];
            uint256 menuStock = _menuStock[i];
            shopMenus[shopId][menuId] = Menu(menuName, menuPrice, menuStock);
        }
        shopDataHash[shopId] = _dataHash;
    }

    function addOrders(uint256 _shopId, bytes32 _orderId) external {
        shopToOrders[_shopId].push(_orderId);
    }
}
