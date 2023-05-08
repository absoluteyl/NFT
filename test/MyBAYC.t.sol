// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { MyBAYC } from "../src/MyBAYC.sol";

contract MyBaYCTest is Test {
  string public name;
  string public symbol;
  MyBAYC public myBAYC;
  address public user1;
  address public user2;
  uint256 public amount;

  function setUp() public {
    amount = 5;
    name = "My Bored Ape Yacht Club";
    symbol = "BAYC";
    myBAYC = new MyBAYC(name, symbol);
    user1 = makeAddr("user1");
    user2 = makeAddr("user2");
  }

  function testNameAndSymbol() public {
    assertEq(myBAYC.name(), name);
    assertEq(myBAYC.symbol(), symbol);
  }

  modifier mintByAmount() {
    for (uint i = 0; i < amount;) {
      myBAYC.mint(user1, i);
      unchecked { ++i; }
    }
    _;
  }

  function testMint() public mintByAmount {
    assertEq(myBAYC.balanceOf(user1), amount);
  }

  function testTransferNonFirstNFT(uint tokenId) public mintByAmount {
    vm.assume(tokenId > 0 && tokenId < amount);
    vm.prank(user1);
    myBAYC.safeTransferFrom(user1, user2, tokenId);
    assertEq(myBAYC.ownerOf(tokenId), user2);
  }

  function testTransferFirstNFT() public mintByAmount {
    vm.prank(user1);
    myBAYC.safeTransferFrom(user1, user2, 0);
    assertEq(myBAYC.ownerOf(0), user2);
  }

  function testApprove(uint256 tokenId) public mintByAmount {
    vm.assume(tokenId < amount);
    vm.prank(user1);
    myBAYC.approve(user2, tokenId);
    assertEq(myBAYC.getApproved(tokenId), user2);
  }
}
