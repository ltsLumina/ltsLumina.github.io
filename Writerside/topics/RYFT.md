<include from="see-also.topic" element-id="see-also">
    <var name="topic" value="Prototyping.md"/>
    <var name="topic-summary" value="RYFT is the spiritual successor to this project."/>
</include>

# RYFT

<primary-label ref="ryft"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="group"></secondary-label>
<secondary-label ref="unreal"></secondary-label>
<secondary-label ref="angelscript"></secondary-label>
<secondary-label ref="c++"></secondary-label>

<tldr>
<p>‘RYFT’ is a first-person parkour speedgame set in a retro synthwave world, developed by 6 students.</p>
<p><a href="https://store.steampowered.com">Soon available on Steam</a></p>
</tldr>

<video src="https://youtu.be/GO6zLJVXBX8" preview-src="ryft_showcase.gif" width="800"/>

<quote>
<p>RYFT taught me to parse player feedback, iterate on features, and build systems that support future content.</p>
</quote>

<chapter title="Design direction" id="design-direction">
    <p>
        RYFT is a speedgame built around movement, momentum, and player mastery. The design evolved through several
        iterations as we tested whether the movement felt fast, controllable, and rewarding to improve.
    </p>
    <p>
        My design process was to identify traversal problems, decide which were worth solving, account for the
        implementation cost, prototype quickly, and iterate through feedback and evaluation. This meant repeatedly testing movement in playable levels rather than relying on the initial concept -- which by the end we had strayed far from.
    </p>
</chapter>

<procedure title="My design process for RYFT" collapsible="false">
    <step>Consider the interaction problems created by the current movement design</step>
    <step>Decide which problems were relevant enough to solve</step>
    <step>Account for implementation complexity and available development time</step>
    <step>Prototype the next movement iteration quickly</step>
    <step>Iterate through player feedback and evaluation</step>
    <p>
        This is the iterative design loop described in <b><a href="Design-Process.md">my design process</a></b>: find
        problems as early and cheaply as possible, then feed what the prototype teaches back into the design.
    </p>
</procedure>

<tabs>
    <tab title="Movement" id="movement">
        <p>
            Movement went through nearly half a dozen iterations over 4–6 weeks. I was <b>solely responsible</b>
            for its design and implementation, including the character controller, abilities, sense of speed,
            and speed-tech.
        </p>
        <img src="ryft_showcase.gif" thumbnail="true" alt=""/>
        <chapter title="Iteration 1" id="iteration-1">
            <p>
                The first iteration tried to replicate <i>Neon White</i>'s movement as closely as possible, aside
                from its movement abilities.
            </p>
            <p>
                Feedback showed that instantly losing momentum felt wrong in a speedgame about going fast. I addressed
                this by adding acceleration and deceleration.
            </p>
        </chapter>
        <chapter title="Iteration 2" id="iteration-2">
            <p>
                Feedback on the second iteration improved, but the sense of speed was still missing. Speedlines
                and a field of view that changed with actions and velocity helped communicate it.
            </p>
        </chapter>
        <video src="../videos/RYFT_MovementComparison.mp4" preview-src="RYFT_MovementComparison.gif" width="800"></video>
        <quote>A comparison between the second iteration of movement and the latest version of the game.</quote>
        <chapter title="Iteration 3" id="iteration-3">
            <p>
                Iterations three and four finally achieved the intended sense of speed. By then, the movement had
                strayed from the original reference enough that larger changes were justified. The first addition
                was sliding:
            </p>
                <img src="ryft_sliding.gif" thumbnail="true" alt=""/>
            <quote>Early development footage of sliding.</quote>
            <p>Sliding addressed two design problems:</p>
            <list>
                <li>
                    It carried momentum after a long fall and while moving especially fast.
                </li>
                <li>
                    It promoted agency and momentum. Although we initially worried it might become too prominent,
                    prototyping showed that it fit the game, so we leaned into it.
                </li>
            </list>
            <chapter title="Inertia" id="inertia">
                <p>
                    The identifying feature of iteration three was the addition of 'inertia'.
                    <br/>
                    Inertia is the system for gaining and carrying momentum through a level. It changes the player's
                    speed based on their actions and how they combine them.
                </p>
                <p>
                    Sliding and using abilities grant inertia for a duration based on the action, up to three stacks
                    and 2.5 seconds at the time. While any stacks remain, the player gains 650 units of speed
                    (base speed 1000, maximum 2000).
                </p>
                <p>
                    Inertia must be managed with every jump and ability. If it expires, the player loses its benefits
                    and slows down considerably, though not enough to make the level impossible to beat.
                </p>
                <p>
                    This enabled much faster movement and created new skips on existing levels, increasing the game's
                    traction during development.
                </p>
                <video src="../videos/inertia-demonstration-v2.mp4" preview-src="inertia-demonstration-v2.gif"></video>
                <quote>Demonstration of iteration 3 compared to iteration 2.<br/>When inertia is enabled, you have infinitely more momentum and control compared to iteration 2.
                        <br/>Conversely, when inertia is disabled (iteration 2), only your movement speed is increased.
                </quote>
            </chapter>
        </chapter>
        <chapter title="Iteration 4" id="iteration-4">
            <p>
                The iteration that fundamentally changed the trajectory of the game (and the player, hah!) was iteration four.
                <br/>
                There were enough changes with this iteration that I felt the need to write patch notes for the dev team:
            </p>
            <deflist title="Patch Notes" id="patch-notes" collapsible="true" default-state="collapsed">
<def title="Patch Notes">
<list>
                    <li>walk speed has been raised by 200 units (800 -&gt; 1000)</li>
                    <li>wall-kicks now grant 100 units of speed. (capped at the max move speed of 2000 units)</li>
                    <li>
                        inertia gained by sliding has been increased by 1s (0.5s -&gt; 1.5s)
                        <list>
                            <li>you can still gain &gt;1.5s of inertia by sliding down slopes.</li>
                        </list>
                    </li>
                    <li>through a combination of all movement mechanics, it is now possible to remain supersonic for as long as you are utilizing your movement mechanics as well as possible.</li>
                    <li>speedzone speed buff reduced by 10 percentage points. (+35% -&gt; +25%)</li>
                    <li>
                        increased FOV gains from speedzones.
                        <list>
                            <li>reducing the speedzone buff enabled me to keep the total movement speed the same. By increasing the FOV, the perceived speed remains equivalent, if not greater.</li>
                        </list>
                    </li>
                    <li><code>State.Movement.Supersonic</code> is now a valid tag.</li>
                    <li>Added camera roll. Will be an adjustable setting in the near future.</li>
                    <li>
                        Slide carries momentum between walls and speedzones. I.e., if you wall-kick off a runwall, and slide as you land on a speedzone, the momentum will be fully retained. If you don't
                        slide, you will lose most of your momentum (through friction). Either way you gain the speed boost from the speedzone.
                    </li>
                    <li>Added view bobbing while walking.</li>
                </list>
            </def>
            </deflist>
                <p>
                    As you can see, there are a lot of changes, and far too many to reason each one.
                    <br/>
                    One detail that stands out is point number 2: <code>wall-kicks now grant 100 units of speed. (...)</code>
                </p>
                <p>
                    While iterating on the movement, around iteration 3, I sought to add more movement tech to the game; to increase the skill ceiling – something not every player will use, but
                    something those who wish to master the game can explore.
                </p>
                <p>
                    As an avid fan of Titanfall 2 and its movement – which deserves a spot in the speedgame hall-of-fame – I looked to my favourite TF2
                    speedrunner: <a href="https://www.youtube.com/@zweekSR">Zweek</a>
                </p>
                <p>
                    Zweek has made many videos on the internals of Titanfall's movement, including diving into the source code of the engine. These videos served as the foundation for how I would
                    later implement our versions of some of these mechanics.
                </p>
                <p><img src="zweek_videos_transparent.png" thumbnail="true" alt=""/></p>
                <p>I wanted to see if any of Titanfall's movement tech could work in ours, beginning with air-strafing:</p>
            <deflist type="full" collapsible="true" default-state="collapsed">
            <def title="Air-Strafing" id="air-strafing">
                <p>
                    My fellow designer <a href="https://www.linkedin.com/in/egebarisoncu">Ege Barış Öncü</a> and I looked into the Quake source code and Zweek's video on air strafing to get a better
                    understanding of how it works.
                </p>
                <p>
                    A short explanation: As you look away from the direction you're travelling, and the closer your look vector gets to being perfectly perpendicular with your movement vector, the
                    more speed you gain.
                    <br/>
                    An oversimplification, but a necessary one. For more details, please watch <a href="https://www.youtube.com/watch?v=gRqoXy-0d84">Zweek's video</a> on this.
                </p>
                <p>
                    We realized after a couple of hours of tinkering, however, that this was not the right fit for our game, and I moved on to the next mechanic:
                </p>
            </def>
            <def title="Wall Kicks" id="wall-kicks">
                <p>
                    Wall Kicks are my favourite movement mechanic in Titanfall, as they are your main source of maintaining and gaining speed in the speedrun.
                </p>
                <p>
                    By jumping off a runwall (any wallrunnable surface) within X frames (12 in Titanfall, 8 in RYFT), you gain some speed. By chaining multiple wall kicks together, you can build up
                    more and more speed, but if you miss a single one, you lose a majority of your speed.
                </p>
                <p>
                    RYFT's wall kicks stack up to 5, granting +100 units of speed each. Additionally, each stack increases your maximum movement speed above the base cap of 2000 units (to a maximum
                    speed of 2500 units). This enables great runners to plan their route in favour of more wall kicks to reach a faster top speed, enabling skips that may not be otherwise possible
                    (for example, on the levels Zig-Zag and Lurch)
                </p>
                <p>
                    A skill check for players who want to achieve the absolute fastest times, but absolutely not a requirement for casual players. All levels are made with wall kicks in mind, but are
                    never a requirement for the best medal.
                </p>
            </def>
            <def title="Air Control" id="air-control">
                <p>
                    Air Control is a common variable in all games with vertical movement: The speed at which you move in the air relative to your grounded walk speed, or put simpler: The amount of
                    control you have in the air (0–1).
                </p>
                <p>
                    In game design, there's a concept known as 'kiss-curse': I give you something positive, but in return, I take something away from you.
                </p>
                <p>
                    Our take on air control is to reduce it non-linearly as you near your maximum speed. For example, by performing wall kicks and/or gaining inertia, you increase your speed and can
                    complete the level quicker, but your overall mobility is reduced, making it more difficult to turn in the air.
                    <br/>
                    You will need to plan out your route in finer detail, accounting for the reduced mobility if you wish to move at a faster rate.
                </p>
            </def>
            <def title="Strafe Lurch" id="strafe-lurch">
                <p>
                    An odd mechanic we adopted from Titanfall 2 that gives you a slight lateral boost on initial button press while airborne.
                </p>
                <p>
                    For example, pressing A or D while airborne pushes you slightly further in that direction than if you were walking left/right and jumped for one frame.
                    <br/>
                    It serves as an invisible handhold that makes it slightly easier to move in the air, especially when your air control is lowered.
                </p>
                <p>
                    However, an unintended side effect left in on purpose, due to its use as speed-tech, is to use Strafe Lurch to boost yourself in your desired direction of travel.
                </p>
                <p>
                    For instance, pressing A/D after turning 90 degrees perpendicular to my movement vector will push me parallel to my movement, essentially acting as a small speed boost until you
                    land.
                    <br/>
                    A very minor, but interesting mechanic that players can master to reach unintended speed.
                </p>
            </def>
            </deflist>
        <img src="ryft_thrash_fast.gif" thumbnail="true" alt=""/>
        <quote>Gameplay footage of speedrunning a stage using all the aforementioned movement tech.</quote>
        </chapter>
        <chapter title="Iteration 5" id="iteration-5">
            <p>
                As of writing, we are on iteration 5, which doesn't make as many changes as the previous two iterations.
                <br/>
                For example, inertia no longer has a cap and can be stacked infinitely, so long as you have the resource necessary to use your abilities. Actions like sliding use a derived version
                of inertia which has its own stacking, so you can't infinitely stack it by spamming the slide.
            </p>
        </chapter>
    </tab>
    <tab title="User Interface" id="user-interface">
        <p>
            I was the sole designer for all UI in the game.
            <br/>
            All UIs were designed and developed by me.
        </p>
        <p>The style of the UI was largely inspired by this image:</p>
        <p><img src="ryft_ui_inspo.png" thumbnail="true" alt="" width="490"/></p>
        <p>We dubbed it the 'VCR-style', and it set the tone for how all UI would look moving forward, for two main reasons:</p>
        <list>
            <li>Incredibly easy to derive and create multiple versions from.</li>
            <li>Looks retro and fits our pre-established visual style.</li>
        </list>
        <p>
            There are <b>over 85 widgets</b> in RYFT, with an overwhelming majority using the VCR style.
            <br/>
            Some examples include:
        </p>
        <table width="auto">
            <tr>
                <td><img src="RYFT_PreStageWidget.png" thumbnail="true" alt=""/></td>
                <td><img src="RYFT_MakeMixtapeWidget.png" thumbnail="true" alt=""/></td>
            </tr>
        </table>
        <p>On the other hand, some widgets use the 'CRT-style':</p>
        <p><img src="RYFT_PostPostStageWidget.png" thumbnail="true" alt="" width="490"/></p>
        <p>
            The decision as to what style something should use depends on whether it is a modal/tip, or a full-screen overlay.
            For instance, the <code>MakeMixtapeWidget</code> is a modal with many buttons and configuration, so it uses the VCR style.
            The <code>PreStageWidget</code>, however, covers the full screen and has no obvious buttons (there are some hover interactions, but otherwise the menu is dismissed with keyboard/controller inputs)
        </p>
        <p>The UI has only ever gotten praise, with the very little feedback we did get pertaining to feature requests, rather than constructive criticism.</p>
        <p>
            I am very proud of my work on the UI. I believe it shows that I am willing to learn new things outside my comfort zone, as UI was previously something I distanced myself from, that
            I ultimately relegated myself to since <i>someone</i> eventually has to do it.
        </p>
    </tab>
    <tab title="What I Learned">
      <warning>Under Construction...</warning>
    </tab>
</tabs>

## Closing Thoughts

Very proud of myself and the team for this achievement.  
Reach out on [LinkedIn](https://www.linkedin.com/in/itslumina), [Discord](https://discordapp.com/users/287272193946288129), or via [email](mailto:itsluminas@gmail.com).