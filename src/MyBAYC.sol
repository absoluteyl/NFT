// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC721 {
  function balanceOf(address owner) external view returns (uint balance);
  function ownerOf(uint tokenId) external view returns (address owner);

  function safeTransferFrom(address from, address to, uint tokenId) external;
  function transferFrom(address from, address to, uint tokenId) external;

  function approve(address to, uint tokenId) external;
  function getApproved(uint tokenId) external view returns (address operator);

  function isApprovedForAll(
    address owner,
    address operator
  ) external view returns (bool);
}

interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint tokenId,
    bytes calldata data
  ) external returns (bytes4);
}

interface IERC721Metadata {
  function name() external view returns (string memory _name);
  function symbol() external view returns (string memory _symbol);
}

interface IERC721Enumerable {
    function totalSupply() external view returns (uint256);
    // function tokenByIndex(uint256 _index) external view returns (uint256);
    // function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

contract MyBAYC is IERC721, IERC721Metadata, IERC721Enumerable {
  string public name;
  string public symbol;
  uint256 public totalSupply;

  constructor(string memory _name, string memory _symbol) {
    name = _name;
    symbol = _symbol;
  }

  event Transfer(address indexed from, address indexed to, uint indexed id);
  event Approval(address indexed owner, address indexed spender, uint indexed id);
  event ApprovalForAll(
      address indexed owner,
      address indexed operator,
      bool approved
  );

  // Mapping from token ID to owner address
  mapping(uint => address) internal _ownerOf;

  // Mapping owner address to token count
  mapping(address => uint) internal _balanceOf;

  // // Mapping from token ID to approved address
  mapping(uint => address) internal _approvals;

  // // Mapping from owner to operator approvals
  mapping(address => mapping(address => bool)) public isApprovedForAll;

  function ownerOf(uint id) external view returns (address owner) {
    owner = _ownerOf[id];
    require(owner != address(0), "token doesn't exist");
  }

  function balanceOf(address owner) external view returns (uint) {
    require(owner != address(0), "owner = zero address");
    return _balanceOf[owner];
  }

  function approve(address spender, uint id) external {
    address owner = _ownerOf[id];
    require(
      msg.sender == owner || isApprovedForAll[owner][msg.sender],
      "not authorized"
    );

    _approvals[id] = spender;

    emit Approval(owner, spender, id);
  }

  function getApproved(uint id) external view returns (address) {
    require(_ownerOf[id] != address(0), "token doesn't exist");
    return _approvals[id];
  }

  function _isApprovedOrOwner(
    address owner,
    address spender,
    uint id
  ) internal view returns (bool) {
    return (spender == owner ||
      isApprovedForAll[owner][spender] ||
      spender == _approvals[id]);
  }

  function transferFrom(address from, address to, uint id) public {
    require(from == _ownerOf[id], "from != owner");
    require(to != address(0), "transfer to zero address");

    require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

    _balanceOf[from]--;
    _balanceOf[to]++;
    _ownerOf[id] = to;

    delete _approvals[id];

    emit Transfer(from, to, id);
  }

  function safeTransferFrom(address from, address to, uint id) external {
    transferFrom(from, to, id);

    require(
      to.code.length == 0 ||
        IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") ==
        IERC721Receiver.onERC721Received.selector,
      "unsafe recipient"
    );
  }

  function mint(address to, uint id) external {
    _mint(to, id);
  }

  function _mint(address to, uint id) private {
    require(to != address(0), "mint to zero address");
    require(_ownerOf[id] == address(0), "already minted");

    _balanceOf[to]++;
    totalSupply++;
    _ownerOf[id] = to;

    emit Transfer(address(0), to, id);
  }
}
