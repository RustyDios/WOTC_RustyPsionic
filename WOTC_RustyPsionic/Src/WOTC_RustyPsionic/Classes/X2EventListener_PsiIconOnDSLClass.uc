//*******************************************************************************************
//  FILE:   Psionics Class. stuff                                 
//  
//	File created	07/12/20	10:30
//	LAST UPDATED    07/12/20	22:30
//
//	FIXES UP THE ICON FOR PSI STAT on DSL IF USING THIS CLASS
//
//*******************************************************************************************
class X2EventListener_PsiIconOnDSLClass extends X2EventListener;

//add the listener
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreatePsiIconOnDSL_Class());

	return Templates;
}

//create the listener	PsiIconOnDSL
static function X2EventListenerTemplate CreatePsiIconOnDSL_Class()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'PsiIconOnDSL_Class');

	Template.RegisterInTactical = false;	//listen during missions
	Template.RegisterInStrategy = true;		//listen during avenger

	//set to listen for event, do a thing, at this time
	Template.AddCHEvent('DSLShouldShowPsi', Class_PsiIconOnDSL, ELD_Immediate); //priority 42 to run after other changes which set the psi icon

	return Template;
}

/*
// For REF only called from DSL ShouldShowPsi
// `XEVENTMGR.TriggerEvent('DSLShouldShowPsi', EventTup, Unit);
Data:
EventTup = new class'LWTuple';
	EventTup.Id = 'ShouldShowPsi';
	EventTup.Data.Add(2);
	EventTup.Data[0].kind = LWTVBool;
	EventTup.Data[0].b = false;
	EventTup.Data[1].kind = LWTVName;
	EventTup.Data[1].n = nameof(Screen.class);

Source: Unit

No Gamestate
*/

//what does the listener do when it hears a call?
static function EventListenerReturn Class_PsiIconOnDSL(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local LWTuple				Tuple;
    local XComGameState_Unit    UnitState;

	Tuple = LWTuple(EventData);
	UnitState = XComGameState_Unit(EventSource);

	if (UnitState.GetSoldierClassTemplateName() == 'RustyPsionic')
	{
		Tuple.Data[0].b = true;
    }

	return ELR_NoInterrupt;
}
