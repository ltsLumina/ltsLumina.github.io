---
switcher-label: Contribution
---

# FATE

## Leadership { switcher-key="Leadership"}

FATE is a love-letter to Destiny (2), and an attempt at creating a new genre ("Raid-like").  
Our combined efforts across 7 weeks brought us a product we were over-joyed to play, and especially to see others enjoying it and its marvels.

### Vision

The project went through many iterations, including a drastic pivot on the day of our Alpha deadline. I was leading the charge on this pivot: directing our new game vision, rethinking our thought-process, and down-scoping our engineering.  

Our initial vision was of a semi-procedurally-generated map -- consisting of sublevels that we would stitch together procedurally -- as you progress through 2 puzzles and a boss fight.

### Pivot

Realizing the difficulty of making this work in a multiplayer setting (after dozens of hours of troubleshooting), I announced to our team that our current vision and workflow would not be sustainable. The team was in unanimous agreement.  

Later that day, we pivoted to a hand-crafted experience with 3 characters (down from 4), more thought-provoking puzzles, more cooperation, and far more sustainable workflows. Workflow changes included better communication about working hours, scoping down areas where we were lacking in raw workforce (e.g. Animations), and focusing on polishing our core experience, rather than opting for more content -- even though we felt it was doable -- aiming for more healthy and sustainable work.

### End Result

The pivot was often discussed in retrospectives as the saving-grace moment, and most pivotal reason behind the success of our game.

I am very glad I stepped up and led the pivot and project moving forward, and see this as a milestone in my time as a student, showcasing strong ownership and respect for the project and my team.

## Implementation { switcher-key="Implementation"}

FATE's technical implementation is my most ambitious project yet, stretching 15,000+ lines of code across Angelscript and C++. Over 300+ hours spent coding (by hand -- AI was not used to generate large chunks of code. Occasionally used for refactoring.)

[![wakatime](https://wakatime.com/badge/user/018b0c84-c3a0-4f65-b3b0-741d40b02439/project/4fa5f7c0-6d66-4188-85c3-1e207ee6bcad.svg)](https://wakatime.com/badge/user/018b0c84-c3a0-4f65-b3b0-741d40b02439/project/4fa5f7c0-6d66-4188-85c3-1e207ee6bcad)
<img src="FATE-as-metrics.png" alt="FATE Angelscript metrics" style="block"/>
<img src="FATE-cpp-metrics.png" alt="FATE C++ metrics" style="block"/>

We used a combination of **Angelscript**, **GAS** (Gameplay Ability System), [network] **Replication**, and the **AdvancedSessions** plugin in this project.  
As the lead programmer (and designer), I built the core functionality of our game's entire framework through a combination of these parts.  

The first couple weeks for the programmers and designers consisted of getting caught up to speed on how to work with GAS and Replication, two things no one else had worked with previously. I acted as the primary source of information on how these systems worked on their own, as well as how I had implemented it for our project.

[Tranek's unofficial GAS documentation](https://github.com/tranek/GASDocumentation), Epic Games' own GAS tutorials, and a handful of GDC talks were used as starting points for everyone (including myself when I began researching these topics.)

Two scripts that did a lot of heavy-lifting were the GunComponent and HealthAttributes scripts. I held sole ownership of these scripts. (As the most proficient at angelscript during development, I held ownership of all script files, barring a couple.)

<p>
You can view the related files in their entirety here:
<br></br>
<resource src="GunComponent.as"/>
<br></br>
<resource src="HealthAttributes.as"/>
</p>
<code>
The up-to-date files are hosted on a private repository, so these files are dated to August 3rd 2026.
</code>

My thought process in the development of most scripts was to write clean, self-documenting code, with additional documentation when applicable, or to clarify tips/tricks with the language that my in-learning teammates would appreciate.

### GunComponent

<code-block lang="actionscript" collapsible="true" default-state="collapsed" collapsed-title="GunComponent.as - Fire() function" emphasize-lines="4,5,6,7,16,24,39,40,43">
<![CDATA[
/**
	 * Fires four traces, which each serve a separate purpose toward calculating where a bullet will hit.
	 * Each trace returns a point in space that is used to calculate the end result.
	 * - `TargetPoint`: The vector point hit from the player's eyes to the center of the player's view across `MaxDistance`units.
	 * - `SpreadPoint`: Vector point at which the bullet would hit when accounting for added spread from `BulletIndex` (recoil), `MovementError` (penalty) and crouch/standing coefficient.
	 * - `MagnetizedPoint` Vector point that the `BulletMagnetism` stat 'pulled' the `SpreadPoint` toward, based on the `ErrorAngle` of the `SpreadPoint`.
	 * - `FinalPoint`: The final point in space that the bullet will hit, accounting for `TargetPoint`, `SpreadPoint`, and `MagnetizedPoint` (if a target was hit by the magnetism capsule trace).
	 */
	void Fire(FHitResult&out Hit)
	{
		ApplyRecoilImpulse();

		// Distance from the player to the point hit.
		float32 Distance;
		// The point the player was aiming at.
		FVector TargetPoint = GetTargetPoint(UGunComponent::TRACE_DISTANCE, Distance);

		// Where the spread wants the bullet to go.
		float ConeExtents;
		FVector SpreadPoint = GetSpreadPoint(TargetPoint, ConeExtents);

		TArray<AActor> IgnoreActors;
		IgnoreActors.Add(GetOwner());
		FVector SpreadEnd = TraceStart + SpreadPoint * 10000.0f;

		FHitResult HeadHit;
		System::LineTraceSingle(TraceStart,
								SpreadEnd,
								ETraceTypeQuery::Visibility,
								false,
								IgnoreActors,
								EDrawDebugTrace::None,
								HeadHit,
								true,
								FLinearColor::Transparent); // transparent because we don't want to render the trace here, we handle it in its own Cosmetic_DrawXXX function.

		// MAGNETISM - Where the bullet gets dragged to, if applicable (an enemy was within magnetism/aim-assist range).
		FHitResult MagnetismHit;
		AActor TargetActor = SweepForTarget(MagnetismHit, Distance);
		FVector MagnetizedPoint = GetMagnetizedPoint(TargetActor, MagnetismHit, SpreadPoint);

		// The final impact point, affected by magnetism if applicable (i.e., only magnetize if we hit the body of the target. We dont want to magnetize the bullet away from the head.)
		FVector ImpactPoint = TraceStart + (IsValid(TargetActor) && !FHitResult::IsPrecisionHitFromHitResult(HeadHit) ? MagnetizedPoint : SpreadPoint) * UGunComponent::TRACE_DISTANCE;
		TraceFinalHit(ImpactPoint, Hit);

		if (GetOwner().HasAuthority())
			BulletIndex++;

		TimeSinceLastShot = 0;
	}
]]>
</code-block>

The highlighted lines of code in the code block emphasize the core calculations that build toward the final bullet impact location.  
Several rays are fired from the player's view that build a target profile, including:
1. The exact point in space the player was aiming at.
2. A deviation from the target point (1.) -- the 'spread point' (or bloom.)
3. The target the player is aiming at, if applicable. Used for bullet-magnetism (makes near-misses more likely to hit. This is what makes shooting feel so snappy in Bungie's games like Halo, Destiny, and Marathon.)
4. The final calculated point in space the bullet will hit.

There are a few more things happening behind the scenes to make the shooting feel as good as possible, but you can read up on that in the full script file.

### HealthAttributes

Finally, the HealthAttributes script is the backbone of taking/dealing damage.

<code-block lang="actionscript" collapsible="true" default-state="collapsed" collapsed-title="HealthAttributes.as - PostGameplayEffectExecute()">
<![CDATA[
if (Health.CurrentValue == OldHealth && !IsDamageImmune)
{
    // health didnt change.
    Log(n"PostApply", f"GameplayEffect: {EffectSpec.ToSimpleString()} - VALUE HAD NO CHANGE.");
    return;
}
else if (WasHealed)
{
    // receiving healing doesn't do anything special here.
}
// we want to continue the on-hit logic if we're damage immune,
// but overwriting `TookDamage = true` would potentially lead to side effects like enchantment triggers,
// hence why we do this odd check.
else if (TookDamage || (IsDamageImmune))
{
    // DamageDealt according to Calculation Class.
    float DamageDealt = AppliedMagnitude;
    float AbsDamageDealt = Math::Abs(DamageDealt);
    float DamageCapped = Math::Clamp(AbsDamageDealt, 0, UGenericGunAttributes::DAMAGE_CAP);

    // Apply hit reactions (e.g. regen-block)

    TSubclassOf<UAngelscriptGameplayEffect> RegenBlockedEffect = UAssetSubsystem::Get().DefaultRegenerationBlockedEffect;
    InstigatorASC.ApplyGameplayEffectToTarget(RegenBlockedEffect, AbilitySystemComponent, 1, EffectSpec.Context);

    // Gets the enchantment triggers based on a list of conditions.
    auto TriggerTags = GetEnchantmentTriggers(TookDamage, WasPrecision, WasKill, EffectSpec);
    for (auto& TriggerTag : TriggerTags)
    {
        // The instigator of the enchant trigger recieves the event (typically always the player)
        InstigatorASC.SendGameplayEvent(TriggerTag, Payload);

        // Log the information.
        if (TriggerTag.IsValid())
            Log(n"Enchantments", f"{InstigatorAvatar.GetName()} received tag: {TriggerTag=}");

        if (InstigatorASC != AbilitySystemComponent) // we're essentially checking if we're not the player here.
        {
            // We also send the event to the abilitysystem who got hit, so they can react to it as well.
            // E.g., if the enemy wants to react to getting precision hit, they can call "Wait Gameplay Event to Actor".
            AbilitySystemComponent.SendGameplayEvent(TriggerTag, Payload);

            // Log the information.
            if (TriggerTag.IsValid())
                Log(n"Enchantments", f"{ReceiverAvatar.GetName()} received tag: {TriggerTag=}");
        }
    }

    // A lot more happens above and below here, but for the sake of brevity I've cut it down.
    // You can view the file in its entirety from the link above. 
}
]]>
</code-block>

Something we did to make the GameplayAbility/Effect workflow more tailored to our project was to extend the built-in EffectContext with our own fields like IsPrecisionHit.   
This gave both script and blueprint an easy way to ask: "was this a precision hit?", and even overwrite it for special enchantments -- allowing them to deal precision damage -- proccing other enchantments.   

A small change like this quickly builds the feeling of a rogue-lite when one headshot activates multiples effects and chains across enemies.

Many changes like these that gave us extended functionality in script or blueprint were often made on the C++ side.  
I also extended our editor through C++ and Angelscript to improve our workflow (examples include linking directly to documentation in the toolbar.)

Alongside the implementation of GAS -- which comes with client-predicted replication -- we also had a lot of manual replication to handle.  
My primary role on the replication side of things was replicating game state to the UI, such as healthbars, nametags, and boss-bars.  
However, as the most experienced with replication, I still remained the primary source of information and assistance on the topic.

### Closing Thoughts

Having written 15,000+ lines of code, this is only a fraction of my work on this project, but should you want to hear more, please do not hesitate to reach out to me on [LinkedIn](https://www.linkedin.com/in/itslumina), [Discord](https://discordapp.com/users/287272193946288129), [email](mailto:itsluminas@gmail.com), or elsewhere.

<seealso style="cards">
    <category ref="angel">
        <a href="Angel.md" summary="This project served as a partial base for FATE."/>
    </category>
</seealso>