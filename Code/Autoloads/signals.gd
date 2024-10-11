extends Node

# UI
signal ButtonPressed(id:String, from:String)
signal NotifyResourceEmpty(type:CardData.Resource_Type)
signal NotifyDeckEmpty(deck:DeckButton)
signal NotifyActiveEventCard(card:EventCard)
signal FlashCard(card:Card, color:Color)


# DeckButton Selection
signal SelectDeck(id:String, type:DeckData.Type)
signal PlayWith(event_deck_id:String, player_deck_id:String)


# GAME
signal LoadDataManager()
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
signal UnlockDeck()


# Grabber
signal SelectCard(card:Card)
signal UnselectCard(card:Card)
