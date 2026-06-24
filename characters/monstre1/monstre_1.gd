extends CharacterBody3D


# =========================================================
# RÉGLAGES
# =========================================================

@export_category("Déplacement")

@export_range(0.1, 10.0, 0.1)
var vitesse: float = 0.8

@export_range(0.5, 50.0, 0.5)
var distance_patrouille: float = 3.0


@export_category("Délais aléatoires")

@export_range(0.0, 30.0, 0.1)
var delai_minimum: float = 1.0

@export_range(0.0, 30.0, 0.1)
var delai_maximum: float = 5.0


@export_category("Orientation")

# Orientation du monstre lorsqu'il va vers la droite.
# Modifie cette valeur dans l'inspecteur si nécessaire.
@export_range(-360.0, 360.0, 1.0)
var angle_deplacement_droite: float = 90.0

# Orientation lorsque le monstre est immobile.
@export_range(-360.0, 360.0, 1.0)
var angle_idle: float = 90.0


@export_category("Animations")

@export
var animation_idle: StringName = &"hiphop_sadle"

@export
var animation_mouvement: StringName = &"hiphop_hiphop"


# =========================================================
# NŒUDS
# =========================================================

@onready var visuel: Node3D = $Skeleton3D
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var machine_animation: AnimationNodeStateMachinePlayback = (
	animation_tree.get("parameters/playback")
	as AnimationNodeStateMachinePlayback
)


# =========================================================
# VARIABLES INTERNES
# =========================================================

var position_depart_x: float
var direction: float = 1.0

var en_attente: bool = false
var temps_attente: float = 0.0

var animation_actuelle: StringName = &""

var generateur_aleatoire := RandomNumberGenerator.new()

var gravite: float = ProjectSettings.get_setting(
	"physics/3d/default_gravity"
)


# =========================================================
# DÉMARRAGE
# =========================================================

func _ready() -> void:
	position_depart_x = global_position.x

	generateur_aleatoire.randomize()

	animation_tree.active = true

	_orienter_pour_deplacement()
	_jouer_animation(animation_mouvement)


# =========================================================
# BOUCLE PRINCIPALE
# =========================================================

func _physics_process(delta: float) -> void:
	_appliquer_gravite(delta)

	if en_attente:
		_gerer_attente(delta)
	else:
		velocity.x = direction * vitesse
		velocity.z = 0.0

	move_and_slide()

	if not en_attente:
		_verifier_limites()

	_mettre_a_jour_animation()


func _appliquer_gravite(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravite * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0


# =========================================================
# ATTENTE ALÉATOIRE
# =========================================================

func _gerer_attente(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0

	temps_attente -= delta

	if temps_attente <= 0.0:
		en_attente = false
		temps_attente = 0.0

		_orienter_pour_deplacement()
		_jouer_animation(animation_mouvement)


func _commencer_attente(nouvelle_direction: float) -> void:
	direction = nouvelle_direction

	velocity.x = 0.0
	velocity.z = 0.0

	en_attente = true
	temps_attente = _obtenir_delai_aleatoire()

	_orienter_idle()
	_jouer_animation(animation_idle)


func _obtenir_delai_aleatoire() -> float:
	var minimum := minf(delai_minimum, delai_maximum)
	var maximum := maxf(delai_minimum, delai_maximum)

	return generateur_aleatoire.randf_range(minimum, maximum)


# =========================================================
# ALLERS-RETOURS
# =========================================================

func _verifier_limites() -> void:
	var limite_droite := position_depart_x + distance_patrouille
	var limite_gauche := position_depart_x - distance_patrouille

	if direction > 0.0 and global_position.x >= limite_droite:
		_placer_sur_x(limite_droite)
		_commencer_attente(-1.0)

	elif direction < 0.0 and global_position.x <= limite_gauche:
		_placer_sur_x(limite_gauche)
		_commencer_attente(1.0)


func _placer_sur_x(nouvelle_position_x: float) -> void:
	var nouvelle_position := global_position
	nouvelle_position.x = nouvelle_position_x
	global_position = nouvelle_position


# =========================================================
# ORIENTATION
# =========================================================

func _orienter_idle() -> void:
	# Le monstre regarde vers toi pendant son attente.
	visuel.rotation.y = deg_to_rad(angle_idle)


func _orienter_pour_deplacement() -> void:
	var angle_final := angle_deplacement_droite

	if direction < 0.0:
		angle_final += 180.0

	visuel.rotation.y = deg_to_rad(angle_final)


# =========================================================
# ANIMATIONS
# =========================================================

func _mettre_a_jour_animation() -> void:
	if en_attente:
		_jouer_animation(animation_idle)
	else:
		_jouer_animation(animation_mouvement)


func _jouer_animation(nom_animation: StringName) -> void:
	if animation_actuelle == nom_animation:
		return

	if machine_animation == null:
		push_error(
			"Impossible de récupérer la machine d'états de l'AnimationTree."
		)
		return

	animation_actuelle = nom_animation
	machine_animation.travel(nom_animation)
