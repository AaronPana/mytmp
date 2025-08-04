#!/bin/bash

# =========================
# 🧩 TEMPLATE DE COMANDO
# =========================

# ============
# 🔧 CONFIG
# ============

SCRIPT_NAME=$(basename "$0")
SUBCOMMAND=""
VERBOSE=false
ARGS=()

# Comandos permitidos
VALID_SUBCOMMANDS=("start" "stop" "status")

# Opciones con argumento
# Será útil para validar que no se interponga otra opción entre la bandera y su argumento
VALID_FLAGS_WITH_ARG=("-c" "--config")
VALID_FLAGS_PATTERN=$(IFS="|"; echo "${VALID_FLAGS_WITH_ARG[*]}")

# ===============
# 🧪 FUNCIONES
# ===============

log() {
  [ "$VERBOSE" = true ] && echo "[LOG] $*"
}

error() {
  echo "[ERROR] $*" && exit 1;
}

errorHelp() {
  echo -e "[ERROR] $*\n" && showHelp && exit 1;
}

showHelp() {
  echo "USO:"
  echo "  $SCRIPT_NAME <subcomando> [OPCIONES] [ARGUMENTOS]"
  echo ""
  echo "DESCRIPCIÓN:"
  echo "  Herramienta CLI para gestionar ciertas funcionalidades."
  echo ""
  echo "SUBCOMANDOS:"
  echo "  start                    Inicia el proceso."
  echo "  stop                     Detiene el proceso."
  echo "  status                   Muestra el estado del proceso."
  echo ""
  echo "OPCIONES COMUNES:"
  echo "  -h, --help               Muestra esta ayuda."
  echo "  -v, --verbose            Muestra detalles adicionales."
  echo "  -c, --config <archivo>   Ruta al archivo de configuración."
  echo ""
  echo "NOTAS:"
  echo "  Alguna nota"
  echo ""
  echo "EJEMPLOS:"
  echo "  $SCRIPT_NAME start --config config.yml"
  echo "  $SCRIPT_NAME status -v"
}

validateSubcommand() {
  varSubCmd=$1

  for subcmd in "${VALID_SUBCOMMANDS[@]}"; do
    [[ "$subcmd" == "$varSubCmd" ]] && return 0;
  done

  error "Subcomando invalido: '$varSubCmd'"
}

# ==============
# 🎛️ SUBCOMANDOS
# ==============

cmd_start() {
  log "Iniciando proceso..."
  local cmd=">> $SCRIPT_NAME start"
  
  local CONFIG_FILE=""

  for ((i = 0; i < ${#ARGS[@]}; i++)); do
    case "${ARGS[$i]}" in
      -c|--config)
        CONFIG_FILE="${ARGS[$((i+1))]}"
        [[ -z "$CONFIG_FILE" ]] && error "'${ARGS[$i]}' necesita un argumento";

        cmd+=" ${ARGS[$i]} $CONFIG_FILE"

        ((i++))
        # En caso que la opcion use mas argumentos
        # ((i += N))
        ;;
      *)
        error "Parámetro desconocido: '${ARGS[$i]}'"
        ;;
    esac
  done
  
  log "$cmd"
  echo "🚀 Comando START ejecutado"
  exit 0
}

cmd_stop() {
  log "Deteniendo proceso..."
  
  local cmd=">> $SCRIPT_NAME stop"
  
  log "$cmd"
  echo "🛑 Comando STOP ejecutado"
  exit 0
}

cmd_status() {
  log "Consultando estado..."

  local cmd=">> $SCRIPT_NAME status"

  log "$cmd"
  echo "📊 Comando STATUS ejecutado"
  exit 0
}

# ==============
# 🎛️ OPCIONES
# ==============

# op_config() {}

# ========================
# 🚀 LÓGICA DEL COMANDO
# ========================

# Validar si no se reciben parametros
[[ $# -eq 0 ]] && errorHelp "Falta subcomando";

# Validar si el unico parametro es '-h' o '--help'
[[ $# -eq 1 ]] && [[ "$1" == "-h" || "$1" == "--help" ]] && showHelp && exit 0;

# Validar que el subcomando enviado sea valido
validateSubcommand $1
SUBCOMMAND="$1"
shift

# Validar opcionales
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    *)
      if [[ "$1" =~ ^($VALID_FLAGS_PATTERN)$ ]]; then

          # Validar que a una bandera con argumento no le siga otra bandera cualquiera
          [[ "$2" == -* || -z "$2" ]] && {
            # Errores especificos por su lógica propia
            echo "[ERROR] '$1' requiere un argumento valido"
            [[ -n "$2" ]] && echo "[ERROR] No puede ser '$2'"
            exit 1
          }

          ARGS+=("$1" "$2")
          shift 2
        else
          ARGS+=("$1")
          shift
        fi
      ;;
  esac
done

# Subcomando seleccionado
# Si no debe recibir argumentos u opciones, lanza error
case "$SUBCOMMAND" in
  start)
    cmd_start
    ;;
  stop)
    [[ -n "$ARGS" ]] && error "'$SUBCOMMAND' está recibiendo ${#ARGS[*]} parámetro/s de más: ${ARGS[*]}";
    cmd_stop
    ;;
  status)
    [[ -n "$ARGS" ]] && error "'$SUBCOMMAND' está recibiendo ${#ARGS[*]} parámetro/s de más: ${ARGS[*]}";
    cmd_status
    ;;
  *)
    errorHelp "Subcomando desconocido: $SUBCOMMAND";
    ;;
esac

exit 0
