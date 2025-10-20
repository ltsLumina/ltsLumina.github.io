---
switcher-label: Puzzle
---

<show-structure for="chapter,procedure" depth="0"></show-structure>

# Breakdown
<primary-label ref="palindra"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unreal"></secondary-label>

> Press the "Puzzle" switcher in the top right of the website, left of the "Reach out!" button to switch between different puzzle designs. { style = "note" }

## Piano Puzzle {switcher-key="Piano"}

The piano puzzle was designed with the intent of being an interactive puzzle, providing audio and visual feedback to the
player. The player must find and play the correct sequence of notes to receive a key required for progression.

<img src="palindra-piano-past.png" alt="A screenshot from the piano room in the 'past' timeline in PALINDRA." width="500"></img>

Inside the piano room, the piano takes center stage, marking it as the focal point of the puzzle.
The player can interact with the piano keys, which produce a corresponding note when pressed. The correct sequence of
notes is supplied through environmental storytelling, with sheet music locked behind a prior puzzle.

Originally, the sheet music was designed to be part of a larger cryptographic puzzle, but due to time constraints, it
was simplified to a direct note sequence.

<table width="600">
  <tr>
    <td>
      <img src="practice sheet.png" alt="Palindra Screenshot 1" width="300"/>
    </td>
    <td>
      <img src="ciphered sheet.png" alt="Palindra Screenshot 2" width="300"/>
    </td>
  </tr>
</table>

In the end, the player must play "In the End" by Linkin Park to solve the puzzle, which is a funny tie-in to my personal love for Linkin Park, the piano puzzle being the final puzzle, and also as a nod to the theme of time present in PALINDRA.

## Implementation { switcher-key="Piano" id="implementation_piano" }

I created all logic for the puzzle in Blueprints.  
The piano keys are implemented as interactable objects that play a sound and animate when pressed.  
A system is in place to check the sequence of notes played against the correct sequence, and if any key is  incorrect, the list of pressed keys resets to allow for a new attempt at playing the sequence.

## Fireplace Puzzle {switcher-key="Fireplace"}

The fireplace puzzle was one of our stretch-goal puzzles that we would love to include if we had the time, and luckily we did!  

Conceptually, we wanted a puzzle that would physically alter the environment in some way; like hindering traversal, but revealing potential clues.  

<table width="800">
  <tr>
    <td>
      <img src="palindra-fireplace-present.png" alt="A screenshot from the fireplace room in the 'PRESENT' timeline in PALINDRA." width="400" thumbnail="true" border-effect="rounded"></img>
    </td>
    <td>
      <img src="palindra-fireplace-past.png" alt="A screenshot from the fireplace room in the 'PAST' timeline in PALINDRA." width="400" thumbnail="true" border-effect="rounded"></img>
    </td>
  </tr>
</table>

While exploring the 'past' timeline, you can choose to light or extinguish the fireplace. The effect isn't immediately obvious, until you time-travel to the 'present' timeline.
Upon travelling to the present, depending on the state of the fireplace, the area which was once burned down and decrepit, is now mostly intact, but more importantly: traversable.  

<img src="palindra-fireplace-present-restored.png" 
alt="A screenshot from the fireplace room in the 'PRESENT' timeline in PALINDRA, showing the restored area after extinguishing the fireplace in the past." width="400" thumbnail="true">
</img>

The grandfather clock is part of a larger puzzle, granting access to a safe which contains the note sequence for the piano puzzle.
By repairing the clock, which is now accessible after extinguishing the fireplace in the past, the clock begins to chime at a specific time, displayed on the clock face.  
The clock chimes approximately every 60 seconds, with the clock hands moving in real-time to reflect the in-game time.
The player must decipher the time and input the corresponding numbers into the safe to retrieve the note sequence.  

After unlocking the safe, the clock stops chiming, indicating that the puzzle has been solved and to prevent further confusion.

## Implementation { switcher-key="Fireplace" id="implementation_fireplace" }
The fireplace puzzle was implemented using both C++ and Blueprints in Unreal Engine 5.
I was not responsible for coding the fireplace puzzle, but I did design the puzzle wholly.

## Section Three {switcher-key="Paintings"}

This section is not available yet - coming soon!