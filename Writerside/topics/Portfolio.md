<include from="see-also.topic" element-id="see-also-defaults"></include>

# Portfolio

<primary-label ref="lum"></primary-label>
<secondary-label ref="tech-designer"></secondary-label>
<secondary-label ref="unity"></secondary-label>
<secondary-label ref="unreal"></secondary-label>
<secondary-label ref="c#"></secondary-label>
<secondary-label ref="c++"></secondary-label>
<secondary-label ref="angelscript"></secondary-label>
<secondary-label ref="jira"></secondary-label>
<secondary-label ref="p4"></secondary-label>
<secondary-label ref="github"></secondary-label>

<quote>
<p>
Hello, I'm <b>Alexander "Lum" Andrejeff</b>, a Technical Designer based in <b>Stockholm, Sweden</b>.
</p>

<p>At <tooltip term="Futuregames">Futuregames</tooltip> I specialize in the <b>design <u>and</u> development</b> of <b>gameplay mechanics</b>, <br/><b>complex systems</b>, and <b>backend tech</b> <i>(engine and tooling)</i>.</p>

<p>I bring a <b><a href="Prototyping.md">unique perspective on game design</a></b> through my <b>programming background</b>, tying together engineers, gameplay programmers, and designers.</p>
</quote>

<tip>
<p>Reach out on <a href="https://www.linkedin.com/in/itslumina/">LinkedIn</a> or email me at: <a href="mailto:itsluminas@gmail.com">itsluminas@gmail.com</a>  
<br/>
View my <resource src="Resume.pdf"></resource>, watch my <a href="https://youtu.be/1d3kRUk4NzA">Showreel</a>, or read more <a href="About-Me.md"></a>.</p>
</tip>

---

## FATE

<primary-label ref="fate"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="group"></secondary-label>
<secondary-label ref="unreal"></secondary-label>
<secondary-label ref="multiplayer"></secondary-label>
<secondary-label ref="c++"></secondary-label>
<secondary-label ref="angelscript"></secondary-label>

<video src="https://youtu.be/cMRGwG6g7GQ" preview-src="8man-chaos-fate.gif" muted="true"/>

<quote>
<p>‘FATE’ is an online-multiplayer "Raid-like", building on <a href="https://en.wikipedia.org/wiki/Destiny_(video_game)">Destiny's</a> gunplay and raid mechanics.</p>
</quote>

<!-- at most 2 videos side-to-side for mobile! -->
<table width="auto">
    <tr>
      <td><img src="fate-pvp.gif" thumbnail="true" alt="PvP Footage"/></td>
      <td><img src="fate-3tap.gif"  thumbnail="true" alt="Firing in the Shooting Range as Izanagi"/></td>
    </tr>
</table>

<chapter id="game-info-fate" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">GAME INFO</format>
</title>
<quote>
<p>
Battle your way through challenging encounters featuring mechanics and puzzles that challenge you and up to two friends.
Battle swarms of enemies, grow stronger, and conquer <b>The Ruined Guardian.</b>
</p>
<p>
<b>Engine:</b> Unreal Engine 5.7 (custom angelscript fork)
<br/><b>Genre:</b> 'Raid-like' (FPS + Destiny Raid + Rogue-lite)
<br/><b>Team Size:</b> 10 (4 Designers, 4 Programmers, 2 VFX/Animators)
<br/><b>Duration:</b> 7 weeks @ Futuregames (2026)
</p>
</quote>
</chapter>

<chapter id="roles-and-responsibilities_fate" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format>
</title>
<tip>Press a step to expand/collapse it.</tip>
<deflist type="full" collapsible="true" default-state="collapsed">
    <def title="Gunplay &amp; Abilities">
        <p>Designed <b>distinct PvE and PvP gunplay, akin to Destiny and Halo</b>. Achieved by breaking down what makes those games fun and how they implement them.</p>
        <p>Developed the <b>gun logic and all related abilities</b>: <b>shoot</b>, <b>reload</b>, <b>ADS</b>, etc.
        <br/>View my most extensive script here: <resource src="GunComponent.as"/></p>
    </def>
    <def title="Guns &amp; Heroes">
        <p>Concepted, pitched, and iterated on <b>three hero designs</b>: <b>Hawkmoon</b>, <b>Izanagi</b>, and <b>Bastion</b>.</p>
        <p><b>Hawkmoon: Short-range forgiving</b> revolver with a medium magazine and fire-rate.</p>
        <p><b>Izanagi: Long-range precision</b> sniper with an alternate burst-fire mode.</p>
        <p><b>Bastion: Medium-range machine-gun</b> with a large magazine and high fire-rate.</p>
        <br/>
        <p><a href="FATE.md#guns-and-heroes">Read more about their design and implementation here.</a></p>
    </def>
    <def title="Enchantments (upgrades)">
        <p>Designed and implemented <b>'enchantments' (rogue-lite upgrades)</b>. The design of each was catered toward each hero's playstyle, including some that were <b>unique</b> to each hero.</p>
        <p>Each enchantment is a GameplayAbility granted upon picking up the enchantment orb. <br/>The ability auto-activates when granted, executing its logic (stat buffs, VFX/SFX, deal damage, etc.) </p>
        <p>A non-exhaustive list <a href="https://docs.google.com/spreadsheets/d/185Nj0lvcnXBs3CzpVRlTaijVfU537k-QxnOOKjZVzqE/edit?usp=sharing">can be viewed here.</a></p>
    </def>
    <def title="GAS (Gameplay Ability System)">
        <p>Designed and implemented all <b><a href="GAS-Architecture.md" summary="Read more about how and why I structured the GAS architecture.">GAS architecture</a></b> including <b>attributes</b>, <b>classes</b>, <b>abilities & effects</b>, etc.</p>
        <p>Parts of the implementation were handled in C++, such as custom GameplayEffectContext properties.</p>
    </def>
    <def title="Netcode">
        <p>Worked with the <b>AdvancedSessions plugin</b>, <b>SteamSockets</b>, <b>SteamSubsystem</b>, and more to connect clients to each other.</p>
        <p><b>RPCs, Replication, and custom</b> <code>async</code> <b>nodes</b> were used for synchronizing state across clients.</p>
    </def>
</deflist>

<chapter id="additional-responsibilities" collapsible="true" default-state="collapsed" level="4">
<title>
<format style="bold" color="e14273">Additional Responsibilities</format>
</title>
<list>
<li><p><control>Combat Systems</control>, Interaction, UI, <control>Puzzle Subsystems</control></p></li>
<li><p>C++ core architecture (extended in Angelscript by self and team members)</p></li>
<li><p>Main &amp; Pause menus (Session-handling, extensive settings options)</p></li>
<li><p>DLSS implementation</p></li>
</list>
</chapter>

</chapter>

<chapter id="tools_fate" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">TOOLS</format>
</title>
<p>Unreal Engine 5.7, JetBrains Rider, Visual Studio Code, Diversion, Perforce, Trello, Miro.</p>
</chapter>

<chapter id="links_fate" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">LINKS</format>
</title>
<list>
<li><p><a href="https://futuregames.itch.io/fate">Itch.io</a></p></li>
<li><p><a href="https://docs.google.com/spreadsheets/d/185Nj0lvcnXBs3CzpVRlTaijVfU537k-QxnOOKjZVzqE/edit?usp=sharing">Enchantments List</a></p></li>
<li><p><a href="https://docs.google.com/spreadsheets/d/1d4uRtZOHxGTzWUpi4ebbzvki4Iu-aRwLK1duB4opFeU/edit?gid=1324727752#gid=1324727752">Enchantment Rarity Calculation</a></p></li>
</list>
</chapter>
<a href="FATE.md" as="button" mode="classic" icon="info">View the detailed breakdown</a>

---

## RYFT

<primary-label ref="ryft"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="group"></secondary-label>
<secondary-label ref="unreal"></secondary-label>
<secondary-label ref="angelscript"></secondary-label>
<secondary-label ref="c++"></secondary-label>

<video src="https://youtu.be/GO6zLJVXBX8" preview-src="ryft_showcase.gif"/>

<quote>
<p>‘RYFT’ is a first-person parkour speedgame set in a retro synthwave world. </p>
<p><a href="https://store.steampowered.com" as="button" mode="transparent">Available on Steam (soon)</a></p>
</quote>

<!-- at most 2 videos side-to-side for mobile! -->
<table width="auto">
    <tr>
      <td><img src="ryft_thrash_fast.gif"  thumbnail="true" alt="Chopped-up gameplay footage of RYFT."/></td>
      <td><img src="ryft_ui_demonstration.gif" thumbnail="true" alt="UI created by me."/></td>
    </tr>
</table>

<chapter id="game_info_ryft" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">GAME INFO</format>
</title>

<quote>
<p>Traverse through a retro synthwave world where the only goal is to go FAST!</p>
<p>
<b>Engine:</b> Unreal Engine 5.8 (custom angelscript fork)
<br/><b>Genre:</b> Parkour/Speedgame
<br/><b>Team Size:</b> 6 (3 Designers, 3 Programmers)
<br/><b>Duration:</b> 4 weeks (+2 pre prod.) @ Futuregames (2026)
</p>
<p>Features licensed music from <a href="https://epidemicsound.com">Epidemic Sound.</a></p>
</quote>
</chapter>

<chapter id="roles-and-responsibilities_ryft" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format>
</title>
<tip>Press a step to expand/collapse it.</tip>
<deflist type="full" collapsible="true" default-state="collapsed">
    <def title="Player Movement">
        <p>Designed, prototyped, iterated, and fully developed the movement abilities including <b>dash</b>, <b>grapple</b>, <b>mantle</b>, and more.</p>
        <p>Movement went through <a href="RYFT.md" summary="Read more about each iteration.">half a dozen iterations</a>, built on <a href="https://docs.google.com/document/d/13lN_6bHk4n_5mxYfQAJLzR8i6ntqcQczTnsEIPtKB7M/edit?usp=sharing" summary="Link to a compilation of all our playtest feedback.">over 25 playtests.</a></p>
    </def>
    <def title="UI/UX">
        <p>Designed, implemented, and iterated on <b>all the user interfaces</b>.</p>
        <p>Read more about my work on the UI in the design breakdown.</p>
    </def>
    <def title="Subsystems">
        <p>Designed, unit tested, and fully developed the architecture and systems that the game runs on, including <b>nine different subsystems</b> which control game logic, level transitions, and more.</p>
            <chapter title="View a few subsystem scripts" id="ryft-scripts" collapsible="true" default-state="collapsed">
                <resource src="StageSubsystem.as"/>
                <resource src="MixtapeSubsystem.as"/>
                <resource src="RemixSubsystem.as"/>
            </chapter>
    </def>
    <def title="GAS (Gameplay Ability System)">
        Designed and implemented all <b><a href="GAS-Architecture.md" summary="Read more about how and why I structured the GAS architecture.">GAS architecture</a></b> including <b>attributes</b>, <b>classes</b>, <b>abilities & effects</b>, etc. 
    </def>
</deflist>
</chapter>

<chapter id="tools_ryft" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">TOOLS</format>
</title>

Unreal Engine 5.8, JetBrains Rider, Visual Studio Code, Diversion, Trello.
</chapter>

<chapter id="links_ryft" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">LINKS</format>
</title>

<list>
<li><p><a href="https://futuregames.itch.io/ryft"><format style="strikethrough">Itch.io</format></a></p></li>
<li><p><a href="https://store.steampowered.com"><format style="strikethrough">Steam</format> (coming soon)</a></p></li>
<li><p><a href="https://docs.google.com/document/d/13lN_6bHk4n_5mxYfQAJLzR8i6ntqcQczTnsEIPtKB7M/edit?usp=sharing">Playtest Document</a></p></li>
</list>
</chapter>

<a href="RYFT.md" as="button" mode="classic" icon="info">View the detailed breakdown on RYFT</a>

---

## ANGEL

<primary-label ref="angel"></primary-label>
<secondary-label ref="solo"></secondary-label>
<secondary-label ref="unreal"></secondary-label>
<secondary-label ref="angelscript"></secondary-label>

<img src="../videos/angel_project_wip-gif.gif" alt="WIP footage of the Angel Project" width="600"/>

<quote>
<p>A work-in-progress clone of Valorant.</p> 
<p>This project demonstrates my proficiency in <b>Gun & Ability Systems</b>, and <b><a href="https://angelscript.hazelight.se">Angelscript</a></b>.</p>
</quote>
<warning>Work-in-Progress!</warning>

<note>
<p><b>No copyright infringement is intended.</b></p>  
All infringing assets serve only as references during development and will be replaced by assets created by me or friends, fan-made, or sourced from free asset libraries.
<p>Credits can be found in the project's <a href="https://github.com/ltsLumina/Angel">GitHub repository</a> under <a href="https://github.com/ltsLumina/Angel/blob/main/Credits.txt">"Credits.txt"</a></p>
</note>

<table width="auto">
  <tr>
    <td>
      <img src="../videos/abilities-gif.gif" thumbnail="true" alt=""/>
    </td>
    <td>
      <img src="../videos/drop_gun-gif.gif" thumbnail="true" alt=""/>
    </td>
  </tr>
</table>

<a href="Angel.md" as="button" mode="classic" icon="info">Read about the Implementation</a>

---

## Skills & Process

<primary-label ref="skills"></primary-label>
<secondary-label ref="c#"></secondary-label>
<secondary-label ref="c++"></secondary-label>
<secondary-label ref="blueprint"></secondary-label>
<secondary-label ref="angelscript"></secondary-label>
<secondary-label ref="java"></secondary-label>
<secondary-label ref="blank"></secondary-label>
<secondary-label ref="jira"></secondary-label>
<secondary-label ref="miro"></secondary-label>
<secondary-label ref="ms-office"></secondary-label>
<secondary-label ref="maya"></secondary-label>
<secondary-label ref="p4"></secondary-label>
<secondary-label ref="github"></secondary-label>

<quote>
<p id="i-design-for">
I design for <b><tooltip term="Bartle's Taxonomy">different player types</tooltip></b> and for how they play together, and I <b>balance intrinsic and extrinsic rewards</b> using <b><tooltip term="Self-Determination Theory">self-determination theory</tooltip>.</b>
</p>

<p>• Experienced in <b>C#</b>, <b>Blueprint</b>, and <b><tooltip term="Angelscript">Angelscript</tooltip></b>, with limited experience in <b>C++</b> and <b>Java</b>.</p>

<p>• Well-versed in Unreal's <b><a href="GAS-Architecture.md">Gameplay Ability System</a></b> (GAS), <b>data-driven development</b>, <b>complex systems</b>, and making <b>networked multiplayer</b> games using <b>replication</b>.</p>

<p>• <b>Rapid prototyping</b>, <b>iteration</b>, and <b>ownership</b> of <b>gameplay mechanics and systems</b>, <a href="https://github.com/Hazelight/UnrealEngine-Angelscript/commits?author=ltsLumina" summary="Contribution page of Hazelight/UnrealEngine-Angelscript. Link may 404 if you are not signed in to an 'Epic Games'-linked account.">engine divergences</a>, and tooling.</p>
</quote>
<a href="Prototyping.md" as="button" mode="classic" icon="pen">View my design process</a>
<a href="GAS-Architecture.md" as="button" mode="classic" icon="projects">View my GAS Architecture</a>

<chapter title="Tools &amp; Software" collapsible="true" default-state="collapsed" level="4">
<list columns="3">
<li><p>Markdown</p></li>
<li><p>GitHub (CI/CD)</p></li>
<li><p>Machinations</p></li>
<li><p>XML</p></li>
<li><p>Perforce</p></li>
<li><p>Miro</p></li>
<li><p>Visual Studio Code</p></li>
<li><p>JIRA</p></li>
<li><p>Figma</p></li>
<li><p>JetBrains Rider</p></li>
<li><p>Slack</p></li>
<li><p>Notion</p></li>
<li><p>Autodesk Maya</p></li>
<li><p>Trello</p></li>
<li><p>Lucidchart</p></li>
</list>
</chapter>

---

## SOMNIUM <format><img src="Debut_Win25_White.png" alt="" style="inline" width="125"/></format>

<primary-label ref="somnium"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="group"></secondary-label>
<secondary-label ref="unity"></secondary-label>
<secondary-label ref="c#"></secondary-label>
<secondary-label ref="award"></secondary-label>

<video src="https://www.youtube.com/watch?v=ZB1c6866ts8" width="600" preview-src="../videos/somnium-trailer.gif"/>

<quote>
<p>
‘Somnium’ is a retro-inspired first-person dungeon crawler.
<br/>Winner of the <b>'Best Debut Game'</b> award at the Future Game Awards (2025)
</p>
</quote>

<table width="auto">
            <tr>
                <td><img src="somnium-2.png" alt="Screenshot of the staff weapon unlock."  thumbnail="true"/>
                </td>
                <td><img src="somnium-3.png" alt="Screenshot of multiple enemies on screen at once." 
                         thumbnail="true"/></td>
            </tr>
</table>

<chapter id="game_info_som" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">GAME INFO</format>
</title>

<quote>
<p>Crawl through a hand-crafted dungeon with two weapons and enemy types. Grab the dream, power-up, and make your escape.</p>
<p>&nbsp;</p>
<p><b>Engine:</b> Unity 6</p>
<p><b>Genre:</b> Dungeon-crawler</p>
<p><b>Team Size:</b> 11 (4 Designers, 4 Programmers, 3 VFX/Animators)</p>
<p><b>Duration:</b> 2.5 weeks @ Futuregames (2025)</p>
</quote>
</chapter>

<chapter id="roles-and-responsibilities_som" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format>
</title>

Combat & Tech Designer, Programming.

<deflist type="full" collapsible="true" default-state="collapsed">
    <def title="3C (Character, Camera, Controls)">
        Designed and implemented the player's camera and controls, tuning the experience for the <a href="https://www.microsoft.com/sv-se/d/xbox-adaptive-controller/8NSDBHZ1N3D8/0002">XBOX adaptive controller</a>, and an audience of ages 4-9. 
    </def>
    <def title="Combat System">
        <p>Designed and implemented two weapons: the Dagger, and the Staff.</p>
        <p>Implemented the 'kick/force-push' mechanic, enabling the player to knock back enemies and environmental objects.</p>
    </def>
    <def title="Enemy AI and Combat">
        Designed and implemented both enemy's AI and attack patterns.
    </def>
    <def title="Interaction System">
        Designed and implemented the game's interaction mechanics, enabling players to pick up items and weapons.
    </def>
</deflist>
</chapter>

<chapter id="tools_som" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">TOOLS</format>
</title>
Unity, JetBrains Rider, Perforce, Trello, Miro.
</chapter>

<chapter id="links_som" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">LINKS</format>
</title>

<list>
<li><p><a href="https://futuregames.itch.io/somnium">Itch.io</a></p></li>
</list>
</chapter>
<a href="Somnium.md" as="button" mode="classic" icon="info">View the detailed breakdown on Somnium</a>

---

## NEON RIVALRY

<primary-label ref="neon-rivalry"></primary-label>
<secondary-label ref="lbs"></secondary-label>
<secondary-label ref="solo"></secondary-label>
<secondary-label ref="unity"></secondary-label>
<secondary-label ref="co-op"></secondary-label>
<secondary-label ref="award"></secondary-label>

<video src="https://www.youtube.com/watch?v=BDWqbVHXUpc" width="600" preview-src="neon-rivalry-trailer-short.gif"/>

<quote>
<p>Neon Rivalry is a couch co-op 2.5D fighting game created in Unity during a game project course in High School (LBS Kreativa Gymnasiet, Gothenburg, 2024).</p>
<p>Winner of the <b>'Best Trailer'</b> award at the LBS Game Awards.</p>
</quote>
<table width="auto">
    <tr>
      <td><img src="nr4.png" alt="Neon Rivalry Combat #1" thumbnail="true"/></td>
      <td><img src="nr5.png" alt="Neon Rivalry Combat #2" thumbnail="true"/></td>
    </tr>
  </table>

<chapter id="game_info_nr" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">GAME INFO</format>
</title>

<quote>
<p>Pick a fighter and challenge your friend in this couch co-op fighting game. Utilize your light and heavy attacks or combo with aerial moves to best your opponent!</p>
<p>Features licensed music from the band <a href="https://open.spotify.com/artist/1DFATttAHQi5zOPvZitP26?si=Xcvp5H_dQcaANu4R0-T_og">Anbaric.</a></p>
<p>&nbsp;</p>

<p><b>Engine:</b> Unity</p>
<p><b>Genre:</b> Fighting</p>
<p><b>Team Size:</b> 5 (1 Designer/Programmer, 4 Artists)</p>
<p><b>Duration:</b> 7.5 months (August 2023 – April 2024) @ LBS</p>
</quote>
</chapter>

<chapter id="roles-and-responsibilities_nr" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format>
</title>

Game Designer, Product Owner, Scrum Master, Programmer (C#).

<deflist type="full" collapsible="true" default-state="collapsed">
    <def title="State Machine">
        Implemented the game state flow for menus, gameplay, and match transitions.
    </def>
    <def title="Combat System">
        Designed and implemented the core combat logic and player-vs-player interactions.
    </def>
    <def title="3C (Character, Camera, Controls)">
        Designed and implemented the player-facing controls and camera behaviour for the fighting experience.
    </def>
</deflist>
</chapter>

<chapter id="tools_nr" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">TOOLS</format>
</title>

Unity, JetBrains Rider, GitHub, Trello, Google Drive, JetBrains Qodana, JetBrains Space <b>(CI/CD)</b>.
</chapter>

<chapter id="links_nr" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">LINKS</format>
</title>

<list>
<li><p><a href="https://www.youtube.com/watch?v=BDWqbVHXUpc">Trailer</a></p></li>
</list>
</chapter>

<a href="Neon-Rivalry.md" as="button" mode="classic" icon="info">Read my retrospective on Neon Rivalry</a>

---

## PALINDRA

<primary-label ref="palindra"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="group"></secondary-label>
<secondary-label ref="unreal"></secondary-label>

<video src="https://www.youtube.com/watch?v=pQPQpJtuY8Y" preview-src="Palindra-Trailer.gif" width="600"/>

<quote>
<p>‘Palindra’ is an atmospheric puzzle game with a time-travel mechanic. The game was created as part of the Game Project 3 course at Futuregames, Malmö (2025).</p>
</quote>

<table width="auto">
    <tr>
      <td><img src="palindra-fireplace-present.png" alt="Screenshot of the fireplace in Palindra, during the present timeline."  thumbnail="true"/></td>
      <td><img src="palindra-piano-past.png" alt="Screenshot of the piano room in Palindra, during the past timeline."  thumbnail="true"/></td>
    </tr>
</table>

<chapter id="game_info_pal" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">GAME INFO</format>
</title>

<quote>
<p>Traverse two distinct timelines, collecting information from the present and applying it in the past to alter the other time, leading you one step closer to solving what happened to the old queen.</p>
<p>&nbsp;</p>
<p><b>Engine:</b> Unreal Engine 5.3</p>
<p><b>Genre:</b> Puzzle Adventure</p>
<p><b>Team Size:</b> 10 (1 Designers, 3 Programmers, 6 Artists)</p>
<p><b>Duration:</b> 6 weeks @ Futuregames (2025)</p>
</quote>
</chapter>

<chapter id="roles-and-responsibilities_pal" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format>
</title>

Game Designer and Associate Programmer (C++).

<deflist type="full" collapsible="true" default-state="collapsed">
    <def title="Level Design">
        Designed the playable spaces and player flow around the game's time-travel mechanic.
    </def>
    <def title="Puzzle Design">
        Built and iterated on environmental puzzles that use past/present state changes to progress.
    </def>
    <def title="UI/UX Design">
        Created the interface to support puzzle readability and player guidance.
    </def>
</deflist>
</chapter>

<chapter id="tools_pal" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">TOOLS</format>
</title>

<b>Unreal Engine 5</b> (C++ &amp; Blueprints), JetBrains Rider, <b>Perforce</b>, <b>JIRA</b>, <b>Miro</b>, Discord.
</chapter>

<chapter id="links_pal" collapsible="true" default-state="collapsed">
<title>
<format style="bold" color="e14273">LINKS</format>
</title>

<list>
<li><p><a href="https://futuregames.itch.io/palindra">Itch.io</a></p></li>
</list>
</chapter>

<a href="Palindra.md" as="button" mode="classic" icon="info">View the detailed breakdown on Palindra</a>

---

<p>&nbsp;</p>

## About Me

<primary-label ref="lum"></primary-label>

<a href="About-Me.md" as="button" mode="classic" icon="person">Read more about me!</a>

<p>&nbsp;</p>

---

## Other Projects { collapsible="true" default-state="collapsed" }

> The projects listed below are smaller games and prototypes I have worked on either solo or in small teams.
> They are included here to showcase a broader range of my skills and experiences, but aren't intended as portfolio
> pieces.

### PLORA

<primary-label ref="plora"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unity"></secondary-label>

<procedure>
  <table width="900">
    <tr>
      <td width="300">
        PLORA is a 3D infinite runner with a 2D-perspective created in Unity by a 14-member team as part of Game Project 1.

<p>&nbsp;</p>

**Platform:** Windows  
**Engine:** Unity 6.0 HDRP  
**Genre:** Infinite Runner (3D in 2D-perspective)  
**Team Size:** 14  
**Duration:** 2.5 Weeks @ Futuregames (2024)
</td>
      <td>
        <video src="https://www.youtube.com/watch?v=1oeAm2Fegz4" width="300" height="400"
                preview-src="PLORAcoverLOGO.png">
            <img src="PLORAcoverLOGO.png" alt="Plora Cover Art" width="300" height="400"/>
        </video>
      </td>
    </tr>
  </table>
</procedure>

### <format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format> {id="roles-and-responsibilities_plo"}

Technical Designer, Gameplay & Tools Programmer.

- Player Movement
- Repair, Refuel, and Recharge System
- Scoring System

### <format style="bold" color="e14273">TOOLS</format> {id="tools_plo"}

Unity, JetBrains Rider, Perforce, GitHub, JIRA, Miro.

### <format style="bold" color="e14273">LINKS</format> {id="links_plo"}

- [Itch.io](https://futuregames.itch.io/plora)

### <format style="bold" color="e14273">SCREENSHOTS</format> {id="screenshots_plo"}

  <table width="900">
    <tr>
      <td><img src="plora intro.png" alt="Plora main menu screen." width="300" thumbnail="true"/></td>
      <td><img src="plora gameplay.png" alt="Early gameplay with dialogue showing." width="300" thumbnail="true"/></td>
      <td><img src="plora gameplay late.png" alt="Plora Gameplay later in the game." width="300" thumbnail="true"/></td>
    </tr>
  </table>

---

### DEAD SECTOR

<primary-label ref="dead-sector"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unity"></secondary-label>
<secondary-label ref="group"></secondary-label>

<procedure>
  <table width="900">
    <tr>
      <td>
Dead Sector was created as a month-long collaborative project between Futuregames Malmö and Warsaw. Scavenge for gear,
grow stronger, and master melee, ranged, and powerful special attacks to survive.

<p>&nbsp;</p>

**Platform:** Windows  
**Engine:** Unity  
**Genre:** Action / Roguelike-style Scavenge  
**Team Size:** 16 (5 Programmers, 7 Artists, 3 Designers, 1 Producer)  
**Duration:** 3.5 weeks @ Futuregames (2025)
</td>
      <td>
        <video src="https://www.youtube.com/watch?v=NRYq1QncCZc" width="300" height="400"
                preview-src="DEAD-SECTOR-banner.png">
            <img src="DEAD-SECTOR-banner.png" alt="Dead Sector Cover Art" width="300" height="400"/>
        </video>
      </td>
    </tr>
  </table>
</procedure>

### <format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format> {id="roles-and-responsibilities_ds" }

Lead Gameplay Programmer, Gameplay Designer, Technical Designer, Level Designer.

### <format style="bold" color="e14273">TOOLS</format> {id="tools_ds"}

Unity, JetBrains Rider, Perforce, JIRA, Miro.

### <format style="bold" color="e14273">LINKS</format> {id="links_ds"}

- [Itch.io](https://futuregames.itch.io/dead-sector)

### <format style="bold" color="e14273">SCREENSHOTS</format> {id="screenshots_ds"}

  <table width="900">
    <tr>
      <td><img src="ds-1.png" alt="Screenshot of a grenade exploding and killing multiple enemies." width="300" thumbnail="true"/></td>
      <td><img src="ds-6.png" alt="Screenshot representing the final boss fight of Dead Sector." width="300" thumbnail="true"/></td>
      <td><img src="ds-7.png" alt="Screenshot of some dialogue at the start of the game, in Dead Sector." width="300" thumbnail="true"/></td>
    </tr>
  </table>

---

### STOKOS

<primary-label ref="dead-sector"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unity"></secondary-label>
<secondary-label ref="group"></secondary-label>
<secondary-label ref="gamejam"></secondary-label>

<img src="stokos.png" alt="STOKOS cover art" width="600"/>

<quote>
<p>STOKOS is a 2D celeste-like platformer created as part of a 3-day game jam with some friends at Futuregames.</p>
<p>&nbsp;</p>
<p><b>Engine:</b> Unity 5</p>
<p><b>Genre:</b> 2D Platformer</p>
<p><b>Team Size:</b> 3 Programmers</p>
<p><b>Duration:</b> 3 days @ Futuregames (2024)</p>
</quote>

### <format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format> {id="roles-and-responsibilities_sto"}

Tech & Level Designer

### <format style="bold" color="e14273">TOOLS</format> {id="tools_sto"}

Unity, JetBrains Rider, GitHub

### <format style="bold" color="e14273">LINKS</format> {id="links_sto"}

- [Itch.io](https://itslumina.itch.io/stokos)

---

### Prototyping Course

<primary-label ref="plora"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unity"></secondary-label>
<secondary-label ref="solo"></secondary-label>

<video src="../videos/Prototype.mp4" width="600" preview-src="prototyping.png"/>

<quote>
<p>This project was created as part of the Prototyping Course at Futuregames, where the goal is to prototype a game that focuses on the 3C's of game design. (Character, Camera, and Controls).</p>
<p><b>A detailed breakdown is available as it was produced as part of the assignment.</b></p>
<p><b>Engine:</b> Unity 6</p>
<p><b>Genre:</b> 3D Platformer</p>
<p><b>Team Size:</b> Solo</p>
<p><b>Duration:</b> 7 days @ Futuregames (2025)</p>
</quote>

### <format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format> {id="roles-and-responsibilities_prototyping"}

Solo Developer (Designer/Programmer/Artist)

### <format style="bold" color="e14273">TOOLS</format> {id="tools_prototyping"}

Unity, JetBrains Rider, GitHub, Notion

<chapter id="breakdown_prototyping">
<title>
<format style="bold" color="e14273">BREAKDOWN</format>
</title>

<a href="Prototyping.md#v1" as="button" mode="classic" icon="info">Read more about my design process.</a>
</chapter>

### Board Game Design Course

<primary-label ref="palindra"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="group"></secondary-label>

We created a board game entirely from scratch, designed as part of the Board Game Design Course at Futuregames.

**A detailed breakdown is available as it was produced as part of the assignment.**

### <format style="bold" color="e14273">ROLES AND RESPONSIBILITIES</format> {id="roles-and-responsibilities_bgd"}

Designer, Playtester, Documenter

### <format style="bold" color="e14273">TOOLS</format> {id="tools_bgd"}

Google Sheets (Excel), Google Docs, Miro

- <resource src="Board Game Design - Personal Reflection - Alexander Andrejeff.pdf"></resource>