//*******************************************************************************************
//  FILE:   X2StrategyElement_RustyPsionic_GTS                                   
//  
//	File created by RustyDios	10/01/21	15:30	
//	LAST UPDATED				10/01/21	15:30
//
//	Contains the setup required for the GTS unlock
//
//*******************************************************************************************

class X2StrategyElement_RustyPsionic_GTS extends X2StrategyElement config (RustyPsionic);

var config int	RDPsionic_GTS_RANK;
var config string ImagePath;

var config array<name>	strRDPsionic_GTS_COST_TYPE;
var config array<int>	iRDPsionic_GTS_COST_AMOUNT;

//add the GTS template
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_SixthSenseUnlock());

	return Templates;
}

//create the GTS template
static function X2SoldierAbilityUnlockTemplate Create_SixthSenseUnlock()
{
	local X2SoldierAbilityUnlockTemplate	Template;
	local ArtifactCost						Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, 'Rusty_SixthSenseUnlock');

	Template.AllowedClasses.AddItem('RustyPsionic');
	Template.AbilityName = 'RustySixthSense';
	Template.strImage = "img:///" $default.ImagePath; //UILibrary_RustyPsionic.GTS_SixthSense or UILibrary_RustyPsionic.GTS_SixthSenseCC

	//Requirements
	Template.Requirements.RequiredHighestSoldierRank = default.RDPsionic_GTS_RANK; // default 4 disciple
	Template.Requirements.RequiredSoldierClass = 'RustyPsionic';
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	for (i = 0; i < default.strRDPsionic_GTS_COST_TYPE.Length; i++)
	{
		if (default.iRDPsionic_GTS_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strRDPsionic_GTS_COST_TYPE[i];
			Resources.Quantity = default.iRDPsionic_GTS_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}
	
	return Template;
}

