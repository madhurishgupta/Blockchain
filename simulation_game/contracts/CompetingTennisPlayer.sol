pragma solidity ^0.5.0;

import "./TennisPlayerBase.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";

contract CompetingTennisPlayer is TennisPlayerBase {

  using SafeMath for uint;
  using SafeCast for uint;

  uint8 public conditionCostToPlay = 20;
  uint8 public xpGainOnWin = 10;
  uint8 public xpGainOnLoss = 5;

  mapping (uint => bool) enlistedPlayers;

  event Enlist(uint indexed _playerId);
  event Delist(uint indexed _playerId);
  event MatchPlayed(uint indexed playerId, uint indexed opponentId, uint indexed winner);

  function enlist(uint _id) public {
    require(ownerOf(_id) == msg.sender, "Must be the owner of player to enlist");
    require(enlistedPlayers[_id] == false, "Must not already be enlisted");
    require(players[_id].condition >= conditionCostToPlay, "Must be match fit to enlist");
    enlistedPlayers[_id] = true;
    emit Enlist(_id);
  }

  function delist(uint _id) public {
    require(ownerOf(_id) == msg.sender, "Must be the owner of player to enlist");
    require(enlistedPlayers[_id] == true, "Must already be enlisted");
    _delist(_id);
  }

  function playMatch(uint _id, uint _opponentId) public {
    require(ownerOf(_id) == msg.sender, "Must be the owner of player to enlist");
    require(enlistedPlayers[_id] == true, "Must already be enlisted");
    require(enlistedPlayers[_opponentId] == true, "Must already be enlisted");
    _requireMatchCondition(_id, "Player condition is low");
    _requireMatchCondition(_opponentId, "Opponent player condition is low");
    uint playerScore = uint(players[_id].agility)
                  .add(uint(players[_id].stamina))
                  .add(uint(players[_id].power))
                  .add(uint(players[_id].technique));

    uint opponentScore = uint(players[_opponentId].agility)
                  .add(uint(players[_opponentId].stamina))
                  .add(uint(players[_opponentId].power))
                  .add(uint(players[_opponentId].technique));

    players[_id].condition = uint(players[_id].condition).sub(uint(conditionCostToPlay)).toUint8();
    players[_opponentId].condition = uint(players[_opponentId].condition).sun(uint(conditionCostToPlay)).toUint8();

    (uint winner, uint loser) = (playerScore >= opponentScore) ? (_id, _opponentId) : (_opponentId, _id);

    players[winner].xp = uint(players[winner].xp).add(uint(xpGainOnWin));
    players[loser].xp = uint(players[loser].xp).add(uint(xpGainOnLoss));

    emit MatchPlayed(_id, _opponentId, winner);

    _isMatchCondition(_id);
    _isMatchCondition(_opponentId);    
  }

  function _delist(uint _id) private {
    enlistedPlayers[_id] = false;
    emit Delist(_id);
  }

  function _requireMatchCondition(uint _id, string memory _message) private {
    if(!_isMatchCondition(_id)) {
      revert(_message);
    }
  }

  function _isMatchCondition(uint _id) private returns (bool) {
    if( players[_id].condition < conditionCostToPlay) {
      _delist(_id);
      return false;
    }
    return true;
  }
}
