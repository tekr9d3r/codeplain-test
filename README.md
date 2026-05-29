# Codeplain Demo — Memory Match in Elm

A live demonstration of [codeplain](https://codeplain.ai) — a tool that turns plain-language specs into working code.

## What's in this repo

| File | Description |
|---|---|
| `memory-match-elm.plain` | The spec file — the only thing written manually |
| `presentation.html` | Demo page with the game embedded, render stats, and comparison |
| `plain_modules/memory-match-elm/` | Generated Elm source code + compiled `index.html` |

## How it was built

1. A `.plain` file was written describing the game in plain English
2. `codeplain memory-match-elm.plain` was run in the terminal
3. Codeplain rendered all 8 functionalities in **2 minutes 5 seconds**
4. The output was compiled to a single `index.html` with `elm make`

Zero lines of game code were written manually.

## The .plain file

```
***definitions***

- :App: is a memory match card game.
- :Card: is a game tile with a hidden face-down state and a revealed face-up state.
- :Board: is the 4x4 grid of :Card:s displayed to :Player:.
- :Player: is the person playing :App:.

***implementation reqs***

- :Implementation: should be in Elm.
- :App: should follow The Elm Architecture (Model, Update, View).
- :Board: should contain 16 :Card:s made up of 8 matching pairs of emoji symbols.

***functional specs***

- At the start of the game, all :Card:s are face-down and randomly shuffled.
- :Player: can flip a :Card: face-up by clicking on it.
- Matching pairs stay face-up. Non-matching pairs flip back after 1 second.
- :App: tracks and displays the number of moves :Player: has made.
- :App: displays a congratulations message when all pairs are matched.
- :Player: can restart at any time via a "New Game" button.
```

## Render stats

- **Total time:** 2 minutes 5 seconds
- **Functionalities rendered:** 8
- **Files generated:** 2 (`Main.elm`, `MemoryGame.elm`)
- **Language:** Elm 0.19.1
- **Codeplain version:** v0.3.1
- **Lines written manually:** 0

## Links

- [codeplain.ai](https://codeplain.ai) — official website
- [plainlang.org](https://plainlang.org/) — documentation
- [platform.codeplain.ai](https://www.codeplain.ai/) — get started
