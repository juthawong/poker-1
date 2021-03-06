constants = require './constants.js'
globalVariables = require './globalVariables.js'
toolbox = require './toolbox.js'

toggleCardSelection = (sprite) ->
    if not sprite.isSelected then sprite.y = sprite.y - constants.SELECTED_CARD_Y_OFFSET
    else sprite.y = sprite.y + constants.SELECTED_CARD_Y_OFFSET
    sprite.isSelected = !sprite.isSelected

displayCards = (array) ->
    leftMargin = ( globalVariables.screenWidth - ( Math.floor( globalVariables.scaledCardWidth / 4 ) * array.length + Math.floor( 3 * globalVariables.scaledCardWidth / 4 ) ) ) / 2
    spritesShouldBeRemoved = []
    if globalVariables.cardsAtHand.children.length > 0
        for i in [0...globalVariables.cardsAtHand.children.length]
            spritesShouldBeRemoved.push( globalVariables.cardsAtHand.children[i] )
        for i in [0...spritesShouldBeRemoved.length]
            globalVariables.cardsAtHand.remove( spritesShouldBeRemoved[i] )
    for i in [0...array.length]
        cardName = toolbox.getCardName array[i]
        cardSprite = globalVariables.cardsAtHand.create( leftMargin + i * Math.floor( globalVariables.scaledCardWidth / 4 ), globalVariables.screenHeight - globalVariables.scaledCardHeight - constants.MARGIN, cardName )
        cardSprite.scale.setTo( globalVariables.scaleWidthRatio, globalVariables.scaleHeightRatio )
        cardSprite.isSelected = false
        cardSprite.inputEnabled = true
        cardSprite.index = i
        cardSprite.value = array[i]
        cardSprite.input.useHandCursor = true
        cardSprite.events.onInputDown.add( tapDownOnSprite, this )
        cardSprite.events.onInputUp.add( tapUp, this )

showEarnedScoreTextWithFadeOutEffect = (numOfScoresEarnedCurrentRound, game) ->
    globalVariables.textOfEarnedScores.text = '+ ' + numOfScoresEarnedCurrentRound
    globalVariables.textOfEarnedScores.alpha = 1
    game.add.tween( globalVariables.textOfEarnedScores ).to( { alpha: 0 }, 2000, Phaser.Easing.Linear.None, true)

showBigStampForTheLargestPlayedCardsCurrentRound = (numOfCardsPlayed, usernameWithLargestCardsForCurrentRound, game) ->
    startX = null
    startY = null
    if usernameWithLargestCardsForCurrentRound is globalVariables.username
        startX = globalVariables.screenWidth / 2 + ( numOfCardsPlayed + 3 ) * globalVariables.scaledCardWidth / 8 - constants.MAKER_ICON_SIZE / 2
        startY = globalVariables.screenHeight - 2 * globalVariables.scaledCardHeight - 2 * constants.MARGIN - constants.MAKER_ICON_SIZE / 2
    else if usernameWithLargestCardsForCurrentRound is globalVariables.player1Username.text
        startX = globalVariables.screenWidth - 2 * constants.MARGIN - constants.AVATAR_SIZE - constants.MAKER_ICON_SIZE / 2
        startY = globalVariables.screenHeight / 2 - globalVariables.scaledCardHeight / 2 - constants.MAKER_ICON_SIZE / 2
    else if usernameWithLargestCardsForCurrentRound is globalVariables.player2Username.text
        startX = globalVariables.screenWidth / 2 + ( numOfCardsPlayed + 3 ) * globalVariables.scaledCardWidth / 8 - constants.MAKER_ICON_SIZE / 2
        startY = 2 * constants.MARGIN + constants.AVATAR_SIZE - constants.MAKER_ICON_SIZE / 2
    else if usernameWithLargestCardsForCurrentRound is globalVariables.player3Username.text
        startX = ( numOfCardsPlayed + 3 ) * globalVariables.scaledCardWidth / 4 + 2 * constants.MARGIN + constants.AVATAR_SIZE - constants.MAKER_ICON_SIZE / 2
        startY = globalVariables.screenHeight / 2 - globalVariables.scaledCardHeight / 2 - constants.MAKER_ICON_SIZE / 2
    globalVariables.bigSign = game.add.sprite( startX, startY, 'big' )
    globalVariables.bigSign.width = constants.MAKER_ICON_SIZE
    globalVariables.bigSign.height = constants.MAKER_ICON_SIZE

###
Show played cards or historically played cards as sprites for specific player
@param: n                               player index
@param: valuesOfPlayedCards             values of played cards or historically played cards
@param: isCurrentRound                  boolean value:
                                        - true: the played cards is for current round
                                        - false: the played cards is for historical round
###
showPlayedCardsForUser = (n, valuesOfPlayedCards, isCurrentRound) ->
    startX = null
    startY = null
    userPlayedCards = null
    switch n
        when 0         # current user
            startX = globalVariables.screenWidth / 2 - (valuesOfPlayedCards.length + 3) * globalVariables.scaledCardWidth / 8
            startY = globalVariables.screenHeight - 2 * globalVariables.scaledCardHeight - 2 * constants.MARGIN
            if isCurrentRound then userPlayedCards = globalVariables.currentUserPlayedCards
            else userPlayedCards = globalVariables.meHistoricalPlayedCardGroupForOneRound
        when 1         # the 1st user
            startX = globalVariables.screenWidth - ( valuesOfPlayedCards.length + 3 ) * globalVariables.scaledCardWidth / 4 - 2 * constants.MARGIN - constants.AVATAR_SIZE
            startY = globalVariables.screenHeight / 2 - globalVariables.scaledCardHeight / 2
            if isCurrentRound then userPlayedCards = globalVariables.user1PlayedCards
            else userPlayedCards = globalVariables.player1HistoricalPlayedCardGroupForOneRound
        when 2         # the 2nd user
            startX = globalVariables.screenWidth / 2 - ( valuesOfPlayedCards.length + 3 ) * globalVariables.scaledCardWidth / 8
            startY = 2 * constants.MARGIN + constants.AVATAR_SIZE
            if isCurrentRound then userPlayedCards = globalVariables.user2PlayedCards
            else userPlayedCards = globalVariables.player2HistoricalPlayedCardGroupForOneRound
        when 3         # the 3rd user
            startX = 2 * constants.MARGIN + constants.AVATAR_SIZE
            startY = globalVariables.screenHeight / 2 - globalVariables.scaledCardHeight / 2
            if isCurrentRound then userPlayedCards = globalVariables.user3PlayedCards
            else userPlayedCards = globalVariables.player3HistoricalPlayedCardGroupForOneRound
    # remove played cards
    userPlayedCards.removeAll()
    for i in [0...valuesOfPlayedCards.length]
        playedCard = userPlayedCards.create startX + i * globalVariables.scaledCardWidth / 4, startY, toolbox.getCardName( valuesOfPlayedCards[i] )
        playedCard.width = globalVariables.scaledCardWidth
        playedCard.height = globalVariables.scaledCardHeight

sendGetReadyMessage = () ->
    csrfToken = document.getElementsByName( 'csrf-token' )[0].content
    globalVariables.meStatusText.text = 'Ready'
    io.socket.post '/get_ready',
        _csrf: csrfToken
        userId: globalVariables.userId
        loginToken: globalVariables.loginToken
    , (resData, jwres) ->
        if jwres.statusCode is 200
            globalVariables.prepareButton.visible = false
            globalVariables.leaveButton.visible = false
        else alert resData

showCoveredCards = () ->
    if not globalVariables.isShowingCoveredCards
        stageWidth = 11 * globalVariables.scaledCardWidth / 4 + 2 * constants.MARGIN
        stageHeight = globalVariables.scaledCardHeight + 2 * constants.MARGIN

        coveredCardsStage = globalVariables.coveredCards.create( globalVariables.screenWidth / 2 - stageWidth / 2, globalVariables.screenHeight / 2 - stageHeight / 2, 'stageBackground' )
        coveredCardsStage.alpha = 0.3
        coveredCardsStage.width = stageWidth
        coveredCardsStage.height = stageHeight
        for i in [0...globalVariables.coveredCards.values.length]
            cardName = toolbox.getCardName( globalVariables.coveredCards.values[i] )
            coveredCard = globalVariables.coveredCards.create( coveredCardsStage.x + constants.MARGIN + i * globalVariables.scaledCardWidth / 4, coveredCardsStage.y + constants.MARGIN, cardName )
            coveredCard.scale.setTo( globalVariables.scaleWidthRatio, globalVariables.scaleHeightRatio )
        globalVariables.isShowingCoveredCards = true

tapUp = (sprite, pointer) ->
    if pointer.x >= globalVariables.cardsAtHand.children[0].x and
    pointer.x <= ( globalVariables.cardsAtHand.children[globalVariables.cardsAtHand.children.length - 1].x + globalVariables.cardsAtHand.children[globalVariables.cardsAtHand.children.length - 1].width ) and
    pointer.y >= globalVariables.cardsAtHand.children[0].y and
    pointer.y <= ( globalVariables.cardsAtHand.children[0].y + globalVariables.cardsAtHand.children[0].height )
        globalVariables.endSwipeCardIndex = -1
        for i in [0...globalVariables.cardsAtHand.children.length - 1]
            if pointer.x >= globalVariables.cardsAtHand.children[i].x and
            pointer.x <= globalVariables.cardsAtHand.children[i + 1].x
                globalVariables.endSwipeCardIndex = i
                break
        if globalVariables.endSwipeCardIndex is -1 then globalVariables.endSwipeCardIndex = globalVariables.cardsAtHand.children.length - 1
        if globalVariables.startSwipeCardIndex <= globalVariables.endSwipeCardIndex
            for i in [globalVariables.startSwipeCardIndex...globalVariables.endSwipeCardIndex + 1]
                toggleCardSelection( globalVariables.cardsAtHand.children[i] )
        else
            for i in [globalVariables.endSwipeCardIndex...globalVariables.startSwipeCardIndex + 1]
                toggleCardSelection( globalVariables.cardsAtHand.children[i] )

        selectedCardValues = []
        for i in [0...globalVariables.cardsAtHand.children.length]
            if globalVariables.cardsAtHand.children[i].isSelected then selectedCardValues.push( globalVariables.cardsAtHand.children[i].value )
        if globalVariables.gameStatus is constants.GAME_STATUS_SETTLING_COVERED_CARDS
            if selectedCardValues.length is 8
                globalVariables.settleCoveredCardsButton.inputEnabled = true
                globalVariables.settleCoveredCardsButton.setFrames( 1, 0, 1 )
            else
                globalVariables.settleCoveredCardsButton.inputEnabled = false
                globalVariables.settleCoveredCardsButton.setFrames( 2, 2, 2 )
        else if globalVariables.gameStatus is constants.GAME_STATUS_PLAYING
            if toolbox.validateSelectedCardsForPlay( selectedCardValues, globalVariables.firstlyPlayedCardValuesForCurrentRound, globalVariables.cardsAtHand.values, globalVariables.mainSuit, globalVariables.cardValueRanks, globalVariables.nonBankerPlayersHaveNoMainSuit )
                globalVariables.playCardsButton.inputEnabled = true
                globalVariables.playCardsButton.setFrames( 1, 0, 1 )
            else
                globalVariables.playCardsButton.inputEnabled = false
                globalVariables.playCardsButton.setFrames( 2, 2, 2 )

tapDownOnSprite = (sprite, pointer) ->
    globalVariables.startSwipeCardIndex = sprite.index

hideLeftPlayer = (username) ->
    if globalVariables.player1Username
        if  username is globalVariables.player1Username.text
            globalVariables.user1Avatar.destroy()
            globalVariables.player1Username.destroy()
            globalVariables.player1IsBankerIcon.destroy()
            globalVariables.player1StatusText.destroy()
    if globalVariables.player2Username
        if username is globalVariables.player2Username.text
            globalVariables.user2Avatar.destroy()
            globalVariables.player2Username.destroy()
            globalVariables.player2IsBankerIcon.destroy()
            globalVariables.player2StatusText.destroy()
    if globalVariables.player3Username
        if username is globalVariables.player3Username.text
            globalVariables.user3Avatar.destroy()
            globalVariables.player3Username.destroy()
            globalVariables.player3IsBankerIcon.destroy()
            globalVariables.player3StatusText.destroy()

backgroundTapped = () ->
    if globalVariables.isShowingCoveredCards
        # cancel showing covered cards
        spritesShouldBeRemoved = []
        for i in [1...10]
            spritesShouldBeRemoved.push( globalVariables.coveredCards.children[i] )
        for i in [0...spritesShouldBeRemoved.length]
            globalVariables.coveredCards.remove( spritesShouldBeRemoved[i] )
        globalVariables.isShowingCoveredCards = false
    else
        # cancel card selections
        for i in [0...globalVariables.cardsAtHand.children.length]
            if globalVariables.cardsAtHand.children[i].isSelected
                toggleCardSelection( globalVariables.cardsAtHand.children[i] )
    # if player is currently selecting which cards to play, since his/her selections are canceled now should disable the play card button
    if globalVariables.gameStatus is constants.GAME_STATUS_PLAYING
        globalVariables.playCardsButton.inputEnabled = false
        globalVariables.playCardsButton.setFrames( 2, 2, 2 )
    # if player is a banker and is deciding which cards get to be the new covered cards, since his/her/selections are canceled, now should disable the settle covered card button
    if globalVariables.gameStatus is constants.GAME_STATUS_SETTLING_COVERED_CARDS
        globalVariables.settleCoveredCardsButton.inputEnabled = false
        globalVariables.settleCoveredCardsButton.setFrames( 2, 2, 2 )

playSelectedCards = () ->
    selectedCards = []
    valuesOfCurrentUserPlayedCards = []
    # cards played, now disable and hide the play cards button
    globalVariables.playCardsButton.inputEnabled = false
    globalVariables.playCardsButton.setFrames( 2, 2, 2 )
    globalVariables.playCardsButton.visible = false
    for i in [0...globalVariables.cardsAtHand.children.length]
        if globalVariables.cardsAtHand.children[i].isSelected
            selectedCards.push( globalVariables.cardsAtHand.children[i] )
            valuesOfCurrentUserPlayedCards.push( globalVariables.cardsAtHand.children[i].value )
    csrfToken = document.getElementsByName( 'csrf-token' )[0].content
    io.socket.post '/play_cards',
        playedCardValues: valuesOfCurrentUserPlayedCards
        roomName: globalVariables.roomName
        _csrf: csrfToken
        userId: globalVariables.userId
        loginToken: globalVariables.loginToken
    , (resData, jwres) ->
        if jwres.statusCode is 200
            for i in [0...selectedCards.length]
                globalVariables.cardsAtHand.remove( selectedCards[i] )
                index = globalVariables.cardsAtHand.values.indexOf( selectedCards[i].value )
                globalVariables.cardsAtHand.values.splice( index, 1 )
            # reposition the remaining cards
            numOfCardsLeft = globalVariables.cardsAtHand.children.length
            leftMargin = ( globalVariables.screenWidth - ( Math.floor( globalVariables.scaledCardWidth / 4 ) * numOfCardsLeft + Math.floor( 3 * globalVariables.scaledCardWidth / 4 ) ) ) / 2
            for i in [0...globalVariables.cardsAtHand.children.length]
                globalVariables.cardsAtHand.children[i].x = leftMargin + i * Math.floor( globalVariables.scaledCardWidth / 4 )
                globalVariables.cardsAtHand.children[i].index = i
            showPlayedCardsForUser( 0, valuesOfCurrentUserPlayedCards, true )
        else console.log( resData )

showPlayer1Info = (game, username) ->
    globalVariables.user1Avatar = game.add.sprite( globalVariables.screenWidth - constants.AVATAR_SIZE - constants.MARGIN, game.world.centerY - constants.AVATAR_SIZE / 2, 'avatar' )
    globalVariables.user1Avatar.width /= 2
    globalVariables.user1Avatar.height /= 2
    globalVariables.player1IsBankerIcon = game.add.sprite( globalVariables.screenWidth - constants.AVATAR_SIZE - constants.MARGIN, game.world.centerY - constants.AVATAR_SIZE / 2, 'bankerIcon' )
    globalVariables.player1IsBankerIcon.width = constants.MAKER_ICON_SIZE
    globalVariables.player1IsBankerIcon.height = constants.MAKER_ICON_SIZE
    globalVariables.player1IsBankerIcon.visible = false
    globalVariables.player1Username = game.add.text( globalVariables.screenWidth - constants.AVATAR_SIZE - constants.MARGIN, game.world.centerY + constants.AVATAR_SIZE / 2 + constants.MARGIN, username, constants.TEXT_STYLE )
    globalVariables.player1Username.setTextBounds( 0, 0, constants.AVATAR_SIZE, 25 )

showPlayer2Info = (game, username) ->
    globalVariables.user2Avatar = game.add.sprite( game.world.centerX - constants.AVATAR_SIZE / 2, constants.MARGIN, 'avatar' )
    globalVariables.user2Avatar.width /= 2
    globalVariables.user2Avatar.height /= 2
    globalVariables.player2IsBankerIcon = game.add.sprite( game.world.centerX - constants.AVATAR_SIZE / 2, constants.MARGIN, 'bankerIcon' )
    globalVariables.player2IsBankerIcon.width = constants.MAKER_ICON_SIZE
    globalVariables.player2IsBankerIcon.height = constants.MAKER_ICON_SIZE
    globalVariables.player2IsBankerIcon.visible = false
    globalVariables.player2Username = game.add.text( game.world.centerX - constants.AVATAR_SIZE / 2, constants.AVATAR_SIZE + 2 * constants.MARGIN, username, constants.TEXT_STYLE )
    globalVariables.player2Username.setTextBounds( 0, 0, constants.AVATAR_SIZE, 25 )

showPlayer3Info = (game, username) ->
    globalVariables.user3Avatar = game.add.sprite( constants.MARGIN, game.world.centerY - constants.AVATAR_SIZE / 2, 'avatar' )
    globalVariables.user3Avatar.width /= 2
    globalVariables.user3Avatar.height /= 2
    globalVariables.player3IsBankerIcon = game.add.sprite( constants.MARGIN, game.world.centerY - constants.AVATAR_SIZE / 2, 'bankerIcon' )
    globalVariables.player3IsBankerIcon.width = constants.MAKER_ICON_SIZE
    globalVariables.player3IsBankerIcon.height = constants.MAKER_ICON_SIZE
    globalVariables.player3IsBankerIcon.visible = false
    globalVariables.player3Username = game.add.text( constants.MARGIN, game.world.centerY + constants.AVATAR_SIZE / 2 + constants.MARGIN, username, constants.TEXT_STYLE )
    globalVariables.player3Username.setTextBounds( 0, 0, constants.AVATAR_SIZE, 25 )

raiseScore = () ->
    aimedScores = parseInt( globalVariables.textOfAimedScores.text )
    currentSetScores = parseInt( globalVariables.callScoreStage.children[2].text )
    if currentSetScores < ( aimedScores - 5 )
        currentSetScores += 5
        globalVariables.callScoreStage.children[2].text = '' + currentSetScores

showCallScorePanel = (game, currentScore) ->
    globalVariables.callScoreStage = game.add.group()
    stageWidth = 11 * globalVariables.scaledCardWidth / 4 + 2 * constants.MARGIN
    stageHeight = globalVariables.scaledCardHeight + 2 * constants.MARGIN
    background = globalVariables.callScoreStage.create( globalVariables.screenWidth / 2 - stageWidth / 2, globalVariables.screenHeight / 2 - stageHeight / 2, 'stageBackground' )
    background.alpha = 0.3
    background.width = stageWidth
    background.height = stageHeight

    raiseScoreButton = game.add.button( game.world.centerX - constants.ROUND_BUTTON_SIZE / 2 - constants.ROUND_BUTTON_SIZE - constants.MARGIN, game.world.centerY - stageHeight / 2 + constants.MARGIN, 'raiseScoreButton', raiseScore, this, 1, 0, 1, 0 )
    globalVariables.callScoreStage.add( raiseScoreButton )

    currentScoreText = game.add.text( game.world.centerX - constants.ROUND_BUTTON_SIZE / 2, game.world.centerY - stageHeight / 2 + constants.MARGIN, '' + currentScore - 5, constants.LARGE_TEXT_STYLE )
    currentScoreText.setTextBounds( 0, 0, constants.ROUND_BUTTON_SIZE, constants.ROUND_BUTTON_SIZE )
    globalVariables.callScoreStage.add( currentScoreText )

    lowerScoreButton = game.add.button( game.world.centerX + constants.ROUND_BUTTON_SIZE / 2 + constants.MARGIN, game.world.centerY - stageHeight / 2 + constants.MARGIN, 'lowerScoreButton', lowerScore, this, 1, 0, 1 )
    globalVariables.callScoreStage.add( lowerScoreButton )

    setScoreButton = game.add.button( game.world.centerX - constants.BUTTON_WIDTH - constants.MARGIN / 2, game.world.centerY + constants.ROUND_BUTTON_SIZE / 2, 'setScoreButton', setScore, this, 1, 0, 1 )
    globalVariables.callScoreStage.add( setScoreButton )

    passButton = game.add.button( game.world.centerX + constants.MARGIN / 2, game.world.centerY + constants.ROUND_BUTTON_SIZE / 2, 'passButton', pass, this, 1, 0, 1, 0 )
    globalVariables.callScoreStage.add( passButton )

setScore = () ->
    csrfToken = document.getElementsByName( 'csrf-token' )[0].content
    aimedScore = parseInt( globalVariables.callScoreStage.children[2].text )
    io.socket.post '/set_score',
        score: aimedScore
        roomName: globalVariables.roomName
        _csrf: csrfToken
        userId: globalVariables.userId
        loginToken: globalVariables.loginToken
    , (resData, jwres) ->
        if jwres.statusCode is 200
            globalVariables.callScoreStage.destroy( true, false )
            globalVariables.meStatusText.text = '' + aimedScore
        else alert resData

lowerScore = () ->
    aimedScores = parseInt( globalVariables.textOfAimedScores.text )
    currentSetScores = parseInt( globalVariables.callScoreStage.children[2].text )
    if currentSetScores > 5
        currentSetScores -= 5
        globalVariables.callScoreStage.children[2].text = '' + currentSetScores

pass = () ->
    csrfToken = document.getElementsByName( 'csrf-token' )[0].content
    globalVariables.meStatusText.text = '不要'
    io.socket.post '/pass',
        _csrf: csrfToken
        userId: globalVariables.userId
        loginToken: globalVariables.loginToken
        username: globalVariables.username
        roomName: globalVariables.roomName
    , (resData, jwres) ->
        if jwres.statusCode is 200 then globalVariables.callScoreStage.destroy( true, false )
        else alert resData

surrender = () ->
    csrfToken = document.getElementsByName( 'csrf-token' )[0].content
    io.socket.post '/surrender',
        _csrf: csrfToken
        userId: globalVariables.userId
        loginToken: globalVariables.loginToken
    , (resData, jwres) ->
        if jwres.statusCode is 200
        else alert resData

settleCoveredCards = () ->
    valuesOfSelectedCoveredCards = []
    for i in [0...globalVariables.cardsAtHand.children.length]
        if globalVariables.cardsAtHand.children[i].isSelected then valuesOfSelectedCoveredCards.push( globalVariables.cardsAtHand.children[i].value )
    return if valuesOfSelectedCoveredCards.length isnt 8
    for i in [0...valuesOfSelectedCoveredCards.length]
        index = globalVariables.cardsAtHand.values.indexOf( valuesOfSelectedCoveredCards[i] )
        globalVariables.cardsAtHand.values.splice( index, 1 )
    displayCards( globalVariables.cardsAtHand.values )
    coveredCardsIcon = globalVariables.coveredCards.create( constants.MARGIN, constants.MARGIN, 'back' )
    coveredCardsIcon.scale.setTo( globalVariables.scaleWidthRatio, globalVariables.scaleHeightRatio )
    coveredCardsIcon.inputEnabled = true
    globalVariables.coveredCards.values = valuesOfSelectedCoveredCards
    coveredCardsIcon.events.onInputDown.add( showCoveredCards, this )
    globalVariables.settleCoveredCardsButton.visible = false
    globalVariables.settleCoveredCardsButton.inputEnabled = false
    globalVariables.settleCoveredCardsButton.setFrames( 2, 2, 2 )

    csrfToken = document.getElementsByName( 'csrf-token' )[0].content
    io.socket.post '/settleCoveredCards',
        _csrf: csrfToken
        userId: globalVariables.userId
        loginToken: globalVariables.loginToken
        roomName: globalVariables.roomName
        coveredCards: globalVariables.coveredCards.values
        banker: globalVariables.username
        cardsAtHand: globalVariables.cardsAtHand.values
    , (resData, jwres) ->
        if jwres.statusCode is 200 then showSelectSuitPanel()
        else alert resData

showSelectSuitPanel = () ->
    globalVariables.gameStatus = constants.GAME_STATUS_DECIDING_SUIT
    globalVariables.selectSuitButton.visible = true
    globalVariables.selectSuitButton.inputEnabled = false
    globalVariables.selectSuitButton.setFrames( 2, 2, 2 )
    stageWidth = 4 * constants.SUIT_ICON_SIZE + 8 * constants.MARGIN
    stageHeight = 2 * constants.MARGIN + constants.SUIT_ICON_SIZE
    background = globalVariables.selectSuitStage.create( globalVariables.screenWidth / 2 - stageWidth / 2, globalVariables.screenHeight / 2 - stageHeight / 2, 'stageBackground' )
    background.alpha = 0.3
    background.width = stageWidth
    background.height = stageHeight
    globalVariables.selectSuitStage.add( background )
    # add spade icon
    spadeIcon = globalVariables.selectSuitStage.create( background.x + (1 + 2 * 0) * constants.MARGIN + 0 * constants.SUIT_ICON_SIZE, background.y + constants.MARGIN, 'spade' )
    spadeIcon.width = constants.SUIT_ICON_SIZE
    spadeIcon.height = constants.SUIT_ICON_SIZE
    spadeIcon.inputEnabled = true
    spadeIcon.input.useHandCursor = true
    spadeIcon.events.onInputDown.add( () ->
        suitTapEffect( 1 )
    , this )
    globalVariables.selectSuitStage.add( spadeIcon )
    # add heart icon
    heartIcon = globalVariables.selectSuitStage.create( background.x + (1 + 2 * 1) * constants.MARGIN + 1 * constants.SUIT_ICON_SIZE, background.y + constants.MARGIN, 'heart' )
    heartIcon.width = constants.SUIT_ICON_SIZE
    heartIcon.height = constants.SUIT_ICON_SIZE
    heartIcon.inputEnabled = true
    heartIcon.input.useHandCursor = true
    heartIcon.events.onInputDown.add( () ->
        suitTapEffect( 2 )
    , this )
    globalVariables.selectSuitStage.add( heartIcon )
    # add club icon
    clubIcon = globalVariables.selectSuitStage.create( background.x + (1 + 2 * 2) * constants.MARGIN + 2 * constants.SUIT_ICON_SIZE, background.y + constants.MARGIN, 'club' )
    clubIcon.width = constants.SUIT_ICON_SIZE
    clubIcon.height = constants.SUIT_ICON_SIZE
    clubIcon.inputEnabled = true
    clubIcon.input.useHandCursor = true
    clubIcon.events.onInputDown.add( () ->
        suitTapEffect( 3 )
    , this )
    globalVariables.selectSuitStage.add( clubIcon )
    # add diamond icon
    diamondIcon = globalVariables.selectSuitStage.create( background.x + (1 + 2 * 3) * constants.MARGIN + 3 * constants.SUIT_ICON_SIZE, background.y + constants.MARGIN, 'diamond' )
    diamondIcon.width = constants.SUIT_ICON_SIZE
    diamondIcon.height = constants.SUIT_ICON_SIZE
    diamondIcon.inputEnabled = true
    diamondIcon.input.useHandCursor = true
    diamondIcon.events.onInputDown.add( () ->
        suitTapEffect( 4 )
    , this )
    globalVariables.selectSuitStage.add( diamondIcon )

    rectangle = globalVariables.selectSuitStage.create( spadeIcon.x, spadeIcon.y, 'rectangle' )
    rectangle.width = constants.SUIT_ICON_SIZE + 10
    rectangle.height = constants.SUIT_ICON_SIZE + 10
    rectangle.visible = false
    globalVariables.selectSuitStage.add( rectangle )

selectSuit = () ->
    csrfToken = document.getElementsByName( 'csrf-token' )[0].content
    io.socket.post '/chooseMainSuit',
        _csrf: csrfToken
        userId: globalVariables.userId
        loginToken: globalVariables.loginToken
        roomName: globalVariables.roomName
        banker: globalVariables.username
        mainSuit: globalVariables.mainSuit
    , (resData, jwres) ->
        if jwres.statusCode is 200
            globalVariables.surrenderButton.visible = false
            globalVariables.selectSuitButton.visible = false
            spritesShouldBeRemoved = []
            for i in [0...globalVariables.selectSuitStage.children.length]
                spritesShouldBeRemoved.push( globalVariables.selectSuitStage.children[i] )
            for i in [0...spritesShouldBeRemoved.length]
                globalVariables.selectSuitStage.remove( spritesShouldBeRemoved[i] )
            globalVariables.iconOfMainSuit.frame = globalVariables.mainSuit
            globalVariables.playCardsButton.visible = true
            globalVariables.playCardsButton.inputEnabled = false
            globalVariables.playCardsButton.setFrames 2, 2, 2
            globalVariables.gameStatus = constants.GAME_STATUS_PLAYING
        else alert( resData )

suitTapEffect = (suitIndex) ->
    globalVariables.mainSuit = suitIndex
    rectangle = globalVariables.selectSuitStage.children[globalVariables.selectSuitStage.children.length - 1]
    suitIcon = globalVariables.selectSuitStage.children[suitIndex]
    rectangle.x = suitIcon.x - 5
    rectangle.y = suitIcon.y - 5
    rectangle.visible = true
    globalVariables.selectSuitButton.inputEnabled = true
    globalVariables.selectSuitButton.setFrames( 1, 0, 1 )

leaveRoom = () ->
    csrfToken = document.getElementsByName( 'csrf-token' )[0].content
    io.socket.post '/leave_room',
        _csrf: csrfToken
        userId: globalVariables.userId
        loginToken: globalVariables.loginToken
    , (resData, jwres) ->
        if jwres.statusCode is 200 then window.location.href = '/'
        else alert( resData )

showHistoricallyPlayedCards = (game) ->
    # hide playCardButton if it is currently visible
    if globalVariables.playCardsButton.visible is true
        globalVariables.isPlayCardButtonVisibleBeforeShowingHistoricalRecordStage = true
        globalVariables.playCardsButton.visible = false
    else globalVariables.isPlayCardButtonVisibleBeforeShowingHistoricalRecordStage = false
    # hide historicalButton
    globalVariables.historicalButton.visible = false

    # initialize historical record stage group
    globalVariables.historicalRecordStage = game.add.group()

    background = globalVariables.historicalRecordStage.create( 0, 0, 'stageBackground' )
    background.alpha = 0.3
    background.width = globalVariables.screenWidth
    background.height = globalVariables.screenHeight

    background.inputEnabled = true
    background.events.onInputDown.add( hideHistoricalRecordStage, this )
    globalVariables.historicalRecordStage.add( background )

    lastRoundButton = game.add.button( globalVariables.screenWidth - 2 * constants.MARGIN - constants.BUTTON_WIDTH - constants.AVATAR_SIZE, globalVariables.screenHeight - globalVariables.scaledCardHeight - constants.BUTTON_HEIGHT - 2 * constants.MARGIN - constants.SELECTED_CARD_Y_OFFSET, 'lastRound', showLastRoundPlayedCards, this, 1, 0, 1 )
    globalVariables.historicalRecordStage.add( lastRoundButton )

    nextRoundButton = game.add.button( globalVariables.screenWidth - 2 * constants.MARGIN - constants.BUTTON_WIDTH - constants.AVATAR_SIZE, globalVariables.screenHeight - globalVariables.scaledCardHeight - constants.BUTTON_HEIGHT - 2 * constants.MARGIN - constants.SELECTED_CARD_Y_OFFSET + constants.MARGIN + constants.BUTTON_HEIGHT, 'nextRound', showNextRoundPlayedCards, this, 1, 0, 1 )
    globalVariables.historicalRecordStage.add( nextRoundButton )

    globalVariables.historicalRoundIndex = globalVariables.meHistoricalPlayedCardValues.length
    showLastRoundPlayedCards()

hideHistoricalRecordStage = () ->
    # if playCardButton was visible before showing historical record stage, make it visible again
    if globalVariables.isPlayCardButtonVisibleBeforeShowingHistoricalRecordStage is true
        globalVariables.playCardsButton.visible = true
    globalVariables.historicalRecordStage.destroy( true, false )
    # show historicalButton
    globalVariables.historicalButton.visible = true
    # remove historical played card sprites for each player
    globalVariables.meHistoricalPlayedCardGroupForOneRound.removeAll()
    globalVariables.player1HistoricalPlayedCardGroupForOneRound.removeAll()
    globalVariables.player2HistoricalPlayedCardGroupForOneRound.removeAll()
    globalVariables.player3HistoricalPlayedCardGroupForOneRound.removeAll()

toggleLastAndNextRoundButton = () ->
    if globalVariables.meHistoricalPlayedCardValues.length is 1
        # there's only one historical round, lastRoundButton and nextRoundButton should both be disabled
        globalVariables.historicalRecordStage.children[1].inputEnabled = false
        globalVariables.historicalRecordStage.children[1].setFrames( 2, 2, 2 )
        globalVariables.historicalRecordStage.children[2].inputEnabled = false
        globalVariables.historicalRecordStage.children[2].setFrames( 2, 2, 2 )
    else if globalVariables.historicalRoundIndex is 0
        # no more last round, lastRoundButton should be disabled
        globalVariables.historicalRecordStage.children[1].inputEnabled = false
        globalVariables.historicalRecordStage.children[1].setFrames( 2, 2, 2 )

        globalVariables.historicalRecordStage.children[2].inputEnabled = true
        globalVariables.historicalRecordStage.children[2].setFrames( 1, 0, 1 )
    else if globalVariables.historicalRoundIndex is ( globalVariables.meHistoricalPlayedCardValues.length - 1 )
        # no more next round, nextRoundButton should be disabled
        globalVariables.historicalRecordStage.children[1].inputEnabled = true
        globalVariables.historicalRecordStage.children[1].setFrames( 1, 0, 1 )

        globalVariables.historicalRecordStage.children[2].inputEnabled = false
        globalVariables.historicalRecordStage.children[2].setFrames( 2, 2, 2 )
    else
        globalVariables.historicalRecordStage.children[1].inputEnabled = true
        globalVariables.historicalRecordStage.children[1].setFrames( 1, 0, 1 )

        globalVariables.historicalRecordStage.children[2].inputEnabled = true
        globalVariables.historicalRecordStage.children[2].setFrames( 1, 0, 1 )

showLastRoundPlayedCards = () ->
    return if globalVariables.historicalRoundIndex is 0
    globalVariables.historicalRoundIndex -= 1
    # enable or disable last and next round button based on historical round index and how many historical rounds we have so far
    toggleLastAndNextRoundButton()
    # show the historical round played cards for each player
    showPlayedCardsForUser( 0, globalVariables.meHistoricalPlayedCardValues[globalVariables.historicalRoundIndex], false )
    showPlayedCardsForUser( 1, globalVariables.player1HistoricalPlayedCardValues[globalVariables.historicalRoundIndex], false )
    showPlayedCardsForUser( 2, globalVariables.player2HistoricalPlayedCardValues[globalVariables.historicalRoundIndex], false )
    showPlayedCardsForUser( 3, globalVariables.player3HistoricalPlayedCardValues[globalVariables.historicalRoundIndex], false )

showNextRoundPlayedCards = () ->
    return if globalVariables.historicalRoundIndex is globalVariables.meHistoricalPlayedCardValues.length - 1
    globalVariables.historicalRoundIndex += 1
    # enable or disable last and next round button based on historical round index and how many historical rounds we have so far
    toggleLastAndNextRoundButton()
    # show the historical round played cards for each player
    showPlayedCardsForUser( 0, globalVariables.meHistoricalPlayedCardValues[globalVariables.historicalRoundIndex], false )
    showPlayedCardsForUser( 1, globalVariables.player1HistoricalPlayedCardValues[globalVariables.historicalRoundIndex], false )
    showPlayedCardsForUser( 2, globalVariables.player2HistoricalPlayedCardValues[globalVariables.historicalRoundIndex], false )
    showPlayedCardsForUser( 3, globalVariables.player3HistoricalPlayedCardValues[globalVariables.historicalRoundIndex], false )

endGame = ( isSurrender, gameResults, game ) ->
    # Banker surrendered
    if isSurrender
        clearGameInfo()
        showGameResultsPanel( gameResults, game )
    # Game ended
    else
        # 庄家被扣底
        if gameResults.shouldEarnScoresInCoveredCards
            globalVariables.coveredCards.values = gameResults.coveredCardsToExpose
            showCoveredCards()
            # show scores earned from covered cards
            showEarnedScoreTextWithFadeOutEffect( gameResults.scoresEarnedFromCoveredCards, game )
            setTimeout( () ->
                # hide exposed covered cards
                globalVariables.coveredCards.removeAll()
                clearGameInfo()
                showGameResultsPanel( gameResults, game )
            , 2000 )
        else
            clearGameInfo()
            showGameResultsPanel( gameResults, game )

clearGameInfo = () ->
    globalVariables.currentUserPlayedCards.removeAll()
    globalVariables.user1PlayedCards.removeAll()
    globalVariables.user2PlayedCards.removeAll()
    globalVariables.user3PlayedCards.removeAll()
    globalVariables.isShowingCoveredCards = false
    globalVariables.cardsAtHand.removeAll()
    globalVariables.coveredCards.removeAll()

    hideAndDisableButton( globalVariables.playCardsButton )
    hideAndDisableButton( globalVariables.historicalButton )

    hideAndDisableButton( globalVariables.surrenderButton )
    hideAndDisableButton( globalVariables.settleCoveredCardsButton )

    globalVariables.startSwipeCardIndex = null
    globalVariables.endSwipeCardIndex = null
    globalVariables.iconOfMainSuit.frame = 0
    globalVariables.textOfCurrentScores.text = '0'
    globalVariables.textOfAimedScores.text = '80'
    globalVariables.textOfEarnedScores.text = ''

    globalVariables.meStatusText.text = ''
    globalVariables.player1StatusText.text = ''
    globalVariables.player2StatusText.text = ''
    globalVariables.player3StatusText.text = ''

    globalVariables.player1IsBankerIcon.destroy() if globalVariables.player1IsBankerIcon
    globalVariables.player2IsBankerIcon.destroy() if globalVariables.player2IsBankerIcon
    globalVariables.player3IsBankerIcon.destroy() if globalVariables.player3IsBankerIcon

    globalVariables.callScoreStage.destroy( true, false ) if globalVariables.callScoreStage

    globalVariables.gameStatus = null

    hideAndDisableButton( globalVariables.selectSuitButton )
    globalVariables.selectSuitStage.removeAll()
    globalVariables.mainSuit = null
    globalVariables.firstlyPlayedCardValuesForCurrentRound = []
    globalVariables.bigSign.destroy() if globalVariables.bigSign

    globalVariables.cardValueRanks = null

    globalVariables.meHistoricalPlayedCardValues = []
    globalVariables.player1HistoricalPlayedCardValues = []
    globalVariables.player2HistoricalPlayedCardValues = []
    globalVariables.player3HistoricalPlayedCardValues = []

    globalVariables.meHistoricalPlayedCardGroupForOneRound.removeAll()
    globalVariables.player1HistoricalPlayedCardGroupForOneRound.removeAll()
    globalVariables.player2HistoricalPlayedCardGroupForOneRound.removeAll()
    globalVariables.player3HistoricalPlayedCardGroupForOneRound.removeAll()

    globalVariables.historicalRecordStage.destroy( true, false ) if globalVariables.historicalRecordStage
    globalVariables.historicalRoundIndex = null

    globalVariables.isPlayCardButtonVisibleBeforeShowingHistoricalRecordStage = false

    globalVariables.nonBankerPlayersHaveNoMainSuit = constants.FALSE
    globalVariables.gameResultsStage.destroy( true, false ) if globalVariables.gameResultsStage

showGameResultsPanel = (gameResults, game) ->
    globalVariables.gameResultsStage = game.add.group()
    stageWidth = 11 * globalVariables.scaledCardWidth / 4 + 2 * constants.MARGIN
    stageHeight = constants.TITLE_TEXT_HEIGHT * 6 + constants.MARGIN * 7

    background = globalVariables.gameResultsStage.create( globalVariables.screenWidth / 2 - stageWidth / 2, globalVariables.screenHeight / 2 - stageHeight / 2, 'stageBackground' )
    background.alpha = 0.3
    background.width = stageWidth
    background.height = stageHeight

    bankerResultText = ''
    changedChipsTextForNonBankers = ''
    changedChipsTextForBanker = ''
    changedChipsForWaterpool = ''

    # 庄家投降
    if gameResults.changedQuantityOfWaterpool > 0
        bankerResultText = '庄家输了'
        changedChipsTextForBanker = '-' + Math.abs( gameResults.numOfWinningChipsForBanker )
        changedChipsTextForNonBankers = '0'
        changedChipsForWaterpool = '+' + gameResults.changedQuantityOfWaterpool
    # 庄家没投降，被打输了
    else if gameResults.numOfWinningChipsForBanker < 0
        bankerResultText = '庄家输了'
        changedChipsTextForBanker = '-' + Math.abs( gameResults.numOfWinningChipsForBanker )
        changedChipsTextForNonBankers = '+' + Math.abs( gameResults.numOfWinningChipsForBanker ) / 3
        changedChipsForWaterpool = '0'
    # 庄家赢了
    else
        bankerResultText = '庄家赢了'
        changedChipsTextForBanker = '+' + ( Math.abs( gameResults.numOfWinningChipsForBanker ) + gameResults.changedQuantityOfWaterpool )
        changedChipsTextForNonBankers = '-' + Math.abs( gameResults.numOfWinningChipsForBanker ) / 3
        changedChipsForWaterpool = '-' + Math.abs( gameResults.changedQuantityOfWaterpool )

    usernames = [
        globalVariables.username
        globalVariables.player1Username.text
        globalVariables.player2Username.text
        globalVariables.player3Username.text
    ]
    changedChipsText = ['', '', '', '']
    for i in [0...usernames.length]
        if usernames[i] is gameResults.bankerUsername then changedChipsText[i] = changedChipsTextForBanker
        else changedChipsText[i] = changedChipsTextForNonBankers

    winOrLoseText = game.add.text( game.world.centerX - constants.TITLE_TEXT_WIDTH / 2, background.y + constants.MARGIN, bankerResultText, constants.LARGE_TEXT_STYLE )
    winOrLoseText.setTextBounds( 0, 0, constants.TITLE_TEXT_WIDTH, constants.TITLE_TEXT_HEIGHT )
    globalVariables.gameResultsStage.add( winOrLoseText )

    for i in [0...usernames.length]
        playerUsernameText = game.add.text( background.x + constants.MARGIN, background.y + (2 + i) * constants.MARGIN + (i + 1) * constants.TITLE_TEXT_HEIGHT, usernames[i], constants.TEXT_STYLE )
        globalVariables.gameResultsStage.add( playerUsernameText )
        playerChangedChipsText = game.add.text( background.x + background.width - constants.MARGIN - constants.TITLE_TEXT_WIDTH, background.y + ( 2 + i ) * constants.MARGIN + ( i + 1 ) * constants.TITLE_TEXT_HEIGHT, changedChipsText[i], constants.TEXT_STYLE )
        globalVariables.gameResultsStage.add( playerChangedChipsText )

    waterpoolName = game.add.text( background.x + constants.MARGIN, background.y + 5 * constants.MARGIN + 5 * constants.TITLE_TEXT_HEIGHT, '水池', constants.TEXT_STYLE )
    globalVariables.gameResultsStage.add( waterpoolName )
    waterpoolChangedChipsText = game.add.text( background.x + background.width - constants.MARGIN - constants.TITLE_TEXT_WIDTH, background.y + 6 * constants.MARGIN + 5 * constants. TITLE_TEXT_HEIGHT, '' + gameResults.changedQuantityOfWaterpool, constants.TEXT_STYLE )
    globalVariables.gameResultsStage.add( waterpoolChangedChipsText )

    # update the text of chips won at the upper right corner
    numOfCurrentChipsWon = parseInt( globalVariables.textOfChipsWon.text )
    updatedCurrentChipsWon = numOfCurrentChipsWon + parseInt( changedChipsText[0] )
    globalVariables.textOfChipsWon.text = '' + updatedCurrentChipsWon
    # update the waterpool
    globalVariables.textOfWaterpool.text = '' + gameResults.currentWaterpoll

    setTimeout( () ->
        globalVariables.gameResultsStage.destroy true, false
        showAndEnableButton( globalVariables.prepareButton )
        showAndEnableButton( globalVariables.leaveButton )
    , 2000 )

hideAndDisableButton = (button) ->
    button.inputEnabled = false
    button.visible = false
    button.setFrames( 2, 2, 2 )

showAndEnableButton = (button) ->
    button.inputEnabled = true
    button.visible = true
    button.setFrames( 1, 0, 1 )

module.exports =
    toggleCardSelection: toggleCardSelection
    displayCards: displayCards
    showCoveredCards: showCoveredCards
    showPlayedCardsForUser: showPlayedCardsForUser
    tapUp: tapUp
    tapDownOnSprite: tapDownOnSprite
    backgroundTapped: backgroundTapped
    playSelectedCards: playSelectedCards
    showPlayer1Info: showPlayer1Info
    showPlayer2Info: showPlayer2Info
    showPlayer3Info: showPlayer3Info
    hideLeftPlayer: hideLeftPlayer
    showCallScorePanel: showCallScorePanel
    raiseScore: raiseScore
    lowerScore: lowerScore
    pass: pass
    surrender: surrender
    settleCoveredCards: settleCoveredCards
    showSelectSuitPanel: showSelectSuitPanel
    setScore: setScore
    selectSuit: selectSuit
    leaveRoom: leaveRoom
    sendGetReadyMessage: sendGetReadyMessage
    showBigStampForTheLargestPlayedCardsCurrentRound: showBigStampForTheLargestPlayedCardsCurrentRound
    showEarnedScoreTextWithFadeOutEffect: showEarnedScoreTextWithFadeOutEffect
    showHistoricallyPlayedCards: showHistoricallyPlayedCards
    endGame: endGame
    showGameResultsPanel: showGameResultsPanel
    clearGameInfo: clearGameInfo
    hideAndDisableButton: hideAndDisableButton
    showAndEnableButton: showAndEnableButton