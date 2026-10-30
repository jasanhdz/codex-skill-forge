# Codex/OpenCode Forge

Planner -> Generator -> Evaluator para proyectos que usan Codex u OpenCode.

El paquete usa el formato portable de Agent Skills y conserva el flujo del
Forge original de Claude Code:

```text
prompt -> SPEC.md -> codigo + git -> FINDINGS.md -> fixes (maximo 3 passes)
```

## Instalacion

Desde este directorio:

```bash
bash instalar.sh /ruta/a/tu/proyecto
```

Por defecto instala el skill en `.agents/skills/forge`, que es la ubicación
de proyecto de Codex. También crea una copia en `.opencode/skills/forge`
para instalaciones de OpenCode que no descubran `.agents/skills`.

La instalación no ejecuta Forge ni instala dependencias del proyecto.

## Uso en Codex u OpenCode

Abre la herramienta dentro del proyecto y escribe:

```text
$forge "construye un panel de reservas para una barberia"
```

En OpenCode también puedes escribir `/forge` si la interfaz muestra los
skills como comandos. Si no aparece, reinicia la sesión o usa la ruta
`.opencode/skills/forge`.

El skill puede ejecutar el ciclo dentro de la sesión actual. Para contextos
completamente frescos por fase, usa el runner opcional:

```bash
.agents/skills/forge/scripts/forge-run.sh \
  --backend codex \
  "construye un panel de reservas para una barberia"
```

OpenCode:

```bash
.agents/skills/forge/scripts/forge-run.sh \
  --backend opencode \
  "construye un panel de reservas para una barberia"
```

El runner requiere que `codex` u `opencode` estén instalados y autenticados.
Consulta `--help` para opciones y variables de configuración.

El backend `auto` prefiere Codex si ambos comandos están disponibles. Puedes
forzar un binario alternativo:

```bash
FORGE_CODEX_BIN=/ruta/a/codex \
  .agents/skills/forge/scripts/forge-run.sh --backend codex "prompt"
```

## Archivos generados por el ciclo

- `SPEC.md`: contrato de producto creado por Planner.
- `FINDINGS.md`: evidencia de evaluación creada por Evaluator.
- commits Git: checkpoints creados por Generator.

## Seguridad

Revisa `instalar.sh` antes de ejecutarlo. El skill puede pedir a Codex u
OpenCode que ejecute comandos, modifique archivos, instale dependencias y
arranque servidores. No pongas secretos en `SPEC.md` ni en los prompts.

## Limitaciones

El formato de skills es portable, pero la delegación de subagentes y los
permisos son propios de cada host. El runner usa una interfaz CLI mínima y
puede requerir ajustar flags según la versión instalada de Codex u OpenCode.
