// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GameContentRewards {
    address public owner;

    struct Content {
        address creator;
        string contentHash; // Hash of the content for verification
        uint256 reward;
        bool rewarded;
    }

    mapping(uint256 => Content) public contents;
    uint256 public contentCount;

    event ContentAdded(uint256 indexed contentId, address indexed creator, string contentHash);
    event RewardClaimed(uint256 indexed contentId, address indexed creator, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addContent(string memory _contentHash, uint256 _reward) public {
        require(_reward > 0, "Reward must be greater than 0.");

        contentCount++;
        contents[contentCount] = Content({
            creator: msg.sender,
            contentHash: _contentHash,
            reward: _reward,
            rewarded: false
        });

        emit ContentAdded(contentCount, msg.sender, _contentHash);
    }

    function claimReward(uint256 _contentId) public {
        Content storage content = contents[_contentId];

        require(msg.sender == content.creator, "Only the creator can claim the reward.");
        require(!content.rewarded, "Reward has already been claimed.");

        content.rewarded = true;
        payable(content.creator).transfer(content.reward);

        emit RewardClaimed(_contentId, content.creator, content.reward);
    }

    function fundContract() public payable onlyOwner {
        require(msg.value > 0, "Funding amount must be greater than 0.");
    }

    function withdrawFunds(uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient contract balance.");
        payable(owner).transfer(_amount);
    }

    receive() external payable {}
}
