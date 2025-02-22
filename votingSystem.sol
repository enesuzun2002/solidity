// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Vote{

    // Adayların sayı sınırı
    uint256 public candidateLimit = 2;
    // En yüksek oyu alan adayları kaydeder
    uint256 maxVoted = 0;
    uint256 maxVoted2 = 0;
    // Seçimin berabere bitmesi durumu
    bool draw = false;

    // Masa Adresini saklar
    address payable public desk;

    // Kontratın deploy edildiği zamanı gösterir
    uint deployDate;
    // Seçim bitti mi bitmedi mi kontrol eder
    bool voteDone = false;
    
    // Çağrıldığı fonksiyonların sadece seçmen tarafından çalıştırılmış olmasını kontrol eder
    modifier onlyVoter() {
        require(msg.sender == voter.wallet, "Only voter can call this method!");
        _;
    }

    // Çağrıldığı fonksiyonların sadece masa tarafından çalıştırılmış olmasını kontrol eder
    modifier onlyDesk() {
        require(msg.sender == desk, "Only desk can call this method!");
        _;
    }

    // Aday'ın verilerini tutan struct yapısı
    struct Candidate{
        string name;
        string surname;
        int age;
        int voteCount;
        address payable wallet;
        uint256 betAmount;
    }

    // Seçmenin verilerini tutan struct yapısı
    struct Voter{
        string name;
        string surname;
        int age;
        bool isVoted;
        address payable wallet;
        uint256 votedTo;
        uint256 betAmount;
    }

    // Seçmen oluşturma
    Voter public voter;
    // Yeni eklenen seçmenlerin kaydedileceği dizi
    Voter[] public voters;

    // Yeni eklenen adayların kaydedileceği dizi
    Candidate[] public candidates;

    // Yapıcı metod
    constructor(address payable _desk) payable {
        desk = _desk;
    }

    // Bahis fonksiyonu
    function bet(uint256 candidate) onlyVoter external payable {
        for(uint256 i = 0; i < voters.length; i++){
            if (msg.sender == voters[i].wallet)
                if (voters[i].betAmount == 0 && voters[i].isVoted && voters[i].votedTo == candidate)
                    voters[i].betAmount = address(this).balance;
                else
                    return;
            else
                return;
        }
        candidates[candidate].betAmount += address(this).balance;
        desk.transfer(address(this).balance);
    }

    // Yeni seçmen ekler
    function addVoter(string memory name, string memory surname, int age, address payable wallet) public returns (string memory){
        if (age < 18)
            return "You are too young to vote!";

        if (age >= 65)
            return "You are too old to vote!";
        
        for(uint256 i = 0; i < voters.length; i++){
            if (wallet == voters[i].wallet){
                voter = voters[i];
                return "This voter is already added! Set the current voter to it.";
            }
        }
        voter = Voter(name, surname, age, false, wallet, 0, 0);
        voters.push(voter);
        return "You can vote successfully now!";
    }

    // Oy verir
    function vote(uint256 candidate) onlyVoter public returns (string memory) {
        if(msg.sender != voter.wallet){
            for(uint256 i = 0; i < voters.length; i++){
                if (msg.sender == voters[i].wallet){
                    voter = voters[i];
                }
            }
            if (msg.sender != voter.wallet)
                return "You aren't a voter!";
        }
        if (block.timestamp >= (deployDate + 3 minutes)){
            voteDone = true;
            return "You can't vote now the election is completed";
        }
        if (candidates.length != candidateLimit)
            return "Election will start once the candidates are filled!";
        if (keccak256(abi.encodePacked(voter.name)) == keccak256(abi.encodePacked("")))
            return "Please set your information correctly";
        
        if(voter.isVoted)
            return "You have already voted";
        if (!voteDone){
            setVoteCount(candidate);
            voter.votedTo = candidate;
            voter.isVoted = true;
            return string(abi.encodePacked("You have voted for ", candidates[candidate].name));
        }

        return "Election is done you can't vote anymore get the results from getElectionLeader!";
    }

    // Aday ekler
    function addCandidate (string memory name, string memory surname, int age, address payable wallet) public returns (string memory){
        if (age <= 18)
            return "You are too young to be a candidate!";

        if (age >= 65)
            return "You are too old to be a candidate!";

        for(uint256 i = 0; i < candidates.length; i++){
            if (wallet == candidates[i].wallet)
                return "This candidate is already added!";
        }

        if(candidates.length == candidateLimit){
            deployDate = block.timestamp;
            return "Maximum candidate amount is reached!";
        }

        Candidate memory can = Candidate(name, surname, age, 0, wallet, 0);
        candidates.push(can);
        return "Candidate successfully added.";
    }

    // Aday'ın oy sayısını arttırır.
    function setVoteCount(uint256 candidate) private {
        candidates[candidate].voteCount += 1;
    }

    // Sadece masa tarafından çalıştırılabilen seçim bitince bahis ödüllerini yatıran fonksiyon
    function claimBet() onlyDesk public payable {
        if(voteDone){
            getElectionLeader();
            if(draw){
                candidates[maxVoted].wallet.transfer(candidates[maxVoted].betAmount / 4);
                candidates[maxVoted2].wallet.transfer(candidates[maxVoted2].betAmount / 4);
            }
            candidates[maxVoted].wallet.transfer(candidates[maxVoted].betAmount / 4);
            for(uint256 i = 0; i < voters.length; i++){
                if (voters[i].votedTo == maxVoted || draw && voters[i].votedTo == maxVoted2)
                    voters[i].wallet.transfer(voters[i].betAmount * 2);
            }
        }
    }

    // Seçim liderini döndürür
    function getElectionLeader() public returns (string memory){
        int maxVoteCount = 0;
        for (uint256 i = 0; i < candidates.length; i++){
            if (candidates[i].voteCount > maxVoteCount){
                maxVoteCount = candidates[i].voteCount;
                maxVoted = i;
                draw = false;
            } else if (candidates[i].voteCount >= maxVoteCount){
                maxVoted2 = i;
                draw = true;
            }
        }
        if (draw && voteDone)
            return string(abi.encodePacked("Election is a draw, ", abi.encodePacked(candidates[maxVoted].name, abi.encodePacked(" and ", abi.encodePacked(candidates[maxVoted2].name, " won!")))));
        
        if (draw)
            return string(abi.encodePacked("Election is a draw currently, ", abi.encodePacked(candidates[maxVoted].name, abi.encodePacked(" and ", abi.encodePacked(candidates[maxVoted2].name, " won!")))));
        
        if (voteDone)
            return string(abi.encodePacked("Election leader is ", candidates[maxVoted].name));

        return string(abi.encodePacked("Election leader is currently ", candidates[maxVoted].name));
    }
}
