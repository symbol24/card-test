extends Node

# UI
signal ButtonPressed(id:String, from:String)
signal NotifyResourceEmpty(type:CardData.Resource_Type)
signal NotifyDeckEmpty(deck:Deck)
signal NotifyActiveEventCard(card:EventCard)


# Deck Selection
signal SelectDeck(id:String, type:DeckData.Type)
signal PlayWith(event_deck_id:String, player_deck_id:String)


# GAME
signal LoadDataManager()
signal AddResource(type:CardData.Resource_Type, amount:int)
signal UseResource(type:CardData.Resource_Type, amount:int)
signal ResourceUpdated(type:CardData.Resource_Type, amount:int)
signal DiscardCard(card:Card)
signal UseCard(card:Card)
signal CompleteCard(card:Card)
signal CardDiscarded(card:Card)
signal ToggleColliders(value:bool)
signal DiscardReady(discard:Discard)
signal AddNewPlayerCard(card_data:CardData)
signal DisplayNothingReward()
signal DrawCard(deck:Deck)
signal CheckCardsOnCard(card:Card, cards:Array[Card])


# Event Cards and Deck
signal MouseEnterCard(card:Card)
signal MouseExitCard(card:Card)
signal NullActiveCard()
signal ToggleCollider(is_on:bool)
signal ToggleCardForButton(button:PackedScene, card:Card, display:bool)
signal DrawCards(deck_type:DeckData.Type, amount:int)
signal UnlockDeck()


# Grabber
signal SelectCard(card:Card)
signal UnselectCard(card:Card)