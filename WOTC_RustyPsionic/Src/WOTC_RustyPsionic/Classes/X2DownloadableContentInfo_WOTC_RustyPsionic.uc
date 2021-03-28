//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_WOTC_RustyPsionic.uc                                    
//  
//	File created by RustyDios	04/04/20	10:00	
//	LAST UPDATED				12/01/21	17:20
//
//	ADDS custom abilities used by my psionics
//
//*******************************************************************************************

class X2DownloadableContentInfo_WOTC_RustyPsionic extends X2DownloadableContentInfo config (RustyPsionic);

var config bool bEnableLogging, bTrashTheOldLab;

static event OnLoadedSavedGame(){}

static event InstallNewCampaign(XComGameState StartState){}

//*******************************************************************************************
//		OPTC code 
//*******************************************************************************************

static event OnPostTemplatesCreated()
{
	AddPsionicGTSUnlock();

    if(default.bTrashTheOldLab)
    {
        TrashTheOldPsiLab();
    }
	else
	{
		AdjustPsiOverhaulSlot();
	}
	//end OPTC
}

////////////////////////////////////////////////////////////////////////
//	FUNCTION TO ADJUST PSI OVERHAUL V3 PSIAMP SLOT 
//	THIS LETS THE SLOT BE EMPTY
////////////////////////////////////////////////////////////////////////
static function AdjustPsiOverhaulSlot()
{
	local CHItemSlotStore 	SlotStore;
	local CHItemSlot 		Template;

	SlotStore = class'CHItemSlotStore'.static.GetStore();

	Template = SlotStore.GetSlot(eInvSlot_PsiAmp);

	if (Template != none)
	{
		Template.GetSlotUnequipBehaviorFn = PsiAmpSlotGetUnequipBehavior_Rusty;
	}

    `LOG("Rustys Psionic Class adjusted Psi Overhaul Slot", default.bEnableLogging,'RustyPsionicClass');

}

function ECHSlotUnequipBehavior PsiAmpSlotGetUnequipBehavior_Rusty(CHItemSlot Slot, ECHSlotUnequipBehavior DefaultBehavior, XComGameState_Unit UnitState, XComGameState_Item ItemState, optional XComGameState CheckGameState)
{    
    return eCHSUB_AllowEmpty;
}

////////////////////////////////////////////////////////////////////////
//	FUNCTION TO TRASH THE ORIGINAL PSILAB, MAY ALSO BE DONE IN OTHER MODS
//	NAMELY ADVENT AVENGERS PSIONICS FROM START
////////////////////////////////////////////////////////////////////////

static function TrashTheOldPsiLab()
{
    local X2StrategyElementTemplateManager  AllStratElements;
    local X2GameplayMutatorTemplate         FakeTemplate;

    AllStratElements = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

    // Disable the PSI Labs.
    `CREATE_X2TEMPLATE(class'X2GameplayMutatorTemplate', FakeTemplate, 'PsiChamber');
        FakeTemplate.Category = "None";
        AllStratElements.AddStrategyElementTemplate(FakeTemplate, true);
   
    // Just in case. Difficulty modifiers.
    `CREATE_X2TEMPLATE(class'X2GameplayMutatorTemplate', FakeTemplate, 'PsiChamber_Diff_0');
        FakeTemplate.Category = "None";
        AllStratElements.AddStrategyElementTemplate(FakeTemplate, true);
    `CREATE_X2TEMPLATE(class'X2GameplayMutatorTemplate', FakeTemplate, 'PsiChamber_Diff_1');
        FakeTemplate.Category = "None";
        AllStratElements.AddStrategyElementTemplate(FakeTemplate, true);
    `CREATE_X2TEMPLATE(class'X2GameplayMutatorTemplate', FakeTemplate, 'PsiChamber_Diff_2');
        FakeTemplate.Category = "None";
        AllStratElements.AddStrategyElementTemplate(FakeTemplate, true);
    `CREATE_X2TEMPLATE(class'X2GameplayMutatorTemplate', FakeTemplate, 'PsiChamber_Diff_3');
        FakeTemplate.Category = "None";
        AllStratElements.AddStrategyElementTemplate(FakeTemplate, true);
    
    `LOG("Rustys Psionic Class just burned the OLD Psi Lab schematics",default.bEnableLogging,'RustyPsionicClass');

}

////////////////////////////////////////////////////////////////////////
//	Adds GTS Purchases for Psionic 
//	code adapted from Iridar and HotBlodded via discord
////////////////////////////////////////////////////////////////////////
static function AddPsionicGTSUnlock()
{
	local X2StrategyElementTemplateManager	TemplateManager;
	local X2FacilityTemplate				Template;
	local array<name>						SoldierUnlocks;
	local name								SoldierUnlock;

	//Karen!!
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	//create the 'to add' array
	SoldierUnlocks.AddItem('Rusty_SixthSenseUnlock');	//see X2StrategyElement_RustyPsionic_GTS

	//if the facility exists ... 
	Template = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('OfficerTrainingSchool'));
	if (Template != none)
	{
		foreach SoldierUnlocks(SoldierUnlock)
		{
			//and we can't find the template ... add it
			if (Template.SoldierUnlockTemplates.Find(SoldierUnlock) == INDEX_NONE)
			{
				Template.SoldierUnlockTemplates.AddItem(SoldierUnlock);
			}
		}
	}
}

//*******************************************************************************************
// Tag Expansion Handler - this creates the custom string fields for localisation file
//*******************************************************************************************
static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name TagText;
	
	TagText = name(InString);
	switch (TagText)
	{
		case 'PANACEA_APGRANTED':		OutString = string(class'X2Ability_RustyPsionic'.default.iPANACEA_APGRANTED);			return true;
		case 'PANACEA_COST_AP':			OutString = string(class'X2Ability_RustyPsionic'.default.iPANACEA_APCOST);				return true;
		case 'PANACEA_COST_COOLDOWN':	OutString = string(class'X2Ability_RustyPsionic'.default.iPANACEA_COOLDOWN);			return true;
		case 'PANACEA_COST_FREE':		OutString = string(class'X2Ability_RustyPsionic'.default.bPANACEA_FREEREQUIRESPOINTS);	return true;
		case 'PANACEA_COST_TURNENDING':	OutString = string(class'X2Ability_RustyPsionic'.default.bPANACEA_CONSUMEALL);			return true;
		case 'PANACEA_COST_CHARGES':	OutString = string(class'X2Ability_RustyPsionic'.default.iPANACEA_CHARGES);				return true;
		case 'PSIHEAL_COST_AP':			OutString = string(class'X2Ability_RustyPsionic'.default.iPSIHEAL_APCOST);				return true;
		case 'PSIHEAL_COST_COOLDOWN':	OutString = string(class'X2Ability_RustyPsionic'.default.iPSIHEAL_COOLDOWN);			return true;
		case 'PSIHEAL_COST_FREE':		OutString = string(class'X2Ability_RustyPsionic'.default.bPSIHEAL_FREEREQUIRESPOINTS);	return true;
		case 'PSIHEAL_COST_TURNENDING':	OutString = string(class'X2Ability_RustyPsionic'.default.bPSIHEAL_CONSUMEALL);			return true;
		case 'PSIHEAL_COST_CHARGES':	OutString = string(class'X2Ability_RustyPsionic'.default.iPSIHEAL_CHARGES);				return true;
		case 'SSDODGE':					OutString = string(class'X2Ability_RustyPsionic'.default.iSSDodge);						return true;
		case 'SSTURN':					OutString = string(class'X2Ability_RustyPsionic'.default.iSSNumTurns);					return true;
		default:	return false;		break;
    }  
}
