// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./StandardTokenWithFees.sol";
import "./Pausable.sol";
import "./BlackList.sol";

abstract contract UpgradedStandardToken is StandardToken {
    uint public _totalSupply;

    function transferByLegacy(address from, address to, uint value) public virtual returns (bool);
    function transferFromByLegacy(address sender, address from, address spender, uint value) public virtual returns (bool);
    function approveByLegacy(address from, address spender, uint value) public virtual returns (bool);
    function increaseApprovalByLegacy(address from, address spender, uint addedValue) public virtual returns (bool);
    function decreaseApprovalByLegacy(address from, address spender, uint subtractedValue) public virtual returns (bool);
}

contract WusdToken is Pausable, StandardTokenWithFees, BlackList {
    address public upgradedAddress;
    bool public deprecated;
    
    event DestroyedBlackFunds(address indexed _blackListedUser, uint _balance);
    event Issue(uint amount);
    event Redeem(uint amount);
    event Deprecate(address newAddress);
    
    constructor(uint256 _initialSupply, string memory _name, string memory _symbol, uint8 _decimals) {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[msg.sender] = _initialSupply;
        deprecated = false;
    }

    function transfer(address _to, uint _value) public whenNotPaused override returns (bool) {
        require(!isBlackListed[msg.sender], "Sender is blacklisted");
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
        } else {
            return super.transfer(_to, _value);
        }
    }

    function balanceOf(address who) public view override returns (uint) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }

    function oldBalanceOf(address who) public view returns (uint) {
        return super.balanceOf(who);
    }

    function approve(address _spender, uint _value) public whenNotPaused override returns (bool) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);
        } else {
            return super.approve(_spender, _value);
        }
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused override returns (bool) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).increaseApprovalByLegacy(msg.sender, _spender, _addedValue);
        } else {
            return super.increaseApproval(_spender, _addedValue);
        }
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused override returns (bool) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).decreaseApprovalByLegacy(msg.sender, _spender, _subtractedValue);
        } else {
            return super.decreaseApproval(_spender, _subtractedValue);
        }
    }

    function totalSupply() public view override returns (uint) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).totalSupply();
        } else {
            return _totalSupply;
        }
    }

    function issue(uint amount) public onlyOwner {
        require(balances[owner] + amount >= balances[owner], "Overflow");
        balances[owner] += amount;
        _totalSupply += amount;
        emit Issue(amount);
        emit Transfer(address(0), owner, amount);
    }

    function redeem(uint amount) public onlyOwner {
        require(balances[owner] >= amount, "Insufficient balance");
        _totalSupply -= amount;
        balances[owner] -= amount;
        emit Redeem(amount);
        emit Transfer(owner, address(0), amount);
    }

    function destroyBlackFunds(address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser], "User not blacklisted");
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }

    function deprecate(address _upgradedAddress) public onlyOwner {
        require(_upgradedAddress != address(0), "Invalid address");
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        emit Deprecate(_upgradedAddress);
    }

}
