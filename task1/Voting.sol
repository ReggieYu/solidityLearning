// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//创建一个名为Voting的合约，包含以下功能：
//一个mapping来存储候选人的得票数
//一个vote函数，允许用户投票给某个候选人
//一个getVotes函数，返回某个候选人的得票数
//一个resetVotes函数，重置所有候选人的得票数
contract Voting {
    // 存储候选人得票数的映射
    mapping(bytes32 => uint256) public votesReceived;
    // 候选人名单
    bytes32[] public candidateList;

    // 构造函数初始化候选人
    constructor(bytes32[] memory _candidates) {
        candidateList = _candidates;
    }

    // 投票函数
    function vote(bytes32 candidate) public {
        require(validCandidate(candidate), "Invalid candidate");
        votesReceived[candidate] += 1;
    }

    // 查询得票数
    function getVotes(bytes32 candidate) public view returns (uint256) {
        return votesReceived[candidate];
    }

    // 重置所有候选人票数
    function resetVotes() public {
        for(uint i = 0; i < candidateList.length; i++) {
            votesReceived[candidateList[i]] = 0;
        }
    }

    // 验证候选人有效性
    function validCandidate(bytes32 candidate) private view returns (bool) {
        for(uint i = 0; i < candidateList.length; i++) {
            if (candidateList[i] == candidate) {
                return true;
            }
        }
        return false;
    }
}