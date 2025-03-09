// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract StakingToken is ERC20, Ownable {
    error StakingToken__StakingTokenCannotStakeZero();
    error StakingToken__StakingTokenNotEnoughTokens();
    error StakingToken__StakingTokenNotEnoughRewards();
    error StakingToken__StakingTokenThereIsNoStake();

    event TokensStaked(address indexed user, uint256 indexed amount);
    event TokensWithdrawn(address indexed user, uint256 indexed amount);
    event RewardClaimed(address indexed user, uint256 indexed amount);

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public rewardBalance;
    mapping(address => uint256) public stakingTimestamp;

    uint256 public constant REWARD_RATE = 50;
    
    constructor() ERC20("Staking Token", "STK") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function stake(uint256 amount) external {
        if(amount <= 0) {
            revert StakingToken__StakingTokenCannotStakeZero();
        }

        if(balanceOf(msg.sender) <= amount) {
            revert StakingToken__StakingTokenNotEnoughTokens();
        }

        _transfer(msg.sender, address(this), amount);

        stakedBalance[msg.sender] += amount;
        stakingTimestamp[msg.sender] = block.timestamp;

        emit TokensStaked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        if(stakedBalance[msg.sender] <= 0) {
            revert StakingToken__StakingTokenThereIsNoStake();
        }

        updateRewards(msg.sender);

        stakedBalance[msg.sender] -= amount;

        _transfer(address(this), msg.sender, amount);

        emit TokensWithdrawn(msg.sender, amount);
    }

    function claimRewards(uint256 amount) public {
        updateRewards(msg.sender);

        uint256 rewards = rewardBalance[msg.sender];
        if(rewards <= amount) {
            revert StakingToken__StakingTokenNotEnoughRewards();
        }

        rewardBalance[msg.sender] -= amount;
        stakedBalance[msg.sender] += amount;

        emit RewardClaimed(msg.sender, amount);
    }

    function updateRewards(address user) internal {
        uint256 staked = stakedBalance[user];
        if (staked > 0) {
            uint256 timeStaked = block.timestamp - stakingTimestamp[user];
            uint256 rewards = (staked * timeStaked * REWARD_RATE) / 100;
            rewardBalance[user] += rewards;
            stakingTimestamp[user] = block.timestamp;
        }
    }

    function getStakedBalance(address user) external view returns(uint256 balance) {
        balance = stakedBalance[user];
        return balance;
    }

    function getRewardBalance(address user) external view returns(uint256 balance) {
        balance = rewardBalance[user];
        return balance;
    }
}