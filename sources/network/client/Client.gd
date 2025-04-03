extends NetInterface
class_name NetClient

#
func WarpPlayer(mapID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var mapData : FileData = DB.MapsDB.get(mapID, null)
		if mapData:
			Launcher.Map.EmplaceMapNode(mapID)
			PushNotification(mapData._name, _rpcID)

func EmotePlayer(playerID : int, emoteID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	var entity : Entity = Entities.Get(playerID)
	if entity && entity.get_parent() && entity.interactive:
		entity.interactive.DisplayEmote.call_deferred(emoteID)

func AddPlayer(agentID : int, entityType : ActorCommons.Type, shape : int, spirit : int, currentShape : int, nick : String, velocity : Vector2, position : Vector2i, orientation : Vector2, state : ActorCommons.State, skillCastID : int, level : int, health : int, hairstyle : int, haircolor : int, gender : ActorCommons.Gender, race : int, skintone : int, equipments : Dictionary, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Launcher.Map.AddEntity(agentID, entityType, shape, spirit, currentShape, nick, velocity, position, orientation, state, skillCastID)
		if entity:
			UpdatePublicStats(agentID, level, health, hairstyle, haircolor, gender, race, skintone, currentShape, _rpcID)
			RefreshEquipments(agentID, equipments, _rpcID)

func AddEntity(agentID : int, entityType : ActorCommons.Type, currentShape : int, velocity : Vector2, position : Vector2i, orientation : Vector2, state : ActorCommons.State, skillCastID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		Launcher.Map.AddEntity(agentID, entityType, currentShape, DB.UnknownHash, currentShape, "", velocity, position, orientation, state, skillCastID)

func RemoveEntity(agentID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		Launcher.Map.RemoveEntity(agentID)

func FullUpdateEntity(ridAgent : int, velocity : Vector2, position : Vector2, orientation : Vector2, state : ActorCommons.State, skillCastID : int):
	if Launcher.Map:
		Launcher.Map.FullUpdateEntity(ridAgent, velocity, position, orientation, state, skillCastID)

func UpdateEntity(ridAgent : int, velocity : Vector2, position : Vector2):
	if Launcher.Map:
		Launcher.Map.UpdateEntity(ridAgent, velocity, position)

func ChatAgent(ridAgent : int, text : String, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(ridAgent)
		if entity && entity.get_parent():
			if entity.type == ActorCommons.Type.PLAYER && Launcher.GUI:
				Launcher.GUI.chatContainer.AddPlayerText(entity.nick, text)
			if entity.interactive:
				entity.interactive.DisplaySpeech.call_deferred(text)

func ToggleContext(enable : bool, _rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.dialogueWindow.Toggle(enable)

func ContextText(author : String, text : String, _rpcID : int = NetworkCommons.RidSingleMode):
	if not author.is_empty():
		Launcher.GUI.dialogueWindow.AddName(author)
	Launcher.GUI.dialogueWindow.AddDialogue(text)
	Launcher.GUI.dialogueWindow.ToggleButton(false, "")

func ContextContinue(_rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.dialogueWindow.ToggleButton(true, "Next")

func ContextClose(_rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.dialogueWindow.ToggleButton(true, "Close")

func ContextChoice(texts : PackedStringArray, _rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.dialogueWindow.AddChoices(texts)

func TargetAlteration(ridAgent : int, targetID : int, value : int, alteration : ActorCommons.Alteration, skillID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(targetID)
		var caller : Entity = Entities.Get(ridAgent)
		if caller && entity && entity.get_parent() and entity.interactive:
			entity.interactive.DisplayAlteration.call_deferred(entity, caller, value, alteration, skillID)

func Casted(agentID : int, skillID : int, cooldown : float, _rpcID : int = NetworkCommons.RidSingleMode):
	var entity : Entity = Entities.Get(agentID)
	if entity and entity.get_parent() and entity.interactive:
		entity.interactive.DisplaySkill.call_deferred(entity, skillID, cooldown)

func Morphed(ridAgent : int, morphID : int, morphed : bool, _rpcID : int = NetworkCommons.RidSingleMode):
	var entity : Entity = Entities.Get(ridAgent)
	if entity:
		var morphData : EntityData = DB.EntitiesDB.get(morphID, null)
		if morphData:
			entity.stat.Morph(morphData)
			entity.SetVisual(morphData, morphed)

func UpdatePublicStats(ridAgent : int, level : int, health : int, hairstyle : int, haircolor : int, gender : ActorCommons.Gender, race : int, skintone : int, currentShape : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(ridAgent)
		if entity and entity.stat:
			entity.stat.level			= level
			entity.stat.health			= health
			entity.stat.currentShape	= currentShape

			var newHair : bool = entity.stat.hairstyle != hairstyle or entity.stat.haircolor != haircolor
			entity.stat.hairstyle		= hairstyle
			entity.stat.haircolor		= haircolor
			if newHair and entity.visual:
				entity.visual.SetHair()

			var newBody : bool = entity.stat.gender != gender or entity.stat.race != race or entity.stat.skintone != skintone
			entity.stat.gender			= gender
			entity.stat.race			= race
			entity.stat.skintone		= skintone
			if newBody and entity.visual:
				entity.visual.SetBody()
				entity.visual.SetFace()

			entity.stat.RefreshVitalStats()

func UpdatePrivateStats(experience : int, gp : int, mana : int, stamina : int, karma : int, weight : float, shape : int, spirit : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player and Launcher.Player.stat:
		Launcher.Player.stat.experience		= experience
		Launcher.Player.stat.gp				= gp
		Launcher.Player.stat.mana			= mana
		Launcher.Player.stat.stamina		= stamina
		Launcher.Player.stat.karma			= karma
		Launcher.Player.stat.weight			= weight
		Launcher.Player.stat.shape			= shape
		Launcher.Player.stat.spirit			= spirit
		Launcher.Player.stat.RefreshVitalStats()

func UpdateAttributes(strength : int, vitality : int, agility : int, endurance : int, concentration : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player and Launcher.Player.stat:
		Launcher.Player.stat.strength		= strength
		Launcher.Player.stat.vitality		= vitality
		Launcher.Player.stat.agility		= agility
		Launcher.Player.stat.endurance		= endurance
		Launcher.Player.stat.concentration	= concentration
		Launcher.Player.stat.RefreshAttributes()

func LevelUp(ridAgent : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(ridAgent)
		if entity and entity.get_parent() and entity.stat:
			entity.LevelUp()

func ItemAdded(itemID : int, customfield : StringName, count : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player:
		var cell : BaseCell = DB.GetItem(itemID, customfield)
		if cell and Launcher.Player.inventory.PushItem(cell, count):
			if Launcher.GUI:
				Launcher.GUI.pickupPanel.AddLast(cell, count)
				Launcher.GUI.inventoryWindow.RefreshInventory()
			cell.used.emit()

func ItemRemoved(itemID : int, customfield : StringName, count : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player:
		var cell : BaseCell = DB.GetItem(itemID, customfield)
		if cell:
			Launcher.Player.inventory.PopItem(cell, count)
			CellTile.RefreshShortcuts(cell)
			if Launcher.GUI and Launcher.GUI.inventoryWindow:
				Launcher.GUI.inventoryWindow.RefreshInventory()
			cell.used.emit()

func ItemEquiped(ridAgent : int, itemID : int, customfield : StringName, state : bool, _rpcID : int = NetworkCommons.RidSingleMode):
	var entity : Entity = Entities.Get(ridAgent)
	if entity:
		var cell : ItemCell = DB.GetItem(itemID, customfield)
		if cell:
			if state:
				entity.inventory.EquipItem(cell)
			else:
				entity.inventory.UnequipItem(cell)

			entity.visual.SetEquipment(cell.slot)
			if entity == Launcher.Player:
				Launcher.GUI.inventoryWindow.RefreshInventory()
				cell.used.emit()

func RefreshInventory(cells : Array[Dictionary], _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player and Launcher.Player.inventory:
		Launcher.Player.inventory.ImportInventory(cells)
	if Launcher.GUI and Launcher.GUI.inventoryWindow:
		Launcher.GUI.inventoryWindow.RefreshInventory()

func RefreshEquipments(ridAgent : int, equipments : Dictionary, _rpcID : int = NetworkCommons.RidSingleMode):
	var entity : Entity = Entities.Get(ridAgent)
	if entity:
		if entity.inventory:
			entity.inventory.ImportEquipment(equipments)
		if entity == Launcher.Player and Launcher.GUI and Launcher.GUI.inventoryWindow:
			Launcher.GUI.inventoryWindow.RefreshInventory()

func DropAdded(dropID : int, itemID : int, customfield : StringName, pos : Vector2, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		Launcher.Map.AddDrop(dropID, DB.GetItem(itemID, customfield), pos)

func DropRemoved(dropID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		Launcher.Map.RemoveDrop(dropID)

#
func PushNotification(notif : String, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.GUI:
		Launcher.GUI.notificationLabel.AddNotification(notif)

#
func AuthError(err : NetworkCommons.AuthError, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.GUI:
		Launcher.GUI.loginPanel.FillWarningLabel(err)
		if err == NetworkCommons.AuthError.ERR_OK:
			FSM.EnterState(FSM.States.CHAR_SCREEN)

func CharacterError(err : NetworkCommons.AuthError, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.GUI:
		Launcher.GUI.characterPanel.FillWarningLabel(err)

func CharacterInfo(info : Dictionary, equipment : Dictionary, _rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.characterPanel.AddCharacter(info, equipment)

# Progress
func UpdateSkill(skillID : int, level : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player:
		var skill : SkillCell = DB.GetSkill(skillID)
		if skill:
			Launcher.Player.progress.AddSkill(skill, 1.0, level)
			if Launcher.GUI and Launcher.GUI.skillWindow:
				Launcher.GUI.skillWindow.RefreshSkills()

func UpdateBestiary(mobID : int, count : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player:
		Launcher.Player.progress.AddBestiary(mobID, count)
		if Launcher.GUI and Launcher.GUI.progressWindow:
			Launcher.GUI.progressWindow.RefreshBestiary(mobID)

func UpdateQuest(questID : int, state : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player:
		Launcher.Player.progress.SetQuest(questID, state)
		if Launcher.GUI and Launcher.GUI.progressWindow:
			Launcher.GUI.progressWindow.RefreshQuest(questID)

func RefreshProgress(skills : Dictionary, quests : Dictionary, bestiary : Dictionary, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player:
		for skill in skills:
			UpdateSkill(skill, skills[skill])
		for quest in quests:
			UpdateQuest(quest, quests[quest])
		for mob in bestiary:
			UpdateBestiary(mob, bestiary[mob])

#
func ConnectServer():
	if not isOffline:
		uniqueID = multiplayerAPI.get_unique_id()
	if Launcher.GUI and Launcher.GUI.loginPanel:
		Launcher.GUI.loginPanel.EnableButtons.call_deferred(true)
	Peers.AddPeer(NetworkCommons.RidSingleMode, NetworkCommons.UseWebSocket and not NetworkCommons.UseENet)

func DisconnectServer():
	uniqueID = NetworkCommons.RidDefault
	Launcher.Mode(true, true)
	FSM.EnterState(FSM.States.LOGIN_SCREEN)
	Peers.RemovePeer(NetworkCommons.RidSingleMode)

func ConnectionFailed():
	DisconnectServer()
	AuthError(NetworkCommons.AuthError.ERR_SERVER_UNREACHABLE)

#
func _enter_tree():
	if isOffline:
		uniqueID = NetworkCommons.RidSingleMode
		ConnectServer.call_deferred()
		return

	if not multiplayerAPI.connected_to_server.is_connected(ConnectServer):
		multiplayerAPI.connected_to_server.connect(ConnectServer)
	if not multiplayerAPI.connection_failed.is_connected(ConnectionFailed):
		multiplayerAPI.connection_failed.connect(ConnectionFailed)
	if not multiplayerAPI.server_disconnected.is_connected(DisconnectServer):
		multiplayerAPI.server_disconnected.connect(DisconnectServer)

	var serverAddress : String = NetworkCommons.LocalServerAddress if isLocal else NetworkCommons.ServerAddress
	var serverPort : int = NetworkCommons.WebSocketPort if useWebSocket else NetworkCommons.ENetPort
	if isTesting:
		serverAddress = NetworkCommons.LocalServerAddress if isLocal else NetworkCommons.ServerAddressTesting
		serverPort = NetworkCommons.WebSocketPortTesting if useWebSocket else NetworkCommons.ENetPortTesting

	var ret : Error = FAILED
	var tlsOptions : TLSOptions = TLSOptions.client_unsafe()
	if useWebSocket:
		var prefix : String = "ws://" if isLocal else "wss://"
		ret = currentPeer.create_client(prefix + serverAddress + ":" + str(serverPort), tlsOptions)
	else:
		ret = currentPeer.create_client(serverAddress, serverPort)
		if ret == OK and not isLocal:
			ret = currentPeer.host.dtls_client_setup(serverAddress, tlsOptions)

	assert(ret == OK, "Client could not connect, please check the server adress %s and port number %d" % [serverAddress, serverPort])
	if ret == OK:
		currentPeer.set_target_peer(MultiplayerPeer.TARGET_PEER_SERVER)
		multiplayerAPI.multiplayer_peer = currentPeer

		Util.PrintLog("Client", "Initialized with: %s, %s, %s, %s" % [
			"WebSocket" if useWebSocket else "ENet",
			"Offline" if isOffline else "Online",
			"Local" if isLocal else "Public",
			"Testing" if isTesting else "Release"
		])

func Destroy():
	if multiplayerAPI.connected_to_server.is_connected(ConnectServer):
		multiplayerAPI.connected_to_server.disconnect(ConnectServer)
	if multiplayerAPI.connection_failed.is_connected(ConnectionFailed):
		multiplayerAPI.connection_failed.disconnect(ConnectionFailed)
	if multiplayerAPI.server_disconnected.is_connected(DisconnectServer):
		multiplayerAPI.server_disconnected.disconnect(DisconnectServer)

	super.Destroy()
