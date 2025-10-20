class ZedKillCount extends Mutator
	Config(ZedKillCount);

struct ZedEntry {
	var string Name;
	var int Total, Count;
};

var const array<ZedEntry> Zed;
var config string ThousandsSeparator, ZedKillCountMessage, ZedKillCountEntry;
var config color TextColour, HighlightColour;
var string TextCode, HighlightCode;
var int CurrentWave, ClotKillCount, GoreFastKillCount, StalkerKillCount, CrawlerKillCount, BloatKillCount, SirenKillCount, HuskKillCount, ScrakeKillCount, FleshPoundKillCount;

static function FillPlayInfo(PlayInfo PlayInfo) {
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting("Zed Kill Count", "ZedKillCountMessage",		"Kill count message",	0, 1,	"Text",		"256");
	PlayInfo.AddSetting("Zed Kill Count", "ZedKillCountEntry",		"Entry text",		0, 2,	"Text",		"64");
	PlayInfo.AddSetting("Zed Kill Count", "ThousandsSeparator",		"Thousands separator",	0, 3,	"Text",		"1");
}

static event string GetDescriptionText(string Property) {
	switch (Property) {
		case "ZedKillCountMessage":
			return "Shown in front of the first line.";
		case "ZedKillCountEntry":
			return "Entry text. %name% gets replaced with monster's name, %count% with the number of kills during the last wave and %total% with total kills.";
		case "ThousandsSeparator":
			return "Thousands separator is used to chop long numbers into more easily readable bits.";
		default:
			return Super.GetDescriptionText(Property);
	}
}

function MatchStarting() {
	SetTimer(5.0, True);
}

function Timer() {
	if (CurrentWave != KFGameType(Level.Game).WaveNum)
		SpamKillCount();
}

function SpamKillCount() {
	local string Message;
	local int i, Count;
	CurrentWave = KFGameType(Level.Game).WaveNum;
	if (CurrentWave == KFGameType(Level.Game).FinalWave)
		SetTimer(0, False);
	Message = ZedKillCountMessage$" ";
	++Count;
	for (i = 9; i >= 0; --i) {
		if (Default.Zed[i].Total > 0) {
			Message $= Repl(Repl(Repl(TextCode$ZedKillCountEntry$" ", "%name%", Default.Zed[i].Name), "%count%", HighlightCode$Default.Zed[i].Count$TextCode), "%total%", AddThousandsSeparators(Default.Zed[i].Total));
			Default.Zed[i].Count = 0;
			++Count;
		}
		if (Count >= 4) {
			SendMessage(Left(Message, Len(Message) - 1));
			Count = 0;
			Message = "";
		}
	}
	if (Count > 0)
		SendMessage(Left(Message, Len(Message) - 1));
}

function SendMessage(string Message) {
	local controller C;
	for (C = Level.ControllerList; C != None; C = C.nextController) {
		if (C.IsA('PlayerController')) {
			if (C.PlayerReplicationInfo.PlayerName ~= "WebAdmin" && C.PlayerReplicationInfo.PlayerID == 0)
				PlayerController(C).TeamMessage(None, Repl(Repl(Message, TextCode, ""), HighlightCode, ""), 'ZedKillCount');
			else
				PlayerController(C).TeamMessage(None, Message, 'ZedKillCount');
		}
	}
}

function string AddThousandsSeparators(int IntNumber) {
	local string StringNumber, Result;
	local int Length;
	StringNumber = String(IntNumber);
	for (Length = Len(StringNumber); Length > 0; Length = Len(StringNumber)) {
		if (Length > 3) {
			Result = ThousandsSeparator$Right(StringNumber, 3)$Result;
			StringNumber = Left(StringNumber, Length - 3);
		}
		else
			break;
	}
	return StringNumber$Result;
}

function IncreaseKillCount(int Index) {
	++Default.Zed[Index].Count;
	++Default.Zed[Index].Total;
	++Default.Zed[9].Count;
	++Default.Zed[9].Total;
}

function PostBeginPlay() {
	local GameRules GR;
	Super.PostBeginPlay();
	GR = spawn(class'ZedKillCountGameRules');
	ZedKillCountGameRules(GR).ParentMutator = Self;
	if (Level.Game.GameRulesModifiers == None)
		Level.Game.GameRulesModifiers = GR;
	else Level.Game.GameRulesModifiers.AddGameRules(GR);
	TextCode = class'Engine.GameInfo'.static.MakeColorCode(TextColour);
	HighlightCode = class'Engine.GameInfo'.static.MakeColorCode(HighlightColour);
}

defaultproperties {
	ZedKillCountMessage="Zed Kill Count:"
	ZedKillCountEntry="%name% %count% (%total%)"
	ThousandsSeparator=","
	TextColour=(B=255,G=255,R=255,A=255)
	HighlightColour=(B=0,G=0,R=255,A=255)
	Zed(0)=(Name="Clot",Count=0,Total=0)
	Zed(1)=(Name="Crawler",Count=0,Total=0)
	Zed(2)=(Name="Stalker",Count=0,Total=0)
	Zed(3)=(Name="Gorefast",Count=0,Total=0)
	Zed(4)=(Name="Bloat",Count=0,Total=0)
	Zed(5)=(Name="Siren",Count=0,Total=0)
	Zed(6)=(Name="Husk",Count=0,Total=0)
	Zed(7)=(Name="Scrake",Count=0,Total=0)
	Zed(8)=(Name="Fleshpound",Count=0,Total=0)
	Zed(9)=(Name="Total",Count=0,Total=0)
	GroupName="KF-ZedKillCount"
	FriendlyName="Zed Kill Count"
	Description="This mutator displays the number of each zeds killed after wave ends."
}
