extends BaseAgent
class_name AIAgent

#
var aiBehaviour : int					= AICommons.Behaviour.NONE
var aiState : AICommons.State			= AICommons.State.IDLE
var aiTimer : Timer						= null
var aiRefreshDelay : float				= randf_range(AICommons.MinRefreshDelay, AICommons.MaxRefreshDelay)
var attackers : Array					= []
var followers : Dictionary[int, Array]	= {}
var leader : BaseAgent					= null
var hasNodeGoal : bool					= false
var nodeGoal : Node2D					= null
var spawnInfo : SpawnObject				= null
var skillSelected : SkillCell			= null

var minWanderingSpeed : int				= 100
var maxWanderingSpeed : int				= 100

#
func ResetNav():
	super.ResetNav()
	if hasNodeGoal:
		hasNodeGoal = false
		nodeGoal = null
		actionTimer.stop()

func SetNodeGoal(goal : Node2D, pos : Vector2):
	WalkToward(pos)
	hasNodeGoal = goal != null
	nodeGoal = goal

func AddAttacker(attacker : BaseAgent, damage : int = 0):
	if attacker:
		var currentTick : int = Time.get_ticks_msec()
		for entry in attackers:
			if entry.attacker == attacker:
				entry.damage += damage
				entry.time = currentTick
				return

		var attackerInfo : Dictionary = {
			"attacker": attacker,
			"damage": damage,
			"time": currentTick
		}
		attackers.append(attackerInfo)
		if attackers.size() > AICommons.MaxAttackerCount:
			RemoveOldestAttacker()
		for groupID in followers:
			for follower in followers[groupID]:
				follower.AddAttacker(attacker, damage)
				AI.Refresh(follower)

func ClearAttacker():
	attackers.clear()

func RemoveOldestAttacker():
	attackers.sort_custom(func(a, b): return a.time < b.time)
	attackers.erase(0)

func GetMostValuableAttacker() -> BaseAgent:
	var target : BaseAgent = null
	var maxDamage : int = -1
	for entry in attackers:
		if entry.attacker and SkillCommons.IsInteractable(self, entry.attacker) and entry.damage > maxDamage:
			maxDamage = entry.damage
			target = entry.attacker
	return target

func GetNearbyMostValuableAttacker() -> BaseAgent:
	var target : BaseAgent = null
	var maxDamage : int = -1
	for entry in attackers:
		if entry.attacker and entry.damage > maxDamage and AICommons.IsReachable(self, entry.attacker):
			maxDamage = entry.damage
			target = entry.attacker
	return target

func GetDamageRatio(attacker : BaseAgent) -> float:
	for entry in attackers:
		if entry.attacker == attacker:
			if entry.time > Time.get_ticks_msec() - ActorCommons.AttackTimestampLimit and stat.current.maxHealth > 0:
				return float(entry.damage) / float(stat.current.maxHealth) if entry.damage < stat.current.maxHealth else 1.0
	return 0.0

func AddFollower(follower : BaseAgent):
	if follower and ActorCommons.IsAlive(follower):
		# Set Leader data
		if not follower.data._id in followers:
			followers[follower.data._id] = []
		followers[follower.data._id].push_back(follower)

		# Set Follower data
		follower.leader = self
		for entry in attackers:
			follower.AddAttacker(entry.attacker)

func RemoveFollower(follower : BaseAgent):
	if follower:
		if follower.data._id in followers:
			followers[follower.data._id].erase(follower)
		follower.leader = null

#
func SetSkillCastID(skillID : int):
	super.SetSkillCastID(skillID)
	if skillID == DB.UnknownHash:
		skillSelected = null

func SetData():
	aiBehaviour = data._behaviour
	for skillID in data._skillSet:
		AddSkill(DB.SkillsDB[skillID], data._skillProba[skillID])
	for itemID in data._drops:
		AddItem(DB.ItemsDB[itemID], data._dropsProba[itemID])
	minWanderingSpeed = int(stat.current.walkSpeed / 4)
	maxWanderingSpeed = int(stat.current.walkSpeed / 2)
	super.SetData()

func _exit_tree():
	AI.Stop(self)

func _ready():
	super._ready()
	aiTimer = Timer.new()
	aiTimer.set_name("AiTimer")
	aiTimer.set_one_shot(true)
	Callback.OneShotCallback(aiTimer.ready, AI.Reset, [self])
	add_child.call_deferred(aiTimer)
