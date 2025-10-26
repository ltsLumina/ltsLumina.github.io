---
switcher-label: Mechanic
---

<show-structure for="chapter,procedure" depth="0"></show-structure>

# Breakdown

<primary-label ref="angel"></primary-label>
<secondary-label ref="futuregames"></secondary-label>
<secondary-label ref="unreal"></secondary-label>
<secondary-label ref="angelscript"></secondary-label>

> Press the "Mechanic" switcher in the top right of the website, left of the "Reach out!" button to switch between
different mechanic breakdowns. { style = "note" }

This project is very early in development, and is very prototype-heavy at the moment. Nothing is final, nor is this page
complete.

## Guns {switcher-key="Guns"}

Each gun has been recreated to closely mimic the feel and behavior of their counterparts in Valorant.  
This includes aspects such as recoil patterns, fire and reload speeds, as well as sound and visual effects.  
In doing so, I have gained a deeper understanding of gun mechanics in FPS games, and how to implement them in Unreal.  

The "How" is covered in the [Implementation section](#implementation_guns) below.

The goal of this project was to understand the complex mechanics behind Valorant's gunplay, and to recreate that experience as closely as possible, in the same engine that Valorant itself is built in (Unreal Engine).
I can confidently say that through this project, and the countless hours I have spent analyzing and recreating these mechanics, I have achieved that goal.  

From the way the recoil behaves, to the individual spread of bullets, and the unique feel of each gun, I have managed to capture the essence of Valorant's gunplay in my own implementation.  
Knowing this, I feel confident in my ability to design and implement complex gun mechanics in future projects, and I feel confident I can apply this to Valorant itself, should the opportunity arise.  

I studied Valorant's gun mechanics extensively, through a combination of direct observation, data analysis, scouring the patch notes, reading developer blogs (the few that exist), and through the tireless efforts of the Valorant wiki community.
For reference, I have read through every single patch note released for each of the five guns I have recreated, to ensure that my implementation is as accurate as possible.  

Each variable gives me insight into how the gun is intended to behave, and by implementing these values into my own system, I can closely mimic the behavior of the original guns.
While I don't know exactly how Riot has implemented their guns, I can make educated guesses based on the data available to me, and through trial and error, I can refine my implementation to closely match the feel of the original guns.

<table width="790">
  <tr>
    <td>
      <img src="angel-Phantom-BP-1.png" alt="A view of the first half of the details panel for the base gun class." width="300" thumbnail="true"/>
    </td>
    <td>
      <img src="angel-Phantom-BP-2.png" alt="A view of the second half of the details panel for the base gun class." width="300" thumbnail="true"/>
    </td>
  </tr>
</table>
> A view of the details panel for the base gun class, showing many of the variables that define gun behavior. Most of these, and their values, were taken directly from Valorant's patch notes.

I feel confident that my implementation is close to the original, although far more rudimentary, as I'm sure Riot has a much more complex system in place. The important part is that the end result feels similar to the original, which I believe I have achieved.

Lastly, the system I have built is modular and extensible, allowing for easy addition of new guns and mechanics in the future.
This was a design decision I made early on, as I always do, to ensure that my systems are flexible and adaptable to future needs, even if the current project is small in scope.  
I see this as a valuable learning experience.

## Implementation { switcher-key="Guns" id="implementation_guns" }

> This section is on the technical side of recreating Valorant's guns. { style = "note" }

There are five guns in the game, showcasing the basic archetypes of guns found in Valorant:

- Pistol (Classic)
- Rifle (Vandal & Phantom)
- Sniper (Operator)
- Shotgun (Judge)

Each gun is built on a base class per archetype ("RifleBase, PistolBase, etc."), which defines the core functionality
and variables for that archetype.
The archetype base classes inherit from a common "GunBase" class, which contains shared functionality and variables for
all guns, like shooting, recoil, reloading, and equipping.

<img src="angel-AGunBase-as.png" alt="The AGunBase class in Angelscript." width="500" thumbnail="true"/>

All base classes are written in Angelscript, a scripting language implemented into a fork of Unreal by Hazelight (creators of It Takes Two, Split Fiction). [Read more about it on their website.](https://angelscript.hazelight.se)

The primary reason for using Angelscript over Blueprints or C++ is the rapid iteration time, as scripts can be
hot-reloaded during runtime, allowing for quick testing and tweaking of values without needing to recompile or restart
Unreal.
Furthermore, the language is growing in popularity, being used by other studios like Embark Studios (of "The Finals",
and "ARC Raiders"), and Croteam (of "The Talos Principle"), making it a valuable skill to learn.

Any audiovisual effects, animations, and particle effects are handled in Blueprints, as it is easier to handle those in
Blueprints.
Recoil is some-what handled in Blueprints thanks to Timelines, but the core logic is still in Angelscript.

### Shooting

When the player presses the fire button, the "Shoot" function is called on the gun, which checks if the gun can be fired.  
Assuming all checks pass, a trace is performed from the player's eyeline to the target point, with some spread applied based on a number of factors, like movement, crouching, and firing state (first shot, continuous fire, etc.).

<img src="angel-AGunBase-as-Trace.png" alt="The Trace function in the AGunBase class in Angelscript." width="500" thumbnail="true" style="block"/>
> The primary trace function used to determine where a bullet hits. A hit is registered if the trace collides with an object, and damage is applied based on the hit location (head, body, legs), as well as any armor the target may have.

The target point is calculated by the following function:
<img src="angel-AGunBase-as-GetTargetPoint.png" alt="The GetTargetPoint function in the AGunBase class in Angelscript." width="500" thumbnail="true" style="block"/>
> The function fires a ray from the player's camera to determine the target point.

<img src="angel-AGunBase-as-GetSpread.png" alt="The GetSpread function in the AGunBase class in Angelscript." width="500" thumbnail="true" style="block"/>
> GetSpread() calculates the spread based on various factors. It also outputs the current spread value for debugging purposes (drawing a cone in the world).

Once combined, these functions determine where the bullet hits, and damage is applied accordingly.  
Bullet penetration is also factored in, allowing bullets to pass through certain objects and deal reduced damage to targets behind them. At the time of writing, the damage reduction by bullet penetration is not fully implemented yet.  
Damage falloff over distance, on the other hand, is fully implemented.

### Damage Falloff
Damage falloff is calculated based on the distance between the shooter and the target.

<img src="angel-UDamageFalloff-as.png" alt="The UDamageFalloff class in Angelscript." width="500" thumbnail="true" style="block"/>
> The UDamageFalloff class is responsible for returning damage based on distance.

The damage to deal at a given range is set in a TMap variable, where the key is the distance in meters (unreal units / 100), and the value is an FVector, where each axis represents a body part hit (X=Head, Y=Body, Z=Legs). This allows for easy tweaking of damage values at different ranges.

When a bullet hits a target, the distance to the target and the body part hit is passed in by parameter, and the appropriate damage is retrieved from the TMap.  
I believe Valorant does this a little different, using a multiplier for headshots and leg shots, meaning you only need to store the body damage values, but I opted for this approach for simplicity and ease of tweaking.

### Recoil
Recoil is handled by a combination of Angelscript and Blueprints.  
The invocation of recoil is done in Angelscript, while the actual camera movement is handled in Blueprints using Timelines.  
At the time of writing, this system is still a work in progress, and will therefore be omitted for now.

### Equip
Equipping a gun is handled in Angelscript, with some Blueprint functionality for the actual animation and sound effects.  
When the player equips a gun, the "Equip" function is called on the gun, which attaches the gun to the player's hand socket, plays the equip animation, and sets the gun as the current weapon.
The UHolsterComponent class is responsible for all equipping and holstering functionality.

<img src="angel-UHolsterComponent-EquipGun.png" alt="The EquipGun function in the UHolsterComponent class in Angelscript." width="500" thumbnail="true" style="block"/>
> The EquipGun function handles equipping a gun to the player.

The actual equip logic is fairly straightforward, with most of the complexity being handled by the GrantGun function covered below.

<img src="angel-UHolsterComponent-GrantGun.png" alt="The GrantGun function in the UHolsterComponent class in Angelscript." width="500" thumbnail="true" style="block"/>
> The GrantGun function handles giving a gun to the player by spawning a new instance.

When a gun is granted to the player, a new instance of the gun is spawned, and the gun is added to the player's holster.  
The function ensures only one gun per archetype is holstered/equipped at a time. This is handled by checking if a gun of the same 'GunType' is already holstered, and if so, it is removed before adding the new gun.

### Reload
Reloading is also straightforward, with the "Reload" function being called when the player presses the reload button.
The function makes some very basic checks, like if the gun is already reloading, if there is ammo in reserve, and if the gun is not already full.
Then it calls a blueprint event to play the reload animation and sound effects, and finally refills the gun's magazine after the animation has completed.

### That's it!
For now, that's all there is to the gun implementation.  
As mentioned earlier, this is still a work in progress, and there are many features and improvements that can be made to the system.  

However, I believe this is a solid foundation for recreating Valorant's gun mechanics, and I look forward to continuing to refine and expand upon this system in the future.

> To explore other mechanics, select the "Mechanic" switcher in the top right of the website, left of the "Reach out!" button to switch between different mechanic breakdowns. { style = "note" }

## Abilities {switcher-key="Abilities"}

WIP.

## Implementation { switcher-key="Abilities" id="implementation_abilities" }

WIP.

## Agents {switcher-key="Agents"}

WIP.

## Implementation { switcher-key="Agents" id="implementation_agents" }

WIP.

## Buy Phase {switcher-key="Phases"}
> [Skip to the round phase](#round-phase) { style = "note" }

WIP.

## Implementation { switcher-key="Phases" id="implementation_buy_phase" }

WIP.

## Round Phase {switcher-key="Phases"}

WIP.

## Implementation { switcher-key="Phases" id="implementation_round" }