// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

//A simple ERC721 that allows users to mint NFTs as they please.
contract ERC721Demo is ERC721 {
    uint256 public vvalue = 100;
    mapping(address => string) public addresslist;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        addresslist[0x1AE978F987e9d4CCC32850D995C62F3f6e575EfD] = 'hello';
    }

    function setValue() public {
        vvalue = 11;
    }

    function mint(uint256 tokenId) external {
        _safeMint(_msgSender(), tokenId);
    }
}
