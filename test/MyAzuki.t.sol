// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { MyAzuki } from "../src/MyAzuki.sol";

contract MyAzukiTest is Test {
  string public name;
  string public symbol;
  MyAzuki public myAzuki;
  address public user1;
  address public user2;
  uint256 public amount;

  function setUp() public {
    amount = 5;
    name = "My Azuki";
    symbol = "AZUKI";
    myAzuki = new MyAzuki();
    user1 = makeAddr("user1");
    user2 = makeAddr("user2");
  }

  function testNameAndSymbol() public {
    assertEq(myAzuki.name(), name);
    assertEq(myAzuki.symbol(), symbol);
  }

  modifier mintByAmount() {
    vm.prank(user1);
    myAzuki.mint(amount);
    _;
  }

  function testMint() public mintByAmount {
    assertEq(myAzuki.balanceOf(user1), amount);
  }

  function testTransferNonFirstNFT(uint256 tokenId) public mintByAmount  {
    vm.assume(tokenId > 0 && tokenId < amount);
    vm.prank(user1);
    myAzuki.safeTransferFrom(user1, user2, tokenId);
    assertEq(myAzuki.ownerOf(tokenId), user2);
  }

  function testTransferFirstNFT() public mintByAmount  {
    vm.prank(user1);
    myAzuki.safeTransferFrom(user1, user2, 0);
    assertEq(myAzuki.ownerOf(0), user2);
  }

  function testApprove(uint256 tokenId) public mintByAmount {
    vm.assume(tokenId < amount);
    vm.prank(user1);
    myAzuki.approve(user2, tokenId);
    assertEq(myAzuki.getApproved(tokenId), user2);
  }
}
