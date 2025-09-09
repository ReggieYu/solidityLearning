// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//����һ����ΪVoting�ĺ�Լ���������¹��ܣ�
//һ��mapping���洢��ѡ�˵ĵ�Ʊ��
//һ��vote�����������û�ͶƱ��ĳ����ѡ��
//һ��getVotes����������ĳ����ѡ�˵ĵ�Ʊ��
//һ��resetVotes�������������к�ѡ�˵ĵ�Ʊ��
contract Voting {
    // �洢��ѡ�˵�Ʊ����ӳ��
    mapping(bytes32 => uint256) public votesReceived;
    // ��ѡ������
    bytes32[] public candidateList;

    // ���캯����ʼ����ѡ��
    constructor(bytes32[] memory _candidates) {
        candidateList = _candidates;
    }

    // ͶƱ����
    function vote(bytes32 candidate) public {
        require(validCandidate(candidate), "Invalid candidate");
        votesReceived[candidate] += 1;
    }

    // ��ѯ��Ʊ��
    function getVotes(bytes32 candidate) public view returns (uint256) {
        return votesReceived[candidate];
    }

    // �������к�ѡ��Ʊ��
    function resetVotes() public {
        for(uint i = 0; i < candidateList.length; i++) {
            votesReceived[candidateList[i]] = 0;
        }
    }

    // ��֤��ѡ����Ч��
    function validCandidate(bytes32 candidate) private view returns (bool) {
        for(uint i = 0; i < candidateList.length; i++) {
            if (candidateList[i] == candidate) {
                return true;
            }
        }
        return false;
    }
}