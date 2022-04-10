// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Vote{

    //storage
    uint256 public candidateAmount = 0;
    mapping(uint256 => Candidate) public candidates;
    uint256 public candidateLimit = 5;

    address payable public desk;

    uint deployDate;
    bool voteDone = false;
    
    modifier onlyVoter() {
        require(msg.sender == voter.wallet, "Only voter can call this method!");
        _;
    }
    
    function bet() onlyVoter external payable {
        desk.transfer(address(this).balance);
    }

    struct Candidate{
        string name;
        string surname;
        int age;
        int voteCount;
        Voter[] votes;
        address wallet;
    }

    struct Voter{
        string name;
        string surname;
        int age;
        bool isVoted;
        address wallet;
    }

    Voter public voter;
    Voter[] public voters;

    constructor(address payable _desk) {
        desk = _desk;
    }

    function addVoter(string memory name, string memory surname, int age, address wallet) public returns (string memory){
        if (age < 18){
            return "You are too young to vote!";
        }
        for(uint256 i = 0; i < voters.length; i++){
            if (wallet == voters[i].wallet){
                voter = voters[i];
                return "This voter is already added!\nSet the current voter to it.";
            }
        }
        voter = Voter(name, surname, age, false, wallet);
        voters.push(voter);
        return "You can vote successfully now!";
    }

    function vote(uint256 candidate) public returns (string memory) {
        if (block.timestamp >= (deployDate + 30 seconds)){
            voteDone = true;
            return "You can't vote now the election is completed";
        }
        if (candidateAmount != 4)
            return "Election will start once the candidates are filled!";
        if (keccak256(abi.encodePacked(voter.name)) == keccak256(abi.encodePacked("")))
            return "Please set your information correctly";
        
        if(voter.isVoted)
            return "You have already voted";
        if (!voteDone){
            setVoteCount(candidate);
            voter.isVoted = true;
            return string(abi.encodePacked("You have voted for ", candidates[candidate].name));
        }

        return "Election is done you can't vote anymore get the results from getElectionLeader!";
    }

    function addCandidate (string memory name, string memory surname, int age, address wallet) public returns (string memory){
        if (age <= 18)
            return "You are too young to be a candidate!";
        if(candidateAmount == candidateLimit){
            deployDate = block.timestamp;
            return "Maximum candidate amount is reached!";
        }
        
        for(uint256 i = 0; i < candidateAmount; i++){
            if (wallet == candidates[i].wallet){
                return "This candidate is already added!";
            }
        }

        Candidate storage candidate = candidates[candidateAmount];
        candidate.name = name;
        candidate.surname = surname;
        candidate.age = age;
        candidateAmount += 1;
        return "Candidate successfully added.";
    }

    function setVoteCount(uint256 candidate) private {
        candidates[candidate].voteCount += 1;
    }

    function getElectionLeader() public returns (string memory){
        int maxVoteCount = 0;
        uint256 maxVoted = 0;
        uint256 maxVoted2 = 0;
        bool draw = false;
        if(block.timestamp >= (deployDate + 10 minutes)){
            voteDone = true;
        }
        for (uint256 i = 0; i < candidateAmount; i++){
            if (candidates[i].voteCount > maxVoteCount){
                maxVoteCount = candidates[i].voteCount;
                maxVoted = i;
            } else if (candidates[i].voteCount >= maxVoteCount){
                maxVoted2 = i;
                draw = true;
            }
        }
        if (draw)
            return string(abi.encodePacked("Election is a draw, ", abi.encodePacked(candidates[maxVoted].name, abi.encodePacked(" and ", abi.encodePacked(candidates[maxVoted2].name, " won!")))));
        
        return string(abi.encodePacked("Election leader is currently ", candidates[maxVoted].name));
        /*
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
            return string(abi.encodePacked(string(abi.encodePacked(can3.name, " and ")), string(abi.encodePacked(can2.name, string(abi.encodePacked(" are equal and ", string(abi.encodePacked(can1.name, " is last.")))))))); */
    }
}
