# Prototyping
<primary-label ref="plora"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unity"></secondary-label>
> This breakdown was written as part of the prototyping course at Futuregames and therefore has a different structure from my usual breakdowns.
> A gameplay video can be seen at the bottom of the page. { style = "note" }

<video src="../../Writerside/videos/Prototype.mp4" width="500" preview-src="prototyping.png">
    <img src="prototyping.png" alt="Prototyping Course Preview" width="500" style="block"/>
</video>

## What is this project

The prototype is highly inspired by the likes of Titanfall 2, Neon White, and Mirror’s Edge.  
Run on the sides of buildings, jumping and dashing from wall-to-wall while scaling them vertically with your grappling arm.  

The intended audience is 16-24 year olds who enjoy rapid action and quick, precise movements akin to mechanics found in games that are frequently speedrun.  

The core mechanic, being the movement of the game, was developed in C# with the
help of my programming background, allowing me to be more ambitious. The
movement, grappling arm, camera, and visual effects were all made with my own code.
Only the two particle systems were pre-made assets.

## Why did I make these choices

From the inception of the idea, originally inspired by the Mirror’s Edge example from the
first lecture, I wanted to make a prototype that was truly a _prototype_. The code is a
complete and utter mess — on purpose.   

I chose the simplest and quickest solution to
every problem or addition to the game in the name of efficiency.
I could comfortably add or tweak any given mechanic or feature rapidly with little regard
for bugs, save for any game-breaking ones (which I fortunately did not encounter).
I have a deep passion for speedrunning, although I don’t do it much myself, I really enjoy
the concept of moving precisely through an environment in whichever way you can to
achieve the fastest possible time. It gives me the same feeling that immersive sims do,
but to a far lesser extent — that feeling of solving a puzzle or challenge in whichever
creative way you can come up with.   

This prototype has the goal of giving the player a sense of agency, giving them the option to tread their own path to the goal, rather than a  strict, predetermined route. It also comes with the added challenge of doing it as quickly
as possible.  

**Reasons for designing the game this way are threefold:**

Firstly, I am shockingly inexperienced with level design, and I think it shows. However, I
feel that it adds some charm to the gameplay, allowing you more freedom of movement,
simply because I am unable to pave a properly designed path.  

Secondly, to enhance the sense of competition and will to improve your time, I
added a ‘ghost’ of the player which treads the level on a predetermined path that I
personally recorded. The intention is for the ghost to take a relatively quick path, while
leaving room for improvement. That extra room for improvement is highly intentional, as
it gives the player enough of a gap to improve their technique to beat the ghost, while
still being difficult enough that it takes a handful of attempts.  

Finally, I have a philosophy when designing and creating games, based on my past five
years of experience: Make small, simple games that are highly polished.
I would much rather create something simple, yet complete, than something overly
complex and end up half-baked.  
While this prototype is neither complex nor simple, I do find it complete. It serves its
purpose as a proof of concept — and an idea turned reality. It showcases the complex
relationship between the 3C’s of game design:

- The movement is easy to pick up, but has layered complexity through its various
  mechanics and the way they are used in tandem. For instance, the dash is
  optional, but allows for far quicker times and potential sequence breaks.
- The controls support that same vision, being tied to only seven* keys total. The
  complexity comes in the way you combine your actions. Dashing before/after
  jumping, grappling to gain speed and/or flinging yourself, etc.
  *(WASD, Spacebar, and Left/Right-click, not counting the optional sprint and reset
  keys).
- And finally, the camera. By adjusting the field of view, shaking the camera on
  impact, adding speedlines when moving exceptionally quickly, and, although not
  necessarily a camera feature, the timers on the UI, collectively add a lot to the
  sense of speed and accomplishment.

The intended player experience, targeted at younger males who have a keen sense of
speed and mobility often found in FPS games, is to experience a sense of “controllable
turbulence.” In other words, you should feel like you are fully in control of your character’s trajectory, and it is up to your own creative problem-solving and skill expression to tread a path to the goal in whichever way is the quickest.  

A known consequence of targeting this specific niche is that the game may not be “for
everyone”. Some players may not enjoy the game at all, while others find it exactly “their
cup of tea”. I was aware of this, and even had it confirmed during playtests.  

The game provides you with a vague path to the end, but how you tread it and how
quickly is up to you. A conscious design decision was that any path other than the
“intended” one should be significantly quicker. This is highly evident in the initial level,
where the ‘default’ path follows a set of wall jumps off non-grappleable surfaces, while a
far quicker route requires you to grapple to red surfaces and scale multiple buildings off
the main path.  

The grappling arm alone is not the unique selling point, but a complement to the
movement system. They are inherently tied together and complement each other
through their own strengths and weaknesses. For instance, the movement on its own
can hardly scale a wall vertically, but together with the grapple, you can easily do so,
while gaining speed in the process. A reward for using the mechanic.
On the other hand, the grappling arm cannot traverse a level on its own. You are often
required to air strafe, wallrun, jump, and dash to reach advantageous positions where
you can then utilize your other tool.  

Further explanations on the design of the camera and controls can be viewed in the next
section:

## How did I make it

The prototype was developed wholly by me.  
Before becoming a designer, I had been making games since 2021, studying at LBS and Futuregames Malmö as a programmer (2024-2025). 
This background has helped me immensely, as it gives me far more time to ideate, design,
prototype, playtest, evaluate, and iterate (in that order, courtesy of the iterative process).  

I used Notion for jotting down initial ideas and thoughts; JetBrains Rider for my IDE of choice, and GitHub as version control.

Through a handful of playtests, I saw a couple of things that stood out to me.  
Firstly, the existence of an air-dash was often neglected, even when told of its existence.
This led me to add a dash indicator to the HUD, directly below the crosshair, where the
player’s eyes are often looking. This increased the air-dash use by participants
dramatically.  
Conversely, the air-jump/double jump did not require any tweaks at all, as
players would often hit the space bar in a desperate attempt to jump, not realizing at the
moment that it would actually work (this was true even if they knew it existed).  

During another playtest, a player mentioned that they really appreciated the on-screen
timers, displaying the RTA (“Real-time attack”) and IGT (“In-game time”), a display of the
unscaled time, and the scaled time, respectively. Since the game can be slowed down
by the player at any point, this could lead to an advantage due to the enhanced precision
it allows. Therefore, a separate timer for potentially slowed gameplay was deemed
necessary for competitive integrity.  

The timers give you an incentive to improve, a score to chase.
Two participants acknowledged that they felt like they were improving and having more
fun doing so, because they could see the time it took to complete the level decrease
with each successful attempt.  

Another participant was struggling to press the dash key, which at that point was bound
to **Left Shift**. Seeing that struggle, I decided to move the dash to **Left-Click** , to be one
less key to worry about on the keyboard, as players were already dealing with the
complexity of regular movement. This also resulted in players using the dash far more.  

Finally, through my own personal playtests, conducted frequently (because I was having
fun playing the game myself), I deemed a shift in where speed was gained necessary.
For instance, I originally shifted the top speed while in the air to a higher value (**35**),
while lowering the ground speed (**25**).  
After playing through the initial level a few times, I felt like I was too slow on the
ground, and too quick in the air, resulting in the speed being shifted once more to the
point at which it remained: high ground speed (**35**), and medium air speed (**30**).
The air-dash allows you to hit a theoretical max of **45 u/s**, not accounting for speed
gained by the grapple (theoretical max surpasses **100 u/s**)  

**Some additional design decisions include:**

- Switching the crosshair icon to a different, clearer icon when in range and looking
  at a grappleable surface.
- Adding a wall-run gauge below the crosshair, indicating how long you can stay on
  a given wall.
- Slowing the game down upon reaching the goal for ~1.5s, giving you the time to
  hit the reset key ( **R** ) if you wish to retry, even if you beat the level.
- Adding a ‘ghost’ of the player, playing through the level at a decent pace.
- A wind sound that scales its volume relative to velocity, making you feel like you
  are actually moving really fast.
- Clear colour-coded walls: Blue for wallrun, Red for grapple.  

**Some final thoughts to take away from this experience:**  
I would have loved to playtest more to get more honest, direct feedback. 
I felt like most players were afraid of giving critical feedback, be it out of kindness or
because they couldn’t see anything immediately negative about the experience.
Often, the feedback I got was “it’s good” or “it’s fun”.   
Poking for more information often yielded better results. 

Furthermore, had I been more experienced in level design, I would have loved to design
a better introduction to the game, rather than throwing them directly into it. The usual
design process of slowly introducing game mechanics would be a good start, but I felt
like it would drag out the prototype too long. Perhaps that was a misjudgment, and I’m
curious to see where I can learn from it in the future.  

I’m very grateful for this prototype, because it has shown me that I can go from idea to
playable prototype in very little time, while still having the tools necessary to extend,
iterate, and polish it with playtest feedback.

## Links

[Zipper.cs | Update()](https://gist.github.com/ltsLumina/2e44ae880536ec335c62e398ac34bc03) - The main function for grappling. Horribly coded, and all in Update(), but it works, and it only took 2.5 minutes to make.  
[Dash Logic and some Audio | Update()](https://gist.github.com/ltsLumina/55a63627dfe3f4f5e1b8d724a1f5c875) - Another example of terrible coding practices, but it doesn’t matter because it’s for a prototype, and therefore only took a few minutes to implement into a playable state. There’s even some leftover code from when
crouching was a thing.
