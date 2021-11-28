// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AddAndSubtract {
    int public balance;

    constructor() {
        balance = 0;
    }

    function add() public {
        balance += 5;
    }

    function subtract() public {
        balance -= 5;
    }
}
