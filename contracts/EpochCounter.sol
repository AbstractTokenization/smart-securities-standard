pragma solidity ^0.4.18;

import { SafeMath } from "./zeppelin-solidity/contracts/math/SafeMath.sol";

/** @title EpochCounter organizes tokens into epochs in order to make dividend
* payments, etc. possible. */
contract EpochCounter {
  using SafeMath for uint256;
  /** values 
    * @param {address} token
    * @param {address} user
    * @param {uint256} epochNumber
    * @returns {uint256} epochBalance
    */
  mapping(address => mapping(address => mapping(uint256 => uint256))) public values;

  /** epoch
    * @param {address} token
    * @return {uint256} epochNumber
    */
  mapping(address => uint256) public epoch;

  /** advance
    * @param {address} token
    * @param {address} user
    * @param {uint256} amount the amount to roll forward
    */
  function advance(
    address token, 
    address user, 
    uint256 epochSource, 
    uint256 epochTarget, 
    uint256 amount
  ) public {
    // TODO: Decide access control
    require(epochSource > epochTarget);
    uint256 sourceQ = values[token][user][epochSource];
    require(sourceQ >= amount);
    values[token][user][epochSource].sub(amount);
    values[token][user][epochTarget].add(amount);
  }

  /** next
    * @param {address} token
    */
  function next(address token) public {
    require(msg.sender == token);
    epoch[token]++;
  }
}
