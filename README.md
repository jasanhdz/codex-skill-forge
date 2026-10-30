# Forge

## Planner -> Generator -> Evaluator

Forge es un skill portable para **Codex** y **OpenCode** que convierte una
idea en una aplicación funcional mediante un ciclo controlado de planificación,
construcción y evaluación.

> **Cero contexto compartido**: los agentes se coordinan escribiendo archivos
> en disco.

```text
        prompt          SPEC.md           app + git
Humano ────────► Planner ───────► Generator ─────────► Evaluator
                                      ▲                    │
                                      └──── FINDINGS.md ◄───┘
                                          (hasta 3 pasadas)
```

## Por qué existe

Un agente que planifica, programa y evalúa su propio trabajo suele pasar por
alto errores. Forge separa esas responsabilidades y convierte el estado del
proceso en archivos que puedes inspeccionar, versionar y reutilizar.

| Problema | Solución de Forge |
| --- | --- |
| Requisitos ambiguos | Planner crea una especificación cerrada |
| Implementación sin checkpoints | Generator trabaja con Git |
| El creador se autoevalúa | Evaluator usa un contexto separado |
| "Terminado" es subjetivo | `SPEC.md` contiene un rubric binario |
| Fallos difíciles de reproducir | `FINDINGS.md` guarda evidencia |
| Contexto excesivo | Cada fase lee solo los archivos necesarios |

## El ciclo completo

```text
┌─────────────────────────────────────────────────────────────┐
│                         FORGE                               │
├─────────────────────────────────────────────────────────────┤
│  1. PLAN                                                    │
│     Planner convierte la idea en SPEC.md                    │
│                              │                              │
│                              ▼                              │
│  2. BUILD                                                   │
│     Generator implementa el producto y crea commits         │
│                              │                              │
│                              ▼                              │
│  3. EVALUATE                                                │
│     Evaluator ejecuta la app y verifica cada criterio        │
│                              │                              │
│                              ▼                              │
│  4. DECIDE                                                  │
│     ¿Hay findings critical o major?                          │
│             │ sí                         │ no                │
│             ▼                            ▼                   │
│       Generator corrige              Forge termina           │
│       y vuelve a evaluar                                      │
└─────────────────────────────────────────────────────────────┘
```

## Los tres roles

| Rol | Lee | Escribe | Nunca debe hacer |
| --- | --- | --- | --- |
| **Planner** | Prompt, `PLAN.md` opcional | `SPEC.md` | Programar o preguntar decisiones de producto |
| **Generator** | `SPEC.md`, `AGENTS.md`, `FINDINGS.md` | Código y commits | Editar `SPEC.md` o `FINDINGS.md` |
| **Evaluator** | `SPEC.md`, aplicación ejecutándose | `FINDINGS.md` | Arreglar código |

## Archivos de coordinación

```text
proyecto/
├── .agents/skills/forge/       # Descubrimiento de Codex
├── .opencode/skills/forge/     # Descubrimiento de OpenCode
├── PLAN.md                     # Contexto opcional escrito por ti
├── SPEC.md                     # Contrato del producto
├── FINDINGS.md                 # Evidencia de la evaluación
└── .git/                       # Checkpoints del Generator
```

### `SPEC.md`

Define qué significa "terminado":

```text
Objetivo → Scope → User flows → Modelo de datos
        → Stack → Assumptions → Rubric verificable
```

### `FINDINGS.md`

Registra el resultado de cada pasada:

```text
10/10 criterios pasan
Abiertos: ninguno
Resueltos: F-01, F-02
```

Cada finding debe incluir ID, severidad, criterio afectado, reproducción y
evidencia.

## Instalación rápida

Forge se instala desde el repositorio público:

```bash
curl -fsSL https://raw.githubusercontent.com/jasanhdz/codex-skill-forge/main/instalar.sh | bash
```

Para instalarlo en una carpeta concreta:

```bash
curl -fsSL https://raw.githubusercontent.com/jasanhdz/codex-skill-forge/main/instalar.sh \
  | bash -s -- /ruta/a/tu/proyecto
```

El instalador crea las dos ubicaciones para maximizar compatibilidad:

```text
.agents/skills/forge/      → Codex
.opencode/skills/forge/    → OpenCode
```

También puedes revisar el instalador antes de ejecutarlo:

```bash
curl -fsSL https://raw.githubusercontent.com/jasanhdz/codex-skill-forge/main/instalar.sh \
  -o /tmp/forge-install.sh
less /tmp/forge-install.sh
bash /tmp/forge-install.sh /ruta/a/tu/proyecto
```

## Uso en Codex

Abre Codex desde la raíz del proyecto:

```bash
cd /ruta/a/tu/proyecto
codex
```

Invoca Forge explícitamente:

```text
$forge "construye un panel de reservas para una barbería"
```

Codex también puede activar el skill automáticamente cuando la petición
coincide con su descripción.

## Uso en OpenCode

Abre OpenCode desde la raíz del proyecto:

```bash
cd /ruta/a/tu/proyecto
opencode
```

Invoca Forge:

```text
/forge "construye un panel de reservas para una barbería"
```

OpenCode puede usar cualquier proveedor configurado, incluido OpenAI. Forge no
depende del proveedor: recibe instrucciones del host y coordina el trabajo por
archivos.

## Ejecución con contextos frescos

El skill puede coordinar las fases dentro de la sesión actual. Para ejecutar
cada fase como una invocación CLI independiente, usa el runner:

```text
Forge runner
      │
      ├── codex exec "Planner..."
      ├── codex exec "Generator..."
      └── codex exec "Evaluator..."
```

Con Codex:

```bash
.agents/skills/forge/scripts/forge-run.sh \
  --backend codex \
  "construye una aplicación de notas minimalista"
```

Con OpenCode:

```bash
.agents/skills/forge/scripts/forge-run.sh \
  --backend opencode \
  "construye una aplicación de notas minimalista"
```

El runner detecta Codex automáticamente si no se indica `--backend`:

```bash
.agents/skills/forge/scripts/forge-run.sh \
  "continúa el build existente"
```

Opciones disponibles:

| Opción | Función |
| --- | --- |
| `--backend auto` | Usa Codex si está disponible; después OpenCode |
| `--backend codex` | Fuerza `codex exec` |
| `--backend opencode` | Fuerza `opencode run` |
| `--max-passes N` | Cambia el máximo de pasadas |
| `--help` | Muestra la ayuda |

## Reglas de parada

```text
                       ┌───────────────┐
                       │ Evaluator     │
                       │ escribe       │
                       │ FINDINGS.md   │
                       └───────┬───────┘
                               │
                  ┌────────────▼────────────┐
                  │ ¿critical o major       │
                  │ abierto y pass < 3?     │
                  └────────────┬────────────┘
                         sí     │      no
                         ▼       │       ▼
                    modo fix     │    terminar
                         │        │
                         └────────┘
```

Forge termina cuando ocurre cualquiera de estas condiciones:

| Condición | Resultado |
| --- | --- |
| No hay findings `critical` o `major` | Build terminado |
| Se alcanzan tres pasadas | Termina con pendientes documentados |
| Una fase falla dos veces | Se detiene y reporta el error |
| Falta `SPEC.md` o `FINDINGS.md` | La fase se reintenta o falla explícitamente |

Los findings `minor` no fuerzan otra pasada si no quedan fallos críticos o
mayores, pero permanecen visibles en `FINDINGS.md`.

## Evaluación con Playwright

El Evaluator verifica la aplicación como usuario real:

| Superficie | Herramienta |
| --- | --- |
| Interfaz web | Playwright |
| APIs | `curl` |
| Sintaxis | Herramientas del proyecto |
| Arranque | Comando real del README o `SPEC.md` |
| Persistencia | Recarga y estado real del navegador |

Si Playwright no está instalado, el Evaluator no debe instalar dependencias sin
autorización. Debe usar `curl` y shell cuando sea posible, y declarar en
`FINDINGS.md` qué criterios de UI no pudo verificar.

## Seguridad

Forge puede pedir a Codex u OpenCode que ejecute comandos y modifique el
proyecto. Antes de usarlo en un repositorio importante:

- Revisa el instalador remoto.
- Usa un repositorio Git limpio.
- No pongas secretos en prompts, `SPEC.md` o `FINDINGS.md`.
- Revisa los permisos de shell del host.
- Inspecciona los commits antes de publicarlos.
- No ejecutes el runner con permisos máximos salvo que sea necesario.

## Requisitos

| Requisito | Uso |
| --- | --- |
| Codex u OpenCode | Host del skill |
| Un modelo configurado | Planner, Generator y Evaluator |
| Git | Checkpoints del Generator |
| Bash | Instalador y runner |
| Playwright | Recomendado para UI |

## Solución de problemas

### Forge no aparece

Comprueba que estás en la raíz del proyecto y reinicia Codex u OpenCode:

```bash
test -f .agents/skills/forge/SKILL.md
test -f .opencode/skills/forge/SKILL.md
```

### El runner no encuentra Codex u OpenCode

Comprueba los binarios:

```bash
command -v codex
command -v opencode
```

Puedes indicar una ruta específica:

```bash
FORGE_CODEX_BIN=/ruta/a/codex \
  .agents/skills/forge/scripts/forge-run.sh --backend codex "prompt"
```

### El Evaluator no crea `FINDINGS.md`

Revisa la salida del agente y confirma que tiene permisos para escribir en la
raíz del proyecto. Forge reintenta la evaluación una vez y se detiene si la
salida sigue faltando.

### El servidor de la aplicación queda activo

El Evaluator debe matar los procesos que inicia. Comprueba manualmente:

```bash
ps aux | grep '[p]ython3 -m http.server'
```

## Estado del proyecto

Forge está publicado en:

https://github.com/jasanhdz/codex-skill-forge

Licencia: MIT.
