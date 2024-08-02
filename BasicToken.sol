// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import './SafeMath.sol';

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
abstract contract ERC20Basic {
  function totalSupply() public view virtual returns (uint);
  function balanceOf(address who) public view virtual returns (uint256);
  function transfer(address to, uint256 value) public virtual returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
abstract contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  uint256 private _totalSupply;

  /**
  * @dev Returns the total number of tokens in existence.
  */
  function totalSupply() public view override returns (uint) {
    return _totalSupply;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public override returns (bool) {
    require(_to != address(0), "Transfer to the zero address");
    require(_value <= balances[msg.sender], "Insufficient balance");

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the balance of.
  * @return balance An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view override returns (uint256 balance) {
    return balances[_owner];
  }
}
