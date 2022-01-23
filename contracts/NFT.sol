pragma solidity 0.8.11;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Pausable, Ownable {

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_){}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer (
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _withdraw(uint amount) internal onlyOwner {

        (bool success, ) = owner().call{value : amount}("");

        require(success, "Withdraw failed.");
    }
}