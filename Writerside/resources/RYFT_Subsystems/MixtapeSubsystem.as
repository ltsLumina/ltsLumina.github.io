namespace Mixtape
{
	UFUNCTION(BlueprintPure)
	bool GetIsMixtapeActive() property
	{
		if (GetCurrentWorld() == nullptr || UMixtapeSubsystem::Get() == nullptr)
			return false;

		return UMixtapeSubsystem::Get().ActiveMixtape != nullptr;
	}

	UFUNCTION(BlueprintPure)
	bool GetIsCustomizedMixtape() property
	{
		return UMixtapeSubsystem::Get().CurrentParams.Seed != 0;
	}
}

enum EMixtapeEndReason
{
	Completed,
	Cancelled
}

// Mixtape data tables use the stage row as their primary payload. The nested
// stage PersistentID identifies the corresponding row in the master stage table.
struct FMixtapeRow
{
	UPROPERTY(Meta=(ShowOnlyInnerProperties))
	FStageRow Stage;

	FMixtapeRow(FStageRow InStage)
	{
		Stage = InStage;
	}
}

class UMixtapeSubsystem : UScriptGameInstanceSubsystem
{
	access ReadOnly = private, *(readonly);

	UPROPERTY()
	access:ReadOnly
	UDataTable ActiveMixtape;

	UPROPERTY()
	TArray<float> Scores;

	int StageIndex = -1;

	UFUNCTION(BlueprintPure)
	float GetAggregateScore() property
	{
		float Sum = 0;
		for (auto Score : Scores)
			Sum += Score;

		return Sum;
	}

	TArray<FRemixModifier> GetAvailableModifiers() property
	{
		if (Mixtape::IsCustomizedMixtape)
			return CurrentParams.AvailableModifiers;
		else
		{
			auto RowName = ActiveMixtape.RowNames[StageIndex];
			FStageRow Row;
			ActiveMixtape.FindRow(RowName, Row);
			return Row.GetRemixSet().AvailableModifiers;
		}
	}

	FRemixModifier DeathModifier;

	UFUNCTION(NotBlueprintCallable)
	private void StageBegin(bool bIsInitialAttempt, int AttemptNum)
	{
		StageIndex = UStageSubsystem::Get().GetStageRowIndex();
	}

	UFUNCTION(NotBlueprintCallable)
	private void StageRestarted(EStageRestartReason Reason)
	{
		UModalTipWidget Modal;
		Tips::RequestTip(n"Mixtape.Death", Modal);

		if (Reason == EStageRestartReason::Death || (Reason == EStageRestartReason::ManualReset && Game::Player.CharacterMovement.IsFalling()))
		{
			bool bHasDeathModifier = false;

			TArray<FRemixModifier> NegativeCandidates;
			for (auto Mod : AvailableModifiers)
			{
				if (Mod.Type == EModifierType::Negative)
					NegativeCandidates.Add(Mod);
			}

			if (NegativeCandidates.Num() > 0)
			{
				DeathModifier = NegativeCandidates[Math::RandRange(0, NegativeCandidates.Num() - 1)];
				bHasDeathModifier = true;
			}

			// if we couldn't find a negative modifier to add, and we're in a custom mixtape, then the player probably didnt select any, and we can early return.
			if (!bHasDeathModifier)
				return;

			// nothing usable in the supplied list (or not a randomized mixtape)
			else if (!bHasDeathModifier)
			{
				/* TArray<FRemixModifier> Random = Remix::GetRandomRemix(1, EModifierType::Negative);
				if (Random.Num() > 0)
				{
					DeathModifier = Random[0];
					bHasDeathModifier = true;
				} */
			}

			if (bHasDeathModifier)
			{
				bool bSuccess = URemixSubsystem::Get().AddModifier(DeathModifier);
				if (bSuccess) // application can fail
					Modal::LoadModal(n"Mixtape.Death", FOnSoftClassLoaded(this, n"MixtapeDeath"));
			}
		}
	}

	UFUNCTION(NotBlueprintCallable)
	private void MixtapeDeath(UClass LoadedClass)
	{
		auto Modal = Cast<UMixtapeDeathModalWidget>(WidgetBlueprint::CreateWidget(LoadedClass, Game::PlayerController));
		Modal.NewModifier = DeathModifier;
		Modal.AddToViewport(3);
	}

	UFUNCTION(NotBlueprintCallable)
	private void StageCompleted(FStageCompleteInfo Info)
	{
		StageIndex = UStageSubsystem::Get().GetStageRowIndex();

		if (Scores.IsValidIndex(StageIndex))
			Scores[StageIndex] = Info.RemixScore;
		else
			Scores.Add(Info.RemixScore);

		if (StageIndex >= Stage::StageTable.RowNames.Num() - 1)
			EndMixtape(EMixtapeEndReason::Completed);
	}

	UFUNCTION(NotBlueprintCallable)
	private void OnTransition(ETransitionState TransitionState, TSoftObjectPtr<UWorld> NewMap)
	{
		if (TransitionState != ETransitionState::PreTransition)
			return;

		if (!IsMapInMixtape(NewMap))
		{
			Invalidate();
		}
	}

	bool IsMapInMixtape(TSoftObjectPtr<UWorld> OtherMap)
	{
		if (!Mixtape::IsMixtapeActive)
			return false;

		for (auto Map : Stage::Rows)
		{
			if (Map.Level.AssetName == OtherMap.AssetName)
				return true;
		}

		return false;
	}

	FMakeMixtapeParams CurrentParams;

	UFUNCTION(Category = "Mixtape")
	void BeginMixtape(UDataTable MixtapeTable, bool bCustom, FMakeMixtapeParams Params = FMakeMixtapeParams())
	{
		auto Subsystem = UStageSubsystem::Get();
		Subsystem.OnStageBegin.AddUFunction(this, n"StageBegin");
		Subsystem.OnStageRestart.AddUFunction(this, n"StageRestarted");
		Subsystem.OnStageCompleted.AddUFunction(this, n"StageCompleted");
		Subsystem.OnTransitioning.AddUFunction(this, n"OnTransition");

		if (bCustom || Mixtape::IsMixtapeActive) // IsMixtapeActive checks if we're restarting the current mixtape
		{
			CurrentParams = Params;				 // stored for replay
			UDataTable CustomizedTable = MixtapeTable;

			if (!Mixtape::IsMixtapeActive)		 // we can skip all the init if we're restarting an existing mixtape
			{
				CustomizedTable.EmptyTable();

				FRandomStream Stream = FRandomStream(Params.Seed);

				check(Params.NumStages > 0, "Mixtape has 0 stages selected. Check the ComboSwitcherDigits for an invalid digit.");
				for (int i = 0; i < Params.NumStages; i++)
				{
					UDataTable DefaultTable = UProjectGlobals::StageTable; // the master table, not the dynamic one from Stage::StageTable
					TArray<FStageRow> DefaultStages;
					DefaultTable.GetAllRows(DefaultStages);

					TArray<FStageRow> CandidateStages;
					for (FStageRow FirstRow : DefaultStages)
					{
						if (FirstRow.bIsDevelopmentOnlyStage)
							continue;

						const bool bAnyEpisode = Params.Episode == EStageEpisode::EpisodeDebug; // random: include all stages
						if (!bAnyEpisode && FirstRow.Episode != Params.Episode)
							continue;

						CandidateStages.Add(FirstRow);
					}

					check(!CandidateStages.IsEmpty(), "No candidate stages found! Check your mixtape creation params.");

					int j = Stream.RandRange(0, CandidateStages.Num() - 1);

					FStageRow CustomRow;
					CustomRow.PersistentID = CandidateStages[j].PersistentID;
					CustomRow.Level = CandidateStages[j].Level;
					CustomRow.Episode = EStageEpisode(Stream.RandRange(0, int(EStageEpisode::EpisodeDebug) - 1));
					CustomRow.MedalMap = CandidateStages[j].MedalMap;
					CustomRow.StageName = CandidateStages[j].StageName;
					CustomRow.Track = CandidateStages[j].Track;

					CustomRow.Cubemap = CandidateStages[j].Cubemap;

					CustomRow.RemixSet = NewObject(this, URemixSet, bTransient = true);
					CustomRow.NumModifiers.Add(EModifierType::Positive, Remix::GetNumModifiersByType(CustomRow.RemixSet, EModifierType::Positive));
					CustomRow.NumModifiers.Add(EModifierType::Negative, Remix::GetNumModifiersByType(CustomRow.RemixSet, EModifierType::Negative));

					UDataTable ModifierTable = UProjectGlobals::ModifiersTable;
					TArray<FRemixModifier> AllModifiers = Params.AvailableModifiers;

					int k = 0;
					int Attempts = 0;
					int NumModifiers = Params.NumRemixesPerStage;
					TArray<FRemixModifier> DefaultModifiers;
					const int MaxAttempts = NumModifiers * 20; // guard against an endless loop

					if (!AllModifiers.IsEmpty())
					{
						while (k < NumModifiers && Attempts < MaxAttempts)
						{
							Attempts++;

							int l = Stream.RandRange(0, AllModifiers.Num() - 1);
							FRemixModifier Mod = AllModifiers[l];

							// Skip adding a duplicate modifier if it doesn't support stacking
							if (!Mod.bStackable && DefaultModifiers.Contains(Mod))
								continue;

							DefaultModifiers.Add(Mod);

							k++;
						}
					}

					CustomRow.RemixSet.MakeRemixSet(ModifierTable, DefaultModifiers, AllModifiers);

					FName RowName = DefaultTable.RowNames[i];
					CustomizedTable.AddRow(RowName, FMixtapeRow(CustomRow));
				}
			}

			ActiveMixtape = CustomizedTable;

			Stage::TransitionToMap(Stage::Rows[0].Level);
			return;
		}

		ActiveMixtape = MixtapeTable;

		auto RowName = MixtapeTable.RowNames[0];
		FStageRow FirstRow;
		Stage::FindRow(RowName, FirstRow);
		Stage::TransitionToStage(FirstRow.Level);
	}

	UFUNCTION(Category = "Mixtape")
	void EndMixtape(EMixtapeEndReason Reason)
	{
		Modal::LoadModal(n"Mixtape.End", FOnSoftClassLoaded(this, n"MixtapeEnd"));
	}

	UFUNCTION(NotBlueprintCallable)
	private void MixtapeEnd(UClass LoadedClass)
	{
		auto Modal = Modal::CreateModalFromLoadedClass(LoadedClass);
		Modal.OnModalSelection.AddUFunction(this, n"OnSelection");
	}

	UDataTable PreviousMixtape;

	UFUNCTION(NotBlueprintCallable)
	private void OnSelection(bool bConfirmed)
	{
		if (bConfirmed)
		{
			Stage::TransitionToMenu();
			Invalidate();
		}
		else
		{
			PreviousMixtape = ActiveMixtape; // store a copy before it gets invalidated
			BeginMixtape(PreviousMixtape, false, CurrentParams);
		}
	}

	private void Invalidate()
	{
		auto Subsystem = UStageSubsystem::Get();
		Subsystem.OnStageBegin.UnbindObject(this);
		Subsystem.OnStageRestart.UnbindObject(this);
		Subsystem.OnStageCompleted.UnbindObject(this);
		Subsystem.OnTransitioning.UnbindObject(this);

#if EDITOR
		if (IsValid(ActiveMixtape))
			ActiveMixtape.EmptyTable();
#endif

		ActiveMixtape = nullptr;
		Scores.Empty();
	}
}