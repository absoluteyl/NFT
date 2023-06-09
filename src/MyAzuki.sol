// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/console.sol";
import "ERC721A/ERC721A.sol";

contract MyAzuki is ERC721A {
  constructor() ERC721A("My Azuki", "AZUKI") {}

  function mint(uint256 quantity) external payable {
      // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
      _mint(msg.sender, quantity);
  }
}
