# Table Quick Reference

Both for me and anyone else who might read this in the future... (sorry)

This project contains quite a few indexes which stand for different things, I'm going to try to keep a reference to which index goes with each status here.

## Rank

|id|rank|
|---|---|
|1|Ace (internally)|
|2-10|2-10|
|11|J|
|12|Q|
|13|K|
|14|Ace (get function)|
|99|Stone Card|

## Suite

|id|suite|
|---|---|
|1|Spades|
|2|Hearts|
|3|Clubs|
|4|Diamonds|
|0|Red (Smeared Joker Active)|
|-1|Black (Smeared Joker Active)|
|-3|Wild Card|
|-4|Stone Card|

## Modifier

Learned later that it's actually called enhancements in game

|id|Mod/Enhancement|When Scored
|---|---|---|
|0|Plain Card|NA|
|1|Stone Card|IdHandType and OnScoreScoring|
|2|Wild Card|IdHandType|
|3|Bonus Card|OnScoreScoring|
|4|Lucky Card|OnScoreScoring|
|5|Mult Card|OnScoreScoring|
|6|Glass Card|OnScoreScoring (Breaks PostScoreEffects)|
|7|Steel Card|OnScoreHand|
|8|Gold Card|Pays out PostScoreEffects|

Note: Gold Cards don't pay out, glass cards don't break (asof 0.1.0)

## Seal

|id|Mod/Enhancement|When Scored
|---|---|---|
|0|No Seal|NA|
|1|Purple|Gives Tarot on Discard|
|2|Blue|Gives Planet PostScoreEffects|
|3|Gold|OnScoreScoring|
|4|Red|OnScoreScoring, OnScoreHand (if an effect took place)|

Gold and red function currently, purple and blue don't have any cards to gen yet...

## Edition (Playing Cards)

|id|Mod/Enhancement|When Scored
|---|---|---|
|0|No Edition|NA|
|1|Foil|OnScoreScoring|
|2|Holographic|OnScoreScoring|
|3|Polychrome|OnScoreScoring|

## Edition (Jokers)

|id|Mod/Enhancement|When Scored
|---|---|---|
|-1|Negative|NA|
|0|No Edition|NA|
|1|Foil|OnScoreJokers|
|2|Holographic|OnScoreJokers|
|3|Polychrome|OnScoreJokers|

## Hand Types

Reverse order of priority, so

|id|Hand|
|---|---|
|1|Flush Five|
|2|Flush House|
|3|5OAK|
|4|Straight Flush|
|5|4OAK|
|6|Full House|
|7|Flush|
|8|Straight|
|9|3OAK|
|10|Two Pair|
|11|Pair|
|12|High Card|

## Sorting

sortMode: True=Rank, False=Suite

## Full Joker Possible Activation Stages

1. OnBuy when bought from shop/created other ways
2. OnSell when sold/destroyed (often undoes OnBuy effects)
3. OnShopEnd when shop is done i.e. perkeo
4. OnBlind when blind starts i.e. burglar
5. OnDiscard when discarding
6. OnPlayEffect before cards begin to score i.e. green joker upgrade
7. OnScore, when cards score
8. OnScoreRe, retriggers scoring cards
9. OnHand, checked by each card in hand after scoring cards
10. OnHandRe, retriggers card in hand effects
11. OnJoker, independant joker effects
12. ScoringDone, after scoring has completed (like glass cards breaking)
13. OnRoundDone, after the round is over
14. OnPayout, adds extra stage to payout

might need more later we'll see ig

## Scoring tldr

Order of scoring same as in real balatro:
1. OnPlayEffects (not really scoring but midas mask, DNA, ect)
2. OnScoreScoring
3. OnScoreHand
4. OnScoreJoker

### Set OnScoreScoring Stages

 1. Basic Scoring (Bonus and Stone taken care of here)
 2. Mult Card or Lucky Card Mult or Glass Card
 3. Lucky Card Payout
 4. Editions
 5. Gold Seal Payout

 5 on are Joker-dependent, afterwards checking retrigger stages:
 
 1. Red Seal Retrigger
 
 2 on are also Joker-dependent, any retrigger effect. Retriggers will retrigger any effect in the other table, but not thier own table (can't retrigger a retrigger)

 Jokers will be automatically assigned a non-set stage ID to trigger based on joker position, if they score/take effect OnScoring.

### Set OnScoreHand Stages

1. Steel Cards

2 on are Joker-dependent once again.

Retriggers:

1. Red Seal Retrigger (if a steel or joker triggered only)

2 on are for Mimes (or Bluestorms copying Mimes).

Note that retriggers only occur if the card scores in the first place, which is not always the case anymore.

### OnScoreJoker
OnScoreJoker iterates upwards from 1 to the number of stages contained. Some effects like editions might bring the pop-up key down to give one joker multiple pop up effects. All jokers contribute something to this stage, if they have no effect they will contribute "false", which is skipped over automatically.

#### Baseball Card

Baseball card scores OnScoreJoker whenever it iterates over a uncommon joker. (not implemented yet idk why this is here)

## JokerCode

Jokers are given code which is saved as an index.lua in the jokerCode folder. The index is the order I drew them in the spritesheet, aka completely arbitrary.

### Joker AddStages

Each joker contains some keys linked to functions, the keys being as above in full joker activation stages. OnBuy is only called once at the start. OnSell is called when the joker is sold. Most stages are added through a function called AddStages which adds the functions according to the keys to the correct stage tables, to be called when needed.

### Joker ShiftUpdate

Some jokers have a function called ShiftUpdate. Despite the name, this is called not only when jokers are dragged, but also when new jokers are added via addnewjoker. This means shiftupdate takes care of joker-position-specific effects like the copy jokers, and also updates joker-composition-specific effects like Joker Stencil.

#### Copy Jokers (Bluestorm)

Some jokers will have a tag that states they can't be copied. Some jokers have a table with a list of which of their functions are ok to copy. The rest will simply have all of their functions except onBuy copied.

Copy jokers gain their effects during the shiftupdate stage. When blueprint attempts to copy, it is checked if the target is blueprint or brainstorm. If so, it will force the other joker to shiftupdate first, so that it copies the updated effect of the joker.

### Joker myJSlotId

Some jokers rely on knowing their joker slot position, such as all on score or on hand jokers. These jokers have a key called myJSlotId, who's value is updated on buy and after every shift.