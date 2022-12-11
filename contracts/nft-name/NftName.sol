// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol';
import { Upgradable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/upgradables/Upgradable.sol';
import { StringToAddress, AddressToString } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/StringAddressUtils.sol';

contract NameNft is AxelarExecutable, Upgradable {
    using StringToAddress for string;
    using AddressToString for address;

    error AlreadyInitialized();

    mapping(uint256 => bytes) public original; //abi.encode(originaChain, operator, tokenId);
    mapping(address => string) public addresslist;
    string public chainName; //To check if we are the source chain.
    IAxelarGasService public immutable gasReceiver;

    SupportedChains[] public supportedchains;

    NftName[] public nftlist;
    // mapping(address => NftName) public nftOwnerAddress;
    mapping(string => address) public nftMinting; //当前正在铸造的nft
    mapping(string => uint256) public mintingResponse;

    enum PayloadType {
        minting,
        query,
        response,
        authorization,
        deauthorization,
        transfer
    }

    enum MessageResult {
        success,
        fail
    }

    struct SupportedChains {
        string chainName;
        address contractaddr;
    }

    struct NftName {
        string name;
        address userAddress;
        bool isOwner; //所有权
        bool isRightToUse; //使用权
    }

    event ResponseEvent(uint256 indexed msgId, PayloadType indexed msgType, MessageResult indexed result);

    /*
    soildity中的数组map遍历
    1.初始化支持的链的列表 只有所有者可以初始化 
    2.实现铸造的方法 铸造之前去其他的链上查询
    */

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) {
        gasReceiver = IAxelarGasService(gasReceiver_);
    }

    // constructor() AxelarExecutable(0x1AE978F987e9d4CCC32850D995C62F3f6e575EfD) {
    //     gasReceiver = IAxelarGasService(0x1AE978F987e9d4CCC32850D995C62F3f6e575EfD);
    // }

    function addOrUpdateSupportedChain(string calldata chainName_, address contractaddr) public {
        for (uint256 i = 0; i < supportedchains.length; i++) {
            if (keccak256(bytes(chainName_)) == keccak256(bytes(supportedchains[i].chainName))) {
                supportedchains[i].contractaddr = contractaddr;
                return;
            }
        }
        supportedchains.push(SupportedChains(chainName_, contractaddr));
    }

    function deleteSupportedChain(string calldata chainName_) public {
        for (uint256 i = 0; i < supportedchains.length; i++) {
            if (keccak256(bytes(chainName_)) == keccak256(bytes(supportedchains[i].chainName))) {
                delete supportedchains[i];
                return;
            }
        }
    }

    //锁定name 将name标记为 铸造中 需要有增加超时 释放对该name的锁定
    function startMint(string calldata name, uint256 msgId) external payable {
        require(keccak256(bytes(name)) != keccak256(bytes('')), 'name is null');
        //检查名称在本合约内检查名称是否被占用
        require(_checkName(name), 'name has been used');
        require(nftMinting[name] == address(0), 'name is minting now');
        nftMinting[name] = msg.sender;

        for (uint256 i = 0; i < supportedchains.length; i++) {
            if (keccak256(bytes(chainName)) != keccak256(bytes(supportedchains[i].chainName))) {
                bytes memory payload = abi.encode(PayloadType.query, abi.encode(name), msgId);
                string memory stringAddress = supportedchains[i].contractaddr.toString();
                gasReceiver.payNativeGasForContractCall{ value: msg.value / 10 }(
                    address(this),
                    supportedchains[i].chainName,
                    stringAddress,
                    payload,
                    msg.sender
                );
                //gas 回调时支付的gas
                bytes memory payload_ = abi.encode(PayloadType.response, abi.encode(true, name), msgId);
                gasReceiver.payNativeGasForContractCall{ value: msg.value / 10 }(
                    stringAddress.toAddress(),
                    chainName,
                    address(this).toString(),
                    payload_,
                    msg.sender
                );
                gateway.callContract(supportedchains[i].chainName, stringAddress, payload);
            }
        }
    }

    function queryByName(string calldata name) external view returns (NftName memory) {
        int256 i = findNftNameInList(name);
        if (i >= 0) {
            return nftlist[uint256(i)];
        }
        return NftName('', address(0), false, false);
    }

    function queryByAddress(address addr) external view returns (NftName[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < nftlist.length; i++) {
            if (nftlist[i].userAddress == addr) {
                count++;
            }
        }
        NftName[] memory list = new NftName[](count);
        count = 0;
        for (uint256 i = 0; i < nftlist.length; i++) {
            if (nftlist[i].userAddress == addr) {
                list[count] = nftlist[i];
                count++;
            }
        }
        return list;
    }

    function _checkName(string memory name) internal view returns (bool) {
        for (uint256 i = 0; i < nftlist.length; i++) {
            if (keccak256(bytes(name)) == keccak256(bytes(nftlist[i].name))) {
                return false;
            }
        }
        return true;
    }

    function _checkOwner(address addr, string memory name) internal view returns (bool) {
        for (uint256 i = 0; i < nftlist.length; i++) {
            if (keccak256(bytes(name)) == keccak256(bytes(nftlist[i].name)) && nftlist[i].userAddress == addr) {
                return true;
            }
        }
        return false;
    }

    function _setup(bytes calldata params) internal override {
        string memory chainName_ = abi.decode(params, (string));
        if (bytes(chainName).length != 0) revert AlreadyInitialized();
        chainName = chainName_;
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        //Decode the payload.
        (PayloadType payloadType, bytes memory data, uint256 msgId) = abi.decode(payload, (PayloadType, bytes, uint256));
        //1.其他链上的合约返回名称是否可用 记录结果 全部返回可用 则开始铸造 不可用则标记 铸造失败 并发送事件
        //2.查询名称状态
        if (payloadType == PayloadType.query) {
            string memory name = abi.decode(data, (string));
            bool result = _checkName(name);
            //再调用回去
            bytes memory payload_ = abi.encode(PayloadType.response, abi.encode(result, name), msgId);
            gateway.callContract(sourceChain, sourceAddress, payload_);
        } else if (payloadType == PayloadType.response) {
            (bool state, string memory name) = abi.decode(data, (bool, string));
            if (!state) {
                mintfail(name, msgId);
            } else {
                if (mintingResponse[name] == supportedchains.length - 2) {
                    //开始铸造
                    minting(name, msgId);
                } else {
                    mintingResponse[name] = mintingResponse[name] + 1;
                }
            }
        } else if (payloadType == PayloadType.authorization) {
            (string memory name, address toaddr) = abi.decode(data, (string, address));
            _authorization(name, toaddr, msgId);
        } else if (payloadType == PayloadType.deauthorization) {
            (string memory name, address toaddr) = abi.decode(data, (string, address));
            _deauthorization(name, toaddr, msgId);
        } else if (payloadType == PayloadType.transfer) {
            (string memory name, address toaddr) = abi.decode(data, (string, address));
            _transferFrom(name, toaddr, msgId);
        }
    }

    function minting(string memory name, uint256 msgId) private {
        address owner = nftMinting[name];
        _minting(name, owner);
        // 发送事件
        emit ResponseEvent(msgId, PayloadType.minting, MessageResult.success);
    }

    function _minting(string memory name, address owner) private {
        NftName memory nftName = NftName(name, owner, true, true);
        nftlist.push(nftName);
        delete nftMinting[name];
        delete mintingResponse[name];
    }

    function _authorization(
        string memory name,
        address toaddr,
        uint256 msgId
    ) private {
        NftName memory nftName = NftName(name, toaddr, false, true);
        //同样的名称则不需要重复添加
        if (findNftNameInList(name) == -1) {
            nftlist.push(nftName);
            emit ResponseEvent(msgId, PayloadType.authorization, MessageResult.success);
        } else {
            emit ResponseEvent(msgId, PayloadType.authorization, MessageResult.fail);
        }
    }

    function _deauthorization(
        string memory name,
        address toaddr,
        uint256 msgId
    ) private {
        int256 i = findNftNameInList(name);
        //同样的地址 同样的名称则不需要重复添加
        if (i >= 0 && nftlist[uint256(i)].userAddress == toaddr) {
            nftlist[uint256(i)].userAddress = address(0);
            nftlist[uint256(i)].isRightToUse = false;
            emit ResponseEvent(msgId, PayloadType.deauthorization, MessageResult.success);
        } else {
            emit ResponseEvent(msgId, PayloadType.deauthorization, MessageResult.fail);
        }
    }

    function findNftNameInList(string memory name) private view returns (int256) {
        for (uint256 i = 0; i < nftlist.length; i++) {
            if (keccak256(bytes(nftlist[i].name)) == keccak256(bytes(name))) {
                return int256(i);
            }
        }
        return -1;
    }

    function mintfail(string memory name, uint256 msgId) private {
        delete nftMinting[name];
        delete mintingResponse[name];
        emit ResponseEvent(msgId, PayloadType.minting, MessageResult.fail);
    }

    //跨链授权
    function authorization(
        address toaddr,
        string calldata tochain,
        string calldata nftname,
        uint256 msgId
    ) public payable {
        require(keccak256(bytes(tochain)) != keccak256(bytes(chainName)), 'CURRENT_CHAIN_NOT_SUPPORT');
        //判断name是否存在
        // require(keccak256(bytes(nftOwnerAddress[msg.sender].name)) == keccak256(bytes(nftname)), 'NOT_OWNER');
        require(_checkOwner(msg.sender, nftname), 'NOT_OWNER');
        require(checkSupportChainByName(tochain), 'NOT_SUPPORT_CHAIN');
        bytes memory payload = abi.encode(PayloadType.authorization, abi.encode(nftname, toaddr), msgId);
        string memory stringAddress = findContractAddrByName(tochain).toString();
        gasReceiver.payNativeGasForContractCall{ value: msg.value }(address(this), tochain, stringAddress, payload, msg.sender);
        gateway.callContract(tochain, stringAddress, payload);
    }

    //撤销授权
    function deauthorization(
        address toaddr,
        string calldata tochain,
        string calldata nftname,
        uint256 msgId
    ) public payable {
        require(keccak256(bytes(tochain)) != keccak256(bytes(chainName)), 'CURRENT_CHAIN_NOT_SUPPORT');
        //判断name是否存在
        //require(keccak256(bytes(nftOwnerAddress[msg.sender].name)) == keccak256(bytes(nftname)), 'NOT_OWNER');
        require(_checkOwner(msg.sender, nftname), 'NOT_OWNER');
        require(checkSupportChainByName(tochain), 'NOT_SUPPORT_CHAIN');
        bytes memory payload = abi.encode(PayloadType.deauthorization, abi.encode(nftname, toaddr), msgId);
        string memory stringAddress = findContractAddrByName(tochain).toString();
        gasReceiver.payNativeGasForContractCall{ value: msg.value }(address(this), tochain, stringAddress, payload, msg.sender);
        gateway.callContract(tochain, stringAddress, payload);
    }

    function checkSupportChainByName(string memory chainName_) private view returns (bool) {
        for (uint256 i = 0; i < supportedchains.length; i++) {
            if (keccak256(bytes(supportedchains[i].chainName)) == keccak256(bytes(chainName_))) {
                return true;
            }
        }
        return false;
    }

    function findContractAddrByName(string memory chainName_) private view returns (address) {
        for (uint256 i = 0; i < supportedchains.length; i++) {
            if (keccak256(bytes(supportedchains[i].chainName)) == keccak256(bytes(chainName_))) {
                return supportedchains[i].contractaddr;
            }
        }
        return address(0);
    }

    //转移
    function transfer(
        address toaddr,
        string calldata tochain,
        string calldata nftname,
        uint256 msgId
    ) public payable {
        //当前链上进行转移
        //require(keccak256(bytes(nftOwnerAddress[msg.sender].name)) == keccak256(bytes(nftname)), 'NOT_OWNER');
        require(_checkOwner(msg.sender, nftname), 'NOT_OWNER');
        if (keccak256(bytes(tochain)) == keccak256(bytes(chainName))) {
            _transferLocal(nftname, toaddr, msg.sender, msgId);
        } else {
            //跨链转移
            require(checkSupportChainByName(tochain), 'NOT_SUPPORT_CHAIN');
            burn(nftname, msg.sender);
            bytes memory payload = abi.encode(PayloadType.transfer, abi.encode(nftname, toaddr), msgId);
            string memory stringAddress = findContractAddrByName(tochain).toString();
            gasReceiver.payNativeGasForContractCall{ value: msg.value }(address(this), tochain, stringAddress, payload, msg.sender);
            gateway.callContract(tochain, stringAddress, payload);
        }
    }

    function _transferLocal(
        string memory name,
        address toaddr,
        address owner,
        uint256 msgId
    ) private {
        burn(name, owner);
        _minting(name, toaddr);
        emit ResponseEvent(msgId, PayloadType.transfer, MessageResult.success);
    }

    function burn(string memory name, address owner) private {
        require(_checkOwner(owner, name), 'NOT_OWNER');
        int256 i = findNftNameInList(name);
        delete nftlist[uint256(i)];
        // delete nftOwnerAddress[owner];
    }

    function _transferFrom(
        string memory name,
        address toaddr,
        uint256 msgId
    ) private {
        int256 i = findNftNameInList(name);
        if (i >= 0) {
            //删除原有list中的内容
            delete nftlist[uint256(i)];
        }
        _minting(name, toaddr);
        emit ResponseEvent(msgId, PayloadType.transfer, MessageResult.success);
    }

    function contractId() external pure returns (bytes32) {
        return keccak256('zhaojie'); //example 0x6fd43e7cffc31bb581d7421c8698e29aa2bd8e7186a394b85299908b4eb9b175
    }
}
