<include from="see-also.topic" element-id="see-also-2params">
    <var name="topic1" value="FATE.md"/>
    <var name="topic1-summary" value="We got a healthier work environment as a result of step 3."/>
    <var name="topic2" value="RYFT.md"/>
    <var name="topic2-summary" value="We added more content because I gave reliable estimates."/>
</include>

# Design Process
<primary-label ref="lum"></primary-label>

<tldr>
<p>I always design <a href="https://www.riotgames.com/darkroom/original/1b58ddf664999d1e51c7a5ee3908f3e3:aedf85c30ef9072a3f1530b2d05706dc/riot-games-fact-sheet-2023.pdf" summary="Riot Games' mission statement, which I follow wholeheartedly.">in favour of the player</a>, because once shipped, it's no longer my/our game – it's the players' – and the best we can do is serve them well.</p>
</tldr>

<tabs>
<tab title="Process" id="v2">

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

<include from="Skills-and-Process.md" element-id="i-design-for"/>
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
This benefits the whole team through less stress and less crunch, and it has held up in group projects such as <tooltip term="FATE-Example">FATE</tooltip> and <tooltip term="RYFT-Example">RYFT</tooltip> (hover/tap for examples)
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
<a href="Prototyping.md" as="button" mode="classic">Read about the 'Prototyping' course.</a>
</tab>
</tabs>

<quote>
<p>Read more about my design process in:</p>
<a href="FATE.md#design-process" as="button" mode="classic" icon="enter" size="s">FATE</a>
<a href="RYFT.md#design-process" as="button" mode="classic" icon="enter" size="s">RYFT</a>
<a href="Somnium.md#weapons-and-ability" as="button" mode="classic" icon="enter" size="s">Somnium</a>
</quote>