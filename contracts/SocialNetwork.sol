// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "./interfaces/ISocialNetwork.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SocialNetwork is ISocialNetwork {
    using Counters for Counters.Counter;
    Counters.Counter private _tweetIds;

    struct TweetData {
        string message;
        uint256 totalLike;
        uint256 time;
        address posterAddr;
    }

    // ツイートを格納するmapping変数
    mapping(uint256 => TweetData) public tweetDataMap;
    // ツイートに対していいねしたかどうかを格納するmapping変数
    mapping(address => mapping(uint256 => bool)) public likedTweet;

    event TweetPosted(address indexed posterAddr, string message, uint256 time);
    event LikeToggled(address indexed sender, uint256 postId,bool isLike);

    function post(string memory _message) external {
        uint256 newId = _tweetIds.current();
        tweetDataMap[newId] = TweetData(_message, 0, block.timestamp, msg.sender);

        _tweetIds.increment();
        emit TweetPosted(msg.sender, _message, block.timestamp);
    }

    function getLastPostId() public view returns (uint256) {
        return _tweetIds.current();
    }

    function getPost(uint256 _postId)
        public
        view
        returns (
            string memory message,
            uint256 totalLikes,
            uint256 time
        )
    {
        TweetData memory tweetData;
        uint256 lastId = _tweetIds.current();
        require(_postId <= lastId, "non existent id");
        tweetData = tweetDataMap[_postId];

        return (tweetData.message, tweetData.totalLike, tweetData.time);
    }

    function like(uint256 _postId) external {
        require(!likedTweet[msg.sender][_postId], "already liked");

        likedTweet[msg.sender][_postId] = true;
        tweetDataMap[_postId].totalLike ++;
        emit LikeToggled(msg.sender, _postId, true);
    }

    function unlike(uint256 _postId) external{
        require(likedTweet[msg.sender][_postId], "didn't like...");

        likedTweet[msg.sender][_postId] = false;
        tweetDataMap[_postId].totalLike --;
        emit LikeToggled(msg.sender, _postId, false);
    }

    // More functions
    function getAllPost() public view returns(TweetData [] memory, bool[] memory){
        uint256 lastPostId = getLastPostId();
        TweetData[] memory tweetData = new TweetData[](lastPostId);
        bool[] memory tweetLikedStatus = new bool[](lastPostId);
        for(uint256 i=0; i<lastPostId; i++){
            TweetData memory tweet = tweetDataMap[i];
            tweetData[i] = TweetData({
                message: tweet.message,
                totalLike: tweet.totalLike,
                time: tweet.time,
                posterAddr: tweet.posterAddr
            });

            tweetLikedStatus[i] = likedTweet[msg.sender][i];
        }
        return (tweetData, tweetLikedStatus);
    }
}
