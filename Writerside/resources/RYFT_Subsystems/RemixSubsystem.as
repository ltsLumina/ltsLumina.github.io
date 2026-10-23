namespace Remix
{
	UFUNCTION(BlueprintPure)
	TArray<FRemixModifier> GetActiveModifiers() property
	{
		return URemixSubsystem::Get().ActiveModifiers;
	}

	UFUNCTION(BlueprintPure)
	TArray<FRemixModifier> GetPreviousModifiers() property
	{
		return UStageSubsystem::Get().LatestCompleteInfo.Modifiers;
	}

	UFUNCTION(BlueprintPure)
	bool HasAnyRemixes()
	{
		return !ActiveModifiers.IsEmpty();
	}

	UFUNCTION(BlueprintPure)
	float GetRemixScore(float CompletionTime)
	{
		if (!Remix::AreRemixesAvailable() || Remix::ActiveModifiers.IsEmpty())
			return 0;

		return URemixSubsystem::Get().CalculateRemixScore(CompletionTime);
	}

	/**
	 * @param bIncludingBlocklist - If true, includes remixes that are blocked in mixtapes (e.g. 'Disables grapple', or 'double resource cost'.)
	 */
	UFUNCTION(BlueprintPure)
	TArray<FRemixModifier> GetRandomRemix(int Count, EModifierType Type)
	{
		TArray<FRemixModifier> Result;

		TArray<FRemixModifier> Rows;
		UDataTable Table = UProjectGlobals::ModifiersTable;
		Table.GetAllRows(Rows);

		// only keep modifiers matching the requested type
		TArray<FRemixModifier> Candidates;
		for (const FRemixModifier& Row : Rows)
		{
			if (Row.Type == Type)
				Candidates.Add(Row);
		}

		if (Candidates.Num() == 0)
			return Result;

		for (int i = 0; i < Count; i++)
		{
			int Rand = Math::RandRange(0, Candidates.Num() - 1);
			Result.Add(Candidates[Rand]);
		}

		return Result;
	}

	UFUNCTION(BlueprintPure)
	bool AreRemixesAvailable()
	{
#if EDITOR
		if (UDebugPreferences::IsDevelopmentMode)
			return true;
#endif

		return Stage::HasGoldMedal() || GM::IsMixtape;
	}

	UFUNCTION(BlueprintPure)
	int GetNumModifiersByType(URemixSet Set, EModifierType Type)
	{
		int Positive = 0;
		int Negative = 0;

		for (FRemixModifier Mod : Set.AvailableModifiers)
		{
			if (Mod.Type == EModifierType::Positive)
				Positive++;
			else
				Negative++;
		}

		return Type == EModifierType::Positive ? Positive : Negative;
	}

	UFUNCTION(BlueprintPure)
	float GetMultiplier(TArray<FRemixModifier> Modifiers)
	{
		if (Modifiers.IsEmpty())
			return 1.f;

		float Value = 1.f;
		for (int i = 0; i < Modifiers.Num(); i++)
		{
			FRemixModifier Row = Modifiers[i];
			Value += Row.Multiplier - 1.f;
		}

		// Snap near-integers (e.g. 0.99 -> 1.0, 2.98 -> 3.0)
		float Nearest = Math::RoundToFloat(Value);
		if (Math::Abs(Value - Nearest) <= 0.02f)
			Value = Nearest;

		return Math::Max(Value, 0.1f); // has floor
	}
}

enum ERemixCategory
{
	Fun,
	Player,
	Abilities,
	Resource,
	Stage,
	Misc,
}

struct FRemixModifier
{
	UPROPERTY()
	FText Description;

	UPROPERTY()
	EModifierType Type;

	UPROPERTY(Meta = (Units = "x"))
	float Multiplier = 1.25f;

	UPROPERTY()
	TSubclassOf<URemixModifierEffect> EffectClass;

	UPROPERTY(Category = "Sorting")
	ERemixCategory Category;

	UPROPERTY(Category = "Stacking")
	bool bStackable = false;

	/** Should a new instance of the remix be applied per stack, or should we increment the stack count?
	 * Requires the gameplay effect to use EGameplayEffectStackingType::None
	 */
	UPROPERTY(Category = "Stacking", Meta = (EditCondition = "bStackable", EditConditionHides))
	bool bInstancedPerStack = false;

	UPROPERTY(Category = "Persistent ID", VisibleAnywhere)
	int PersistentID = -1;
}

event void FOnRemixesChanged(TArray<FRemixModifier> NewRemixes, TArray<FRemixModifier> OldRemixes);
event void FOnRemixesAdded(TArray<FRemixModifier> AddedRemixes);
class URemixSubsystem : UScriptWorldSubsystem
{
	access ReadOnly = private, *(readonly);
	access Remix = private, Remix;

	UPROPERTY()
	access:Remix
    TArray<FRemixModifier> ActiveModifiers;

	UPROPERTY(Category = "Events")
	FOnRemixesChanged OnRemixesChanged;

	UPROPERTY(Category = "Events")
	FOnRemixesAdded OnRemixesAdded;

	UFUNCTION(BlueprintOverride)
	void OnWorldBeginPlay()
	{
		UStageSubsystem::Get().OnStageBegin.AddUFunction(this, n"StageBegin");
		UStageSubsystem::Get().OnStageRestart.AddUFunction(this, n"StageRestart");

		if (GM::IsGameMode(EGameModeType::Stage))
		{
			TArray<FRemixModifier> DefaultMods = UStageSubsystem::Get().ActiveStageRow.GetRemixSet().DefaultModifiers;
			SetActiveModifiers(DefaultMods);

			if (!DefaultMods.IsEmpty())
				PrintWarning("Applied default remix modifiers.", 1.5f);
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void StageBegin(bool bIsInitialAttempt, int AttemptNum)
	{
		auto OwningASC = Game::Player.AbilitySystem;

		// Apply the confirmed set, not whatever the modal is currently showing
		for (auto Row : ActiveModifiers)
		{
			if (!Row.EffectClass.IsValid())
				continue;

			bool bInstancedPerStack = Row.bInstancedPerStack;
			bool bWrongStackingType = Row.bStackable && Row.EffectClass.DefaultObject.StackingType != EGameplayEffectStackingType::AggregateBySource;
			bool bTooFewStacks = Row.bStackable && Row.EffectClass.DefaultObject.StackingType == EGameplayEffectStackingType::AggregateBySource && Row.EffectClass.DefaultObject.StackLimitCount <= 0;

			if (bInstancedPerStack && Row.EffectClass.DefaultObject.StackingType != EGameplayEffectStackingType::None)
			{
				check(false, "InstancedPerStack modifiers must use EGameplayEffectStackingType::None.");
			}

			if (!bInstancedPerStack)
			{
				if (bWrongStackingType || bTooFewStacks)
					check(false, f"{Row.GetLabel()} is marked as bStackable, but the associated gameplay effect has the wrong stacking type ({Row.EffectClass.DefaultObject.StackingType:n})" + f"\nor the StackLimitCount is too low ({Row.EffectClass.DefaultObject.StackLimitCount})");
			}

			FGameplayEffectSpecHandle SpecHandle = OwningASC.MakeOutgoingSpec(Row.EffectClass, 0, OwningASC.MakeEffectContext());
			AbilitySystem::AddAssetTag(SpecHandle, GameplayTags::Effect_Remix_Modifier);

			OwningASC.ApplyGameplayEffectSpecToSelf(SpecHandle);
			Print(f"Applied modifier: {System::GetDisplayName(Row.EffectClass)}", 2.f, FLinearColor::DPink);
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void StageRestart(EStageRestartReason Reason)
	{
		RemoveModifiers();
	}

	UFUNCTION(NotBlueprintCallable)
	private void RemoveModifiers()
	{
		auto OwningASC = Game::Player.AbilitySystem;

		FGameplayEffectQuery ModifierQuery;
		ModifierQuery.EffectTagQuery = FGameplayTagQuery::MakeQuery_MatchTag(GameplayTags::Effect_Remix_Modifier);
		auto ModifierEffects = OwningASC.GetActiveEffects(ModifierQuery);

		FGameplayEffectQuery PersistentQuery; // tag to indicate we dont want to remove this modifier. Use cautiously!
		PersistentQuery.EffectTagQuery = FGameplayTagQuery::MakeQuery_MatchTag(GameplayTags::Effect_Persistent);
		auto PersistentEffects = OwningASC.GetActiveEffects(PersistentQuery);

		for (auto EffectToRemove : ModifierEffects)
		{
			if (!AbilitySystem::IsActiveGameplayEffectHandleValid(EffectToRemove))
				continue;

			if (PersistentEffects.Contains(EffectToRemove))
				continue;

			FString DebugString = AbilitySystem::GetActiveGameplayEffectDebugString(EffectToRemove);
			OwningASC.RemoveActiveGameplayEffect(EffectToRemove);
			Print(f"Removed modifier: {DebugString}", 2.f, FLinearColor(0.69, 0.20, 0.20));
		}
	}

	UFUNCTION()
	void SetActiveModifiers(TArray<FRemixModifier> NewModifiers)
	{
		OnRemixesChanged.Broadcast(NewModifiers, ActiveModifiers);
		ActiveModifiers = NewModifiers;
	}

	UFUNCTION()
	bool AddModifier(FRemixModifier Mod)
	{
		// Skip adding a duplicate modifier if it doesn't support stacking
		if (!Mod.bStackable && ActiveModifiers.Contains(Mod))
			return false;

		TArray<FRemixModifier> Added;
		Added.Add(Mod);

		ActiveModifiers.Add(Mod);

		OnRemixesAdded.Broadcast(Added);
		return true;
	}

	UFUNCTION()
	void ClearModifiers()
	{
		OnRemixesChanged.Broadcast(TArray<FRemixModifier>(), ActiveModifiers);
		ActiveModifiers.Empty();
	}

	access:Remix
    float CalculateRemixScore(float CompletionTime)
	{
		float PlatinumTime = 0;
		if (!UStageSubsystem::Get().ActiveStageRow.MedalMap.Find(EStageMedal::Platinum, PlatinumTime))
			return -1;

		float Score = 0;
		float SafeTime = Math::Max(CompletionTime, 0.01f); // avoid divide by zero
		Score = (PlatinumTime / SafeTime) * 1000.f;
		Score *= Remix::GetMultiplier(ActiveModifiers);
		Score = Math::RoundToInt(Score);
		return Score;
	}
}