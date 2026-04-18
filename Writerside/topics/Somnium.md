# Somnium
<primary-label ref="somnium"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unity"></secondary-label>

Somnium is a retro-inspired dungeon-crawler, created by a wonderful team of 11 talented people.  
Below is a breakdown of my decisions, thoughts, and experiences, throughout its development foo foo.

## Design Responsibilities
My responsibilities as a designer included — but were certainly not limited to:
- The behaviour and implementation of enemy behaviour for two enemy types.
- Weapons (dagger and staff), including the force-push ability.
- Gameplay feel and experience.

### Enemies
In terms of the enemies' design and their implementation, I had a few clear goals in mind:  
- **Enemies should be simple and squishy. No complex path-finding, and not bullet-sponges.**  
- **Should react to the environment. E.g., dying to traps, and/or being pushed around by boxes. (Immersive-Sim-esque)**  

I knew we had to keep enemies simple to have enough time to develop them within such a short timeframe. I didn't think they should be tanky, as that would lead to cognitive dissonance (simple doesn't correlate with tough).
However, with simple enemies often comes the nature of not being very interesting — which I solved through the immersive-sim mechanics.

Enemies were designed to feel part of the world, and that their actions respect its rules just as much as yours do.
This made enemies feel harmonious and intentional, rather than just an obstacle — all without adding any additional mechanics.

Originally, there were no plans for enemies to have any additional logic beyond chasing the player and attacking, but as I was testing physics-based boxes for the force-push ability,
I had the idea of incorporating them into the environment. 
The moment I saw a tower of boxes fall onto an enemy, I had to show my team. That moment defined the design of the game moving forward.  

**The most integral and fun mechanic of the game was the result of testing an entirely unrelated mechanic.** 

The following video is not the original moment but a recreation I made to show my teammates.

![somnium-crates-gif.gif](../videos/somnium-crates-gif.gif)

### Weapons & Ability
As mentioned in the previous section, the force-push ability instantly went from a small addition to create space between enemies, to the selling-point of the game.  
Additionally, we had planned to add two weapons:
- **A short-ranged melee weapon (dagger), which would teach you the basics of the game without overwhelming you.**
- **Highly powerful, ranged weapon (staff) with a couple of optional upgrades. Emphasizes the power fantasy.**

Our first play-test with our target audience (7–10 year olds) highlighted some key aspects of the experience that we wanted to emphasize — for instance, **the power-fantasy.**  
Everytime a player unlocked the staff, they became highly engaged with the game — much more than with the dagger. They also went out of their way to kill all enemies since they had a weapon that felt rewarding to use.  

Besides emphasizing the power-fantasy further, we decided to increase the difficulty of the game toward the final third of the game, as enemies were feeling a bit too weak once the staff was unlocked.
We achieved this increase in difficulty by introducing a higher-tiered version of our enemies that posed higher health and damage values. We also increased the density of enemies in key areas.

### Gameplay Feel & Experience

Once we decided on the project's core premise, I knew I wanted to incorporate immersive-sim features into this experience.  
The main inspiration behind this is the flawless "TLOZ: Breath of the Wild," which demonstrates a world where everything works as you expect.  
- **You can push a rock, and it can roll down the hill and strike all the enemies in a camp.**  
- **You can fire an arrow through a torch that ignites a rope, which burns down a chandelier onto an enemy.**  

Anything you can imagine and expect to happen, very likely will. That feeling was something I wanted to capture in Somnium.  

Adding physics-based crates was the first step. An easy addition that gives the player agency to interact with the environment, albeit in a very lackluster way.
At the start, crates would go flying when you 'kick' them (force-push ability, internally named 'kick'), but nothing else happened.  

That's when the idea of kicking crates, doors, and more into enemies began. Before we knew it, we could kick enemies into traps, enemies into enemies, and more.
The layers of interaction compounded quickly but remained simple — something I communicated we had to ensure.  

Doors were placed between rooms not to hide what's next, but mainly as a way to announce "I'm here!" — another instance of emphasizing our intended player-fantasy.

## Programming Lead as a Designer
Despite being a designer on this project, I took the responsibility of programming lead alongside my responsibility as combat design lead.  

My experience working in cross-disciplinary teams as a programmer was greatly appreciated by the programmers on our team, as they felt they could ask me for guidance.
I was happy to lay the foundation of our game's framework and architecture in a way that enabled everyone to pick a task and have a foundation to work from, rather than starting from scratch.
Due to the project only lasting a couple of weeks, this foundation granted us a much-needed basis to work from.

Besides laying the foundation, I regularly provided guidance and mentoring to our programmers, teaching them new features, tricks, and optimizations to use throughout the project. Their gratitude was never understated.

Finally, through my experienced hardships and countless hours of troubleshooting, I was able to efficiently work around bugs and other glitches with the team.
By the end of the project, we had **squashed every single discovered bug**, a total of over **150**.

## Closing Remarks

Having been such a short project, I never imagined we would create such a remarkable and memorable experience, nor that we would win an award for it.  

I am eternally grateful to all my teammates — my friends — who made this game into what it is.  
An experience I will cherish, a highlight in my career, and a moment of personal growth.