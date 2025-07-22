# 🛠️ Bash Command Template

Este proyecto es una plantilla en **Bash** para crear comandos personalizados con soporte para subcomandos, flags con argumentos, ayuda integrada y logging básico.  
Su objetivo es permitir que cualquier persona pueda adaptar fácilmente este script a sus necesidades creando una herramienta de línea de comandos reutilizable.

## 📦 Requisitos

- ✅ Sistema operativo **Linux**
- ✅ Intérprete de comandos **Bash**
- ✅ Permisos de superusuario para mover el script a `/usr/local/bin` (opcional pero recomendado)

## 📂 Estructura general del script

```bash
# 🧩 TEMPLATE DE COMANDO

# 🔧 CONFIG
VALID_SUBCOMMANDS=()        # Lista de subcomandos permitidos
VALID_FLAGS_WITH_ARG=()     # Lista de flags que requieren argumentos

# 🧪 FUNCIONES
log()                       # Función base para logging
showHelp()                  # Muestra la ayuda general del comando
validateSubcommand()        # Valida que el subcomando ingresado esté permitido

# 🎛️ SUBCOMANDOS
cmd_<subcomando>()          # Una función por cada subcomando definido que contiene la lógica propia del mismo

# 🎚️ OPCIONES
# Aquí se pueden agregar funciones auxiliares específicas de una opción de un subcomando, si lo necesitás.

# 🚀 LÓGICA DEL COMANDO
# 1. Validación de argumentos iniciales (help, subcomando inexistente, etc.)
# 2. Procesamiento de flags opcionales generales
# 3. Ejecución de la función asociada al subcomando seleccionado

```

## 🚀 Pasos para crear tu propio comando

### 🔧 A nivel del archivo

1. **Cambiar el nombre del archivo**  
  Renombrá `mytmp.sh` con el nombre de tu comando personalizado, **sin la extensión `.sh`**.  
  Por ejemplo:

    ```bash
    mv mytmp.sh mycli
    ```

2. **Darle permiso de ejecución**  

    ```bash
    chmod +x mycli
    ```

3. **Moverlo a `/usr/local/bin` para que esté disponible globalmente**  

    ```bash
    sudo mv mycli /usr/local/bin/
    ```

**Ahora podés usar `mycli` como cualquier otro comando.**  

---

### ⚙️ A nivel del contenido

1. **Definir los subcomandos válidos**  
  En la sección superior del script `🔧 CONFIG`, modificá la lista `VALID_SUBCOMMANDS` para agregar los subcomandos que quieras que tu herramienta soporte:

    ```bash
    VALID_SUBCOMMANDS=("start" "stop" "status" "deploy" "build")
    ```

2. **Definir flags que requieren argumentos**  
  Utilizá `VALID_FLAGS_WITH_ARG` para definir qué banderas de cualquier `subcomando` aceptan uno o varios argumentos:

    ```bash
    VALID_FLAGS_WITH_ARG=("-c" "--config" "-o" "--output")
    ```

3. **Modificar la función `showHelp`**  
  En la sección `🧪 FUNCIONES`, adaptá la función `showHelp` para que muestre la descripción de tu comando, sus subcomandos, flags, y ejemplos de uso.  
  Esto actúa como la documentación integrada de tu herramienta.

4. **Agregar funciones para cada subcomando**  
  En la sección `🎛️ SUBCOMANDOS`, agregá una función por cada subcomando con el prefijo `cmd_`.  
  Por ejemplo, para un subcomando `build`:

    ```bash
    cmd_build() {
      # Lógica del comando
    }
    ``` 

    Estas funciones pueden validar flags propias usando la varibale global del script `ARGS` y crear varibles locales para implementar lógica propia del subcomando:

    ```bash
    local CONFIG_FILE=""

    # Recorrer los argumentos restantes en busca de flags propias del subcomando
    for ((i = 0; i < ${#ARGS[@]}; i++)); do
      case "${ARGS[$i]}" in
        -c|--config)
          CONFIG_FILE="${ARGS[$((i+1))]}"
          [[ -z "$CONFIG_FILE" ]] && error "'${ARGS[$i]}' necesita un argumento";

          ((i++))
          # En caso que la opcion use mas argumentos
          # ((i += N))
          ;;
        *)
          error "Parámetro desconocido: '${ARGS[$i]}'"
          ;;
      esac
    done
    ```

5. **Agregar logs personalizados**  
  Dentro de cada `cmd_<subcomando>`, se recomienda usar las funciones `log`, `error`, `errorHelp` o similares para imprimir mensajes informativos, advertencias y errores de ser necesario:

    ```bash
    log "Iniciando proceso..."
    local cmd=">> $SCRIPT_NAME start"
    # Lógica del comando
      error "Parámetro desconocido: '${ARGS[$i]}'"
      ...
    log "$cmd"
    ```
    Notesé que un `log` útil puede ser mostrar el comando que se ejecutó, incluso podés agregar las banderas usadas y sus argumentos.

6. **Agregar validación de flags globales (opcionales)**  
  En la sección `🚀 LÓGICA DEL COMANDO` hay un apartado `# Validar opcionales`, agregá aquí aquellas banderas que apliquen globalmente y no sean específicas de un subcomando. Por ejemplo:

    ```bash
    case "$1" in
      -v|--verbose)
      VERBOSE=true
      shift
      ;;
    ```

7. **Agregar elección de subcomandos a ejecutar**  
  En la sección `🚀 LÓGICA DEL COMANDO` hay un apartado `# Comando seleccionado`, vinculá aquí el nombre del subcomando con su función creada en el paso **4**. Por ejemplo:

    ```bash
    case "$SUBCOMMAND" in
      build) cmd_build ;;
      # Resto de subcomandos 
    esac
    ```

    Considerar que si el subcomando no debe recibir opciones y/o argumentos, esto debe validarse:

    ```bash
    subcommand)
      [[ -n "$ARGS" ]] && error "'$SUBCOMMAND' está recibiendo ${#ARGS[*]} parámetro/s de más: ${ARGS[*]}";
      cmd_subcommand
      ;;
    ```

## 🧪 Ejemplos de uso

```bash
# Mostrar ayuda
mycli -h
mycli --help

# Ejecutar un subcomando
mycli status

# Usar flags opcionales
mycli start -c config.yml
mycli stop -v
```

## 👤 Autor

Desarrollado por [Aarón Paná ✨]  
¿Dudas o sugerencias? ¡Hablame con confianza!

<!-- ## ⚖️ Licencia -->

<!-- Este proyecto está bajo la licencia MIT. Usalo, modificalo y compartilo con libertad. -->
