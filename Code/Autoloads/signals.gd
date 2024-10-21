extends Node

# Sceme Manager
signal SceneLoadingComplete()
signal LoadScene(id:String)


# Save / Load
signal Save()
signal Load()
signal DeleteSave()
signal DeleteAndLoad()
signal UnlockDeckInSave(data:DeckData)

# UI
signal ToggleUiMenu(id:String, display:bool)
signal ToggleLoadingScreen(display:bool)
signal ButtonPressed(id:String, from:String)
signal NotifyResourceEmpty(type:CardData.Resource_Type)
signal NotifyDeckEmpty(deck:DeckButton)
signal NotifyActiveEventCard(card:EventCard)
signal NotifyDiscardEmpty()
signal FlashCard(card:Card, color:Color)
signal DisplaySmallPopup(text:String, timer:float)
signal DisplayBigPopup(title:String, text:String, timer:int, has_btn_1:bool, has_btn_2:bool, has_btn_3:bool)
signal DisplayResultScreen(result_id:String, success:bool)
signal ToggleShuffleButton(disable:bool)
signal DisplaySaveIcon()


# DeckButton Selection
signal SelectDeck(id:String, type:DeckData.Type)
signal PlayWith(event_deck_id:String, player_deck_id:String)


# GAME
signal LoadManagers()
signal ManagerLoaded()
signal AllManagersLoaded()
signal AddResource(type:CardData.Resource_Type, amount:int)
signal UseResource(type:CardData.Resource_Type, amount:int)
signal ResourceUpdated(type:CardData.Resource_Type, amount:int)
signal UseCard(card:Card)
signal CompleteCard(card:Card)
signal PayResourceFromCard(card:Card)
signal ToggleColliders(value:bool)
signal DiscardReady(discard:Discard)
signal AddNewPlayerCard(card_data:CardData, spawn_pos:Vector2)
signal DisplayNothingReward()
signal CheckCardsOnCard(card:Card, cards:Array[Card])
signal CheckFailState()
signal ResetGameData()
signal ClearPlayVariables()
signal CheckEndOfMatchDeckUnlocks(result_id:String, decks_used:Array[String])


# Discard
signal ToggleDiscard(is_displayed:bool)
signal DiscardCard(card:Card)
signal CardDiscarded(card:Card)


# Event Cards and DeckButton
signal MouseEnterCard(card:Card)
signal MouseExitCard(card:Card)
signal NullActiveCard()
signal ToggleCollider(is_on:bool)
signal ToggleCardForButton(type:UiCardButton, card:Card, display:bool)
signal DrawCards(deck_type:DeckData.Type, amount:int, use_cost:bool)
signal UnlockDeckToPlay()
signal ShuffleDeck()


# Grabber
signal SelectCard(card:Card)
signal UnselectCard(card:Card)


# Unlocking
signal MatchPlayedWithDeck(result:String, deck:DeckData)
signal UnlockTarget(type:UnlockTarget.Target_Type, target:String)
signal CheckDeckUnlock()