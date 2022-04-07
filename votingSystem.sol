// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Vote{

    struct Candidate{
        string name;
        string surname;
        int age;
        int voteCount;
    }

    Candidate can1;
    Candidate can2;
    Candidate can3;

    struct Voter{
        string name;
        string surname;
        int age;
        bool isVoted;
    }
    Voter voter;

    constructor() {
        can1 = Candidate("George","Philippe",20, 0);
        can2 = Candidate("Thedor","Gatemp", 45, 0);
        can3 = Candidate("Fred","Bullock", 65, 0);
    }

    function setVoter(string memory name, string memory surname, int age) public returns (string memory){
        if (age < 18){
            return "You are too young to vote!";
        }
        voter = Voter(name, surname, age, false);
        return "You can vote successfully now!";
    }

    function getVoterInfo() public view returns(Voter memory){
        return voter;
    }

    function getCandidateInfo(int candidate) public view returns(Candidate memory){
        if (candidate == 1)
            return can1;
        else if (candidate == 2)
            return can2;
        else if (candidate == 3)
            return can3;
        return can1;
    }

    function vote(int candidate) public returns (string memory) {
        if (keccak256(abi.encodePacked(voter.name)) == keccak256(abi.encodePacked("")))
            return "Please set your information correctly";
        
        if(voter.isVoted)
            return "You have already voted";

        setVoteCount(candidate);
        voter.isVoted = true;
        return string(abi.encodePacked("You have voted for ", getCandidateInfo(candidate).name));
    }

    function setVoteCount(int candidate) private {
        if (candidate == 1)
            can1.voteCount += 1;
        else if (candidate == 2)
            can2.voteCount += 1;
        else if (candidate == 3)
            can3.voteCount += 1;
    }

    function getVoteCount(int candidate) public view returns (int){
        return getCandidateInfo(candidate).voteCount;
    }

    function getVoteLeader() public view returns (string memory){
        if (can1.voteCount > can2.voteCount && can1.voteCount > can3.voteCount)
            return string(abi.encodePacked("Vote leader is currently ", can1.name));
        else if (can2.voteCount > can1.voteCount && can2.voteCount > can3.voteCount)
            return string(abi.encodePacked("Vote leader is currently ", can2.name));
        else if (can3.voteCount > can1.voteCount && can3.voteCount > can2.voteCount)
            return string(abi.encodePacked("Vote leader is currently ", can3.name));
        else if (can1.voteCount == can2.voteCount && can1.voteCount == can3.voteCount)
            return "All candidates have equal count of votes.";
        else if (can1.voteCount == can2.voteCount && can1.voteCount > can3.voteCount)
            return string(abi.encodePacked(string(abi.encodePacked(can1.name, " and ")), string(abi.encodePacked(can2.name, string(abi.encodePacked(" are equal and ", string(abi.encodePacked(can3.name, " is last."))))))));
        else if (can1.voteCount == can3.voteCount && can1.voteCount > can2.voteCount)
            return string(abi.encodePacked(string(abi.encodePacked(can1.name, " and ")), string(abi.encodePacked(can3.name, string(abi.encodePacked(" are equal and ", string(abi.encodePacked(can2.name, " is last."))))))));
        else if (can3.voteCount == can2.voteCount && can3.voteCount > can1.voteCount)
            return string(abi.encodePacked(string(abi.encodePacked(can3.name, " and ")), string(abi.encodePacked(can2.name, string(abi.encodePacked(" are equal and ", string(abi.encodePacked(can1.name, " is last."))))))));
    }
}
