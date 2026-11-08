<include from="see-also.topic" element-id="see-also">
    <var name="topic" value="Angel.md"/>
    <var name="topic-summary" value="This project served as a partial base for FATE."/>
</include>

# FATE

<primary-label ref="fate"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="group"></secondary-label>
<secondary-label ref="unreal"></secondary-label>
<secondary-label ref="angelscript"></secondary-label>
<secondary-label ref="c++"></secondary-label>
<secondary-label ref="miro"></secondary-label>
<secondary-label ref="figma"></secondary-label>

<tldr>
<p> 
FATE is a <b>love-letter to Destiny (2)</b> and an attempt at a <b>new genre ("Raid-like")</b>. 
<br/>Across <b>7 weeks</b>, the efforts of 10 students culminated in a game we were overjoyed to see others play.
</p>
</tldr>

<resource src="Resume.pdf"> foo </resource>

<video src="https://youtu.be/cMRGwG6g7GQ" preview-src="8man-chaos-fate.gif" muted="true" width="800"/>

<quote>
<p>Additionally, FATE's technical implementation is my most ambitious project: <b>15,000+ lines of code</b> across <b><tooltip term="Angelscript" id="angelscript">Angelscript</tooltip>, and C++</b>, with over <b>300</b> coding hours.</p>
<img src="FATE-as-metrics.png" alt="FATE Angelscript metrics" style:="block"/>
</quote>

<chapter title="&af;" id="responsibilities_fate" hide-from-structure="true" level="6">
<deflist title="Responsibilities" type="full" collapsible="true" default-state="collapsed">
<def title="Responsibilities">
<tip>Press a title to expand/collapse it.</tip>
<deflist type="full" collapsible="true" default-state="collapsed">
<include from="responsibilities.topic" element-id="fate-responsibilities"/>
</deflist>
</def>
</deflist>
</chapter>

<chapter title="Design direction" id="design-direction">
    <p>
        FATE is a Destiny-inspired <b><tooltip term="Rogue-lite" id="rogue-lite">roguelite</tooltip> FPS puzzle
        game</b> about collaborating with up to two friends in encounter-based levels. Players solve puzzles while
        repeatedly-spawning enemies create <b>constant pressure</b>, capturing the communication, coordination, and
        combat tension of a traditional Destiny raid in a smaller experience.
    </p>
<procedure>
    <p>The design was guided by three pillars:</p>
    <list>
        <li>
            <b>Collaborative:</b> Each encounter requires at least two players without debug tools. Players must
            <b>communicate and solve problems together</b> while enemy combatants threaten to overwhelm them.
        </li>
        <li>
            <b>Great gunplay:</b> A Bungie-inspired game needed responsive, meaty, distinctive weapons. Bullet
            magnetism makes shots feel responsive, hit VFX and SFX add impact, and three heroes with different guns
            and playstyles make combat interesting and rewarding.
        </li>
        <li>
            <b>Environmental:</b> With a limited art budget, the level had to carry much of the storytelling and
            guidance, <b>leading players through the level</b> and communicating puzzle solutions without making them
            obvious.
        </li>
    </list>
<img src="fate-pillars.png" alt="" thumbnail="false"/>
</procedure>
</chapter>

<tabs>
<tab title="Gunplay" id="implementation">
    <chapter title="GunComponent.as" id="gun-component">
    <tldr>
        The up-to-date files are private, so snippets date to August 3rd 2026.
    </tldr>
<quote>
<img src="fate-pvp.gif" thumbnail="true" alt="PvP Footage"/>
PvP footage during development.</quote>
        <p>
            I designed and implemented the GunComponent, a project pillar: <b>every shot a player fires goes through
            it</b>. FATE's weapons are <b><tooltip term="Hitscan" id="hitscan">hitscan</tooltip></b>, so there are
            no projectiles to simulate. The component answers four questions per trigger pull:
        </p>
        <list>
            <li>
                <b>May this shot fire?</b> It checks fire rate, fire mode (semi, burst or auto), ammo, and cooldown.
            </li>
            <li>
                <b>Where does the bullet go?</b> It starts from the player's aim, adjusts spread for movement and
                firing duration, then nudges near-misses toward a nearby target with bullet-magnetism.
            </li>
            <li>
                <b>What did it hit?</b> It traces that direction, sends the hit through the damage pipeline, and
                plays tracer and impact effects for every player.
            </li>
            <li>
                <b>How should it feel?</b> It applies recoil, eases the view back, and handles aim-down-sights zoom.
            </li>
        </list>
        <p>
            This is a lot for one component, a direct result of our time constraints. With little time for
            abstraction or refactoring, new behaviour went into the component that already owned shooting.
            <b>It's something I learned from:</b> on larger projects I now design for likely refactoring from the start.
        </p>
        <p>
            Spread, recoil, aim-assist, and fire rate are data rather than code, so each gun and hero can be tuned
            independently. The rest of this section covers what most shapes <b>how shooting feels</b>, and why.
        </p>
<procedure>
        <deflist type="full" collapsible="true" default-state="collapsed">
        <def title="Following one shot" id="one-shot">
            <p>
                When the player fires, <code>Fire()</code> builds the bullet's final direction in four steps:
            </p>
            <list type="decimal">
                <li>The exact point in space the player was aiming at.</li>
                <li>A deviation from the target point (1.) -- the 'spread point' (or bloom.)</li>
                <li>
                    A nearby target, if applicable, used to calculate the bullet-magnetism correction.
                </li>
                <li>The final calculated point in space the bullet will hit.</li>
            </list>

<procedure>
<warning>Clarification: Although the variables are named e.g. 'Spread<b>Point</b>', most of them are actually unit vectors, and do not represent a world location. Some time during development the variables' purpose changed, but their names
unfortunately did not.</warning>
&nbsp;
<code-block lang="actionscript" collapsible="true" default-state="collapsed" collapsed-title="GunComponent.as - Fire() function" emphasize-lines="8,12,31-35" src="../resources/GunComponent.as" include-lines="427-469"/>
</procedure>
<p/> <!-- formatting fix -->
     </def>
     <def title="Bullet magnetism" id="bullet-magnetism">
         <p>
             Bullet magnetism bends a near-miss toward a nearby target, making it more likely to hit. I added it
             because it is foundational to Bungie shooters and helps Halo, Destiny, and Marathon feel responsive.
             FATE needed the same feel.
         </p>
         <p>
             The goal is that <b>accuracy should still matter, but a near-miss should not feel needlessly brittle</b>.
             Movement, recoil, and hectic encounters cause small errors, so the system preserves the player's intent
             while rewarding aim near the target. The player must still aim in the right direction.
         </p>
<p id="bullet-magnetism-visualization"><b>Bullet magnetism in-engine</b></p>
    <img src="../videos/bullet-magnetism-visualization.gif" alt="Bullet Magnetism" width="800" thumbnail="true" style:="block"/>
               <p>
                   Although I'm aiming at the target closest to the wall, the bullet is pulled toward the closer
                   target because the bullet-magnetism capsule trace detected it.
               </p>
<table width="auto">
    <tr>
        <td><img src="magnetism_img1-fix.png" alt="Bullet Magnetism" width="600" thumbnail="true"/>
        <p>The actor that the target acquisition capsule (pink) overlaps becomes the target the bullet will magnetize toward.</p>
</td>
        <td><img src="magnetism_img2-fix.png" alt="Bullet Magnetism" width="200" thumbnail="true"/>
<p>The dark blue line is the target point: the exact vector the player was facing when they pressed fire.</p>
</td>
    </tr>
</table>
               <p>
                   The dark blue line/capsule trace is the exact aim point; the light blue line is the final bullet
                   path. Although the trace appears to hit the furthest target, the bullet stopped at the closer target, <b>because the bullet was magnetized toward the acquired target</b>.
               </p>
               <p>
                   The video <a href="https://www.youtube.com/watch?v=yv3lRNAxA0o">"How Halo's Aim Assist ACTUALLY works"</a>
                   showcases the system clearly.
               </p>
<deflist type="full" collapsible="true" default-state="collapsed">
<def title="How bullet magnetism works" id="bullet-magnetism-how">
         <p>
             Studying Destiny's and Marathon's shooting helped enormously. Two videos were instrumental:
             <br/>• <a href="https://www.youtube.com/watch?v=qrJv7mj7Ab4">Accuracy, Aim Assist &amp; Range Explained In-Depth</a> by Drewsky
             <br/>• <a href="https://www.youtube.com/watch?v=LTVi3owxttc">How Aim Assist &amp; Accuracy REALLY Work in Marathon</a> by CoolGuy
         </p>
         <p>
             Each shot sweeps a capsule along the player's aim. Its radius comes from the weapon's aim-assist angle
             (<code>tan(angle) × distance</code>), keeping forgiveness angularly consistent at any range. Our levels
             are large and open, so punishing distant targets felt bad; the same principle explains why we use no
             damage-or-bullet falloff.
         </p>
         <p>
             If the capsule finds a target, the spread direction is pulled toward its hit point by at most that
             angle. Because the pull is capped rather than snapping to the target, aiming still matters.
         </p>
         <p>
             There is one exception: if the spread trace already lands on a precision hit (a head), magnetism is
             skipped. It cannot pull a shot away from an earned headshot, a bug discovered during testing.
         </p>
&nbsp;
<code-block lang="c#" collapsible="true" default-state="collapsed" collapsed-title="GunComponent.as - bullet magnetism (capsule sweep and pull)" emphasize-lines="3,19,27-39,60,66-67" src="../resources/GunComponent.as" include-lines="502-510,512-549,572-604"/>
           </def>
           </deflist>
       </def>
       <def title="Movement spread" id="movement-spread">
           <p>
               Spread is the cone a bullet can land in; <code>GetSpread()</code> sets its width per shot. It builds
               across the magazine along a per-weapon curve, adds a running or airborne penalty, and starts tighter
               while aiming down sights. The first shots after pausing are 'protected' and tighter, <b>rewarding
               pauses between engagements</b>.
           </p>
           <p>
               Movement-spread was originally more punishing, inherited from <a href="Angel.md">the Angel project</a>,
               a tactical FPS where precision requires standing still. FATE is an action FPS like Destiny, so I
               adjusted it repeatedly. Tactical accuracy is binary; action-FPS bloom should naturally react to
               firing rather than decide whether a gun is accurate.
           </p>
           <p>
               Thus <code>GetSpread()</code> increments spread across a magazine instead of simply applying a movement
               penalty. The binary early version made even the first moving shot inaccurate. The current approach
               keeps the start of an engagement accurate while <b>rapid fire naturally widens the bloom</b>.
           </p>
           <p>
               The movement penalty is tuned per gun and hero. Bastion's is larger than Hawkmoon's to support its
               less-mobile, spray-and-pray frontliner fantasy. Its bonus damage for standing still reinforces
               planting your feet. <b>The penalty still allows accuracy while moving</b>, though spread noticeably
               increases across Bastion's 100-round magazine.
           </p>
           <p>
               These knobs live on the weapon definition: spread curve, first-shot and maximum spread (separately
               for hip-fire and aiming down sights), bullets to reach maximum, and running and airborne penalties.
                <br/><b>By placing these knobs in per-weapon data assets, I can easily balance the weapons through a data-oriented way.</b>
           </p>
<img src="angel-Phantom-BP-1.png" alt="" thumbnail="true"/>
<note>
This image is from <a href="Angel.md">the angel project</a>, so the data isn't totally accurate, but gives an approximate idea of what kind of knobs we had available in FATE.
</note>
&nbsp;
<code-block lang="c#" collapsible="true" default-state="collapsed" collapsed-title="GunComponent.as - GetSpread() and IsBulletProtected()" emphasize-lines="8,23-26,29,53-55" src="../resources/GunComponent.as" include-lines="126-134,336-385"/>

</def>
<!--
        <def title="Recoil recovery" id="recoil-recovery">
            <p>
                Every shot kicks the player's view up and sideways, then eases it back.
            </p>
            <p>
                Recovery makes sustained fire less taxing: players need not account for each shot and readjust after
                every bullet. This especially helps high-recoil Hawkmoon and Izanagi, and avoided exhausting players
                unfamiliar with FPS shooting. Once added, <b>gunplay felt much better overall</b>.
            </p>
            <p>
                Implementation was difficult. Recoil is controller input rather than a camera animation, so recovery
                must undo recoil without undoing the player's aim. The component tracks injected recoil ('recovery
                debt') and feeds opposite input back over each weapon's settle time. Because recovery is input,
                mouse or controller movement continues while the view settles. Recoil runs only on the owning client.
            </p>
&nbsp;
<code-block lang="c#" collapsible="true" default-state="collapsed" collapsed-title="GunComponent.as - UpdateRecoil() and ApplyControlRecoil()" emphasize-lines="9,26,38-42,66,72-75" src="../resources/GunComponent.as" include-lines="817-894"/>

</def>
-->
<def title="Cooldown handling" id="cooldown-handling">
            <p>
                The GunComponent handles shot cooldown instead of the gameplay ability through a committed
                <tooltip term="GameplayEffect" id="gameplay-effect-cooldown">GameplayEffect</tooltip>, the standard
                <tooltip term="Gameplay Ability System (GAS)" id="gas-cooldown">GAS</tooltip> approach.
                <code>Shoot()</code> converts fire rate to a cooldown and rejects early shots.
            </p>
            <p>
                This was a deliberate trade-off, for two reasons:
            </p>
            <list>
                <li>
                    The original shooting logic came from <a href="Angel.md">the Angel project</a>, which did not
                    use GAS for shooting. When ported to FATE, I kept its internal cooldown. Because it was not
                    connected to GAS, shooting did not depend on ability commitment, causing debugging issues until
                    I found and reworked the cause.
                </li>
                <li>
                    Manual handling gave more control over allowing, disallowing, or overriding shooting during
                    development. I was unfamiliar with GAS's intricacies, so using what I knew was more efficient
                    than reworking the system mid-project.
                </li>
            </list>
            <p>
                After we reached our deadline, I reviewed the implementation. <b>Future projects use native GAS
                checks</b> for cost and cooldown, with extensive gameplay tags.
            </p>
            <p>
                The component still integrates with GAS: <code>bIgnoreInternalCooldown</code> lets an ability bypass
                the internal cooldown and ammo check when using a custom GameplayEffect cooldown.
            </p>
&nbsp;
<code-block lang="c#" collapsible="true" default-state="collapsed" collapsed-title="GunComponent.as - Shoot() function" emphasize-lines="15,21-31,35-41" src="../resources/GunComponent.as" include-lines="973-1015"/>

</def>
        <def title="What I would change" id="gun-reflection">
            <p>
                If I rebuilt the GunComponent today, I would lean more heavily on native GAS systems. I am more
                familiar with GAS now, and cooldowns could use proper GameplayEffects and gameplay tags instead of
                remaining partly in the component.
            </p>
            <p>
                I would also split its responsibilities: recoil and spread could become separate components, while
                trace logic could be reusable. I did the latter for <a href="RYFT.md" summary=""></a>, which only
                needed magnetized traces.
            </p>
        </def>
        </deflist>
</procedure>
</chapter>
</tab>
<tab title="Guns &amp; Heroes" id="guns-and-heroes">
<procedure title="My design process for FATE's Heroes" id="design-process" collapsible="false">
    <step>Brainstorm heroes that fit a given player fantasy</step>
    <step>Debate their playstyle and role in a team composition</step>
    <step>Prototype the heroes' weapon</step>
    <step>Test their gunplay and role in encounters and waves of enemies</step>
    <step>Iterate the design through feedback without losing its identity</step>
<a href="Design-Process.md" as="button" mode="outline" icon="info">More on my design process</a>
</procedure>

<chapter title="Hero roles" id="hero-roles">
        <p>
            I started with a simple design question: <b>what kind of player fantasy should each hero make feel
            natural?</b> The answer had to shape both the weapon and the way that weapon contributed to a team:
        </p>
        <list>
            <li>
                <b>Hawkmoon:</b> a flexible, approachable sharpshooter who is simple to understand but rewarding to
                use well.
            </li>
            <li>
                <b>Izanagi:</b> a precision specialist with a higher skill ceiling and a deliberate pace.
            </li>
            <li>
                <b>Bastion:</b> an aggressive frontliner who creates immediate momentum through sustained fire.
            </li>
        </list>
        <p>
            I tested those fantasies against the same requirements: each hero had to feel distinct, contribute to a
            cooperative encounter, and remain useful against enemy waves. This created a tension between identity and
            accessibility. A sniper should reward precision, for example, but could not leave its player helpless
            against five or more enemies.
        </p>
        <p>
            My iteration loop was: define the fantasy, prototype the weapon, playtest it in encounters and waves,
            then adjust it without losing its identity. The following sections trace that process.
        </p>
<chapter title="Self-determination Theory" id="self-determination-theory" level="4">
<img src="self-determination-theory.jpg" alt="" thumbnail="true" width="400" style:="inline"/>
<p>
This approach also supported <b><tooltip term="Self-Determination Theory">self-determination theory</tooltip></b>. Each hero offered a different route to autonomy and competence, while cooperative encounters supported relatedness. Hero mastery provided intrinsic rewards, and enchantments (roguelite upgrades) provided extrinsic rewards that encouraged experimentation and progression.
</p>
</chapter>
    </chapter>

<chapter title="Encounter design" id="encounter-design">
<img src="fate-img0.png" thumbnail="true" width="800" alt=""/>
<p>
            Every encounter asks players to collaborate differently. The first encounter, a tether puzzle,
            requires players to position themselves between generators so electricity can reach a capacitor or door.
            While maintaining the puzzle, they must also defeat repeatedly spawning enemies. 
<br/><b>I emphasized shooting as a core design principle because it was the most immediately satisfying part</b>, and enchantments gave players a natural way to grow stronger during each encounter.
        </p>
        <p>
            Every hero had to be capable of surviving waves of enemies through their weapon alone. We decided
            against grenades and other dedicated wave-clear abilities because the project's scope was already large.
            This made ad-clear a central weapon-design problem: a sniper rifle rewards precision at range, while a
            machine gun clears a horde more naturally. The goal was not equal performance, but a distinct solution for
            each hero: Hawkmoon became more forgiving, Izanagi could chain precision kills, and Bastion applied pressure through volume of fire.
        </p>
        <chapter title="Hero weapon iterations" id="hero-weapon-iterations" level="3">
            <p>
                <b>Hawkmoon</b> originally used a six-shooter firing at two rounds per second. It could kill a basic
                enemy with one headshot, but the small magazine and roughly 2.5-second reload made waves difficult.
                Players liked how satisfying it felt to shoot, but reported that six bullets made every shot feel
                overly precious. The redesign increased the magazine size and fire rate, preserving the approachable
                sharpshooter fantasy while allowing longer firing before reloading.
            </p>
            <p>
                <b>Izanagi</b> originally fired one charged shot per magazine, followed by a two-to-three-second
                reload. Izanagi was redesigned more substantially than the other heroes: its hip-fire mode became a
                three-tap burst, replacing the earlier boomstick that launched the player into the air and enabled
                repositioning unavailable to the other heroes.
            </p>
            <note>
                The reload duration was a design constraint: the animations were made to look good rather than serve
                a precise gameplay cadence. We could adjust them slightly, but changing them too much looked
                unnatural, especially when enchantments modified reload speed.
            </note>
            <quote>
                The boomstick's movement created an interesting level-design opportunity, including sniper towers and
                watchpoints built specifically for Izanagi. It was replaced because all heroes received a double jump
                to improve mobility.
            </quote>
            <p>
                The final redesign gave Izanagi a total magazine of 12 rounds: each charged shot costs three rounds,
                and the complete three-tap burst also costs three. This made Izanagi more capable against groups
                without losing its precision identity. It became a fan favourite alongside its innate trait.
            </p>
            <img src="fate-3tap.gif" thumbnail="true" alt="Izanagi firing its three-tap burst in the shooting range"/>
            <p>
                <b>Bastion</b> required the fewest iterations. Its original concept was inspired by Overwatch's
                Bastion: a semi-immobile frontliner protected by a barricade while mowing down the battlefield. The
                barricade was never implemented, but Bastion retained the fantasy through a large health pool, a
                100-round drum magazine, and a fire rate that increases as the magazine drains. Its bullets are weak,
                but the volume of fire makes it a powerful choice for clearing waves.
            </p>
            <p>
                Firing slows Bastion because of the weapon's recoil, selling its power without making the recoil
                uncontrollable. The recoil becomes more sporadic as the magazine gets low, but remains manageable.
                If sustained fire were impossible to control, there would be little reason to commit to the frontliner
                fantasy.
            </p>
        </chapter>
        <chapter title="Hero traits" id="hero-traits" level="3">
            <p>
                When weapon changes alone could not solve the ad-clear problem without flattening the heroes'
                identities, I added hero-specific traits. These traits were designed as the final step in the same
                process: each one addresses a weapon weakness while reinforcing the intended fantasy. Hawkmoon's is
                a unique enchantment; Izanagi's and Bastion's are innate traits:
            </p>
            <list>
                <li>
                    <b>Hawkmoon:</b> Inspired by Destiny's Hawkmoon, each precision hit increases the damage of
                    subsequent precision hits. The final bullet in the magazine deals exponentially more damage based
                    on the number of precision hits landed before reloading. This rewards accuracy and emphasizes the
                    sharpshooter fantasy.
                </li>
                <li>
                    <b>Izanagi:</b> Precision kills trigger a large fireball around the target, dealing heavy area
                    damage and killing basic enemies nearby. This innate trait was added specifically to improve
                    Izanagi's ability to clear groups.
                </li>
                <li>
                    <b>Bastion:</b> Bastion deals increased damage while standing still. The simple, effective
                    bonus reinforces the immobile frontliner fantasy and rewards committing to a firing position.
                </li>
            </list>
        </chapter>
        <tip>
            The heroes' names are drawn from weapons in <a href="https://www.destinythegame.com/">Destiny 2</a>, and their playstyles and defining features are
            similarly inspired by those weapons. This was another deliberate connection to Destiny: FATE's heroes
            echo familiar weapon fantasies while adapting them to our own cooperative, raid-like experience.
        </tip>
    </chapter>

</tab>
<tab title="Damage Pipeline" id="health-attributes">
   <chapter title="HealthAttributes.as" id="healthattributes-chapter">
<tldr>
    The up-to-date files are hosted on a private repository, so snippets are dated to August 3rd 2026.
</tldr>
<deflist type="full" collapsible="true" default-state="collapsed">
   <def title="Damage handling" id="health-damage">
<p>
           The HealthAttributes script is the backbone of taking and dealing damage. Whenever a damage or healing
           <tooltip term="GameplayEffect" id="gameplay-effect">GameplayEffect</tooltip> lands, it works out what
           actually happened (how much damage, whether it was a precision
           hit, whether it was a kill) and fires the matching enchantment triggers.
       </p>
       <p>
           The design goal was to <b>centralize damage handling</b> for both health and shields. Shield handling was
           inherited from <a href="Angel.md">Angel</a>, although shields were never used in FATE. Keeping both
           paths in one system made it possible for enemies and shootable interactable objects to respond to hits
           consistently.
       </p>
       <p>
           For example, the symbol puzzle lets players shoot symbols to tether them together. Custom hit-reaction
           actors expose events for reacting to damage and dying, so puzzle logic can use the same damage system as
           combat. Because the interactions are handled through <tooltip term="Gameplay Ability System (GAS)" id="gas-symbol">GAS</tooltip>, <b>multiple players shooting a symbol are
           resolved through the same shared pipeline</b>.
       </p>
       <p>
           We extended the GameplayEffect context with fields such as <code>IsPrecisionHit</code>, so both script
           and Blueprint could inspect the result of a hit without reconstructing it elsewhere. That context also
           carries the trigger tags used by the enchantment system.
       </p>
&nbsp;
<code-block lang="c#" collapsible="true" default-state="collapsed" collapsed-title="HealthAttributes.as - PostGameplayEffectExecute()" emphasize-lines="31,37-47,66-78,83-88,125-139,191,207-209" src="../resources/HealthAttributes.as" include-lines="150-380"/>
   </def>
   <def title="Designer-friendly enchantments" id="health-enchantments">
       <p>
           Damage also needed to invoke enchantments -- the <tooltip term="Rogue-lite" id="rogue-lite-damage">roguelite</tooltip> upgrades that let players grow
           exponentially stronger. The implementation goal was to make adding one require little code: a designer or
           developer creates a new GameplayAbility asset and adds its entry to the enchantment data table.
           <b>No new branch in the damage handler should be needed for each upgrade.</b>
       </p>
<procedure>
<img src="fate-enchant-data.png" alt="" thumbnail="true"/>
The DataTable view for adding a new enchantment.
</procedure>
<p>
           The HealthAttributes script reads the enchantment trigger tags from the GameplayEffect context and
           invokes every ability that has one of those tags. The tags deliberately fall through: a precision hit
           <b>triggers both</b> <code>Ability_Enchant_Trigger_OnPrecisionHit</code> and the ordinary
           <code>Ability_Enchant_Trigger_OnHit</code> effects, because a precision hit is still a hit.
       </p>
       <p>
           This was especially important when a hit killed an enemy. If only the death trigger ran, ordinary
           on-hit enchantments would never execute, which would undermine the fantasy of breaking the game through
           increasingly powerful roguelite upgrades.
       </p>
       <p>
           The result was a shared pipeline that let enchantments trigger one another and stack without a hard
           ceiling. As gunplay became better at clearing groups, players became less cautious and pushed deeper
           into encounters than before; the damage and enchantment systems made that escalation work without
           adding bespoke branches for every upgrade.
       </p>
&nbsp;
&nbsp;
<code-block lang="c#" collapsible="true" default-state="collapsed" collapsed-title="HealthAttributes.as - GetEnchantmentTriggers()" emphasize-lines="5-20" src="../resources/HealthAttributes.as" include-lines="382-404"/>
   </def>
   <def title="Immunity rules" id="health-immunity">
       <p>Immunity was designed as three separate concepts:</p>
       <list>
           <li><b>Damage immunity</b> prevents damage but still allows enchantment triggers and UI feedback (like hitmarkers) to run.
            This proved especially useful for objects that should react to being shot, and thus provide feedback through e.g. hitmarkers.</li>
           <li><b>Enchantment immunity</b> prevents enchantment triggers while still allowing damage. This was
               never used in production, so the final implementation does not account for it.</li>
           <li><b>Total immunity (Invulnerable)</b> prevents both damage and enchantment logic, including hit markers and similar feedback.
            </li>
       </list>
       <p>
           Enchantment immunity was originally intended for bosses during selected phases or conditions, but that
           design was scrapped. Damage immunity remained useful because it could block health changes without
           preventing other hit-driven reactions.
       </p>
   </def>
   <def title="UI feedback" id="health-ui-replication">
       <p>
           The server-only nature of <code>PostGameplayEffectExecute()</code> meant that UI feedback needed an
           explicit route to the correct client. Hitmarkers and similar feedback were sent through a function on
           the local PlayerController, which executed a <b><tooltip term="Client RPC" id="client-rpc">Client
           RPC</tooltip></b> for that player.
       </p>
       <p>
           This approach worked, but adding a new screen effect meant adding another controller function. The
           <code>ScreenOverlayComponent</code> was later added to the PlayerController to centralize that routing
           and keep UI additions out of the controller itself.
       </p>
&nbsp;
&nbsp;
<code-block lang="c#" collapsible="true" default-state="collapsed" collapsed-title="ScreenOverlayComponent.as - lines 5-81 (total 219)" src="../resources/ScreenOverlayComponent.as" include-lines="5-81"/>
   </def>
   <def title="What I would change" id="health-reflection">
       <p>
           The centralized damage pipeline achieved the flexibility we needed during development: combatants,
           interactable objects, enchantments, hit reactions, and player feedback could all respond to the same
           event. Its trade-off was that a large amount of responsibility accumulated in one script, so future
           projects would benefit from clearer boundaries between damage resolution, trigger dispatch, and UI
           presentation.
       </p>
   </def>
   </deflist>
    </chapter>
</tab>
<tab title="Leadership" id="leadership">
    <chapter title="Vision" id="vision">
        <p>
            The project went through many iterations, including <b>a drastic pivot on the day of our Alpha
            deadline</b>. <br/>I led the charge on this pivot: directing our new game vision, rethinking our
            thought-process, and down-scoping our engineering.
        </p>
        <p>
            Our initial vision was of a <b>semi-procedurally-generated map</b> – consisting of sublevels that we
            would stitch together procedurally – as you progress through two puzzles and a boss fight.
        </p>
    </chapter>
    <chapter title="Pivot" id="pivot">
        <p>
            Our original vision was a semi-procedurally-generated roguelite dungeon, but after dozens of hours of
            troubleshooting we realized that making it work in a multiplayer setting would not be sustainable.
            <b>I announced to our team that our current vision and workflow had to change.</b> The team was in
            unanimous agreement.
        </p>
        <p>
            Later that day, we pivoted to a <b>hand-crafted experience structured like a Destiny raid</b>, with more
            thought-provoking puzzles, more cooperation, and far more sustainable workflows. Workflow changes
            included better communication about working hours, scoping down areas where we were lacking in raw
            workforce (e.g. Animations), and focusing on polishing our core experience, rather than opting for
            more content – even though we felt it was doable – aiming for more healthy and sustainable work.
        </p>
    </chapter>
    <chapter title="Result" id="end-result">
        <p>
            The pivot was often discussed in retrospectives as the saving-grace moment, and the most pivotal reason
            behind the success of our game.
        </p>
        <p>
            I am happy I <b>stepped up and led the pivot</b> and project moving forward, and see this as a
            milestone in my time as a student, showcasing strong ownership and respect for the project and my
            team.
        </p>
    </chapter>

</tab>

<tab title="What I Learned" id="what-i-learned">
<warning> Under Construction!</warning>
<quote>
<img src="fate-img1-environment-enc2.png" thumbnail="false" width="800" alt=""/>
The second encounter, featuring the symbol puzzle.
</quote>
<deflist>
<def title="Designing for different player types">
<p>
I learned how to iterate a design to service a given player by designing three different heroes for different player fantasies and player types.
</p>
</def>
<def title="GAS Architecture &amp; Framework">
<p>
As lead programmer and designer, I built FATE's core framework around Angelscript, C++, GAS, and replication. Because
the rest of the team was new to GAS and replication, I became the primary source of information while we learned from
<a href="https://github.com/tranek/GASDocumentation">Tranek's unofficial GAS documentation</a> and Epic Games' tutorials.
</p>
</def>
<def title="Dependencies">
<p>
        As the lead designer and lead programmer, all team members were dependent on me in some capacity.
        While it was very flattering – being trusted by so many in such a pivotal project – it was also a burden that I learned a lot from.
</p>
<p>
        Furthermore, being so dependent by the whole team meant that if I was ever unavailable – such as during week three of seven – the project grinds to a halt on many fronts, as designs I've written are interpreted without supervision, and systems are modified without proper review.
</p>
<p>
        The takeaway is to <b>scope according to your overall team's capacity</b>, not that of one (or a few) developer(s).
        <b>Account for unavailability</b>, and <b>defer responsibilities</b> throughout your team.
</p>
</def>

</deflist>
</tab>
</tabs>
<quote>
Navigate to some recommended topics.
<br/>
<br/>
<a href="FATE.md#gun-component" as="button" mode="classic" icon="enter">Gunplay</a>
<a href="FATE.md#guns-and-heroes" as="button" mode="classic" icon="enter">Guns &amp; Heroes</a>
<a href="FATE.md#health-attributes" as="button" mode="classic" icon="enter">Damage Pipeline</a>
</quote>

<chapter title="Closing Thoughts" id="closing-thoughts">
    <p>
            FATE began as a multiplayer roguelite dungeon and became a hand-crafted raid-like experience after the pivot I led. Having <b>designed 3 heroes and guns, raid puzzles</b>, written <b>15,000+ lines of code, and spent over 300 hours</b> on the project, I am only able to reflect on so much, so should you want to hear more, please reach out to me on
            <a href="https://www.linkedin.com/in/itslumina">LinkedIn</a>,
            <a href="https://discordapp.com/users/287272193946288129">Discord</a>,
            <a href="mailto:itsluminas@gmail.com">Email</a>
            , or elsewhere to hear more.
    </p>
</chapter>