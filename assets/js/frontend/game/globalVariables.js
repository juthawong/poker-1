// Generated by CoffeeScript 1.10.0
(function() {
  module.exports = {
    screenWidth: Math.max(document.documentElement.clientWidth, window.innerWidth || 0),
    screenHeight: Math.max(document.documentElement.clientHeight, window.innerHeight || 0),
    userId: document.getElementById('userId').innerText,
    username: document.getElementById('username').innerText,
    loginToken: document.getElementById('loginToken').innerText,
    roomName: document.getElementById('roomName').innerText,
    scaledCardWidth: null,
    scaledCardHeight: null,
    scaleWidthRatio: null,
    scaleHeightRatio: null,
    currentUserPlayedCards: null,
    user1PlayedCards: null,
    user2PlayedCards: null,
    user3PlayedCards: null,
    isShowingCoveredCards: false,
    cardsAtHand: null,
    coveredCards: null,
    background: null,
    playCardsButton: null,
    prepareButton: null,
    leaveButton: null,
    surrenderButton: null,
    settleCoveredCardsButton: null,
    startSwipeCardIndex: null,
    endSwipeCardIndex: null,
    iconOfMainSuit: null,
    textOfCurrentScores: null,
    textOfAimedScores: null,
    textOfChipsWon: null,
    textOfRoomName: null,
    numberOfPlayersInRoom: 1,
    player1Username: null,
    player2Username: null,
    player3Username: null,
    user1Avatar: null,
    user2Avatar: null,
    user3Avatar: null,
    meStatusText: null,
    player1IsMakerIcon: null,
    player2IsMakerIcon: null,
    player3IsMakerIcon: null,
    player1StatusText: null,
    player2StatusText: null,
    player3StatusText: null,
    callScoreStage: null,
    selectMainStage: null,
    gameStatus: null,
    selectSuitButton: null,
    selectSuitStage: null,
    mainSuit: null
  };

}).call(this);
