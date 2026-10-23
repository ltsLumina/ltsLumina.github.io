namespace Stage
{
	const FName CURRENT_STAGE = n"CURRENT_STAGE";

	UFUNCTION(BlueprintPure)
	UDataTable GetStageTable() property
	{
		if (GetCurrentWorld() == nullptr)
			return UProjectGlobals::StageTable;

		if (GM::IsMixtape)
			return UMixtapeSubsystem::Get().ActiveMixtape;

		return UProjectGlobals::StageTable;
	}

	/** Returns all rows from the CURRENT stage table. */
	TArray<FStageRow> GetRows() property
	{
		TArray<FStageRow> _Rows;

		if (GM::IsMixtape)
		{
			TArray<FMixtapeRow> MixtapeRows;
			UMixtapeSubsystem::Get().ActiveMixtape.GetAllRows(MixtapeRows);

			for (auto& Row : MixtapeRows)
				_Rows.Add(Row.Stage);

			return _Rows;
		}
		else
		{
			StageTable.GetAllRows(_Rows);
			return _Rows;
		}
	}

	/** Helper to find a row from the CURRENT stage table.
	 * Since mixtape tables use FMixtapeRow, we need to differentiate the lookup.
	 */
	bool FindRow(FName RowName, FStageRow&out Row)
	{
		bool bSuccess = false;

		if (GM::IsMixtape)
		{
			FMixtapeRow MixtapeRow;
			bSuccess = StageTable.FindRow(RowName, MixtapeRow);
			Row = MixtapeRow.Stage;
		}
		else
		{
			bSuccess = StageTable.FindRow(RowName, Row);
		}

		return bSuccess;
	}

	// - EPISODE -

	UFUNCTION(BlueprintPure)
	EStageEpisode GetCurrentEpisode() property
	{
		if (UStageSubsystem::Get() == nullptr)
			return EStageEpisode::EpisodeDebug;

		return UStageSubsystem::Get().ActiveStageRow.Episode;
	}

	UFUNCTION(BlueprintPure)
	bool IsOnboardingLevel()
	{
		return UStageSubsystem::Get().ActiveStageRow.Episode == EStageEpisode::Onboarding;
	}

	UFUNCTION(BlueprintPure)
	bool HasCompletedStage(FName RowName = CURRENT_STAGE)
	{
		FLeaderboard Leaderboard = GetLeaderboard(RowName);
		if (Steam::IsAvailable())
		{
			FLeaderboardEntry LocalEntry;
			return Leaderboard.Find(ULeaderboardSubsystem::Get().GetLocalSteamID(), LocalEntry);
		}

		return Leaderboard.Contains(ULeaderboardSubsystem::Get().GetLocalUsername());
	}

	UFUNCTION(BlueprintPure)
	FStageRow GetPreviousCompletedStage(FName&out RowName)
	{
		TArray<FName> Names = StageTable.RowNames;
		for (int i = Names.Num() - 1; i >= 0; i--)
		{
			if (HasCompletedStage(Names[i]))
			{
				RowName = Names[i];

				FStageRow Row;
				Stage::FindRow(RowName, Row);
				return Row;
			}
		}

		RowName = NAME_None;
		return FStageRow();
	}

	/**
	 * @param RowName - Can be left as default construted to use the current stage.
	 */
	UFUNCTION(BlueprintPure)
	bool IsStageLastOfEpisode(FName OptionalRowName = CURRENT_STAGE)
	{
		auto Subsystem = UStageSubsystem::Get();

		FStageRow Row;
		Stage::FindRow(OptionalRowName, Row);

		FStageRow RowToCheck = Row.Level != nullptr ? Row : Subsystem.ActiveStageRow;

		return int(Subsystem.NextStageRow.Episode) > int(RowToCheck.Episode);
	}

	UFUNCTION(BlueprintPure)
	FStageRow FindStageRow(FName RowName)
	{
		if (RowName.IsEqual(n"CURRENT_STAGE") || RowName.IsNone())
			return UStageSubsystem::Get().ActiveStageRow;

		if (!StageTable.RowNames.Contains(RowName))
		{
			throw(f"Failed to find row '{RowName}'");
			return UProjectGlobals::DebugStageRow;
		}

		FStageRow Row;
		Stage::FindRow(RowName, Row);
		return Row;
	}

	// - LEADERBOARD -

	UFUNCTION(BlueprintPure, Meta = (AdvancedDisplay = "OptionalRowName"))
	FLeaderboard GetLeaderboard(FName OptionalRowName = CURRENT_STAGE)
	{
		return ULeaderboardSubsystem::Get().GetLeaderboard(OptionalRowName);
	}

	bool TryGetLoadedLeaderboard(FName RowName, FLeaderboard&out Leaderboard)
	{
		return ULeaderboardSubsystem::Get().GetLoadedLeaderboard(RowName, Leaderboard);
	}

	void GetLeaderboardAsync(FName OptionalRowName, FOnLeaderboardResult Callback)
	{
		ULeaderboardSubsystem::Get().GetLeaderboardAsync(OptionalRowName, Callback);
	}

	/** Uses the stable Steam ID for the user lookup. Persona names are display-only. */
	void GetCompletionTimeAsync(int64 SteamID, FName OptionalRowName, FOnLeaderboardTimeResult Callback)
	{
		ULeaderboardSubsystem::Get().GetCompletionTimeAsync(SteamID, OptionalRowName, Callback);
	}

	void GetPersonalBestTimeAsync(int64 SteamID, FName OptionalRowName, FOnLeaderboardTimeResult Callback)
	{
		GetCompletionTimeAsync(SteamID, OptionalRowName, Callback);
	}

	/** Uses the stable Steam ID for the user lookup. Persona names are display-only. */
	void IsPersonalBestTimeAsync(int64 SteamID, float ComparisonTime, FName OptionalRowName, FOnLeaderboardBoolResult Callback)
	{
		ULeaderboardSubsystem::Get().IsPersonalBestTimeAsync(SteamID, ComparisonTime, OptionalRowName, Callback);
	}

	UFUNCTION(Category = "Leaderboard")
	bool AddLeaderboardEntry(FLeaderboardEntry Entry, FName OptionalUser = NAME_None)
	{
		FName User = OptionalUser.IsNone() ? Entry.User : OptionalUser;
		FLeaderboardEntry LocalEntry = FLeaderboardEntry(User, Entry.Time, Entry.bIsValid);
		LocalEntry.RemixScore = Entry.RemixScore;
		return ULeaderboardSubsystem::Get().AddLocalLeaderboardEntry(LocalEntry);
	}

	bool ResolvePersistentID(int PersistentID, FName&out RowName)
	{
		for (auto Row : Rows)
		{
			if (Row.PersistentID == PersistentID)
			{
				int i = Rows.FindIndex(Row);
				RowName = StageTable.RowNames[i];
				return true;
			}
		}

		return false;
	}

	/** int-range (1..2..3..etc), 0 if the user has no entry */
	UFUNCTION(BlueprintPure)
	int GetLeaderboardPosition(FLeaderboard InLeaderboard, int64 SteamID)
	{
		FLeaderboardEntry UserEntry;
		if (!InLeaderboard.Find(SteamID, UserEntry))
			return 0;

		TMap<FName, FLeaderboardEntry> Entries = InLeaderboard.Get();

		TArray<FName> Keys;
		Entries.GetKeys(Keys);

		int Position = 1; // 1-X range
		for (FName Key : Keys)
		{
			FLeaderboardEntry Other;
			if (Entries.Find(Key, Other) && IsEntryBetter(Other, UserEntry))
				Position++;
		}

		return Position;
	}

	int Local_GetLeaderboardPosition(FLeaderboard InLeaderboard, FName User = NAME_None)
	{
		FName ResolvedUser = User.IsNone() ? ULeaderboardSubsystem::Get().GetLocalUsername() : User;
		FLeaderboardEntry UserEntry;
		if (!InLeaderboard.Find(ResolvedUser, UserEntry))
			return 0;

		TMap<FName, FLeaderboardEntry> Entries = InLeaderboard.Get();
		TArray<FName> Keys;
		Entries.GetKeys(Keys);

		int Position = 1;
		for (FName Key : Keys)
		{
			FLeaderboardEntry Other;
			if (Entries.Find(Key, Other) && IsEntryBetter(Other, UserEntry))
				Position++;
		}
		return Position;
	}

	bool IsEntryBetter(FLeaderboardEntry A, FLeaderboardEntry B)
	{
		int MedalA = int(Stage::GetMedalForTime(A.Time));
		int MedalB = int(Stage::GetMedalForTime(B.Time));

		if (MedalA != MedalB)
			return MedalA > MedalB; // higher enum value = better medal

		return A.Time < B.Time;
	}

	UFUNCTION(BlueprintPure)
	FLinearColor Local_GetMedalColourByUser(FName User = NAME_None)
	{
		EStageMedal Medal = Stage::GetMedalForTime(Local_GetCompletionTime(User));
		return GetMedalColour(Medal);
	}

	UFUNCTION(BlueprintPure)
	FLinearColor GetMedalColour(EStageMedal Medal)
	{
		switch (Medal)
		{
			case EStageMedal::None:
				return FLinearColor::Gray;

			case EStageMedal::Bronze:
				return FLinearColor::MakeFromHex(0xff977647);

			case EStageMedal::Silver:
				return FLinearColor::MakeFromHex(0xffd6d6d6);

			case EStageMedal::Gold:
				return FLinearColor::MakeFromHex(0xFFD4AF37);

			case EStageMedal::Platinum:
				return FLinearColor::MakeFromHex(0xff51ccd4);

			case EStageMedal::Developer:
				return FLinearColor(1.00, 0.10, 0.10);
		}
	}

	// - MEDAL UTILITY -

	UFUNCTION(BlueprintPure)
	bool HasBronzeMedal(FName User = NAME_None)
	{
		return Local_GetMedal(User) >= EStageMedal::Bronze;
	}

	UFUNCTION(BlueprintPure)
	bool HasSilverMedal(FName User = NAME_None)
	{
		return Local_GetMedal(User) >= EStageMedal::Silver;
	}

	UFUNCTION(BlueprintPure)
	bool HasGoldMedal(FName User = NAME_None)
	{
		return Local_GetMedal(User) >= EStageMedal::Gold;
	}

	UFUNCTION(BlueprintPure)
	bool HasPlatinumMedal(FName User = NAME_None)
	{
		return Local_GetMedal(User) >= EStageMedal::Platinum;
	}

	EStageMedal Local_GetMedal(FName User = NAME_None)
	{
		return GetMedalForTime(Local_GetCompletionTime(User));
	}

	UFUNCTION(BlueprintPure, Meta = (AdvancedDisplay = "OptionalRowName"))
	float GetTimeByMedal(EStageMedal Medal, FName OptionalRowName = CURRENT_STAGE)
	{
		return FindStageRow(OptionalRowName).MedalMap[Medal];
	}

	UFUNCTION(BlueprintPure, Meta = (AdvancedDisplay = "OptionalRowName"))
	EStageMedal GetMedalForTime(float InCompletionTime, FName OptionalRowName = CURRENT_STAGE)
	{
		FStageRow Row;

		UDataTable Table = Stage::StageTable;
		if (!Table.FindRow(OptionalRowName, Row))
		{
			Row = UStageSubsystem::Get().ActiveStageRow;
		}

		if (Row.Level.IsNull())
		{
			throw("StageRow contains an invalid map entry!");
			return EStageMedal::None;
		}

		ThrowIf(Row.MedalMap.IsEmpty() || Row.MedalMap.Num() != int(EStageMedal::Developer) + 1, "MedalMap has not been initialized, or is missing entries!");

		return ParseCompletionTime(Row, InCompletionTime);
	}

	EStageMedal ParseCompletionTime(FStageRow Row, float InCompletionTime)
	{
		if (InCompletionTime <= 0)
			return EStageMedal::None; // invalid time; no medal

		float BestThreshold = -1.0f;
		EStageMedal Result = EStageMedal::Bronze;
		bool bFound = false;

		for (auto& Pair : Row.MedalMap)
		{
			if (int(Pair.Key) < int(EStageMedal::Bronze))
				continue;

			// We want the smallest threshold that is still >= CompletionTime
			if (Pair.Value >= InCompletionTime)
			{
				if (!bFound || Pair.Value < BestThreshold)
				{
					BestThreshold = Pair.Value;
					Result = Pair.Key;
					bFound = true;
				}
			}
		}

		return Result;
	}

	// ~

	// - TIME UTILITY -

	UFUNCTION(BlueprintPure)
	float Local_GetPersonalBestTime(FName User = NAME_None)
	{
		return ULeaderboardSubsystem::Get().Local_GetCompletionTime(User.IsNone() ? ULeaderboardSubsystem::Get().GetLocalUsername() : User);
	}

	UFUNCTION(BlueprintPure)
	float GetWorldRecordTime() property
	{
		FLeaderboard Leaderboard = Stage::GetLeaderboard();
		if (Leaderboard.IsEmpty())
		{
			throw("Level has not been completed by anyone yet.");
			return -1.f;
		}

		float Fastest = BIG_NUMBER;

		for (auto Entry : Leaderboard.Get())
		{
			if (Entry.Value.Time < Fastest)
				Fastest = Entry.Value.Time;
		}

		return Fastest;
	}

	bool Local_IsPersonalBestTime(FName User, float ComparisonTime)
	{
		return ULeaderboardSubsystem::Get().Local_IsPersonalBestTime(User, ComparisonTime);
	}

	/** Checks a user's personal best using their stable Steam ID. The ID is not a mutable persona name. */
	bool IsPersonalBestTimeByUser(int64 SteamID, float ComparisonTime)
	{
		return ULeaderboardSubsystem::Get().IsPersonalBestTime(SteamID, ComparisonTime);
	}

	float Local_GetCompletionTime(FName User = NAME_None, FName OptionalRowName = CURRENT_STAGE)
	{
		return ULeaderboardSubsystem::Get().Local_GetCompletionTime(User.IsNone() ? ULeaderboardSubsystem::Get().GetLocalUsername() : User, OptionalRowName);
	}

	/** Gets a user's completion time using their stable Steam ID. The ID is not a mutable persona name. */
	float GetCompletionTimeByUser(int64 SteamID, FName OptionalRowName = CURRENT_STAGE)
	{
		return ULeaderboardSubsystem::Get().GetCompletionTime(SteamID, OptionalRowName);
	}

	// ~

	// - LEVEL STREAMING -

	UFUNCTION(Category = "Level Streaming")
	void OpenStageBySoftObjectPtr(TSoftObjectPtr<UWorld> StageToOpen)
	{
		UStageSubsystem::Get().OpenStage(StageToOpen);
	}

	UFUNCTION(Category = "Level Streaming")
	void OpenStage(UWorld StageToOpen)
	{
		UStageSubsystem::Get().OpenStage(StageToOpen);
	}

	UFUNCTION(Category = "Level Streaming", Meta = (AdvancedDisplay = "Options"))
	void OpenMap(UWorld MapToOpen, FString Options = "")
	{
		UStageSubsystem::Get().OpenMap(MapToOpen, Options);
	}

	UFUNCTION(Category = "Level Streaming", Meta = (AdvancedDisplay = "Options"))
	void ReloadMap(FString Options = "")
	{
		UStageSubsystem::Get().OpenMap(GetCurrentWorld(), Options);
	}

	UFUNCTION(Category = "Level Streaming")
	void OpenNextStage()
	{
		UStageSubsystem::Get().OpenNextStage();
	}

	UFUNCTION(Category = "Level Streaming")
	void TransitionToStage(TSoftObjectPtr<UWorld> StageToOpen, float InLoadingTime = 2.5f, bool bRewind = false)
	{
		UStageSubsystem::Get().TransitionToStage(StageToOpen, InLoadingTime, bRewind);
	}

	UFUNCTION(Category = "Level Streaming")
	void TransitionToNextStage()
	{
		UStageSubsystem::Get().TransitionToNextStage();
	}

	/**
	 * Transitions to a map that is not in the stage table. For stage transitions, @see TransitionToStage
	 * @param bRewind - Determines the label of the loading screen. True = "Rewinding..." | False = "Fast Forwarding..."
	 */
	UFUNCTION(Category = "Level Streaming", Meta = (AdvancedDisplay = "bRewind"))
	void TransitionToMap(TSoftObjectPtr<UWorld> Map, float LoadingTime = 2.5f, bool bRewind = true)
	{
		UStageSubsystem::Get().TransitionToMap(Map, LoadingTime, bRewind);
	}

	UFUNCTION(Category = "Level Streaming")
	void TransitionToMenu(float LoadingTime = 2.5f)
	{
		UStageSubsystem::Get().TransitionToMap(UProjectGlobals::MenuMap, LoadingTime, true);
	}

	UFUNCTION(Category = "Level Streaming")
	void TransitionToLevelSelect(float LoadingTime = 2.5f)
	{
		UStageSubsystem::Get().TransitionToMap(UProjectGlobals::LevelSelectMap, LoadingTime, true);
	}

	// ~

	// - MISC -

	UFUNCTION(BlueprintPure)
	FStageCompleteInfo GetCurrentCompletionInfo() property
	{
		return UStageSubsystem::Get().LatestCompleteInfo;
	}

	UFUNCTION(BlueprintPure)
	bool IsLevelInStageTable(TSoftObjectPtr<UWorld> Map)
	{
		int Index = -1;

		for (int RowIndex = 0; RowIndex < Rows.Num(); RowIndex++)
		{
			FStageRow Row = Rows[RowIndex];
			if (Row.Level.AssetName == Map.AssetName)
			{
				Index = RowIndex;
				break;
			}
		}

		return Index > -1;
	}
}

enum EStageEpisode
{
	Onboarding,
	Episode1,
	Episode2,
	Episode3,
	Episode4,

	UMETA(DisplayName = "Episode ??", Tooltip = "Exclusively used for debug levels.")
	EpisodeDebug
}

enum EStageRestartReason
{
	CassetteCollected,
	ManualReset,
	Death,
	Unknown
}

mixin bool
IsDebugStage(FStageRow Stage)
{
	return Stage.Level == UProjectGlobals::DebugStageRow.Level;
}

mixin URemixSet GetRemixSet(FStageRow Row) property
{
	if (Row.RemixSet != nullptr)
		return Row.RemixSet;

	auto Subsystem = UStageSubsystem::Get();

	if (Subsystem.InstancedSet == nullptr)
	{
		Subsystem.InstancedSet = NewObject(Subsystem, URemixSet);
		return Subsystem.InstancedSet;
	}
	else
	{
		return Subsystem.InstancedSet;
	}
}

struct FStageRow
{
	access Remix = private, UMixtapeSubsystem, GetRemixSet, GetNumModifiers, UModifiersWidget, UDataTableAssetMenuExtension;

	UPROPERTY(Category = "Stage")
	EStageEpisode Episode = EStageEpisode::EpisodeDebug;

	UPROPERTY(Category = "Stage")
	FText StageName = FText::FromString("Stage Name");

	UPROPERTY(Category = "Stage")
	TSoftObjectPtr<UWorld> Level;

	UPROPERTY(Category = "Stage", Meta = (ReadOnlyKeys))
	TMap<EGameplayAction, bool> EnabledAbilities;

	UPROPERTY(Category = "Remix", Meta = (ReadOnlyKeys, EditCondition = "DefaultModifiers.Num() == 0"))
	access:Remix
	TMap<EModifierType, int> NumModifiers;

	UPROPERTY(Category = "Remix", DisplayName = "Remix Set (Modifiers)")
	access:Remix
	URemixSet RemixSet;

	UPROPERTY(Category = "Audio")
	USoundWave Track;

	/** The minimum time to achieve each medal. */
	UPROPERTY(Category = "Leaderboard", Meta = (ReadOnlyKeys, Units = "s"))
	TMap<EStageMedal, float> MedalMap;

	UPROPERTY(Category = "Persistent ID", VisibleAnywhere)
	int PersistentID = -1;

	/** View from this stage's PlayerStart, shown by level exits that lead here. Written by "Bake Stage Cubemaps". */
	UPROPERTY(Category = "Level Exit")
	TSoftObjectPtr<UTextureCube> Cubemap;

	UPROPERTY(Category = "Development")
	bool bIsDevelopmentOnlyStage = false;

	FStageRow()
	{
		NumModifiers.Add(EModifierType::Positive, 2);
		NumModifiers.Add(EModifierType::Negative, 2);

		MedalMap.Add(EStageMedal::Bronze, 60.f);
		MedalMap.Add(EStageMedal::Silver, 40.f);
		MedalMap.Add(EStageMedal::Gold, 30.f);
		MedalMap.Add(EStageMedal::Platinum, 20.f);
		MedalMap.Add(EStageMedal::Developer, 10.f);

		EnabledAbilities.Add(EGameplayAction::Dash, true);
		EnabledAbilities.Add(EGameplayAction::Grapple, true);
		EnabledAbilities.Add(EGameplayAction::Wallrun, true);
		EnabledAbilities.Add(EGameplayAction::DoubleJump, true);
	}
}

mixin EStageMedal
GetMedal(FPreviousCompleteInfo Info)
{
	return Stage::GetMedalForTime(Info.CompletionTime);
}

struct FPreviousCompleteInfo
{
	UPROPERTY(BlueprintReadOnly)
	float CompletionTime;

	UPROPERTY(BlueprintReadOnly)
	int Attempts;

	UPROPERTY(Category = "Remix")
	float RemixScore;

	UPROPERTY(Category = "Remix")
	TArray<FRemixModifier> Modifiers;
}

UFUNCTION(BlueprintPure, DisplayName = "Get Medal")
mixin EStageMedal GetMedalFromInfo(FStageCompleteInfo Info)
{
	return Stage::GetMedalForTime(Info.CompletionTime);
}

UFUNCTION(BlueprintPure)
mixin float GetPreviousBest(FStageCompleteInfo Info)
{
	return Info.PreviousClear.CompletionTime;
}

struct FStageCompleteInfo
{
	UPROPERTY(BlueprintReadOnly)
	float CompletionTime;

	UPROPERTY(BlueprintReadOnly)
	bool bIsPersonalBest;

	UPROPERTY(BlueprintReadOnly)
	int Attempts;

	UPROPERTY(BlueprintReadOnly)
	bool bIsValid;

	UPROPERTY(Category = "Remix")
	float RemixScore;

	UPROPERTY(Category = "Remix")
	TArray<FRemixModifier> Modifiers;

	UPROPERTY(BlueprintReadOnly)
	FPreviousCompleteInfo PreviousClear;
}

enum ETransitionState
{
	/** Invoked before the transition map is opened.
	 * That means the current level is still open. */
	PreTransition,
	/** We're currently in the loading screen/transition level. */
	Transitioning,
	/** New level has been opened. */
	PostTransition,
}

event void FOnStageBegin(bool bIsInitialAttempt, int AttemptNum);
event void FOnStageCompleted(FStageCompleteInfo Info);
event void FOnStageRestart(EStageRestartReason Reason);
event void FOnStageTransition(ETransitionState TransitionState, TSoftObjectPtr<UWorld> NewMap);
event void FOnStageCheated(FString Command);
class UStageSubsystem : UScriptGameInstanceSubsystem
{
	access ReadOnly = private, *(readonly);

	/* Returns the amount of attempts on the current stage. */
	UPROPERTY(Category = "Stage")
	int Attempts;

	UPROPERTY(Category = "Events")
	FOnStageBegin OnStageBegin;

	UPROPERTY(Category = "Events")
	FOnStageCompleted OnStageCompleted;

	UPROPERTY(Category = "Events")
	FOnStageRestart OnStageRestart;

	/** Broadcasts true while transitioning, and false on completion. */
	UPROPERTY(Category = "Events")
	FOnStageTransition OnTransitioning;

	UPROPERTY(Category = "Events")
	FOnStageCheated OnStageCheated;

	UPROPERTY(BlueprintHidden, NotEditable)
	UStageRules Rules;

	UPROPERTY(BlueprintHidden, NotEditable)
	URemixSet InstancedSet;

	TSubclassOf<UStageRules> GetRulesClass() property
	{
		if (GM::IsMixtape)
			return UMixtapeStageRules;
		else
			return UStoryStageRules;
	}

	UFUNCTION(BlueprintPure)
	FName GetStageID() property
	{
		TArray<FName> Names;
		StageTable.GetRowNames(Names);

		int Index = GetStageRowIndex();
		if (Index != -1)
			return Names[Index];

		ARunWorldSettings Settings = Cast<ARunWorldSettings>(World.WorldSettings);
		return Settings.StageID;
	}

	access:ReadOnly
	FName PreviousLevelName = NAME_None;
	private UDataTable GetStageTable() property
	{
		return Stage::StageTable;
	}

	bool bInitialLevel = true;
	int PreviousIndex = -1;

	int GetStageRowIndex()
	{
		FName LevelName = PreviousLevelName.IsNone() ? World.Name : PreviousLevelName;

		int Index = -1;

		for (int RowIndex = 0; RowIndex < Stage::Rows.Num(); RowIndex++)
		{
			FStageRow Row = Stage::Rows[RowIndex];
			if (Row.Level.AssetName == LevelName)
			{
				PreviousIndex = RowIndex;
				Index = RowIndex;
				break;
			}
		}

		bInitialLevel = false;
		return Index;
	}

	int GetStageRowIndex(FName InPreviousLevelName)
	{
		FName LevelName = InPreviousLevelName.IsNone() ? World.Name : InPreviousLevelName;

		int Index = -1;
		int NextIndex = PreviousIndex + 1;

		for (int RowIndex = 0; RowIndex < Stage::Rows.Num(); RowIndex++)
		{
			FStageRow Row = Stage::Rows[RowIndex];
			if (Row.Level.AssetName == LevelName)
			{
				PreviousIndex = RowIndex;
				Index = RowIndex;
				break;
			}
		}

		if (Index > NextIndex && !bInitialLevel) // skipped one or more levels
		{
			Assertion::Assert(this, f"{(Index - NextIndex)} levels were skipped. Ensure there are no empty entries in {StageTable.Name}.");
		}

		bInitialLevel = false;
		return Index;
	}

	int GetStageRowPersistentID()
	{
		FName LevelName = PreviousLevelName.IsNone() ? World.Name : PreviousLevelName;

		int Index = -1;

		for (int RowIndex = 0; RowIndex < Stage::Rows.Num(); RowIndex++)
		{
			FStageRow Row = Stage::Rows[RowIndex];
			if (Row.Level.AssetName == LevelName)
			{
				Index = Row.PersistentID;
				break;
			}
		}

		return Index;
	}

	UFUNCTION(BlueprintPure)
	FStageRow GetActiveStageRow() property
	{
		TArray<FName> Names;
		StageTable.GetRowNames(Names);

		int Index = GetStageRowIndex();
		if (!Names.IsValidIndex(Index))
		{
#if EDITOR
			Assertion::AssertSuppressibleWarning("Stage not found in StageTable", f"Failed to parse the current level as any FStageRow in {StageTable.Name}.", bDefaultToSuppressInTheFuture = true, bPersistChoice = false);
#endif
			return UProjectGlobals::DebugStageRow;
		}

		FStageRow Row;
		Stage::FindRow(Names[Index], Row);
		return Row;
	}

	UFUNCTION(BlueprintPure)
	FStageRow GetNextStageRow() property
	{
		TArray<FName> Names;
		StageTable.GetRowNames(Names);
		int Index = GetStageRowIndex();
		check(!Names.IsEmpty(), f"No entries found in {StageTable.Name}!");

		if (!Names.IsValidIndex(Index))
		{
#if EDITOR
			Assertion::AssertSuppressibleWarning("Stage not found in StageTable", f"Failed to parse the current level as any FStageRow in {StageTable.Name}.", bDefaultToSuppressInTheFuture = true, bPersistChoice = false);
#endif
			return UProjectGlobals::DebugStageRow;
		}

		int NextIndex = Index + 1;
		if (!Names.IsValidIndex(NextIndex))
		{
			PrintWarning("Final level selected. Reloading current.", 5.f);
			return ActiveStageRow;
		}

		FName NextRowName = Names[NextIndex];

		FStageRow NextRow;
		bool bFound = Stage::FindRow(NextRowName, NextRow);
		if (!bFound)
		{
			PrintWarning("Final level selected. Reloading current.", 5.f);
			return ActiveStageRow;
		}

		if (NextRow.bIsDevelopmentOnlyStage)
		{
			PrintWarning("Next level is development-only. Reloading current.", 5.f);
			return ActiveStageRow;
		}

		return NextRow;
	}

	bool GetNextStageRowChecked(FStageRow&out NextRow) const // wtf does this function do, and why did i add it -lum
	{
		if (NextRow.IsDebugStage())
		{
			throw("Check failed. Couldn't find the next stage.\nReturning the debug stage.");
			return false;
		}

		return true;
	}

	// - Level Select

	bool bStageComplete;

	UFUNCTION(Category = "Stage Selection", Meta = (AdvancedDisplay = "bReloadLevel"))
	void RestartStage(EStageRestartReason Reason, bool bReloadLevel = false)
	{
		if (bStageComplete)
			return; // already transitioning stage, can't reset.

		if (Reason == EStageRestartReason::Death)
		{
			if (IsValid(Game::Player))
				Game::Player.Freeze();

			HUD::AddDeathScreen();
			return;
		}

		HUD::AddLoadingScreen(0.1f);

		CommitRestartStage(Reason, bReloadLevel);
	}

	void CommitRestartStage(EStageRestartReason Reason, bool bReloadLevel)
	{
		Attempts++;

		if (bReloadLevel)
		{
			TSoftObjectPtr<UWorld> LevelToLoad = ActiveStageRow.Level;

			Gameplay::OpenLevelBySoftObjectPtr(LevelToLoad, true);
			return;
		}

		System::FlushPersistentDebugLines();

		Game::Player.CharacterMovement.StopMovementImmediately();
		Game::Player.Teleport(GM::StagePlayerStart.ActorLocation, GM::StagePlayerStart.ActorRotation);
		Game::Player.Controller.SetControlRotation(GM::StagePlayerStart.ActorRotation);

		OnStageRestart.Broadcast(Reason);
	}

	access LevelStreaming = private, OpenStage, OpenStageBySoftObjectPtr, OpenNextStage, TransitionToMenu, OpenMap, TransitionToMap, TransitionToStage, TransitionToLevelSelect, TransitionToNextStage, DeferTransitionToNextStage, ReloadMap;
	access ControllerOnly = private, ARunController;

	UFUNCTION(NotBlueprintCallable)
	access:ControllerOnly
	void OpenTransitionMapToNextStage()
	{
		TransitionToNextStage();
	}

	access:LevelStreaming
	void TransitionToStage(TSoftObjectPtr<UWorld> StageToTransitionTo, float InLoadingTime = 2.5f, bool bRewind = false)
	{
		// If we're transitioning from a map that isn't a stage, to a stage, we want to use the regular loading screen
		//  and not the transition screen (since that's only for use *between* stages)
		if (!GM::IsGameMode(EGameModeType::Stage))
		{
			TransitionToMap(StageToTransitionTo, InLoadingTime, bRewind);
			return;
		}

		// Check if the passed in map is in the stage table. Only stages should be transitioned to from here.
		// To transition between any two maps, use Stage::TransitionToMap()
		if (!ensureAlways((Stage::IsLevelInStageTable(StageToTransitionTo)), "TransitionToStage should only be used on stages."))
		{
			TransitionToMap(StageToTransitionTo); // default parameters
			return;
		}

		bStageComplete = true;

		OnTransitioning.Broadcast(ETransitionState::PreTransition, StageToTransitionTo);

		PreviousLevelName = World.Name;

		FString OptionsStr;
		System::BreakSoftObjectPath(StageToTransitionTo.ToSoftObjectPath(), OptionsStr);
		OptionsStr.Append(f"?Stage?X?Y?{PreviousLevelName}");

		Gameplay::OpenLevelBySoftObjectPtr(UProjectGlobals::TransitionMap, true, OptionsStr);
		OnTransitioning.Broadcast(ETransitionState::Transitioning, StageToTransitionTo);

		TransitionCleanup();
	}

	access:LevelStreaming
	void TransitionToNextStage()
	{
		TransitionToStage(NextLevel);
	}

	access:LevelStreaming
	void TransitionToMap(TSoftObjectPtr<UWorld> Map, float InLoadingTime = 2.5f, bool bRewind = true)
	{
		bStageComplete = true;

		OnTransitioning.Broadcast(ETransitionState::PreTransition, Map);

		FString OptionsStr;
		System::BreakSoftObjectPath(Map.ToCleanSoftObjectPath(), OptionsStr); // clean path cause World object references have their PIE prefix

		int iRewind = bRewind ? 1 : 0;
		OptionsStr.Append(f"?Map?{InLoadingTime}?{iRewind}");

		Gameplay::OpenLevelBySoftObjectPtr(UProjectGlobals::TransitionMap, true, OptionsStr);
		OnTransitioning.Broadcast(ETransitionState::Transitioning, Map);
	}

	access:LevelStreaming
	void OpenMap(TSoftObjectPtr<UWorld> MapToOpen, FString Options = "")
	{
		TransitionCleanup();

		Gameplay::OpenLevelBySoftObjectPtr(MapToOpen, true, Options);
		DeferOnTransitioningCallback();
	}

	void OpenStage(TSoftObjectPtr<UWorld> StageToOpen)
	{
		TransitionCleanup(); // run the cleanup in case the level is opened directly, rather than transitioned from.

		OpenMap(StageToOpen);
	}

	access:LevelStreaming
	void OpenStage(UWorld StageToOpen)
	{
		TransitionCleanup(); // run the cleanup in case the level is opened directly, rather than transitioned from.

		OpenMap(StageToOpen);
	}

	void DeferOnTransitioningCallback()
	{
		System::SetTimerForNextTick(this, "BroadcastPostTransition");
	}

	UFUNCTION(NotBlueprintCallable)
	private void BroadcastPostTransition()
	{
		OnTransitioning.Broadcast(ETransitionState::PostTransition, World);

		bStageComplete = false;
	}

	access:LevelStreaming
	void OpenNextStage()
	{
		OpenStage(NextLevel);
	}

	private void TransitionCleanup()
	{
		PreviousLevelName = NAME_None;

		Gameplay::SetGlobalTimeDilation(1);

		Attempts = 0;
	}

	// - Save/Load

	private FString CleanLevelName(FString LevelName)
	{
		return LevelName.Replace("Lv_", "").Replace("L_", "");
	}

	FString GetSaveSlotString() property
	{
		return CleanLevelName(World.Name.ToString());
	}

	private FString GetSaveSlotString(FName LevelName)
	{
		return CleanLevelName(LevelName.ToString());
	}

	UStageSaveGame SaveStageData(FStageSaveData SaveData)
	{
		UStageSaveGame SaveGame = Gameplay::CreateSaveGameObject(UStageSaveGame);
		SaveGame.SaveData = SaveData;
		Gameplay::SaveGameToSlot(SaveGame, SaveSlotString, 0);

		return SaveGame;
	}

	bool PrintFlag;

	bool LoadStageDataFromSlot(FString SaveSlotStr, UStageSaveGame&out SaveGame)
	{
		if (!Gameplay::DoesSaveGameExist(SaveSlotStr, 0) && !PrintFlag)
		{
			PrintWarning("No saved StageData found!", 3.f);
			PrintFlag = true;
			return false;
		}
		else if (!PrintFlag)
		{
			Print("SaveGame loaded.", 1.f, FLinearColor::FrankGreen);
			PrintFlag = true;
		}

		USaveGame _SaveGame = Gameplay::LoadGameFromSlot(SaveSlotStr, 0);
		if (!IsValid(_SaveGame))
			return false;

		SaveGame = Cast<UStageSaveGame>(_SaveGame);
		return true;
	}

	bool LoadStageData(UStageSaveGame&out SaveGame)
	{
		return LoadStageDataFromSlot(SaveSlotString, SaveGame);
	}

	bool LoadStageDataByRow(FStageRow Row, UStageSaveGame&out SaveGame)
	{
		return LoadStageDataFromSlot(CleanLevelName(Row.Level.AssetName), SaveGame);
	}

	UStageSaveGame AppendTrail(TMap<TSoftObjectPtr<UWorld>, FGhostTrail> NewTrails)
	{
		UStageSaveGame LoadedSave;
		if (!LoadStageData(LoadedSave))
		{
			LoadedSave = SaveStageData(FStageSaveData());
		}

		FStageSaveData AdditionalData = LoadedSave.SaveData;
		AdditionalData.Trails = NewTrails;

		UStageSaveGame Result = SaveStageData(AdditionalData);

		return Result;
	}

	// - Stage

	UFUNCTION(Category = "Stage")
	void BeginStage()
	{
#if EDITOR
		if (Gameplay::GetActorOfClass(AStageGoal) == nullptr)
			FMessageDialog::Open(EAppMsgCategory::Error, EAppMsgType::Ok, FText::FromString("Level does not have an exit (AStageGoal).\nPlease place one somewhere in the level."), FText::FromString("No Exits Found."));
#elif !RELEASE
		check(Gameplay::GetActorOfClass(AStageGoal) != nullptr, f"Couldn't find an exit in {World.Name}!\nMake sure there's a StageGoal actor placed somewhere in the level.");
#endif

#if EDITOR
		// listen for debug stuff
		Cheats::CheatManager.OnDebugCommandExecuted.AddUFunction(this, n"CheatExecuted");
#endif

		bCheatExecuted = false;

		Gameplay::SetGamePaused(false);

		bool bIsInitialAttempt = Attempts == 0;
		OnStageBegin.Broadcast(bIsInitialAttempt, Attempts);
	}

	bool bCheatExecuted;

	UFUNCTION(NotBlueprintCallable)
	private void CheatExecuted(FString Command)
	{
		if (!bCheatExecuted)
			PrintWarning("Cheat detected! Current time has been invalidated and will not be recorded.");

		bCheatExecuted = true;

		OnStageCheated.Broadcast(Command);
	}

	bool IsCurrentAttemptValid()
	{
		return !bCheatExecuted;
	}

	FStageCompleteInfo LatestCompleteInfo;

	UFUNCTION(Category = "Stage")
	void EndStage()
	{
		bStageComplete = true; // blocks other misc. calls while we're handling the stage ending

		Rules = NewObject(this, RulesClass, bTransient = true);
		ULeaderboardSubsystem Subsystem = ULeaderboardSubsystem::Get();

		float CompletionTime = Math::RoundTo(UStageTimerSubsystem::Get().CurrentTime, 3.f);
		float PreviousBest = Steam::IsAvailable() ? Stage::GetCompletionTimeByUser(Subsystem.GetLocalSteamID()) : Stage::Local_GetCompletionTime(Subsystem.GetLocalUsername());
		bool bIsPersonalBest = Steam::IsAvailable() ? Stage::IsPersonalBestTimeByUser(Subsystem.GetLocalSteamID(), CompletionTime) : Stage::Local_IsPersonalBestTime(Subsystem.GetLocalUsername(), CompletionTime);
		bool bIsValid = true;

		bIsValid = CompletionTime > 0 && !bCheatExecuted;

		FPreviousCompleteInfo Previous;
		Previous.CompletionTime = PreviousBest;
		Previous.Attempts = Math::Max(Attempts - 1, 0);
		Previous.RemixScore = Remix::GetRemixScore(PreviousBest);
		Previous.Modifiers = Remix::PreviousModifiers;

		LatestCompleteInfo.Attempts = Attempts;
		LatestCompleteInfo.CompletionTime = CompletionTime;
		LatestCompleteInfo.bIsPersonalBest = bIsPersonalBest;
		LatestCompleteInfo.bIsValid = bIsValid;
		LatestCompleteInfo.RemixScore = Remix::GetRemixScore(CompletionTime);
		LatestCompleteInfo.Modifiers = Remix::ActiveModifiers;
		LatestCompleteInfo.PreviousClear = Previous;

		if (Rules.ShouldRecordGhost())
		{
			UGhostPlaybackSubsystem::Get().SaveGhostTrail(LatestCompleteInfo);
		}

		if (Rules.ShouldSubmitLeaderboard())
		{
			Subsystem.SubmitCompletion(CompletionTime, LatestCompleteInfo.RemixScore, Remix::ActiveModifiers, bIsValid);
		}

		OnStageCompleted.Broadcast(LatestCompleteInfo);

		Rules.OnStageComplete(LatestCompleteInfo);
	}

	// - Misc Helpers

	private TSoftObjectPtr<UWorld> GetNextLevel() property
	{
		FStageRow NextRow;
		if (!GetNextStageRowChecked(NextRow))
			return NextRow.Level;

		return NextStageRow.Level;
	}
}