// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {StakingToken} from "../src/StakingToken.sol";
import {Test} from "forge-std/Test.sol";

contract StakingTokenTest is Test {
    StakingToken stakingToken;
    address user1 = makeAddr("user1");

    function setUp() public {
        stakingToken = new StakingToken();
        stakingToken.transfer(user1, 1000 ether);
        vm.prank(user1);
        stakingToken.approve(address(stakingToken), 1000 ether);
    }

    function testStaking() public {
        vm.startPrank(user1);
        stakingToken.stake(100 ether);
        vm.stopPrank();

        uint256 stakingBalance = stakingToken.getStakedBalance(user1);

        assertEq(stakingBalance, 100 ether);
        assertEq(stakingToken.balanceOf(user1), 900 ether);
        assertEq(stakingToken.balanceOf(address(stakingToken)), 100 ether);
    }

    function testUnstaking() public {
        vm.startPrank(user1);
        stakingToken.stake(100 ether);
        vm.warp(block.timestamp + 10);
        stakingToken.unstake(50 ether);
        vm.stopPrank();

        uint256 stakingBalance = stakingToken.getStakedBalance(user1);
        assertEq(stakingBalance, 50 ether);
        assertEq(stakingToken.balanceOf(user1), 950 ether);
    }

    function testRewardsAccumulate() public {
        vm.startPrank(user1);
        stakingToken.stake(100 ether);
        uint256 stakingBalance = stakingToken.getStakedBalance(user1);
        vm.warp(block.timestamp + 10000);
        stakingToken.claimRewards(50 ether);
        uint256 finalStakingBalance = stakingToken.getStakedBalance(user1);
        vm.stopPrank();

        assertEq(finalStakingBalance, stakingBalance + 50 ether);
    }
}
