# Table Quick Reference

Both for me and anyone else who might read this in the future... (sorry)

This project contains quite a few indexes which stand for different things, I'm going to try to keep a reference to which index goes with each status here.

## Rank

|id|rank|
|---|---|
|1|Ace|
|2-10|2-10|
|11|J|
|12|Q|
|13|K|
|99|Stone Card|

## Suite

|id|suite|
|---|---|
|1|Spades|
|2|Hearts|
|3|Clubs|
|4|Diamonds|
|-3|Stone Card|

When smeared joker active, 1 is black, 0 is red

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
|6|Glass Card*|OnScoreScoring (Breaks PostScoreEffects)|
|7|Steel Card*|OnScoreHand|
|8|Gold Card*|Pays out PostScoreEffects|

\* = Not yet implemented

## Seal

None currently show or function (Gold seal might) WIP

|id|Mod/Enhancement|When Scored
|---|---|---|
|0|No Seal|NA|
|1|Purple|Gives Tarot on Discard|
|2|Blue|Gives Planet PostScoreEffects|
|3|Gold|OnScoreScoring|
|4|Red|OnScoreScoring, OnScoreHand (if an effect took place)|

## Edition (Playing Cards)

Might work, haven't tested, won't show up at least

|id|Mod/Enhancement|When Scored
|---|---|---|
|0|No Edition|NA|
|1|Foil|OnScoreScoring|
|2|Holographic|OnScoreScoring|
|3|Polychrome|OnScoreScoring|

## Edition (Jokers)

Given that jokers are not implemented this is stc, negative is slot -1 to not get in the way with scoring tbh (and also a little bc funny)

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
6. 


## Scoring tldr

Order of scoring same as in real balatro:
1. OnPlayEffects (not really scoring but midas mask, DNA, ect)
2. OnScoreScoring
3. OnScoreHand
4. OnScoreJoker

Currently only OnScoreScoring takes place as of this demo. Ignore the declarative language implying otherwise, this is for future implementation

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
OnScoreJoker iterates over all jokers and applies their appropriate effects, if applicable. Can iterate more than once over same joker if it has multiple effects (like an edition for example), similar to onScoreScoring.

#### Baseball Card

Baseball card scores OnScoreJoker whenever it iterates over a uncommon joker.