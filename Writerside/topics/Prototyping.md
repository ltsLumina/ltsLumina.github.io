# Design Process
<primary-label ref="lum"></primary-label>

<tabs>
<tab title="Process" id="v2">
<quote>
<p>I always design <a href="https://www.riotgames.com/darkroom/original/1b58ddf664999d1e51c7a5ee3908f3e3:aedf85c30ef9072a3f1530b2d05706dc/riot-games-fact-sheet-2023.pdf" summary="Riot Games' mission statement, which I follow wholeheartedly.">in favour of the player</a>, because once shipped, it's no longer my/our game – it's the players' – and the best we can do is serve them well.</p>
</quote>

<p>
Game Design is fundamentally about <a href="https://youtu.be/HqUbpJUiJFI?si=w4aYcasQNCvXvKY5" summary="A talk by Paul Bellezza (of Riot Games) on his journey as a game designer. An early inspiration and professional contact of mine.">solving interaction problems.</a><br/>
<tooltip term="The Door Problem">The door problem</tooltip> presents these problems as questions:
</p>
<list>
<li><p>Are there doors in your game?</p></li>
<li><p>Can the player open them?</p></li>
<li><p>Can the player open every door in the game?</p></li>
<li><p>Or are some doors for decoration?</p></li>
<li><p>etc.</p></li>
</list>

<procedure title="My thought process when designing:" collapsible="false">
    <step>Consider as many interaction problems as possible (writing them down, making flowcharts)</step>
    <step>Decide the relevance of designing around a given problem</step>
    <step>Account for the implementation's complexity and estimated time to develop</step>
    <step>Prototype the first iteration quickly to uncover unexpected problems</step>
    <step>Iterate on the original design through feedback and evaluation.</step>
</procedure>
<p>
This process closely resembles an <tooltip term="Iterative Design Loop">iterative design loop.</tooltip>
<br/>The goal is to find problems as early and cheaply as possible.
</p>

<chapter title="Elaboration" level="2" hide-from-structure="true">
<tip> Press a step to expand/collapse it.</tip>
<deflist type="full" collapsible="true" default-state="collapsed">
<def title="1. Consider the Players' Problems">

<include from="Portfolio.md" element-id="i-design-for"/>
<p>
Given the player type, I list as many potential interaction problems as I can imagine to give myself a broad overview of what I'm designing.
This is the first step because it takes the <b>least time and effort</b> – far less than testing each problem in a prototype, for example.
</p>
<p>
Problems that <i>seem</i> unlikely are <b>especially important to consider</b>: the more players there are, the more likely it is that someone hits them.
At scale, <i>"<tooltip term="Murphy's Law">anything that can go wrong will go wrong</tooltip>."</i>
</p>
</def>

<def title="2. Decide the Relevance">
<p>
Many of the interaction problems I come up with turn out to be irrelevant to design around.
<br/>Since <b>time and effort are finite</b>, I decide which ones are worth the cost.
</p>
<p>
For example; the question <code>What happens if there are two players?</code> can be safely disregarded in a single-player game with no plans for multiplayer.
</p>
<p>
More often than not, though, something I disregarded <b>ends up resurfacing later</b>.
This is usually because the original design has changed, and I have to revisit things I had previously dismissed.
When that happens, I communicate the issue to the design team, and we debate the problems together.
</p>
</def>

<def title="3. Account for Implementation">
<p>
A design is <b>only useful if it can be built in the time available</b>, so I weigh each design against what it would cost to implement.
My programming background (gameplay and engine/tooling) lets me do this comfortably for the technical side, and I'm familiar enough with art workflows like animation and 3D modelling to judge those fairly as well.
</p>
<p>
Because I know the time, tools, and effort it takes to develop something, I can give <b>reliable time and difficulty estimates</b>.
This benefits the whole team through less stress and less crunch, and it has held up in group projects such as <a href="FATE.md" summary="In FATE, a result of this step was a healthier work environment."/> and <a href="RYFT.md" summary="In RYFT, we were able to add more content because I was confident I could create the systems in time."/> (hover the links for examples)
</p>
</def>

<def title="4. Prototype">
<p>
Some problems <b>only appear once a design is playable</b>, and no amount of planning on paper will surface them, so I make a prototype to find them.
My programming background lets me prototype and iterate on game features rapidly, so <b>each iteration costs little and teaches me a lot</b>.
</p>
<p>
This is the step where I iterate the design the most, since it's where I discover both tech <u>and</u> design problems I hadn't accounted for, or ones that resurfaced from step 2.
</p>
</def>

<def title="5. Iterate through Feedback and Evaluation">
<p>
A prototype is <b>only useful if what it teaches feeds back into the design</b>, so I gather feedback from players and the team, evaluate the design myself, and fix problems as soon as I find them.
Each pass irons out kinks and leaves a more polished design, which the team and I iterate on further, starting the cycle anew.
</p>
<p>
This is the <tooltip term="Iterative Design Loop">iterative design loop</tooltip> from the start of this section. <br/>Repeating it is what <b>keeps problems cheap to find and fix</b>.
</p>
</def>

</deflist>
</chapter>
</tab>

<tab title="Example Project" id="v1">

> This breakdown details my design process and thinking through an example project I developed.

<video src="../../Writerside/videos/Prototype.mp4" width="500" preview-src="prototyping.png"/>

> This breakdown was written for the **prototyping course** at Futuregames and therefore has a different structure from my usual breakdowns. { style = "note" }

<chapter title="What's the project?" hide-from-structure="true">
<primary-label ref="plora"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unity"></secondary-label>

<p>
The prototype is highly inspired by the likes of Titanfall 2, Neon White, and Mirror’s Edge.  
Run on the sides of buildings, jumping and dashing from wall-to-wall while scaling them vertically with your grappling arm.
</p>
<p>The intended audience is 16–24-year-olds who enjoy rapid action and quick, precise movements akin to mechanics found in games that are frequently speedrun.</p>

<p>
The core mechanic, being the movement of the game, was developed in C# with the
help of my programming background, allowing me to be more ambitious. The
movement, grappling arm, camera, and visual effects were all made with my own code.
Only the two particle systems were pre-made assets.
</p>
</chapter>

<chapter title="Design Forethought" hide-from-structure="true">

<p>From the start of the idea, originally inspired by the Mirror’s Edge example from the
first lecture, I wanted to make a prototype that was truly a <u>prototype</u>. The code is a complete and utter mess — on purpose.</p>

I chose the simplest and quickest solution to every problem or addition to the game in the name of efficiency.
I could comfortably add or tweak any given mechanic or feature rapidly with little regard
for bugs, save for any game-breaking ones (which I fortunately did not encounter).
I have a deep passion for speedrunning, although I don’t do it much myself, I really enjoy
the concept of moving precisely through an environment in whichever way you can to
achieve the fastest possible time. It gives me the same feeling that immersive sims do,
but to a far lesser extent — that feeling of solving a puzzle or challenge in whichever
creative way you can come up with.

This prototype has the goal of giving the player a sense of agency, giving them the option to tread their own path to the goal, rather than a strict, predetermined route. It also
comes with the added challenge of doing it as quickly
as possible.

<p><b>Reasons for designing the game this way are threefold:</b></p>

Firstly, I am fairly inexperienced with level design, and I think it shows. However, I feel that it adds some charm to the gameplay, allowing you more freedom of movement,
simply because I am unable to pave a properly designed path.

Secondly, to enhance the sense of competition and will to improve your time, I
added a ‘ghost’ of the player which treads the level on a predetermined path that I
personally recorded. The intention is for the ghost to take a relatively quick path, while
leaving room for improvement. That extra room for improvement is highly intentional, as
it gives the player enough of a gap to improve their technique to beat the ghost, while
still being challenging enough that it takes a handful of attempts.

Finally, I have a philosophy when designing and creating games, based on my past five
years of experience: Make small, simple games that are highly polished.
I would much rather create something simple, yet complete, than something overly
complex and end up half-baked.  
While this prototype is neither complex nor simple, I do find it complete. It serves its
purpose as a proof of concept — and an idea turned reality. It showcases the complex
relationship between the 3C’s of game design:

<list>
<li><p>The movement is easy to pick up, but has layered complexity through its various
mechanics and the way they are used in tandem. For instance, the dash is
optional, but allows for far quicker times and potential sequence breaks.</p></li>
<li><p>The controls support that same vision, being tied to only seven* keys total. The
complexity comes in the way you combine your actions. Dashing before/after
jumping, grappling to gain speed, and/or flinging yourself, etc.
*(WASD, Spacebar, and Left/Right-click, not counting the optional sprint and reset
keys).</p></li>
<li><p>And finally, the camera: By adjusting the field of view, shaking the camera on impact, adding speedlines when moving exceptionally quickly, and -- although not
necessarily a camera feature -- the timers on the UI collectively add a lot to the sense of speed and accomplishment.</p></li>
</list>

<p>
The intended player experience, targeted at younger men who have a keen sense of speed and mobility often found in FPS games, is to experience a sense of <b>“controllable turbulence.”</b>
In other words, you should feel like you are fully in control of your character’s trajectory, and it is up to your own creative problem-solving and skill expression to
tread a path to the goal in whichever way is the quickest.</p>

<p>
A known consequence of targeting this specific niche is that the game may not be “for
everyone”. Some players may not enjoy the game at all, while others find it exactly “their
cup of tea”. However, to quote Arrowhead Studios: "<i>A game for everyone is a game for no one.</i>"
</p>

<p>
The game provides you with a vague path to the end, but how you tread it and how
quickly is up to you. A conscious design decision was that any path other than the
“intended” one should be significantly quicker. This is clear in the initial level,
where the ‘default’ path follows a set of wall jumps off non-grappleable surfaces, while a
far quicker route requires you to grapple to red surfaces and scale multiple buildings off
the main path.
</p>

<p>
The grappling arm alone is not the unique selling point, but a complement to the movement system. They are inherently tied together and complement each other
through their own strengths and weaknesses. For instance, the movement on its own can hardly scale a wall vertically, but together with the grapple, you can easily do so,
while gaining speed in the process. A reward for using the mechanic. On the other hand, the grappling arm cannot traverse a level on its own. You are often
required to air strafe, wallrun, jump, and dash to reach beneficial positions where you can then use your other tool.
</p>

<p>
Further explanations on the design of the camera and controls can be viewed in the next
section:
</p>
</chapter>

<chapter title="Implementation" hide-from-structure="true">

<p>I developed the prototype wholly.<br/>Before becoming a designer, I had been making games since 2021, studying at LBS and Futuregames Malmö as a programmer (2024–2025).
This background has helped me immensely, as it gives me far more time to ideate, design,
prototype, playtest, evaluate, and iterate (in that order, courtesy of the iterative process).</p>
<p>I used Notion for jotting down initial ideas and thoughts; JetBrains Rider for my IDE of choice, and GitHub as version control.</p>
<p>Through a handful of playtests, I saw a couple of things that stood out to me.<br/>Firstly, the existence of an air-dash was often neglected, even when told of its existence.
This led me to add a dash indicator to the HUD, directly below the crosshair, where the
player’s eyes are often looking. This increased the air-dash use by participants
dramatically.<br/>Conversely, the air-jump/double jump did not require any tweaks at all, as players would often hit the space bar in a desperate attempt to jump, not realizing at the
moment that it would actually work. (This was true even if they knew it existed.)</p>
<p>During another playtest, a player mentioned that they really appreciated the on-screen
timers, displaying the RTA (“Real-time attack”) and IGT (“In-game time”), a display of the unscaled time, and the scaled time, respectively. Since the player can slow down
the game at any point, this could lead to an advantage due to the enhanced precision
it allows. Therefore, a separate timer for potentially slowed gameplay was deemed necessary for competitive integrity.</p>
<p>The timers give you an incentive to improve, a score to chase.
Two participants acknowledged that they felt like they were improving and having more
fun doing so, because they could see the time it took to complete the level decrease
with each successful attempt.</p>
<p>Another participant was struggling to press the dash key, which at that point was bound
to <control>Left Shift</control>. Seeing that struggle, I decided to move the dash to <control>Left-Click</control> , to be one
less key to worry about on the keyboard, as players were already dealing with the
complexity of regular movement. This also resulted in players using the dash far more.</p>
<p>Finally, through my own personal playtests, conducted frequently (because I was having
fun playing the game myself), I deemed a shift in where speed was gained necessary.
For instance, I originally shifted the top speed while in the air to a higher value (<control>35</control>),
while lowering the ground speed (<control>25</control>).<br/>After playing through the initial level a few times, I felt like I was too slow on the
ground, and too quick in the air, resulting in the speed being shifted once more to the
point at which it remained: high ground speed (<control>35</control>), and medium air speed (<control>30</control>).
The air-dash allows you to hit a theoretical max of <control>45 u/s</control>, not accounting for speed
gained by the grapple (theoretical max surpasses <control>100 u/s</control>)</p>

<p><b>Some additional design decisions include:</b></p>

<list>
<li><p>Switching the crosshair icon to a different, clearer icon when in range and looking
at a grappleable surface.</p></li>
<li><p>Adding a wall-run gauge below the crosshair, indicating how long you can stay on
a given wall.</p></li>
<li><p>Slowing the game down upon reaching the goal for ~1.5s, giving you the time to
hit the reset key ( <control>R</control> ) if you wish to retry, even if you beat the level.</p></li>
<li><p>Adding a ‘ghost’ of the player, playing through the level at a decent pace.</p></li>
<li><p>A wind sound that scales its volume relative to velocity, making you feel like you
are actually moving really fast.</p></li>
<li><p>Clear colour-coded walls: Blue for wallrun, Red for grapple.</p></li>
</list>

<p><b>Some final thoughts to take away from this experience:</b><br/>I would have loved to playtest more to get more honest, direct feedback.
I felt like most players were afraid of giving critical feedback, be it out of kindness or
because they couldn’t see anything immediately negative about the experience.
Often, the feedback I got was “it’s good” or “it’s fun”.<br/>Poking for more information often yielded better results.</p>

Furthermore, had I been more experienced in level design, I would have loved to design
a better introduction to the game, rather than throwing them directly into it. The usual
design process of slowly introducing game mechanics would be a good start, but I felt
like it would drag out the prototype too long. Perhaps that was a misjudgment, and I’m
curious to see where I can learn from it in the future.

I’m very grateful for this prototype, because it has shown me that I can go from idea to
playable prototype in very little time, while still having the tools necessary to extend,
iterate, and polish it with playtest feedback.

</chapter>
<chapter title="Links" hide-from-structure="true">
<p>
<a href="https://gist.github.com/ltsLumina/2e44ae880536ec335c62e398ac34bc03">Zipper.cs | Update()</a> - The main function for grappling. Horribly coded, and all in Update (), but it works,
and it only took 2.5 minutes to make.  
<br/><a href="https://gist.github.com/ltsLumina/55a63627dfe3f4f5e1b8d724a1f5c875">Dash Logic and some Audio | Update ()</a> - Another example of terrible coding practices, but it doesn’t matter
because it’s for a prototype, and therefore only took a few minutes to implement into a playable state. There’s even some leftover code from when
crouching was a thing.
</p>
</chapter>
</tab>
</tabs>
