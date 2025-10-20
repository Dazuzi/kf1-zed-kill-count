class ZedKillCountGameRules extends GameRules;

var ZedKillCount ParentMutator;

function ScoreKill(Controller Killer, Controller Killed) {
	local Monster M;
	M = Monster(Killed.Pawn);
	if (ZombieClot(M) != None) ParentMutator.IncreaseKillCount(0);
	else if (ZombieCrawler(M) != None) ParentMutator.IncreaseKillCount(1);
	else if (ZombieStalker(M) != None) ParentMutator.IncreaseKillCount(2);
	else if (ZombieGoreFast(M) != None) ParentMutator.IncreaseKillCount(3);
	else if (ZombieBloat(M) != None) ParentMutator.IncreaseKillCount(4);
	else if (ZombieSiren(M) != None) ParentMutator.IncreaseKillCount(5);
	else if (ZombieHusk(M) != None) ParentMutator.IncreaseKillCount(6);
	else if (ZombieScrake(M) != None) ParentMutator.IncreaseKillCount(7);
	else if (ZombieFleshPound(M) != None) ParentMutator.IncreaseKillCount(8);
	Super.ScoreKill(Killer, Killed);
}
