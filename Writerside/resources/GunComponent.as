namespace UGunComponent
{
	const float TRACE_DISTANCE = 10000;

	enum EFireMode
	{
		Semi,
		Burst,
		Auto
	}
}

UCLASS(Meta = (PrioritizeCategories = "Debug"), Config = "Editor")
class UGunComponent : UActorComponent
{
	default bReplicates = true;

#if EDITOR
	UGunComponentDeveloperSettings DevSettings = UGunComponentDeveloperSettings.DefaultObject;
#endif

	// - end debug

	UPROPERTY(Category = "Gun")
	float ADSEventCooldown = 3.f;
	float ADSEventCooldownCounter = 0.f;

	UFUNCTION(BlueprintPure)
	UWeaponDefinition GetWeaponDefinition() property
	{
		return OwningHero.HeroDefinition.WeaponDefinition;
	}

	UFUNCTION(BlueprintPure)
	URecoilData GetRecoilData() property
	{
		auto Data = WeaponDefinition.RecoilData;
		if (Data == nullptr)
			PrintWarning(f"{WeaponDefinition.Name} has missing RecoilData!", 0);
		return Data;
	}

	UPROPERTY(NotVisible, BlueprintReadOnly)
	AScriptPondHero OwningHero;

	UPROPERTY(NotVisible, BlueprintReadOnly)
	AScriptPondController OwningController;

	UPROPERTY(Category = "Hero | GAS", NotVisible, BlueprintReadOnly)
	const UGenericGunAttributes GenericGunAttributes;

	UFUNCTION(Category = "Gun | Ammo", BlueprintPure)
	int GetCurrentAmmo() property
	{
		float CurrentValue = OwningHero.AbilitySystem.GetAttributeCurrentValue(UGenericGunAttributes, UGenericGunAttributes::AmmoName);
		return int(CurrentValue);
	}

	UFUNCTION(Category = "Gun | Ammo", BlueprintPure)
	int GetCurrentMaxAmmo() property
	{
		float CurrentValue = OwningHero.AbilitySystem.GetAttributeCurrentValue(UGenericGunAttributes, UGenericGunAttributes::MaxAmmoName);
		return int(CurrentValue);
	}

	/**
	 * The rounds per minute (RPM) of the gun, calculated from the fire rate.
	 * This is a derived property and is read-only.
	 */
	UPROPERTY(Category = "Gun | Shooting", VisibleInstanceOnly, BlueprintReadOnly)
	float RPM;

	/**
	 * The cooldown time between shots, in seconds.
	 * This is calculated as the inverse of the fire rate.
	 */
	UPROPERTY(Category = "Gun | Shooting", VisibleInstanceOnly, BlueprintReadOnly, Meta = (Units = "Seconds"))
	float ShootCooldown = 0.1f;

	/**
	 * The time elapsed since the last shot was fired, in seconds.
	 */
	UPROPERTY(Category = "Gun | Shooting", VisibleInstanceOnly, BlueprintReadOnly, Meta = (Units = "Seconds"))
	float TimeSinceLastShot = 0.0f;

	// - shooting helpers

	UPROPERTY(Category = "Gun | Shooting", VisibleInstanceOnly, BlueprintReadOnly, BlueprintGetter = "GetIsFiring")
	protected bool IsFiring;

	UFUNCTION(Category = "Gun | Shooting", BlueprintPure)
	bool GetIsFiring()
	{
		return TriggeredTime > ShootCooldown;
	}

	UPROPERTY(Category = "Gun | Shooting", VisibleInstanceOnly, BlueprintReadOnly, BlueprintGetter = "GetIsOnShootCooldown")
	bool IsOnShootCooldown;

	UFUNCTION(Category = "Gun | Shooting", BlueprintPure)
	bool GetIsOnShootCooldown()
	{
		return TimeSinceLastShot < ShootCooldown;
	}

	/**
	 * The current index in the recoil pattern. This increments with each shot fired.
	 * It is used to determine the recoil offset applied to the gun.
	 */
	UPROPERTY(Category = "Gun | Recoil", VisibleInstanceOnly, BlueprintReadOnly, Replicated)
	int BulletIndex;

	UPROPERTY(Category = "Gun | Recoil", VisibleInstanceOnly, BlueprintReadOnly)
	float RecoilPendingPitch = 0.0f;

	UPROPERTY(Category = "Gun | Recoil", VisibleInstanceOnly, BlueprintReadOnly)
	float RecoilPendingYaw = 0.0f;

	// Random yaw offset applied per bullet (set by RecoilData.RandomDeviation)
	float RandomYawOffsetMultiplier = 0.0f;

	UFUNCTION(BlueprintPure, Category = "Gun | Accuracy")
	bool IsBulletProtected(EPondMovementState MovementState)
	{
		bool IsInProtectedRange = BulletIndex < WeaponDefinition.ProtectedBullets;
		bool IsStill = MovementState == EPondMovementState::Still;
		bool PastStillThreshold = OwningHero.PondCharMoveComp.TimeSinceMoving > 0.5f;
		bool PastShootThreshold = TimeSinceLastShot > 0.75;

		bool Result = IsInProtectedRange && IsStill && (PastStillThreshold && PastShootThreshold);
		return Result;
	}

	UPROPERTY(Category = "Gun | Accuracy", VisibleInstanceOnly)
	FBulletSpreadData AccuracyCone;

	// ~

	UAngelscriptAbilitySystemComponent ASC;
	FVector TraceStart;
	FVector TraceEnd;

	UPROPERTY(BlueprintReadOnly, NotVisible)
	FHitResult LastHitResult;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OwningHero = Cast<AScriptPondHero>(GetOwner());
	}

	void Initialize()
	{
		OwningController = Cast<AScriptPondController>(OwningHero.Controller);

		ComponentTickEnabled = true; // need to defer tick until owning hero is init'd.

		GenericGunAttributes = OwningHero.AbilitySystem.GetAttributeSet(UGenericGunAttributes);

		ASC = AbilitySystem::GetAngelscriptAbilitySystemComponent(GetOwner());

		if (GetOwner().HasAuthority())
			AuthGrantAbilities(ASC);

		OnInitialize();
	}

	UFUNCTION(BlueprintEvent)
	void OnInitialize()
	{}

	UFUNCTION(BlueprintAuthorityOnly)
	void AuthGrantAbilities(UAbilitySystemComponent InASC)
	{
		if (IsValid(WeaponDefinition.ShootGameplayAbility))
			InASC.GiveAbility(WeaponDefinition.ShootGameplayAbility, 0, int(EGASInputID::Shoot));

		if (IsValid(WeaponDefinition.AltFireGameplayAbility))
			InASC.GiveAbility(WeaponDefinition.AltFireGameplayAbility, 0, int(EGASInputID::AltFire));

		if (IsValid(WeaponDefinition.ReloadGameplayAbility))
			InASC.GiveAbility(WeaponDefinition.ReloadGameplayAbility, 0, int(EGASInputID::Reload));
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (!IsValid(OwningController))
			return;

		if (OwningController.IsInputKeyDown(EKeys::RightMouseButton))
			StartAimDownSights();

		TickADSSendEventCooldown(DeltaSeconds);
		UpdateRecoil(DeltaSeconds);
		TimeSinceLastShot += DeltaSeconds;

		if (WeaponDefinition.AltModeUsesZoom)
		{
			if (IsAltMode && !ASC.HasGameplayTag(GameplayTags::State_Sprinting))
			{
				ZoomIn(DeltaSeconds);

				float32 Distance;
				if (ADSEventCooldownCounter >= ADSEventCooldown)
				{
					AScriptEnemyBase Enemy = GetADSTarget(UGunComponent::TRACE_DISTANCE, Distance);
					if (Enemy != nullptr)
						SendADSEventToTarget(Enemy);
				}
			}
			else
				ZoomOut(DeltaSeconds);
		}
	}

	FVector ApplySpread(FVector AimDirection, float SpreadDeg, FBulletSpreadData&out OutSpreadData = FBulletSpreadData())
	{
		float SpreadRad = Math::DegreesToRadians(SpreadDeg);

		// Random yaw angle around the aim direction
		float Yaw = Math::RandRange(0.0f, PI * 2.0f);

		// Random radius (sqrt for even distribution)
		float Radius = Math::Sqrt(Math::RandRange(0.0f, 1.0f)) * Math::Tan(SpreadRad);

		float OffsetX = Math::Cos(Yaw) * Radius;
		float OffsetY = Math::Sin(Yaw) * Radius;

		// Build an orthonormal basis around AimDirection
		FVector Right = FVector::UpVector.CrossProduct(AimDirection).GetSafeNormal();
		FVector Up = AimDirection.CrossProduct(Right).GetSafeNormal();

		// Apply spread offset
		FVector SpreadDir = (AimDirection + Right * OffsetX + Up * OffsetY).GetSafeNormal();

		OutSpreadData.ConeWidth = Math::Atan2(Math::Abs(OffsetX), 1.0f);
		OutSpreadData.ConeHeight = Math::Atan2(Math::Abs(OffsetY), 1.0f);
		OutSpreadData.ErrorAngle = Math::RadiansToDegrees(Math::Acos(SpreadDir.DotProduct(AimDirection)));

		return SpreadDir;
	}

	private float GetTraceDuration() property
	{
#if EDITOR
		return DevSettings.DebugTraceDuration;
#else
		return 0;
#endif
	}

	void TickADSSendEventCooldown(float DeltaTime)
	{
		if (ADSEventCooldownCounter < ADSEventCooldown)
		{
			ADSEventCooldownCounter += DeltaTime;
		}
	}

	AScriptEnemyBase GetADSTarget(float MaxDistance = UGunComponent::TRACE_DISTANCE, float32&out Dist = 0.f)
	{
		FVector Location;
		FRotator Rotation;
		OwningHero.Controller.GetPlayerViewPoint(Location, Rotation);
		FVector CameraLocation = Location;
		FVector CameraForward = Rotation.ForwardVector;

		TraceStart = CameraLocation;
		TraceEnd = CameraLocation + CameraForward * MaxDistance;

		FHitResult Hit;
		System::LineTraceSingle(TraceStart,
								TraceEnd,
								ETraceTypeQuery::Bullet,
								false,
								TArray<AScriptPondHero>(),
								EDrawDebugTrace::None,
								Hit,
								true,
								FLinearColor::Red,
								FLinearColor::Green,
								0);

		AScriptEnemyBase Enemy = Cast<AScriptEnemyBase>(Hit.Actor);
		if (Enemy == nullptr)
			return nullptr;

		return Enemy;
	}

	void SendADSEventToTarget(AScriptEnemyBase Enemy)
	{
		if (Enemy == nullptr)
			return;

		Payload.Instigator = GetOwner();
		Enemy.AbilitySystem.SendGameplayEvent(GameplayTags::Ability_Enchant_Trigger_OnADSHit, Payload);
		ADSEventCooldownCounter = 0.f;
	}

	FVector GetTargetPoint(float MaxDistance = UGunComponent::TRACE_DISTANCE, float32&out Dist = 0.f)
	{
		FVector Location;
		FRotator Rotation;
		OwningHero.Controller.GetPlayerViewPoint(Location, Rotation);
		FVector CameraLocation = Location;
		FVector CameraForward = Rotation.ForwardVector;

		TraceStart = CameraLocation;
		TraceEnd = CameraLocation + CameraForward * MaxDistance;

		// Get Target Point (the actual point the player is looking at)
		FHitResult Hit;
		System::LineTraceSingle(TraceStart,
								TraceEnd,
								ETraceTypeQuery::Bullet,
								false,
								TArray<AActor>(),
								EDrawDebugTrace::None,
								Hit,
								true,
								FLinearColor::Red,
								FLinearColor::Green,
								0);

		Dist = Hit.Distance;

#if EDITOR
		Cosmetic_DrawDebugTargetPointTrace(TraceStart, TraceEnd, TraceDuration);
#endif

		FVector TargetPoint = Hit.bBlockingHit ? Hit.Location : TraceEnd;
		return TargetPoint;
	}

	float Spread = 0;

	/**
	 * @return The calculated spread based on bullet index and movement state (e.g. Running vs Crouched).
	 * @remark This function is impure!
	 */
	UFUNCTION(Category = "Gun | Accuracy")
	float GetSpread(EPondMovementState MovementState)
	{
		UCurveFloat Curve = WeaponDefinition.SpreadCurve != nullptr ? WeaponDefinition.SpreadCurve : LinearSpreadCurve;

		bool IsProtected = IsBulletProtected(MovementState);

		float FirstShotSpread = IsAltMode ? WeaponDefinition.AltSpread : WeaponDefinition.HipSpread;
		float MaxSpread = IsAltMode ? WeaponDefinition.AltMaxSpread : WeaponDefinition.HipMaxSpread;

		float CurveTime = 0;

		if (!IsProtected)
		{
			CurveTime = Math::Clamp((1 + BulletIndex) / float(WeaponDefinition.MaxSpreadBullet), 0, 1);
			float Value = Curve.GetFloatValue(CurveTime);
			Value = Math::Clamp(Value, 0, 1);
			Spread += Value;

			if (BulletIndex == 0)
				Spread += FirstShotSpread;
		}
		else
		{
			// protected bullet is slightly tighter (dont mind the magic number)
			Spread = FirstShotSpread * 0.5f;
		}

		float Penalty = 0;

		switch (MovementState)
		{
			case EPondMovementState::Airborne:
				Penalty = WeaponDefinition.AirbornePenalty;
				break;

			case EPondMovementState::Run:
				Penalty = WeaponDefinition.RunPenalty;
				break;

			default:
				break;
		}

		Spread += Penalty;

		Spread = Math::Clamp(Spread, 0, (MaxSpread + Penalty));

#if EDITOR
		if (DevSettings.PrintSpreadInfo && GetOwner().HasAuthority()) // only print spread on authority
		{
			float PrintDuration = DevSettings.PrintSpreadDuration;
			switch (DevSettings.SpreadLoggingType)
			{
				case ESpreadInfoLogging::Normal:
				{
					FString ProtectedSuffix = IsProtected ? "(Protected)" : "";
					Print(f"{Spread=}° degrees {ProtectedSuffix}", PrintDuration, FLinearColor(0.5, 0.5, 1.0));
				}
				break;

				case ESpreadInfoLogging::Verbose:
				{
					// print statements in reverse order to appear top-down on-screen.

					FString ProtectedSuffix = IsProtected ? "(Protected)" : "";
					Print(f"{Curve.GetName()} @ {CurveTime=}", PrintDuration, FLinearColor(0.5, 0.5, 0.8));
					Print(f"{Penalty=}° degrees", PrintDuration, FLinearColor(0.5, 0.5, 0.9));
					Print(f"{Spread=}° degrees {ProtectedSuffix}", PrintDuration, FLinearColor(0.5, 0.5, 1.0));
				}
				break;

				default:
					break;
			}
		}
#endif
		return Spread;
	}

	TArray<FHitResult> Hits;
	bool BlockingHit;
	FGameplayEventData Payload;

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

	float GetAimAssistTraceRadius(float Dist)
	{
		float ConeHalfAngleDeg = GenericGunAttributes.AimAssist.CurrentValue;
		float ConeHalfAngleRad = Math::DegreesToRadians(ConeHalfAngleDeg);
		float Radius = Math::Tan(ConeHalfAngleRad) * Dist;

		return Radius;
	}

	EDrawDebugTrace CapsuleDebugTrace = EDrawDebugTrace::ForDuration;
	AActor SweepForTarget(FHitResult&out MagnetismHit, float Dist)
	{
		TArray<EObjectTypeQuery> ObjTypes;
		ObjTypes.Add(EObjectTypeQuery::Pawn);
		ObjTypes.Add(EObjectTypeQuery::Enemy);

		TArray<AActor> IgnoreActors;
		IgnoreActors.Add(GetOwner());

		float Radius = GetAimAssistTraceRadius(Dist);

#if EDITOR
		CapsuleDebugTrace = (GetOwner().AsPawn().IsLocallyControlled() && DevSettings.DrawLines && DevSettings.DrawAimAssistCapsule && DevSettings.DebugTraceType != EDrawDebugTrace::None) ? DevSettings.DebugTraceType : EDrawDebugTrace::None;
#else
		CapsuleDebugTrace = EDrawDebugTrace::None;
#endif

		System::CapsuleTraceSingleForObjects(TraceStart,
											 TraceEnd,
											 Radius,
											 0,
											 ObjTypes,
											 false,
											 IgnoreActors,
											 CapsuleDebugTrace,
											 MagnetismHit,
											 true,
											 FLinearColor::DPink,
											 FLinearColor::Red,
											 TraceDuration);

		return MagnetismHit.Actor;
	}

	FVector GetSpreadPoint(FVector&in TargetPoint, float&out SpreadDeg)
	{
		FVector AimDirection = (TargetPoint - TraceStart).GetSafeNormal();

		SpreadDeg = GetSpread(OwningHero.PondCharMoveComp.CurrentMovementState);

		FVector BulletDirection = ApplySpread(AimDirection, SpreadDeg, AccuracyCone);
		FVector SpreadEnd = TraceStart + BulletDirection * 10000.0f;

#if EDITOR
		Cosmetic_DrawAccuracyCone(AimDirection, SpreadDeg);
		Cosmetic_DrawDebugSpreadPointTrace(TraceStart, SpreadEnd, TraceDuration);
#endif

		return BulletDirection;
	}

	FVector GetAimDirection(FVector&in TargetPoint)
	{
		return (TargetPoint - TraceStart).GetSafeNormal();
	}

	/**
	 * @note Magetism doesn't work unless the trace was a blocking hit.
	 * In practice, this shouldn't matter since there will always be a wall to hit, but it is noticable when debugging.
	 */
	FVector GetMagnetizedPoint(AActor&in MagnetismTarget, FHitResult MagnetismHit, FVector SpreadPoint)
	{
		FVector PulledDir;
		if (IsValid(MagnetismTarget))
		{
			float MaxPullDeg = GenericGunAttributes.AimAssist.CurrentValue;

			FVector DesiredDir = (MagnetismHit.ImpactPoint - TraceStart).GetSafeNormal();

			FBulletSpreadData AimAssistCone;
			AimAssistCone.ConeWidth = Math::RadiansToDegrees(Math::Atan2(Math::Abs(DesiredDir.Y), 1.0f));
			AimAssistCone.ConeHeight = Math::RadiansToDegrees(Math::Atan2(Math::Abs(DesiredDir.Z), 1.0f));
			AimAssistCone.ErrorAngle = Math::RadiansToDegrees(Math::Acos(Math::Clamp(DesiredDir.DotProduct(SpreadPoint), -1.0f, 1.0f)));

			PulledDir = SpreadPoint;
			if (AimAssistCone.ErrorAngle > KINDA_SMALL_NUMBER)
			{
				// Move only a fraction so we rotate by at most MaxPullDeg
				float Alpha = Math::Min(1.0f, MaxPullDeg / AimAssistCone.ErrorAngle);
				PulledDir = (SpreadPoint + (DesiredDir - SpreadPoint) * Alpha).GetSafeNormal();
			}
			float PullAngleDeg = Math::RadiansToDegrees(Math::Acos(Math::Clamp(SpreadPoint.DotProduct(PulledDir), -1.0f, 1.0f)));
#if EDITOR
			Cosmetic_DrawAimAssistCone(PulledDir, PullAngleDeg);
#endif
		}

		return PulledDir;
	}

#if EDITOR
	void Cosmetic_DrawAccuracyCone(FVector Direction, float AngleInDegrees)
	{
		if (!DevSettings.DrawCones || !DevSettings.DrawAccuracyCone)
			return;

		if (!(GetOwner().AsPawn()).IsLocallyControlled())
			return;

		if (DevSettings.DebugTraceType != EDrawDebugTrace::None)
			System::DrawDebugConeInDegrees(TraceStart,
										   Direction,
										   10000.0f,
										   AngleInDegrees,
										   AngleInDegrees,
										   12,
										   FLinearColor::Blue,
										   TraceDuration);
	}
#endif

#if EDITOR
	void Cosmetic_DrawAimAssistCone(FVector Direction, float AngleInDegrees)
	{
		if (!DevSettings.DrawCones || !DevSettings.DrawAimAssistCone)
			return;

		if (!(GetOwner().AsPawn()).IsLocallyControlled())
			return;

		if (DevSettings.DebugTraceType != EDrawDebugTrace::None)
			System::DrawDebugConeInDegrees(TraceStart,
										   Direction,
										   10000.0f,
										   AngleInDegrees,
										   AngleInDegrees,
										   16,
										   FLinearColor::Purple,
										   TraceDuration);
	}
#endif

	private void TraceFinalHit(FVector FinalDir, FHitResult&out Hit)
	{
		TArray<AActor> ActorsToIgnore;
		ActorsToIgnore.Add(GetOwner()); // guncomponent is attached to character

		Hits.Empty();

		// Perform spread trace (the point the bullet will hit)
		BlockingHit = System::LineTraceMulti(TraceStart,
											 FinalDir,
											 ETraceTypeQuery::Bullet,
											 true,
											 ActorsToIgnore,
											 EDrawDebugTrace::None,
											 Hits,
											 true, // doesn't ignore the owning actor!! (ignores this component)
											 FLinearColor::Transparent,
											 FLinearColor::Transparent,
											 TraceDuration);

#if EDITOR
		Cosmetic_DrawDebugFinalPointTrace(TraceStart, FinalDir, TraceDuration);
#endif

		if (!BlockingHit)
		{
			Log("Trace did not hit anything!");
			ASC.SendGameplayEvent(GameplayTags::Ability_Enchant_Trigger_OnShot, Payload);

			Hit = FHitResult();
			LastHitResult = Hit;

			return;
		}

		FHitResult LastHit = Hits.Last();
		Hit = LastHit;
		LastHitResult = LastHit;

		Payload.Instigator = OwningHero.Controller;
		Payload.Target = LastHit.Actor;
		Payload.TargetData = AbilitySystem::AbilityTargetDataFromHitResult(LastHit);

		// Notify self ASC that we shot (trigger OnShot enchants)
		// Other actors -- such as the one we hit -- aren't notified.
		ASC.SendGameplayEvent(GameplayTags::Ability_Enchant_Trigger_OnShot, Payload);

		// ShootSFX();
		// HitSFX();

		if (GetOwner().HasAuthority())
			ExecuteImpactEffects(Hits, TraceStart);

		if (LastHit.Actor != nullptr)
		{
			Gameplay::ApplyPointDamage(
				LastHit.Actor,
				-1,
				FinalDir,
				LastHit,
				OwningHero.Controller,
				OwningHero,
				TSubclassOf<UDamageType>(UDamageType));

			/* // Pass hit result to enemy, currently used for locational ragdoll force on death.
			if (LastHit.Actor.IsA(AScriptEnemyBase))
			{
				AScriptEnemyBase Enemy = Cast<AScriptEnemyBase>(LastHit.Actor);
				Enemy.LastHitResult = LastHit;
			} */
		}
	}

#if EDITOR
	private void Cosmetic_DrawDebugTargetPointTrace(FVector InStart, FVector InEnd, float InDuration = 1.0f)
	{
		if (!(GetOwner().AsPawn()).IsLocallyControlled())
			return;

		if (!DevSettings.DrawLines || !DevSettings.DrawHitLine)
			return;

		FHitResult DummyHit;
		System::LineTraceSingle(
			InStart,
			InEnd,
			ETraceTypeQuery::Bullet,
			false,
			TArray<AActor>(),
			DevSettings.DebugTraceType,
			DummyHit,
			true,
			FLinearColor::Red,
			FLinearColor::Green,
			InDuration);
	}
#endif

#if EDITOR
	private void Cosmetic_DrawDebugSpreadPointTrace(FVector InStart, FVector InEnd, float InDuration = 1.0f)
	{
		if (!(GetOwner().AsPawn()).IsLocallyControlled())
			return;

		if (!DevSettings.DrawLines || !DevSettings.DrawSpreadLine)
			return;

		FHitResult DummyHit;
		System::LineTraceSingle(
			InStart,
			InEnd,
			ETraceTypeQuery::Bullet,
			false,
			TArray<AActor>(),
			DevSettings.DebugTraceType,
			DummyHit,
			true,
			FLinearColor::Yellow,
			FLinearColor::Green,
			InDuration);
	}
#endif

#if EDITOR
	private void Cosmetic_DrawDebugFinalPointTrace(FVector InStart, FVector InEnd, float InDuration = 1.0f)
	{
		if (!(GetOwner().AsPawn()).IsLocallyControlled())
			return;

		if (!DevSettings.DrawLines || !DevSettings.DrawFinalLine)
			return;

		TArray<AActor> ActorsToIgnore;
		ActorsToIgnore.Add(GetOwner());

		FHitResult DummyHit;
		System::LineTraceSingle(
			InStart,
			InEnd,
			ETraceTypeQuery::Bullet,
			false,
			ActorsToIgnore,
			DevSettings.DebugTraceType,
			DummyHit,
			true,
			FLinearColor::LucBlue,
			FLinearColor::Green,
			InDuration);
	}
#endif

	void ApplyRecoilImpulse()
	{
		if (OwningHero == nullptr || !OwningHero.IsLocallyControlled())
			return;

		if (!IsValid(RecoilData))
			return;

		float RecoilStat = GenericGunAttributes.Recoil.CurrentValue;
		float PitchKick = 0.0f;
		float YawKick = 0.0f;
		RecoilData.CalculateRecoilKick(0, RecoilStat, PitchKick, YawKick);

		// Generate a random yaw offset once per bullet
		if (RecoilData.RandomDeviation > 0)
			RandomYawOffsetMultiplier = Math::RandRange(-RecoilData.RandomDeviation, RecoilData.RandomDeviation);
		else
			RandomYawOffsetMultiplier = 1;

		RecoilPendingPitch += PitchKick;
		RecoilPendingYaw += YawKick;
	}

	void UpdateRecoil(float DeltaSeconds)
	{
		if (OwningHero == nullptr || !OwningHero.IsLocallyControlled())
			return;

		if (!IsValid(RecoilData))
			return;

		if (Math::Abs(RecoilPendingPitch) <= KINDA_SMALL_NUMBER && Math::Abs(RecoilPendingYaw) <= KINDA_SMALL_NUMBER)
			return;

		float LerpTime = Math::Max(RecoilData.RecoilLerpTime, 0.001f);
		float Alpha = Math::Clamp(DeltaSeconds / LerpTime, 0.0f, 1.0f);

		float PitchStep = RecoilPendingPitch * Alpha;
		float YawStep = RecoilPendingYaw * Alpha;

		float MovementRecoilPenalty = OwningHero.GetVelocity().IsNearlyZero() ? 1 : WeaponDefinition.VerticalRecoilRunningMultiplier;
		float AimDownSightsRecoilMultiplier = !IsAltMode ? 1 : WeaponDefinition.AimDownSightsRecoilMultiplier;

		FVector2D Recoil;
		Recoil.Y = PitchStep * MovementRecoilPenalty * AimDownSightsRecoilMultiplier;
		Recoil.X = YawStep * RandomYawOffsetMultiplier * AimDownSightsRecoilMultiplier;
		ApplyControlRecoil(Recoil.Y, Recoil.X);

		RecoilPendingPitch -= PitchStep;
		RecoilPendingYaw -= YawStep;

		// Cleanup after recoil has settled.

		if (Math::Abs(RecoilPendingPitch) <= KINDA_SMALL_NUMBER)
			RecoilPendingPitch = 0.0f;

		if (Math::Abs(RecoilPendingYaw) <= KINDA_SMALL_NUMBER)
			RecoilPendingYaw = 0.0f;

		if (Math::Abs(RecoilPendingYaw) <= KINDA_SMALL_NUMBER)
			RandomYawOffsetMultiplier = 0.0f;
	}

	void ApplyControlRecoil(float PitchDelta, float YawDelta)
	{
		if (OwningHero == nullptr || !OwningHero.IsLocallyControlled())
			return;

		if (Math::Abs(PitchDelta) > KINDA_SMALL_NUMBER)
			OwningHero.AddControllerPitchInput(-PitchDelta);

		if (Math::Abs(YawDelta) > KINDA_SMALL_NUMBER)
			OwningHero.AddControllerYawInput(YawDelta);
	}

	UFUNCTION(NetMulticast)
	void ExecuteImpactEffects(TArray<FHitResult> InHits, FVector InShooterLocation)
	{
		for (FHitResult Hit : InHits)
		{
			/* FRotator TracerRotation = (InShooterLocation - Hit.ImpactPoint).Rotation();
			Niagara::SpawnSystemAtLocation(WeaponDefinition.TracerEffect, Hit.ImpactPoint, TracerRotation); */

			// If we hit a character, run it's assigned hit reaction gameplay cue,
			// do not spawn a normal impact effect.
			if (Hit.Actor.IsA(AScriptPondCharacter) || Hit.Actor.IsA(AScriptPondHero))
			{
				AScriptPondCharacter HitChar = Cast<AScriptPondCharacter>(Hit.Actor);

				if (!IsValid(HitChar))
					continue;

				FGameplayCueParameters CueParams;
				CueParams.Location = Hit.ImpactPoint;
				CueParams.Normal = Hit.ImpactNormal;

				if (FHitResult::IsPrecisionHitFromHitResult(Hit))
				{
					for (FGameplayTag Tag : HitChar.EntityDefinition.PrecisionHitReactionTags)
					{
						GameplayCue::ExecuteGameplayCueOnActor(HitChar, Tag, CueParams);
					}
				}
				else
				{
					for (FGameplayTag Tag : HitChar.EntityDefinition.HitReactionTags)
					{
						GameplayCue::ExecuteGameplayCueOnActor(HitChar, Tag, CueParams);
					}
				}

				continue;
			}

			FRotator ImpactRotation = Hit.ImpactNormal.Rotation();
			Niagara::SpawnSystemAtLocation(WeaponDefinition.HitImpactEffect, Hit.ImpactPoint, ImpactRotation);
		}
	}

	float ElapsedTime;
	float TriggeredTime;

	UFUNCTION(NotBlueprintCallable)
	private void Interim_Shoot(FInputActionValue ActionValue, float32 InElapsedTime,
					   float32 InTriggeredTime, const UInputAction SourceAction)
	{
		this.ElapsedTime = InElapsedTime;
		this.TriggeredTime = InTriggeredTime;

		ASC.TryActivateAbilityByClass(WeaponDefinition.ShootGameplayAbility);
		ASC.PressInputID(int(EGASInputID::Shoot));
	}

	UFUNCTION(NotBlueprintCallable)
	private void Interim_Shoot_Completed(FInputActionValue ActionValue, float32 InElapsedTime,
								 float32 InTriggeredTime, const UInputAction SourceAction)
	{
		ASC.ReleaseInputID(int(EGASInputID::Shoot));
	}

	FTimerHandle SprintCancelCooldown;

	/**
	 * Generic shoot function.
	 * @param bIgnoreInternalCooldown If true, the internal cooldown the gun component handles is ignored (You should use a custom GameplayEffect cooldown if true).
	 */
	UFUNCTION(Category = "Gun Component | Shooting")
	bool Shoot(FHitResult&out Hit, bool bIgnoreInternalCooldown = false)
	{
		if (HeroUtils::IsSprinting(OwningHero))
		{
			OwningHero.PondCharMoveComp.BP_StopSprinting();
			SprintCancelCooldown = System::SetTimer(this, n"SprintCancel", 0.1f, false);
			return false;
		}

		if (System::IsTimerActiveHandle(SprintCancelCooldown))
			return false;

		float FireRateAttribute = GenericGunAttributes.FireRate.CurrentValue;

		ShootCooldown = 1.0 / FireRateAttribute;
		RPM = FireRateAttribute * 60;

		// Assumes player has not fired for a while, reset bullet index
		BulletIndex = TimeSinceLastShot > 0.4f ? 0 : BulletIndex;

		switch (WeaponDefinition.FireMode)
		{
			case UGunComponent::EFireMode::Semi:
			case UGunComponent::EFireMode::Burst:
				// Only allow firing on initial press in semi and burst modes
				if (GetIsFiring())
					return false;
				break;

			case UGunComponent::EFireMode::Auto:
				// Allow holding down the trigger in auto mode
				break;
		}

		if (GetIsOnShootCooldown() && !bIgnoreInternalCooldown)
			return false;

		if (CurrentAmmo <= 0 && !bIgnoreInternalCooldown)
		{
			PrintWarning(f"No ammo! Cannot fire.", 0, FLinearColor(1.0, 0.5, 0.0));
			return false;
		}

		Fire(Hit);

		// if (IsValid(Hit.Actor))
		// Print(f"{Hit.Actor.ActorNameOrLabel=}");

		return true;
	}

	float PreAimDownSightsFOV;
	float ZoomTargetFOV = 0;
	float ZoomMismatchElapsed = 0;
	float ZoomInterpTolerance = 0.1f;
	float ZoomFallbackTimeout = 3.0f;

	UFUNCTION(NotBlueprintCallable)
	private void SprintCancel()
	{
		// this actually does something -- DO NOT REMOVE!
	}

	/**
	 * Divide-by-zero helper.
	 */
	float GetZoomMultiplier() const
	{
		float ZoomValue = GenericGunAttributes.Zoom.CurrentValue;
		ThrowIf(ZoomValue <= 0, "Cannot divide by zero!");

		float Result = Math::Max(ZoomValue, 0.01f);
		return Result;
	}

	private void BeginZoom(UCameraComponent Camera)
	{
		if (!IsValid(Camera))
			return;

		if (PreAimDownSightsFOV <= 0.0f)
			PreAimDownSightsFOV = Camera.FieldOfView;

		ZoomTargetFOV = PreAimDownSightsFOV / GetZoomMultiplier();
	}

	private void UpdateZoom(UCameraComponent Camera, float DeltaSeconds, bool ZoomingIn)
	{
		if (!IsValid(Camera))
			return;

		if (PreAimDownSightsFOV <= 0.0f)
			PreAimDownSightsFOV = Camera.FieldOfView;

		if (ZoomTargetFOV <= 0.0f)
			ZoomTargetFOV = PreAimDownSightsFOV / GetZoomMultiplier();

		float Desired = ZoomingIn ? ZoomTargetFOV : PreAimDownSightsFOV;
		Camera.FieldOfView = Math::FInterpTo(Camera.FieldOfView, Desired, DeltaSeconds, WeaponDefinition.AltZoomSpeed);

		bool LooksZoomedIn = Math::IsNearlyEqual(Camera.FieldOfView, ZoomTargetFOV, ZoomInterpTolerance);
		if (!IsAltMode && LooksZoomedIn)
		{
			ZoomMismatchElapsed += DeltaSeconds;
			if (ZoomMismatchElapsed >= ZoomFallbackTimeout)
			{
				EndZoom(Camera, true);
				ZoomMismatchElapsed = 0;
				return;
			}
		}
		else
		{
			ZoomMismatchElapsed = 0;
		}

		if (Math::IsNearlyEqual(Camera.FieldOfView, Desired, ZoomInterpTolerance))
		{
			Camera.FieldOfView = Desired;

			if (!ZoomingIn)
			{
				PreAimDownSightsFOV = 0;
				ZoomTargetFOV = 0;
			}
		}
	}

	private void EndZoom(UCameraComponent Camera, bool ForceReset = false)
	{
		if (ForceReset)
		{
			if (IsValid(Camera) && PreAimDownSightsFOV > 0.0f)
			{
				Camera.FieldOfView = Math::Max(PreAimDownSightsFOV, Camera.FieldOfView);
				PreAimDownSightsFOV = 0;
			}

			ZoomTargetFOV = 0;
			ZoomMismatchElapsed = 0;
		}
	}

	void ZoomIn(float DeltaSeconds)
	{
		auto Camera = UCameraComponent::Get(GetOwner());
		if (!IsValid(Camera))
			return;

		if (ZoomTargetFOV <= 0.0f)
			BeginZoom(Camera);

		UpdateZoom(Camera, DeltaSeconds, true);
	}

	void ZoomOut(float DeltaSeconds)
	{
		auto Camera = UCameraComponent::Get(GetOwner());
		if (!IsValid(Camera))
			return;

		UpdateZoom(Camera, DeltaSeconds, false);
	}

	UFUNCTION()
	void StartAimDownSights(FInputActionValue ActionValue = FInputActionValue(), float32 InElapsedTime = -1, float32 InTriggeredTime = -1,
							const UInputAction SourceAction = nullptr)
	{
		if (IsAltMode || !HeroUtils::CanAltMode(OwningHero))
			return;

		if (HeroUtils::IsSprinting(OwningHero))
			OwningHero.PondCharMoveComp.BP_StopSprinting();

		auto Camera = UCameraComponent::Get(GetOwner());
		BeginZoom(Camera);

		SetAltMode(true);

		// Only RPC if we're not authoritative
		if (!GetOwner().HasAuthority())
			Server_SetAltMode(true);

		ASC.TryActivateAbilityByClass(WeaponDefinition.AltFireGameplayAbility);
		ASC.PressInputID(int(EGASInputID::AltFire));
	}

	UFUNCTION()
	void EndAimDownSights(FInputActionValue ActionValue = FInputActionValue(), float32 InElapsedTime = -1, float32 InTriggeredTime = -1,
						  const UInputAction SourceAction = nullptr)
	{
		if (!IsAltMode)
			return;

		SetAltMode(false);

		// Only RPC if we're not authoritative
		if (!GetOwner().HasAuthority())
			Server_SetAltMode(false);

		ASC.ReleaseInputID(int(EGASInputID::AltFire));
	}

	UFUNCTION(Server)
	void Server_SetAltMode(bool NewAltMode)
	{
		SetAltMode(NewAltMode);
	}

	UFUNCTION(BlueprintPure)
	bool GetIsAltMode() property
	{
		return HeroUtils::IsAltMode(OwningHero);
	}

	void SetAltMode(bool NewAltMode)
	{
		if (!NewAltMode)
		{
			ASC.RemoveLooseGameplayTag(GameplayTags::State_Weapon_AltFiring, 1, EGameplayTagReplicationState::TagAndCountToAll);
			OwningHero.PondCharMoveComp.StopAimDownSights();
		}
		else
		{
			ASC.AddLooseGameplayTag(GameplayTags::State_Weapon_AltFiring, 1, EGameplayTagReplicationState::TagAndCountToAll);
			OwningHero.PondCharMoveComp.StartAimDownSights();
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void Interim_Reload(FInputActionValue ActionValue, float32 InElapsedTime,
						float32 InTriggeredTime, const UInputAction SourceAction)
	{
		ASC.TryActivateAbilityByClass(WeaponDefinition.ReloadGameplayAbility);
		ASC.PressInputID(int(EGASInputID::Reload));
	}
};

asset LinearSpreadCurve of UCurveFloat
{
	/*
		------------------------------------------------------------------
	1.0 |                                                            .·''|
		|                                                        .·''    |
		|                                                    .·''        |
		|                                                .·''            |
		|                                            .·''                |
		|                                        .·''                    |
		|                                    .··'                        |
		|                                .··'                            |
		|                            .··'                                |
		|                        .··'                                    |
		|                    .··'                                        |
		|                ..·'                                            |
		|            ..·'                                                |
		|        ..·'                                                    |
		|    ..·'                                                        |
	0.0 |..·'                                                            |
		------------------------------------------------------------------
		-0.3                                                           1.0
	*/
	AddLinearCurveKey(-0.3, 0.0);
	AddLinearCurveKey(1.0, 1.0);
}
