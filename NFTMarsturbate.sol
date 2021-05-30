//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MarsturbateSales.sol";

/**
NFT TOKEN - NSFT
*/
contract NFTMarsturbate is ERC721 {
    event NFTCreated(address indexed creator, uint256 tokenId, string tokenURI);


    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    MarsturbateSales private MSales;
    mapping(uint256 => string) public requestTokenUri;
    mapping(uint256 => address) public requestAddresses;
    mapping(bytes32 => uint256) public requestTokenIdsFromId;

    constructor() ERC721("Mrst NFT", "NSFT") public {
    }

    function awardItem(bytes32 requestId, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        requestTokenUri[newItemId] = tokenURI;
        requestAddresses[newItemId] = msg.sender;
        requestTokenIdsFromId[requestId] = newItemId;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        emit NFTCreated(msg.sender, newItemId, tokenURI);
        return newItemId;
    }

    function createSale(uint256 _currentPrice, uint256 _tokenId) public returns (address){
        require(ownerOf(_tokenId) == msg.sender);
        require(_exists(_tokenId) == true);
        MSales.beginSale(_tokenId, _currentPrice);
    }
}