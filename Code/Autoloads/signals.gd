extends Node

# UI
signal ButtonPressed(id:String, from:String)
signal NotifyResourceEmpty(type:CardData.Resource_Type)
signal NotifyPlayerDeckEmpty()
signal NotifyEventDeckEmpty()
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
signal CardDiscarded(card:Card)
signal ToggleColliders(value:bool)


# Event Cards and Deck
signal MouseEnterCard(card:Card)
signal MouseExitCard(card:Card)
signal NullActiveCard()
signal ToggleCollider(is_on:bool)