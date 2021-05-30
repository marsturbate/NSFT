//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Pausable.sol";

/**
* Marsturbate NFTs
* NSFT - Sellable NFTS for Porn
*/

contract MarsturbateSales is Ownable, Pausable {
    event Sent(address indexed payee, uint256 amount, uint256 balance);
    event Received(address indexed payer, uint tokenId, uint256 amount, uint256 balance);

    ERC721 public nftAddress;
    mapping(uint256 => uint256) public currentPrice;
    mapping(uint256 => bool) public inSale;
    mapping(uint256 => uint256) public startSaleDate;
    mapping(uint256 => bytes32) public categoriesAvailable;
    uint private saleDays = 30;


    constructor(address _nftAddress) public {
        require(_nftAddress != address(0) && _nftAddress != address(this));
        nftAddress = ERC721(_nftAddress);
    }

    /**
    * Purchase Token Id
    */
    function purchaseToken(uint256 _tokenId) public payable whenNotPaused {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= currentPrice[_tokenId], 'Not enough money');
        require(inSale[_tokenId] == true, 'Not in sale');
        require(nftAddress._exists(_tokenId), "This NFT is not ERC721");
        require(startSaleDate[_tokenId] + saleDays >= block.timestamp, "Sale ended");

        address tokenSeller = nftAddress.ownerOf(_tokenId);
        _transfer(tokenSeller, msg.value);
        nftAddress.safeTransferFrom(tokenSeller, msg.sender, _tokenId);
        inSale[_tokenId] = false;
        emit Received(msg.sender, _tokenId, msg.value, address(this).balance);
    }

    function _transfer(address _to, uint256 _value) public payable returns (bool){}

    /**
    * Set Sale & Price
    */
    function beginSale(uint256 _tokenId, uint256 _currentPrice) public {
        require(nftAddress._exists(_tokenId), "This Address is not ERC721");
        require(_currentPrice > 0, 'Price error');
        require(inSale[_tokenId] == false, 'Already in sale');
        require(msg.sender == nftAddress.ownerOf(_tokenId), 'Youre not the owner');

        startSaleDate[_tokenId] = block.timestamp;
        inSale[_tokenId] = true;
        currentPrice[_tokenId] = _currentPrice;
    }

    /**
    * Update Price
    */
    function setCurrentPrice(uint256 _tokenId, uint256 _currentPrice) public {
        require(nftAddress._exists(_tokenId), "This Address is not ERC721");
        require(_currentPrice > 0, 'Price error');
        require(inSale[_tokenId] == true, 'Not in sale');
        require(startSaleDate[_tokenId] + saleDays <= block.timestamp, "Sale not ended");
        require(msg.sender == nftAddress.ownerOf(_tokenId), 'Youre not the owner');
        
        startSaleDate[_tokenId] = block.timestamp;
        currentPrice[_tokenId] = _currentPrice;
    }

    /**
    * Get Price
    */
    function getCurrentPrice(uint256 _tokenId) public returns (uint256) {
        require(nftAddress._exists(_tokenId), "This Address is not ERC721");
        return currentPrice[_tokenId];
    }

    function changeDaysSale(uint _days) public onlyOwner returns  (uint256) {
        saleDays = _days;
        return _days;
    }

    function addCategory(uint256 _idCategory, bytes32 _name) public onlyOwner {
        categoriesAvailable[_idCategory] = _name;
    }

    function removeCategory(uint256 _idCategory, bytes32 _name) public onlyOwner {
        require(bytes32(categoriesAvailable[_idCategory]).length>0, 'category not exists');
        delete categoriesAvailable[_idCategory];
    }

}