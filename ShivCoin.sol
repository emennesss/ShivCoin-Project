// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SHIVcoin {
    string public name = "SHIVcoin";
    string public symbol = "SHIV";
    uint256 public totalSupply;
    uint256 public CREATOR_ALLOCATION = 300000000 * 10**18; // 300 million
    uint256 public PUBLIC_ALLOCATION = 700000000 * 10**18; // 700 million
    uint256 public MAX_SUPPLY = 2000000000 * 10**18; // 2 billion
    uint256 public MINT_CHALLENGE_TIME = 1 hours; // 1 hour limit for minting challenge
    uint256 public tokensMintedInCurrentPeriod = 0;
    uint256 public lastMintTime;

    address public creator;
    
    // Mapping to track balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Mapping to track token lock time (for token locking functionality)
    mapping(address => uint256) private unlockTime;

    modifier onlyCreator() {
        require(msg.sender == creator, "Only the creator can call this");
        _;
    }

    modifier canMint() {
        require(tokensMintedInCurrentPeriod < PUBLIC_ALLOCATION, "Public allocation reached for this period");
        _;
    }

    constructor() {
        creator = msg.sender;
        totalSupply = 0;
        lastMintTime = block.timestamp;
    }

    // Function to allow minting for the creator
    function mintForCreator(uint256 amount) public onlyCreator {
        require(totalSupply + amount <= MAX_SUPPLY, "Minting would exceed max supply");
        totalSupply += amount;
    }

    // Public minting function
    function mint(uint256 amount) public canMint {
        require(block.timestamp - lastMintTime >= MINT_CHALLENGE_TIME, "You can only mint once every hour");

        if (totalSupply + amount > MAX_SUPPLY) {
            revert("Minting would exceed max supply");
        }

        totalSupply += amount;
        tokensMintedInCurrentPeriod += amount;
        lastMintTime = block.timestamp;

        _balances[msg.sender] += amount;
    }

    // Burn function to allow anyone to burn their own tokens
    function burn(uint256 amount) public {
        require(amount <= _balances[msg.sender], "You do not have enough tokens to burn");
        
        _balances[msg.sender] -= amount;
        totalSupply -= amount;
    }

    // Getter function for total supply (automatically created for public variable)
    // function getTotalSupply() public view returns (uint256) {
    //     return totalSupply;
    // }

    // Optional ERC20 functions

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // Transfer function to move tokens from one account to another
    function transfer(address to, uint256 amount) public returns (bool) {
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }

    // Approve a spender to spend on behalf of the owner
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    // Transfer tokens from a spender to a recipient
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        return true;
    }

    // Function to lock tokens temporarily (for certain time)
    function lockTokens(address to, uint256 time) public {
        unlockTime[to] = block.timestamp + time;  // Lock the tokens for a specified time
    }

    // Function to check if tokens are unlocked
    function checkUnlock(address account) public view returns (bool) {
        return block.timestamp >= unlockTime[account];
    }

    // Get function for the creator's allocation
    function creatorAllocation() public view returns (uint256) {
        return CREATOR_ALLOCATION;
    }

    // Get function for public allocation
    function publicAllocation() public view returns (uint256) {
        return PUBLIC_ALLOCATION;
    }
}
