// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error totalSupplyExceed();
error pleaseSendTokenPrice();
error TransferFaild();
error pleaseEnterLessPrice();

contract hhcwToken is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20("HHCWToken", "HHCWToken") {}

    uint256 public supply = 20_000_000 ether;
    uint256 public tokenPrice = 1;//wei

    function setTokenPrice(uint256 _amount) public onlyOwner {
    if(_amount>100){
            revert pleaseEnterLessPrice();
        }
        tokenPrice = _amount;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 _amount) public payable {
    if ((totalSupply() + _amount) > supply) {
            revert totalSupplyExceed();
        }
    if(msg.value < (_amount*tokenPrice)){
            revert pleaseSendTokenPrice();   
        }
        _mint(to, _amount);
    }

    function airdrop(address[] memory recipients, uint256[] memory amounts) public onlyOwner {
        require(recipients.length == amounts.length, "Recipients and amounts arrays must have same length");
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 amount = amounts[i];
            require(recipient != address(0), "Recipient cannot be zero address");
            require(amount > 0, "Amount must be greater than zero");
            if ((totalSupply() + amount) > supply) {
            revert totalSupplyExceed();
            }
            _mint(recipient,amount);
        }
    }



    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

     //This is withdraw Function, OnlyOwner Can call this Function
    function withdraw()public onlyOwner{
        (bool success,)=msg.sender.call{value:address(this).balance}("");
        if(!success){
        revert TransferFaild();
        } 
    }
}