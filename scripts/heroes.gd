class_name VeyrakHeroes
extends RefCounted
## Stable IDs are save keys; presentation order may change independently.
const IDS = ["kaerun", "vaelis", "dhoran", "saevra", "nyvara", "ilyra"]
const ATTRIBUTES = ["Might", "Endurance", "Agility", "Precision", "Core", "Resonance"]
const EXPLANATIONS = [
"Might · physical force. Each point adds 5% melee damage.",
"Endurance · resistance to Veyathuun's gravity. Each point adds 20 health.",
"Agility · movement control. Each point adds 2 stamina recovery per second.",
"Precision · weak-point accuracy. Each point adds 1 percentage point of critical chance.",
"Core · biological energy capacity. Each point adds 10 energy and 4% ability power.",
"Resonance · synchronisation with a bonded creature. Each point adds 3% bond-effect strength."
]
const RECORDS = [
{"id":"kaerun", "name":"Kaerun", "role":"VANGUARD", "sex":"Male", "build":"Powerful heavyweight", "unit":"Terrace Defence Corps", "file":"VC-001", "stats":[9,9,4,4,6,4], "weapon":"Powered gauntlets", "resource":"RESOLVE", "background":"A veteran of the lower-city defence terraces, Kaerun earned his command holding a failing evacuation bridge. He believes Veyathuun's strength is measured by the people it protects, not the worlds it commands.", "playstyle":"An aggressive frontline protector. Close the distance, stagger dangerous targets and keep enemies away from your creature. Exceptional health and melee force; limited ranged pressure.", "skills":[["PASSIVE · Unbroken","Dealing or receiving combat damage builds Resolve. Resolve is spent to strengthen heavy attacks."],["TACTICAL · Guardian's Challenge","Challenge nearby enemies and brace against their attacks, creating an opening for allies."],["SIGNATURE · Sovereign Impact","Leap into a targeted area and release a crushing shockwave. Stored Resolve increases its force."]], "paths":"Breaker / Bulwark / Earthshaker", "assessment":"Dependable under pressure. Will disregard orders that abandon civilians."},
{"id":"vaelis", "name":"Vaelis", "role":"RIFTBLADE", "sex":"Male", "build":"Lean and wiry", "unit":"Boundary Intervention Wing", "file":"VC-002", "stats":[5,4,9,8,6,4], "weapon":"Twin phase blades", "resource":"MOMENTUM", "background":"Trained to intercept intruders at the civilisation's outer boundaries, Vaelis returned home with an immaculate service record and a reputation for questioning his superiors. He considers an untested victory a poor measure of strength.", "playstyle":"A mobile melee duellist. Evade attacks, exploit exposed enemies and chain precise strikes. High agility and precision reward clean execution; mistakes are costly.", "skills":[["PASSIVE · Perfect Tempo","Precise dodges and consecutive blade hits build Momentum. Taking a direct hit breaks the chain."],["TACTICAL · Rift Step","Make a short directional phase dash to evade a strike or reach an exposed flank."],["SIGNATURE · Phase Sever","Dash through enemies, leaving a delayed cutting blast along your path."]], "paths":"Duelist / Riftwalker / Executioner", "assessment":"Exceptional initiative. Competitive instincts require supervision."},
{"id":"dhoran", "name":"Dhoran", "role":"FORGEMASTER", "sex":"Male", "build":"Stocky and thickset", "unit":"Civic Forge Directorate", "file":"VC-003", "stats":[7,8,3,6,8,4], "weapon":"Industrial siege cannon", "resource":"HEAT", "background":"Dhoran maintained the gravity anchors beneath Veyathuun's monumental cities before entering military engineering. He trusts structures he can repair and people who keep their promises. His field equipment carries the marks of decades of practical improvements.", "playstyle":"A durable engineer who controls a prepared position. Combine heavy fire with devices and barriers. Strong endurance and core output; repositioning demands planning.", "skills":[["PASSIVE · Thermal Reserve","Heavy fire and active devices generate Heat. Vent it deliberately to avoid an overheat interruption."],["TACTICAL · Pressure Vent","Release stored Heat in a short frontal burst, clearing space around your position."],["SIGNATURE · Bastion Engine","Deploy an anchored engine that shields nearby allies and pulses damage at approaching enemies."]], "paths":"Artificer / Siegebreaker / Architect", "assessment":"Blunt, resourceful and difficult to intimidate. Prioritises structural safety."},
{"id":"saevra", "name":"Saevra", "role":"STORMWARDEN", "sex":"Female", "build":"Tall and muscular", "unit":"High Gravity Guard", "file":"VC-004", "stats":[7,7,5,4,9,4], "weapon":"Gravity polearm", "resource":"GRAVITY CHARGES", "background":"An officer of the High Gravity Guard, Saevra mastered the pressure fields that protect the Council precincts. Her discipline is legendary; her private doubts about the civilisation's certainty of supremacy are absent from official commendations.", "playstyle":"A polearm controller who dictates enemy position. Group targets, interrupt dangerous attacks and follow with heavy area strikes. Excellent core capacity; less suited to distant precision combat.", "skills":[["PASSIVE · Pressure Cycle","Polearm combinations build Gravity Charges, spent on stronger displacement attacks."],["TACTICAL · Gravitic Draw","Pull nearby enemies towards a chosen point, preparing them for a follow-up strike."],["SIGNATURE · Gravity Crown","Lift susceptible enemies briefly, then slam them into a concentrated area. Heavy targets suffer stagger instead."]], "paths":"Crush / Dominion / Tempest", "assessment":"Composed and exacting. Responds poorly to careless use of authority."},
{"id":"nyvara", "name":"Nyvara", "role":"FARSTRIDER", "sex":"Female", "build":"Compact and lean", "unit":"Frontier Survey Office", "file":"VC-005", "stats":[4,4,8,10,5,5], "weapon":"Precision survey rifle", "resource":"FOCUS", "background":"Nyvara charted remote Veyrakian holdings where official maps ended. A gifted observer of unfamiliar habitats, she returned to Veyathuun with specimens, disputed survey reports and an appetite for questions the Council would rather consider settled.", "playstyle":"A precision hunter who wins through distance and preparation. Mark targets, use traps to hold firing lanes and punish exposed weak points. Outstanding precision; vulnerable in a sustained brawl.", "skills":[["PASSIVE · Patient Hunter","Careful aiming and weak-point hits build Focus, strengthening your next charged shot."],["TACTICAL · Anchor Snare","Place a concealed snare that slows an approaching target and reveals its position."],["SIGNATURE · Dead Horizon","Mark a priority target and fire a charged piercing shot through its firing line."]], "paths":"Deadeye / Trapper / Pathfinder", "assessment":"Observant, independent and persistently curious. Excellent field judgement."},
{"id":"ilyra", "name":"Ilyra", "role":"RESONANT", "sex":"Female", "build":"Balanced and athletic", "unit":"Institute of Living Resonance", "file":"VC-006", "stats":[3,5,6,5,8,9], "weapon":"Resonator staff", "resource":"SYNCHRONISATION", "background":"Ilyra studies the relationship between Veyrakian core energy and Veyathuun's native life. Her research treats other organisms as collaborators rather than resources, a position that has earned both influential patrons and quiet institutional resistance.", "playstyle":"A creature partner who coordinates pressure and recovery. Alternate your own attacks with creature commands to build synchronisation. Exceptional bond effects and core power; lower raw melee force.", "skills":[["PASSIVE · Shared Rhythm","Coordinated attacks with your active creature build Synchronisation. Your own staff attacks remain effective independently."],["TACTICAL · Resonant Pulse","Send a directed pulse through the battlefield, striking a target and signalling a creature follow-up."],["SIGNATURE · Convergence","Briefly synchronise with your active creature, empowering both and enabling a joint finishing attack."]], "paths":"Conductor / Symbiosis / Overtone", "assessment":"Empathetic and analytical. Refuses to confuse obedience with understanding."}
]

static func index_of(id: String) -> int:
	return IDS.find(id)

static func record(id: String) -> Dictionary:
	return RECORDS[maxi(0,index_of(id))].duplicate(true)

static func attributes(id: String, equipment: Dictionary = {}) -> Dictionary:
	var result = {}
	var hero = record(id)
	for i in range(ATTRIBUTES.size()):
		var key = ATTRIBUTES[i]
		result[key] = clampi(hero.stats[i] + int(equipment.get(key,0)),1,30)
	return result

static func derived(id: String, level: int = 1, equipment: Dictionary = {}) -> Dictionary:
	var a = attributes(id,equipment)
	var rank = clampi(level,1,30)-1
	return {"Health":100 + 20*a.Endurance + 15*rank,
		"Energy":50 + 10*a.Core,
		"Stamina / sec":10 + 2*a.Agility,
		"Critical chance":2 + a.Precision,
		"Melee power":(1.0 + .05*a.Might)*(1.0+.035*rank),
		"Ability power":(1.0 + .04*a.Core)*(1.0+.035*rank),
		"Bond strength":1.0 + .03*a.Resonance}
