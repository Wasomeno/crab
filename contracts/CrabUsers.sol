// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract CrabUsers {
    mapping(uint256 => bytes32[]) public districtToUserData;
    mapping(address => bytes32) public userToData;
    mapping(uint256 => address[]) public districtToUsers;
    mapping(address => bytes32) public userToActiveOrders;
    mapping(address => bytes32[]) public userToPastOrders;

    function addData(bytes32 _userData, uint256 _district) external {
        districtToUserData[_district].push(_userData);
    }

    function register(
        address _user,
        bytes32 _data,
        uint256 _secret,
        uint256 _district
    ) external {
        string memory _message = "user data";
        bool result = verifyData(_data, _district);
        require(result, "Data not recognized");
        bytes32 dataHashed = keccak256(
            abi.encodePacked(_data, _message, _secret)
        );
        userToData[_user] = dataHashed;
        districtToUsers[_district].push(_user);
    }

    function verifyData(bytes32 _data, uint256 _district)
        internal
        view
        returns (bool result)
    {
        bytes32[] memory datas = districtToUserData[_district];
        uint256 length = districtToUserData[_district].length;
        for (uint256 i; i < length; ++i) {
            bytes32 data = datas[i];
            if (data == _data) {
                result = true;
            }
        }
    }

    function getEthSignedMessageHash(bytes32 _hashMessage)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _hashMessage
                )
            );
    }

    function signIn(address _user, bytes calldata _signature)
        external
        view
        returns (bool)
    {
        bytes32 messageHash = userToData[_user];
        bytes32 ethSignedMesssageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMesssageHash, _signature) == _user;
    }

    function recover(bytes32 _ethSignedMessage, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessage, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function checkRegistered(address _user)
        external
        view
        returns (bool result)
    {
        bytes32 userData = userToData[_user];
        result = userData != 0;
    }

    function getUserActiverOrders(address _user)
        external
        view
        returns (bytes32 order)
    {
        order = userToActiveOrders[_user];
    }

    function getUserPastOrders(address _user)
        external
        view
        returns (bytes32[] memory orders)
    {
        orders = userToPastOrders[_user];
    }

    function addActiveOrder(address _user, bytes32 _orderId) external {
        userToActiveOrders[_user] = _orderId;
    }

    function removeActiveOrder(address _user, bytes32 _orderId) external {
        delete userToActiveOrders[_user];
        userToPastOrders[_user].push(_orderId);
    }
}
