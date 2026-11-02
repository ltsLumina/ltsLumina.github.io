/**
 * Attach this to the player controller.
 */
UCLASS(NotBlueprintable)
class UScreenOverlayComponent : UActorComponent
{
	default bReplicates = true;

	AScriptPondController PC;
	FTimerHandle GetHUDHandle;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		PC = Cast<AScriptPondController>(GetOwner());
		ThrowIf(PC == nullptr, "Component must be attached to the player controller!");

		HUD = Pond::GetPondHUD();
	}

	APondHUD HUD;

	UPondWidgetBase JoiningAlliesWidget;

	bool Validate()
	{
		if (!IsValid(PC))
		{
			PC = Cast<AScriptPondController>(GetOwner());
		}

		return IsValid(PC) && PC.IsLocalController();
	}

	UFUNCTION(Category = "HUD", Client)
	void JoiningAllies()
	{
		if (!Validate())
			return;

		JoiningAlliesWidget = WidgetBlueprint::CreatePondWidget(HUD.JoiningAlliesClass);
	}

	private ULoadingScreenWidget LoadingScreen;

	UFUNCTION(Category = "HUD", Client)
	void AddLoadingScreen()
	{
		if (!Validate())
			return;

		if (!IsValid(HUD))
		{
			System::SetTimer(this, n"AddLoadingScreen", 0.5f, false);
			return;
		}

		LoadingScreen = Cast<ULoadingScreenWidget>(WidgetBlueprint::CreateWidget(Pond::GetPondGameInstanceBase().LoadingScreenClass, PC));
		LoadingScreen.AddToViewport(99);
	}

	UFUNCTION(Category = "HUD", Client)
	void AddLoadingScreenInstant()
	{
		if (!Validate())
			return;

		LoadingScreen = Cast<ULoadingScreenWidget>(WidgetBlueprint::CreatePondWidget(Pond::GetPondGameInstanceBase().LoadingScreenClass, PC, ESlateVisibility::Visible, false));
	}

	UFUNCTION(Category = "HUD", Client)
	void RemoveLoadingScreen(bool bFadeOut = true)
	{
		if (!Validate())
			return;

		if (!IsValid(LoadingScreen))
			return;

		LoadingScreen.RemoveFromParent_WithFade(bFadeOut);
	}

	private UFadeToBlackWidget FadeToBlackWidget;

	UFUNCTION(Category = "HUD", Client)
	void FadeToBlack()
	{
		if (!Validate())
			return;

		if (!IsValid(FadeToBlackWidget))
			FadeToBlackWidget = Cast<UFadeToBlackWidget>(WidgetBlueprint::CreatePondWidget(HUD.FadeToBlackClass));

		FadeToBlackWidget.Black.SetRenderOpacity(0);
		FadeToBlackWidget.PlayAnimationForward(FadeToBlackWidget.Fade);
	}

	UFUNCTION(Category = "HUD", Client)
	void FadeFromBlack()
	{
		if (!PC.IsLocalController())
			return;

		if (!IsValid(FadeToBlackWidget))
			FadeToBlackWidget = Cast<UFadeToBlackWidget>(WidgetBlueprint::CreatePondWidget(HUD.FadeToBlackClass));

		FadeToBlackWidget.Black.SetRenderOpacity(1);
		FadeToBlackWidget.PlayAnimationReverse(FadeToBlackWidget.Fade);
	}

	UFUNCTION(Category = "HUD", Client)
	void SetGameplayOverlay(EScreenOverlay Overlay, bool bEnabled)
	{
		if (!Validate())
			return;

		HUD::GetHUDWidget().ScreenEffects.SetOverlay(Overlay, bEnabled);
	}

	private FText PendingBossBarTitle;
	private bool bPendingBossBar = false;
	private UBossHealthbarWidget BossBarWidget;

	UFUNCTION(Category = "HUD", Client)
	void AddBossBar(FText Title)
	{
		if (!Validate())
			return;

		auto HUDWidget = HUD::GetHUDWidget();

		// If a bar is currently in the slot (could be mid-fade), queue the new one
		// and let the outgoing fade finish before adding
		if (IsValid(BossBarWidget) && HUDWidget.BossBarSlot.ChildrenCount > 0)
		{
			PendingBossBarTitle = Title;
			bPendingBossBar = true;

			System::SetTimer(this, n"OnCurrentBossBarFaded", 1.5, false);
			BossBarWidget.RemoveFromParent_WithFade(true);
			return;
		}

		// Always create fresh — old widget (if any) is already gone or was never added
		BossBarWidget = Cast<UBossHealthbarWidget>(WidgetBlueprint::CreateWidget(HUD.BossBarClass, PC));
		BossBarWidget.BossLabel.SetText(Title);
		BossBarWidget.SetActiveBossBar(); // slot is already empty, no removal needed
	}

	UFUNCTION(NotBlueprintCallable)
	private void OnCurrentBossBarFaded()
	{
		if (!bPendingBossBar)
			return;

		bPendingBossBar = false;
		BossBarWidget = nullptr; // clear so IsValid check in AddBossBar won't re-enter this branch
		AddBossBar(PendingBossBarTitle);
	}

	UFUNCTION(Category = "HUD", Client)
	void RemoveBossBar()
	{
		if (!Validate())
			return;

		bPendingBossBar = false; // cancel any queued bar if explicitly removed
		BossBarWidget.RemoveFromParent_WithFade();
	}

	UFUNCTION(Category = "HUD", NetMulticast, BlueprintAuthorityOnly)
	void AddBossBarToAll(FText Title)
	{
		TArray<AScriptPondHero> Heroes;
		HeroUtils::GetAllHeroes(Heroes);
		for (auto H : Heroes)
		{
			H.PondController.ScreenOverlayComponent.AddBossBar(Title);
		}
	}

	UFUNCTION(Category = "HUD", NetMulticast, BlueprintAuthorityOnly)
	void RemoveBossBarForAll()
	{
		TArray<AScriptPondHero> Heroes;
		HeroUtils::GetAllHeroes(Heroes);

		for (auto H : Heroes)
		{
			if (IsValid(H) && IsValid(H.PondController) && IsValid(H.PondController.ScreenOverlayComponent))
			{
				// Call the Client RPC so it executes safely on each player's respective machine
				H.PondController.ScreenOverlayComponent.RemoveBossBar();
			}
		}
	}

	// Runs on the owning client only — same pattern as AddBossBar
	UFUNCTION(Category = "HUD", Client)
	void SetBossBarPercent(float InPercent)
	{
		if (!IsValid(BossBarWidget))
			return;

		BossBarWidget.Healthbar.SetPercent(InPercent);
	}

	// Called from authority, dispatches to each player's client RPC
	UFUNCTION(Category = "HUD", BlueprintAuthorityOnly)
	void SetBossBarPercentForAll(float InPercent)
	{
		TArray<AScriptPondHero> Heroes;
		HeroUtils::GetAllHeroes(Heroes);
		for (auto H : Heroes)
		{
			H.PondController.ScreenOverlayComponent.SetBossBarPercent(InPercent);
		}
	}
}