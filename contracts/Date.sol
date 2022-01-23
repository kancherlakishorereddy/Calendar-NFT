pragma solidity 0.8.11;
//SPDX-License-Identifier: MIT

contract Date {
    
        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint year) internal pure returns (bool) {
            if (year % 4 != 0) {
                    return false;
            }
            if (year % 100 != 0) {
                    return true;
            }
            if (year % 400 != 0) {
                    return false;
            }
            return true;
        }

        function leapYearsBefore(uint year) internal pure returns (uint) {
            year -= 1;
            return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint month, uint year) internal pure returns (uint) {
            if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                    return 31;
            }
            else if (month == 4 || month == 6 || month == 9 || month == 11) {
                    return 30;
            }
            else if (isLeapYear(year)) {
                    return 29;
            }
            else {
                    return 28;
            }
        }

        function parseTimestamp(uint timestamp) internal pure returns (uint year, uint day) {
            uint secondsAccountedFor = 0;
            uint buf;

            // Year
            year = getYear(timestamp);
            buf = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

            secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
            secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - buf);

            // Day of year
            uint secondsRemaining = timestamp - secondsAccountedFor;
            
            day = secondsRemaining / DAY_IN_SECONDS;

        }

        function getYear(uint timestamp) internal pure returns (uint year) {
            uint secondsAccountedFor = 0;
            uint numLeapYears;

            // Year
            year = uint(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
            numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

            secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
            secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

            while (secondsAccountedFor > timestamp) {
                    if (isLeapYear(uint(year - 1))) {
                            secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                    }
                    else {
                            secondsAccountedFor -= YEAR_IN_SECONDS;
                    }
                    year -= 1;
            }
            return year;
        }

        function getHour(uint timestamp) internal pure returns (uint) {
            return uint((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) internal pure returns (uint) {
            return uint((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) internal pure returns (uint) {
            return uint(timestamp % 60);
        }

        function getWeekday(uint timestamp) internal pure returns (uint) {
            return uint((timestamp / DAY_IN_SECONDS + 4) % 7);
        }
}