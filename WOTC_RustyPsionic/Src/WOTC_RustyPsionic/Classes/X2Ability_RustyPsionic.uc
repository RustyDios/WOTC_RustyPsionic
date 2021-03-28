//*******************************************************************************************
//  FILE:   X2Ability_RustyPsionics                             
//  
//	File created by RustyDios	04/04/20	14:00	
//	LAST UPDATED				12/01/21	17:20
//
//	ADDS custom abilities used by my psionics
//
//*******************************************************************************************
class X2Ability_RustyPsionic extends X2Ability_PsiOperativeAbilitySet config (RustyPsionic);

//grab config vars
var config int iPANACEA_APCOST, iPANACEA_CHARGES, iPANACEA_COOLDOWN, iPANACEA_APGRANTED;
var config bool bPANACEA_CONSUMEALL, bPANACEA_FREEREQUIRESPOINTS;

var config int iPSIHEAL_APCOST, iPSIHEAL_CHARGES, iPSIHEAL_COOLDOWN;
var config bool bPSIHEAL_CONSUMEALL, bPSIHEAL_FREEREQUIRESPOINTS;

var config int iSSS_APCOST, iSSS_CHARGES, iSSS_COOLDOWN, iSSNumTurns, iSSDodge;
var config bool bSSS_CONSUMEALL, bSSS_FREEREQUIRESPOINTS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	//GTS Unlock
	Templates.AddItem(Create_RustySixthSense());
	Templates.AddItem(Create_SixthSense_Stealth());
	Templates.AddItem(PurePassive('SixthSense_Passive',	"img:///UILibrary_RustyPsionic.UIPerk_SixthSense", false , 'eAbilitySource_Psionic'));
	
	//create the two 'filler' abilities (updated with stuff from MZ)
	Templates.AddItem(Create_RustyPsiRevive());
	Templates.AddItem(Create_RustyPsiHeal());

    return Templates;
}

//*******************************************************************************************
// When your concealment is broken, gain a bonus to dodge for a few turns. Passive.
//*******************************************************************************************

static function X2AbilityTemplate Create_RustySixthSense()
{
    local X2AbilityTemplate                 Template;
    local X2AbilityTrigger_EventListener	Trigger;
	local X2Effect_PersistentStatChange     DodgeEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'RustySixthSense');

   	Template.IconImage = "img:///UILibrary_RATImages.UIPerk_SixthSense";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

    // Ability is triggered when individual concealment is broken
    Trigger = new class'X2AbilityTrigger_EventListener';
		Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
		Trigger.ListenerData.EventID = 'UnitConcealmentBroken';
		Trigger.ListenerData.Filter = eFilter_Unit;
		Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
    Template.AbilityTriggers.AddItem(Trigger);

    // Ability is triggered when squad concealment is broken
    Trigger = new class'X2AbilityTrigger_EventListener';
		Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
		Trigger.ListenerData.EventID = 'SquadConcealmentBroken';
		Trigger.ListenerData.Filter = eFilter_Unit;
		Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
    Template.AbilityTriggers.AddItem(Trigger);

    // Create a persistent stat change effect that grants a defense bonus
    DodgeEffect = new class'X2Effect_PersistentStatChange';
		DodgeEffect.EffectName = 'SixthSense_Effect';
		DodgeEffect.BuildPersistentEffect(default.iSSNumTurns, false, true, false, eGameRule_PlayerTurnBegin);
		DodgeEffect.AddPersistentStatChange(eStat_Dodge, default.iSSDodge);
		DodgeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true, ,Template.AbilitySourceName);
		DodgeEffect.DuplicateResponse = eDupe_Refresh;    // Prevent the effect from applying to a unit more than once
    Template.AddShooterEffect(DodgeEffect);

    Template.AdditionalAbilities.AddItem('SixthSense_Passive');
    Template.AdditionalAbilities.AddItem('SixthSense_Stealth');
	//Template.SetUIStatMarkup(class'XLocalizedData'.default.DodgeLabel, eStat_Dodge, 20);

		//Visualizations and stuff
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

    return Template;
}

static function X2AbilityTemplate Create_SixthSense_Stealth()
{
	local X2AbilityTemplate				Template;

	local X2AbilityCost_ActionPoints	ActionPointCost;
	local X2AbilityCharges				Charges;
	local X2AbilityCost_Charges			ChargeCost;
	local X2AbilityCooldown             Cooldown;

	local X2Effect_RangerStealth		StealthEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SixthSense_Stealth');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stealth";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

	//Costs .. AP
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.iSSS_APCOST;
	ActionPointCost.bConsumeAllPoints = default.bSSS_CONSUMEALL;
	ActionPointCost.bFreeCost = default.bSSS_FREEREQUIRESPOINTS;
	Template.AbilityCosts.AddItem(ActionPointCost);

	//Costs .. Charges
	if (default.iSSS_CHARGES > 0)
	{
		Charges = new class'X2AbilityCharges';
		Charges.InitialCharges = default.iSSS_CHARGES;
		Template.AbilityCharges = Charges;

		ChargeCost = new class'X2AbilityCost_Charges';
		Template.AbilityCosts.AddItem(ChargeCost);
	}

	//Costs .. Cooldown
	if (default.iSSS_COOLDOWN > 0)
	{
		Cooldown = new class'X2AbilityCooldown';
		Cooldown.iNumTurns = default.iSSS_COOLDOWN;
		Template.AbilityCooldown = Cooldown;
	}

	//Trigger and targetting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_Stealth');
	Template.AddShooterEffectExclusions();

	//Effects
	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	//Visualizations and stuff
	Template.ActivationSpeech = 'ActivateConcealment';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

	return Template;
}
//*******************************************************************************************
//create the cleanse ability
//*******************************************************************************************

static function X2AbilityTemplate Create_RustyPsiRevive()
{
	local X2AbilityTemplate				Template;

	local X2AbilityCost_ActionPoints	ActionPointCost;
	local X2AbilityCharges				Charges;
	local X2AbilityCost_Charges			ChargeCost;
	local X2AbilityCooldown             Cooldown;

	local X2Condition_UnitProperty		TargetCondition, EnemyCondition, FriendCondition;

	local X2Effect_Persistent			ActionPointPersistEffect;
	local X2Effect_GrantActionPoints	ActionPointEffect;
	local X2Effect_RemoveEffects		MentalEffectRemovalEffect, MindControlRemovalEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RustyPanacea');

	// Icon Properties
	Template.AbilitySourceName = 'eAbilitySource_Psionic';                                       // color of the icon
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_gatekeeper_retract";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MEDIKIT_HEAL_PRIORITY +1;
	Template.Hostility = eHostility_Defensive;
	Template.ConcealmentRule = eConceal_Always;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;	
	
	//Costs .. AP
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.iPANACEA_APCOST;
	ActionPointCost.bConsumeAllPoints = default.bPANACEA_CONSUMEALL;
	ActionPointCost.bFreeCost = default.bPANACEA_FREEREQUIRESPOINTS;
	Template.AbilityCosts.AddItem(ActionPointCost);

	//Costs .. Charges
	if (default.iPANACEA_CHARGES > 0)
	{
		Charges = new class'X2AbilityCharges';
		Charges.InitialCharges = default.iPANACEA_CHARGES;
		Template.AbilityCharges = Charges;

		ChargeCost = new class'X2AbilityCost_Charges';
		Template.AbilityCosts.AddItem(ChargeCost);
	}

	//Costs .. Cooldown
	if (default.iPANACEA_COOLDOWN > 0)
	{
		Cooldown = new class'X2AbilityCooldown';
		Cooldown.iNumTurns = default.iPANACEA_COOLDOWN;
		Template.AbilityCooldown = Cooldown;
	}

	//target and triggers
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeAlive = false;
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.TreatMindControlledSquadmateAsHostile = false;
	TargetCondition.RequireSquadmates = true;
	TargetCondition.FailOnNonUnits = true;
	TargetCondition.ExcludeRobotic = true;
	TargetCondition.ExcludeUnableToAct = false;
	TargetCondition.ExcludeTurret = true;
	Template.AbilityTargetConditions.AddItem(TargetCondition);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	
	Template.bLimitTargetIcons = true;
	Template.DisplayTargetHitChance = true;

	//remove all negative effects, ala restoration
	Template.AddTargetEffect(RemoveEverythingForPanacea());

	//grant an action point
	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = default.iPANACEA_APGRANTED;
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	ActionPointEffect.bSelectUnit = true;
	Template.AddTargetEffect(ActionPointEffect);

	// A persistent effect for the effects code to attach a duration to
	ActionPointPersistEffect = new class'X2Effect_Persistent';
	ActionPointPersistEffect.EffectName = 'Inspiration';
	ActionPointPersistEffect.BuildPersistentEffect( 1, false, true, false, eGameRule_PlayerTurnEnd );
	ActionPointPersistEffect.bRemoveWhenTargetDies = true;
	Template.AddTargetEffect(ActionPointPersistEffect);
	
	//This is basically Solace woo.
	MentalEffectRemovalEffect = class'X2StatusEffects'.static.CreateMindControlRemoveEffects();
	MentalEffectRemovalEffect.DamageTypes.Length = 0;		//	don't let an immunity to "mental" effects resist this cleanse
		FriendCondition = new class'X2Condition_UnitProperty';
		FriendCondition.ExcludeFriendlyToSource = false;
		FriendCondition.ExcludeHostileToSource = true;
	MentalEffectRemovalEffect.TargetConditions.AddItem(FriendCondition);
	Template.AddTargetEffect(MentalEffectRemovalEffect);

	MindControlRemovalEffect = new class'X2Effect_RemoveEffects';
	MindControlRemovalEffect.EffectNamesToRemove.AddItem(class'X2Effect_MindControl'.default.EffectName);
		EnemyCondition = new class'X2Condition_UnitProperty';
		EnemyCondition.ExcludeFriendlyToSource = true;
		EnemyCondition.ExcludeHostileToSource = false;
	MindControlRemovalEffect.TargetConditions.AddItem(EnemyCondition);
	Template.AddTargetEffect(MindControlRemovalEffect);

	//Visualization
	Template.ActivationSpeech = 'HealingAlly';

	Template.bShowActivation = true;
	Template.CustomFireAnim = 'HL_Psi_ProjectileMedium';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.PrerequisiteAbilities.AddItem('Inspire');

	//shadow, chosen and lost
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	//Template.PrerequisiteAbilities.AddItem('NOT_RustyPsiHeal');	//makes it mutually exclusive with heal

	return Template;
}

//Panacea remove effects .. revival basically
static function X2Effect_RemoveEffectsByDamageType RemoveEverythingForPanacea()
{
	local X2Effect_RemoveEffectsByDamageType RemoveEffects;
	local name HealType;

	RemoveEffects = new class'X2Effect_RemoveEffectsByDamageType';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.PanickedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.UnconsciousName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DazedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ObsessedName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.BerserkName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ShatteredName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Ability_Viper'.default.BindSustainedEffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.BleedingOutName);

	foreach class'X2Ability_DefaultAbilitySet'.default.MedikitHealEffectTypes(HealType)
	{
		RemoveEffects.DamageTypesToRemove.AddItem(HealType);
	}

	return RemoveEffects;
}

//*******************************************************************************************
//	create healing ability
//*******************************************************************************************

static function X2AbilityTemplate Create_RustyPsiHeal()
{
	local X2AbilityTemplate				Template;

	local X2AbilityCost_ActionPoints	ActionPointCost;
	local X2AbilityCharges				Charges;
	local X2AbilityCost_Charges			ChargeCost;
	local X2AbilityCooldown             Cooldown;

	local X2Condition_UnitProperty      TargetCondition;
	local X2Condition_UnitStatCheck		UnitStatCheckCondition;
	local X2Condition_UnitEffects		UnitEffectsCondition;

	local X2Effect_ApplyMedikitHeal		MedikitHeal;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RustyPsiHeal');

	// Icon Properties
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';                                       // color of the icon
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_horror";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MEDIKIT_HEAL_PRIORITY +2;
	Template.Hostility = eHostility_Defensive;
	Template.ConcealmentRule = eConceal_Always;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;	
	
	//Costs .. AP
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.iPSIHEAL_APCOST;
	ActionPointCost.bConsumeAllPoints = default.bPSIHEAL_CONSUMEALL;
	ActionPointCost.bFreeCost = default.bPSIHEAL_FREEREQUIRESPOINTS;
	Template.AbilityCosts.AddItem(ActionPointCost);

	//Costs .. Charges
	if (default.iPSIHEAL_CHARGES > 0)
	{
		Charges = new class'X2AbilityCharges';
		Charges.InitialCharges = default.iPSIHEAL_CHARGES;
		Template.AbilityCharges = Charges;

		ChargeCost = new class'X2AbilityCost_Charges';
		Template.AbilityCosts.AddItem(ChargeCost);
	}

	//Costs .. Cooldown
	if (default.iPSIHEAL_COOLDOWN > 0)
	{
		Cooldown = new class'X2AbilityCooldown';
		Cooldown.iNumTurns = default.iPSIHEAL_COOLDOWN;
		Template.AbilityCooldown = Cooldown;
	}

	//target and triggers
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeDead = false;
	TargetCondition.ExcludeAlive = false;
	TargetCondition.ExcludeFullHealth = true;
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.TreatMindControlledSquadmateAsHostile = false;
	TargetCondition.RequireSquadmates = true;
	TargetCondition.FailOnNonUnits = true;
	TargetCondition.ExcludeRobotic = true;
	TargetCondition.ExcludeUnableToAct = false;
	TargetCondition.ExcludeTurret = true;
	Template.AbilityTargetConditions.AddItem(TargetCondition);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	
	Template.bLimitTargetIcons = true;

	//Hack: Do this instead of ExcludeDead, to only exclude properly-dead or bleeding-out units.
	UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
	UnitStatCheckCondition.AddCheckStat(eStat_HP, 0, eCheck_GreaterThan);
	Template.AbilityTargetConditions.AddItem(UnitStatCheckCondition);

	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddExcludeEffect(class'X2StatusEffects'.default.BleedingOutName, 'AA_UnitIsImpaired');
	Template.AbilityTargetConditions.AddItem(UnitEffectsCondition);

	//Apply the heal
	MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
	MedikitHeal.PerUseHP = class'X2Ability_DefaultAbilitySet'.default.MEDIKIT_PERUSEHP +1 ;
	MedikitHeal.IncreasedHealProject = 'BattlefieldMedicine';
	MedikitHeal.IncreasedPerUseHP = class'X2Ability_DefaultAbilitySet'.default.NANOMEDIKIT_PERUSEHP +1;
	Template.AddTargetEffect(MedikitHeal);

	Template.AddTargetEffect(class'X2Ability_SpecialistAbilitySet'.static.RemoveAllEffectsByDamageType());

	//Visualization
	Template.ActivationSpeech = 'HealingAlly';

	Template.bShowActivation = true;
	Template.CustomFireAnim = 'HL_Psi_ProjectileMedium';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	//shadow, chosen and lost
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	//Template.PrerequisiteAbilities.AddItem('NOT_RustyPanacea');	//makes it mutually exclusive with revive

	return Template;
}
