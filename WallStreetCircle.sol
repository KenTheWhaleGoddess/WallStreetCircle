//"SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleCollectible is ERC1155, Ownable {
    uint256 public tokenCounter;
    address public os = 0x495f947276749Ce646f68AC8c248420045cb7b5e;
    uint256 public og_tokenId = 41755310711834619493115302770701979369604126678184953212653412667523296396764;
    address public yieldToken;

    uint256 private _maxPerTx = 21; // Set to one higher than actual, to save gas on <= checks.

    uint256 private _totalSupply = 7777; 

    string private _baseTokenURI;
    string private _baseSuffix;

    constructor () ERC1155 ('')  {
        setBaseURI('https://gateway.pinata.cloud/ipfs/QmdaXBmTtevw3gGKLrzAaHdPeyDVJ9oiK3SWKdoqd1jufH/');
        setBaseSuffix('.json');
    }

    function mintColletibles(uint256 _count) public payable {
        require((_count + tokenCounter) <= getTotalSupply(), "Ran out of NFTs for presale! Sry!");
        IERC1155(os).safeTransferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD, og_tokenId, _count, '');

        createCollectibles(msg.sender, _count);
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(getBaseURI(), toString(tokenId), getBaseSuffix()));
    }

    function ownerMint(uint256 count, address[] memory users) external onlyOwner {
        require((count * users.length) + tokenCounter < _totalSupply, "Cant mint more than mintMax");

        for(uint256 i = 0; i < users.length; i++) {
            createCollectibles(users[i], count);
        }
    }

    function createCollectibles(address _user, uint256 _count) private {
        _mint(_user, 0, _count, '');

    }

    function getTotalSupply() private view returns (uint) {
        return _totalSupply;
    }


    function setYieldToken(address _address) public onlyOwner {
        yieldToken = _address;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }
    function setBaseSuffix(string memory suffix) public onlyOwner {
        _baseSuffix = suffix;
    }

    function getBaseURI() public view returns (string memory){
        return _baseTokenURI;
    }

    function getBaseSuffix() public view returns (string memory){
        return _baseSuffix;
    }
    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }


    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

}
