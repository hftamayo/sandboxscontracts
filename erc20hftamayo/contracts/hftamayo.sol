//@notice este video fue utilizado para seguir el proceso: https://www.youtube.com/watch?v=PdNxXGGWJRI

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.3/token/ERC20/ERC20.sol";

contract HalftamayoToken is ERC20 {
    constructor() ERC20("HalftamayoToken", "HTAMAYO") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}
