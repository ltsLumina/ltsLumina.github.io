---
switcher-label: Puzzle
---

<show-structure for="chapter,procedure" depth="0"></show-structure>

# Palindra
<primary-label ref="palindra"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unreal"></secondary-label>

> Press the "Puzzle" switcher in the top right of the website, left of the "Reach out!" button to switch between different puzzle designs. { style = "note" }

## Piano Puzzle {switcher-key="Piano"}

The piano puzzle was designed with the intent of being an interactive puzzle, providing audio and visual feedback to the
player. The player must find and play the correct sequence of notes to receive a key required for progression.

<img src="original-palindra-piano-concept.png" alt="The original concept for the piano puzzle." width="350" thumbnail="true" border-effect="rounded"></img>

This was the original concept for the piano puzzle. However, due to time constraints, we simplified the puzzle to focus on the core mechanic of playing the piano.

<img src="palindra-piano-past.png" alt="A screenshot from the piano room in the 'past' timeline in Palindra." width="500" thumbnail="true" border-effect="rounded"></img>

Inside the piano room, the piano takes center stage, marking it as the focal point of the puzzle.
The player can interact with the piano keys, which produce a corresponding note when pressed. The correct sequence of
notes is supplied through environmental storytelling, with sheet music locked behind a prior puzzle.  
The note that each piano key corresponds to is shown on the HUD when looking at a key.

<table width="600">
  <tr>
    <td>
      <img src="practice sheet.png" alt="Palindra Screenshot 1" width="300" thumbnail="true" border-effect="rounded"/>
    </td>
    <td>
      <img src="ciphered sheet.png" alt="Palindra Screenshot 2" width="300" thumbnail="true" border-effect="rounded"/>
    </td>
  </tr>
</table>

Originally, the sheet music was designed to be part of a larger cryptographic puzzle, but due to time constraints, it was simplified to a direct note sequence.
In the end, the player must play "In the End" by Linkin Park to solve the puzzle, which is a funny tie-in to my personal love for Linkin Park, the piano puzzle being the final puzzle, and also as a nod to the theme of time present in Palindra.

After conducting some playtests, we received mostly positive feedback about this puzzle. The only playtester who struggled to understand and complete the puzzle was an older gentleman who played very little games.  

Positive feedback consisted of applauds in adding a functioning piano, the background music being dynamic (when you leave the room the piano plays music on its own, and when you leave it stops), and the sound design, which was also done by me. 

**Overall, this puzzle was successful, largely thanks to us cutting the complexity due to the time restraints. A good example of scope management leading to a better end product.**

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
      <img src="palindra-fireplace-present.png" alt="A screenshot from the fireplace room in the 'PRESENT' timeline in Palindra." width="400" thumbnail="true" border-effect="rounded"></img>
    </td>
    <td>
      <img src="palindra-fireplace-past.png" alt="A screenshot from the fireplace room in the 'PAST' timeline in Palindra." width="400" thumbnail="true" border-effect="rounded"></img>
    </td>
  </tr>
</table>

While exploring the 'past' timeline, you can choose to light or extinguish the fireplace. The effect isn't immediately obvious, until you time-travel to the 'present' timeline.
Upon travelling to the present, depending on the state of the fireplace, the area which was once burned down and decrepit, is now mostly intact, but more importantly: traversable.  

<img src="palindra-fireplace-present-restored.png" alt="A screenshot from the fireplace room in the 'PRESENT' timeline in Palindra, showing the restored area after extinguishing the fireplace in the past." width="400" thumbnail="true"></img>

The grandfather clock is part of a larger puzzle, granting access to a safe which contains the note sequence for the piano puzzle.
By repairing the clock, which is now accessible after extinguishing the fireplace in the past, the clock begins to chime at a specific time, displayed on the clock face.  
The clock chimes approximately every 60 seconds, with the clock hands moving in real-time to reflect the in-game time.
The player must decipher the time and input the corresponding numbers into the safe to retrieve the note sequence.  

After unlocking the safe, the clock stops chiming, indicating that the puzzle has been solved and to prevent further confusion.

An issue that arose during playtesting was that it is not clear enough that the fireplace can be interacted with. This led to player frustration, and the player thinking that it's their fault that they cannot figure out how to progress, which was not the intended effect. In an attempt to remedy this issue, we added sparkle particle effects to anything interactable in the game world.

<table width="800">
  <tr>
    <td>
      <img src="palindra-fireplace.png" alt="The fireplace in Palindra." width="400" thumbnail="false" border-effect="rounded"></img>
    </td>
    <td>
      <img src="palindra-table.png" alt="A table with particles indicating that the table is interactable." width="400" thumbnail="false" border-effect="rounded"></img>
    </td>
  </tr>
</table>

While this certainly helped in most cases, the fireplace was still not obvious enough, and we had run out of time to make any drastic changes. Had we had more time, more foresight, and more playtesting sooner, a change could have been made.  
In retrospect, I would have liked to make all interactable objects stand out from the environment. I really admire how Mirror's Edge makes it obvious what can be mantled/vaulted/interacted, etc.

<img src="mirrors-edge-example.jpg" alt="A screenshot from Mirror's Edge showing how interactable objects stand out from the environment." width="500" thumbnail="true" border-effect="rounded"></img>

Had every interactable object had a piece of yellow cloth attached to it, or some other form consistent marker that contrasts the object it is attached to, I feel like it would make it clear to the player immediately what can be interacted with.  
This would be tutorialized within the first 15 seconds of gameplay, making it clear very early on.

**This showcases how I would approach a design problem that was brought to our attention through playtesting.**

## Implementation { switcher-key="Fireplace" id="implementation_fireplace" }
The fireplace puzzle was implemented using both C++ and Blueprints in Unreal Engine 5.
I was not responsible for coding the fireplace puzzle, but I did design the puzzle wholly.

## Painting Puzzle {switcher-key="Paintings"}

This section is not available yet - coming soon!