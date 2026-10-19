# RYFT

<primary-label ref="ryft"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unreal"></secondary-label>
<secondary-label ref="angelscript"></secondary-label>
<secondary-label ref="c++"></secondary-label>

## Movement

<quote>
<p>Breaking down the many iterations of the player's movement, its complexity, skill expression, and evolution from genre to genre.</p>
</quote>

The design of the movement went through nearly half a dozen iterations in the span of 4–6 weeks.  
I was **solely responsible** for the design and implementation of the movement: The **character controller**, **abilities** (dash, grapple, wallrun, double-jump, slide, etc.), sense of speed, **speed-tech**, and more.

### Iteration 1

Our first iteration was 'inspired' by Neon White. To say inspired is a bit equivocal, since I tried my best to replicate it one-to-one (aside from the movement abilities).  

We received plenty of feedback that your momentum was stripped from you at an instant, which doesn't feel great in a speedgame all about going fast. I remedied it by adding
accel-and-deceleration, something the original iteration did not use.

#### Iteration 2

Feedback on the second iteration was steadily improving, but the sense of speed was still not there.  
Speedlines and modulating field of view based on your actions and velocity were added to sell the sense of speed.

### Iteration 3

Finally, with iterations three and four, the real sense of speed was achieved.  
We had slowly strayed away from our original reference game (Neon White) over the course of the project, and by the time iteration three came around, I knew it was time to make
some big changes to the movement.  
The first addition in iteration 3 was sliding:
<p><img src="ryft_sliding.gif"  thumbnail="true" alt=""/></p>
<quote>Early development footage of sliding.</quote>

Sliding was added for two reasons:
- I really wanted sliding in the game. Perhaps not the strongest argument, but after prototyping it, the rest of the development team liked it enough for us to keep it.
- We needed a way to carry momentum after a long fall, *or while moving especially fast (*iteration 4).

#### Inertia

The identifying feature of iteration three was the addition of 'inertia'.  
'Inertia' is the system behind gaining and carrying momentum through the level. It also affects your speed quite drastically, depending on your actions and how you combine them.  

Performing actions like sliding or using your abilities grants a stack of inertia for a duration (depending on the action), for a maximum of 3 stacks and a maximum duration of 2.5s (at the time).
While you have any inertia stacks, you gain +650 units of speed (base speed = 1000 units, max = 2000).  

However, inertia needs to be managed and considered with every jump and ability used. If your inertia expires, you lose all the benefits and slow down drastically. Not too slow to beat the level, but not particularly fast either.

This effect alone enabled players to travel far quicker than they ever could before, and created new skips on all existing levels, which saw the game receive even more traction during development.

### Iteration 4

The iteration that fundamentally changed the trajectory of the game (and the player, hah!) was iteration four.  
There were enough changes with this iteration that I felt the need to write patch notes for the dev team:

#### Patch Notes { collapsible="true" default-state="collapsed" }
- walk speed has been raised by 200 units (800 -> 1000)
- wall-kicks now grant 100 units of speed. (capped at the max move speed of 2000 units)
- inertia gained by sliding has been increased by 1s (0.5s -> 1.5s)
    - you can still gain >1.5s of inertia by sliding down slopes.
- through a combination of all movement mechanics, it is now possible to remain supersonic for as long as you are utilizing your movement mechanics as well as possible.
- speedzone speed buff reduced by 10 percentage points. (+35% -> +25%)
- increased FOV gains from speedzones.
    - reducing the speedzone buff enabled me to keep the total movement speed the same. By increasing the FOV, the perceived speed remains equivalent, if not greater.
- `State.Movement.Supersonic` is now a valid tag.
- Added camera roll. Will be an adjustable setting in the near future.
- Slide carries momentum between walls and speedzones. I.e., if you wall-kick off a runwall, and slide as you land on a speedzone, the momentum will be fully retained. If you don't
  slide, you will lose most of your momentum (through friction). Either way you gain the speed boost from the speedzone.
- Added view bobbing while walking.  

#### Iteration 4 (continued)
As you can see, there are a lot of changes, and far too many to reason each one.  
One detail that stands out is point number 2: `wall-kicks now grant 100 units of speed. (...)`

While iterating on the movement, around iteration 3, I sought to add more movement tech to the game; to increase the skill ceiling – something not every player will use, but something those who wish to master the game can explore.  

As an avid fan of Titanfall 2 and its movement – which deserves a spot in the speedgame hall-of-fame – I looked to my favourite TF2 speedrunner: [Zweek](https://www.youtube.com/@zweekSR)  

Zweek has made many videos on the internals of Titanfall's movement, including diving into the source code of the engine. These videos served as the foundation for how I would later implement our versions of some of these mechanics.
<p><img src="zweek_videos_transparent.png"  thumbnail="true" alt=""/></p>

I wanted to see if any of Titanfall's movement tech could work in ours, beginning with air-strafing:

#### Air-Strafing
My fellow designer [Ege Barış Öncü](https://www.linkedin.com/in/egebarisoncu) and I looked into the Quake source code and Zweek's video on air strafing to get a better understanding of how it works.  

A short explanation: As you look away from the direction you're travelling, and the closer your look vector gets to being perfectly perpendicular with your movement vector, the more speed you gain.  
An oversimplification, but a necessary one. For more details, please watch [Zweek's video](https://www.youtube.com/watch?v=gRqoXy-0d84) on this.

We realized after a couple of hours of tinkering, however, that this was not the right fit for our game, and I moved on to the next mechanic:

#### Wall Kicks
Wall Kicks are my favourite movement mechanic in Titanfall, as they are your main source of maintaining and gaining speed in the speedrun.    

By jumping off a runwall (any wallrunnable surface) within X frames (12 in Titanfall, 8 in RYFT), you gain some speed. By chaining multiple wall kicks together, you can build up more and more speed, but if you miss a single one, you lose a majority of your speed.   

RYFT's wall kicks stack up to 5, granting +100 units of speed each. Additionally, each stack increases your maximum movement speed above the base cap of 2000 units (to a maximum speed of 2500 units).
This enables great runners to plan their route in favour of more wall kicks to reach a faster top speed, enabling skips that may not be otherwise possible (for example, on the levels Zig-Zag and Lurch)

A skill check for players who want to achieve the absolute fastest times, but absolutely not a requirement for casual players. All levels are made with wall kicks in mind, but are never a requirement for the best medal.

#### Air Control
Air Control is a common variable in all games with vertical movement: The speed at which you move in the air relative to your grounded walk speed, or put simpler: The amount of control you have in the air (0–1).  

In game design, there's a concept known as 'kiss-curse': I give you something positive, but in return, I take something away from you.  

Our take on air control is to reduce it non-linearly as you near your maximum speed. For example, by performing wall kicks and/or gaining inertia, you increase your speed and can complete the level quicker, but your overall mobility is reduced, making it more difficult to turn in the air.  
You will need to plan out your route in finer detail, accounting for the reduced mobility if you wish to move at a faster rate.

#### Strafe Lurch
An odd mechanic we adopted from Titanfall 2 that gives you a slight lateral boost on initial button press while airborne.  

For example, pressing A or D while airborne pushes you slightly further in that direction than if you were walking left/right and jumped for one frame.  
It serves as an invisible handhold that makes it slightly easier to move in the air, especially when your air control is lowered.

However, an unintended side effect left in on purpose, due to its use as speed-tech, is to use Strafe Lurch to boost yourself in your desired direction of travel.  

For instance, pressing A/D after turning 90 degrees perpendicular to my movement vector will push me parallel to my movement, essentially acting as a small speed boost until you land.  
A very minor, but interesting mechanic that players can master to reach unintended speed.

### Iteration 5
As of writing, we are on iteration 5, which doesn't make nearly as many changes as the previous two iterations.  
For example, inertia no longer has a cap and can be stacked infinitely, so long as you have the resource necessary to use your abilities. Actions like sliding use a derived version of inertia which has its own stacking, so you can't infinitely stack it by spamming the slide.

## User Interface

I was the sole designer for all UI in the game.  
All UIs were designed and developed by me.

The style of the UI was largely inspired by this image:
<p><img src="ryft_ui_inspo.png"  thumbnail="true" alt="" width="490"/></p>
We dubbed it the 'VCR-style', and it set the tone for how all UI would look moving forward, for two main reasons:
- Incredibly easy to derive and create multiple versions from.
- Looks retro and fits our pre-established visual style.

There are over 30 widgets in RYFT, with an overwhelming majority using this style.  
Some examples include:

<table width="auto">
    <tr>
      <td><img src="RYFT_PreStageWidget.png" thumbnail="true" alt=""/></td>
      <td><img src="RYFT_MakeMixtapeWidget.png"  thumbnail="true" alt=""/></td>
    </tr>
</table>

On the other hand, some widgets use the 'CRT-style':
<p><img src="RYFT_PostPostStageWidget.png"  thumbnail="true" alt="" width="490"/></p>
The decision as to what style something should use depends on whether it is a modal/tip, or a full-screen overlay.  
For instance, the <code>MakeMixtapeWidget</code> is a modal with many buttons and configuration, so it uses the VCR style.  
The <code>PreStageWidget</code>, however, covers the full screen and has no obvious buttons (there are some hover interactions, but otherwise the menu is dismissed with keyboard/controller inputs)

The UI has only ever gotten praise, with the very little feedback we did get pertaining to feature requests, rather than constructive criticism.

I am very proud of my work on the UI. I believe it shows that I am willing to learn new things outside my comfort zone, as UI was previously something I distanced myself from, that
I ultimately relegated myself to since *someone* has to do it eventually.

## Closing Thoughts

Very proud of myself and the team for this achievement.  
Reach out on [LinkedIn](https://www.linkedin.com/in/itslumina), [Discord](https://discordapp.com/users/287272193946288129), or via [email](mailto:itsluminas@gmail.com).

<seealso style="cards">
    <category ref="credits">
        <a href="Credits.md" summary="Contact info for all my current and former colleagues."/>
    </category>
</seealso>
