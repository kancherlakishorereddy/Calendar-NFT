pragma solidity 0.8.11;
//SPDX-License-Identifier: MIT

import "./NFT.sol";
import "./Date.sol";

contract DaysNFT is NFT, Date {
    struct highestBid {
        address bidder;
        uint256 amount;
    }

    uint256 public constant bidDuration = 2;

    uint256 public totalPendingReturns = 0;

    event HighestBidIncreased(
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 amount
    );

    constructor(string memory name_, string memory symbol_) NFT(name_, symbol_){ }

    mapping(uint256 => highestBid) public highestBids;

    mapping(uint256 => mapping(address => uint256)) public pendingReturns;

    function bid(uint256 tokenId) public payable returns (bool) {
        require(
            isBiddingAllowed(tokenId),
            "Token not open for Bidding."
        );

        address bidder = highestBids[tokenId].bidder;
        uint amount = highestBids[tokenId].amount;
        require(amount < msg.value, "Bid Not High Enough");

        pendingReturns[tokenId][bidder] += amount;
        totalPendingReturns += amount;

        highestBids[tokenId] = highestBid(_msgSender(), msg.value);

        emit HighestBidIncreased(tokenId, _msgSender(), msg.value);

        return true;
    }

    function claim(uint256 tokenId) public returns (bool) {
        require(
            !isBiddingAllowed(tokenId),
            "Token cannot be claimed yet."
        );

        address bidder = highestBids[tokenId].bidder;

        require(
            bidder == _msgSender(),
            "Only the highest bidder can claim the Token."
        );

        _safeMint(bidder, tokenId);

        return true;
    }

    function withdraw(uint256 tokenId) public returns (bool) {
        uint256 amount = pendingReturns[tokenId][_msgSender()];

        pendingReturns[tokenId][_msgSender()] = 0;
        totalPendingReturns -= amount;

        (bool success, ) = _msgSender().call{value: amount}("");

        require(success, "Withdraw failed.");

        return true;
    }

    function thankYou(uint256 amount) public onlyOwner {
        require(
            amount < (address(this).balance - totalPendingReturns),
            "Don't you dare..."
        );

        _withdraw(amount);
    }

    function isBiddingAllowed(uint256 tokenId) internal view returns (bool) {
        uint256 currentYear;
        uint256 currentDayofYear;
        uint256 year;
        uint256 dayofYear;

        (currentYear, currentDayofYear) = parseTimestamp(block.timestamp);

        (year, dayofYear) = getDateFromTokenId(tokenId);

        bool isYearLeap = isLeapYear(year);
        bool isCurrentYearLeap = isLeapYear(currentYear);

        require(isValidTokenId(dayofYear, isYearLeap), "Not a valid Token Id.");

        if (currentYear == year) {
            if (
                currentDayofYear < dayofYear &&
                currentDayofYear + bidDuration < dayofYear
            ) {
                return false;
            }
            if (
                dayofYear < currentDayofYear &&
                dayofYear + bidDuration < currentDayofYear
            ) {
                return false;
            }
        } else {
            uint256 limit;
            if (currentYear + 1 == year) {
                if (isCurrentYearLeap) {
                    limit = (currentDayofYear + 2) % 366;
                } else {
                    limit = (currentDayofYear + 2) % 365;
                }

                if (dayofYear > limit) {
                    return false;
                } else {
                    return true;
                }
            } else if (year + 1 == currentYear) {
                if (isYearLeap) {
                    limit = (dayofYear + 2) % 366;
                } else {
                    limit = (dayofYear + 2) % 365;
                }

                if (currentDayofYear > limit) {
                    return false;
                } else {
                    return true;
                }
            } else {
                return false;
            }
        }

        return true;
    }

    function isValidTokenId(uint256 dayofYear, bool isYearLeap)
        internal
        pure
        returns (bool)
    {
        if (isYearLeap) {
            return dayofYear <= 365;
        } else {
            return dayofYear <= 364;
        }
    }

    function getDateFromTokenId(uint256 tokenId)
        internal
        pure
        returns (uint256 year, uint256 day)
    {
        day = tokenId % 1000;

        tokenId = tokenId / 1000;

        year = tokenId;
    }
}
