# Neovim Cheat Sheet

`<leader>` = `Space`

## Perfil `agents`

Iniciar el perfil con la carpeta raíz de proyectos:

```bash
NVIM_PROJECTS_ROOT="$HOME/proyectos" nvim --cmd 'let g:nvim_profile = "agents"'
```

Estructura esperada:

```text
NVIM_PROJECTS_ROOT/
  proyecto/
    runtimes/
      workspace/
```

Cada workspace usa una sesión tmux persistente. Cada agente o terminal es una ventana de esa sesión.

### Globales

- `<leader>aa`: abrir el panel de proyectos, workspaces y sesiones
- `<leader>as`: iniciar o reutilizar `aicontext console` para el proyecto seleccionado
- `<leader>ax`: detener el proceso `aicontext console` del proyecto seleccionado
- `<leader>aD`: cerrar todas las sesiones tmux de agentes y sus terminales
- `<C-w>h/j/k/l` o `<C-w>` con flechas: cambiar entre paneles, también desde una terminal
- `<C-\><C-n>`: salir al modo normal de la terminal para consultar el historial
- `<leader>t<Esc>`: salir del modo terminal sin cerrar la sesión

### Terminal central

- `<C-\><C-n>`: entrar en modo normal para desplazarse por las últimas 10.000 líneas
- `j`/`k`, `<C-u>`/`<C-d>` o `/`: navegar o buscar en el historial desde el modo normal
- `i`: volver al modo de entrada de la terminal

### Panel `Agents`

- `Enter` o clic: expandir proyecto/workspace o enfocar la sesión tmux seleccionada
- `q`: cerrar el panel `Agents` sin detener sesiones
- `p`: crear un proyecto y su carpeta `runtimes`
- `D`: borrar recursivamente el proyecto seleccionado tras confirmación
- `n`: abrir Windows Terminal con Neovim en el perfil `default` dentro del workspace
- `r`: renombrar la sesión tmux seleccionada
- `R`: refrescar proyectos, workspaces y sesiones
- `o`: crear una ventana tmux con `opencode` en el workspace seleccionado
- `c`: abrir `code .` en el workspace seleccionado
- `t`: crear una terminal normal en el workspace seleccionado
- `d`: cerrar la sesión tmux seleccionada
- `i`: mostrar el nombre completo del proyecto seleccionado
- `h`: mostrar ayuda contextual del panel
- `a`: iniciar o reutilizar `aicontext console` para el proyecto seleccionado
- `x`: detener `aicontext console` para el proyecto seleccionado

### Comandos

- `:Agents`: abrir o enfocar el panel
- `:AgentsAicontextStart`: iniciar o reutilizar `aicontext` del proyecto seleccionado
- `:AgentsAicontextStop`: detener `aicontext` del proyecto seleccionado
- `:AgentsCloseAll`: cerrar todas las sesiones tmux gestionadas por el perfil

## Perfil `default`

Iniciar con `nvim`. Los atajos de las siguientes secciones no están disponibles en el perfil `agents`.

### Esquema general

- `<leader>b`: buffers
- `<leader>c`: code
- `<leader>d`: diagnostics
- `<leader>e`: explorer
- `<leader>f`: find
- `<leader>g`: git
- `<leader>i`: abrir externamente
- `<leader>m`: markdown
- `<leader>r`: rest
- `<leader>t`: terminal
- `<leader>w`: windows

### Buffers

- `<leader>ba`: cerrar todos los buffers preservando el layout
- `<leader>bb`: listar buffers
- `<leader>bd`: cerrar buffer actual preservando el layout
- `<leader>bn`: siguiente buffer
- `<leader>bp`: buffer anterior

### Code

- `K`: hover de LSP
- `<leader>ca`: code action
- `<leader>cd`: definition
- `<leader>cf`: format (LSP)
- `<leader>ci`: implementation
- `<leader>cn`: rename
- `<leader>co`: overview LSP en `Trouble`
- `<leader>cr`: references
- `<leader>cs`: document symbols en `Trouble`
- `<leader>ct`: type definition

### Diagnostics

- `<leader>db`: diagnósticos del buffer actual en `Trouble`
- `<leader>dd`: diagnósticos globales en `Trouble`
- `<leader>df`: diagnóstico flotante de la línea
- `<leader>dl`: pasar diagnósticos a loclist
- `<leader>dq`: quickfix en `Trouble`

### Explorer

- `<leader>ee`: toggle `neo-tree`
- `<leader>ef`: revelar fichero actual en `neo-tree`
- `<leader>eg`: abrir `neo-tree` en vista Git
- `<leader>ep`: copiar ruta absoluta del nodo seleccionado en `neo-tree`
- `<leader>eP`: copiar ruta relativa (al cwd) del nodo seleccionado en `neo-tree`

### Find

- `<leader>ff`: buscar ficheros
- `<leader>fg`: buscar texto en proyecto
- `<leader>fc`: paleta de comandos
- `<leader>fh`: help tags
- `<leader>ft`: buscar `TODO/FIXME/NOTE`

### Git

- `[h`: hunk anterior
- `]h`: siguiente hunk
- `<leader>gb`: blame línea
- `<leader>gD`: diff del buffer
- `<leader>gq`: salir del modo diff
- `<leader>gp`: preview hunk
- `<leader>gr`: reset hunk
- `<leader>gs`: stage hunk
- `<leader>gS`: stage buffer
- `<leader>gu`: undo stage hunk

### Abrir externamente

- `<leader>io`: abrir el archivo actual con la aplicación predeterminada del sistema

### Markdown

- `<leader>mp`: abrir/cerrar `markdown-preview.nvim` en el navegador

### REST

- `<leader>rr`: ejecutar petición bajo el cursor en fichero `.http` o `.rest`
- `<leader>ra`: ejecutar todas las peticiones del fichero
- `<leader>ro`: abrir panel de respuesta de `Kulala`
- `<leader>rc`: cerrar panel de respuesta de `Kulala`
- `<leader>re`: seleccionar entorno activo para el fichero `.http`

### Terminal

- `<leader>tt`: terminal flotante 1 (`id=100`)
- `<leader>t1t`: terminal flotante 2 (`id=101`)
- `<leader>t2t`: terminal flotante 3 (`id=102`)
- `<leader>t3t`: terminal flotante 4 (`id=103`)
- `<leader>t4t`: terminal flotante 5 (`id=104`)
- `<leader>th`: terminal horizontal 1 (`id=200`)
- `<leader>t1h`: terminal horizontal 2 (`id=201`)
- `<leader>t2h`: terminal horizontal 3 (`id=202`)
- `<leader>t3h`: terminal horizontal 4 (`id=203`)
- `<leader>t4h`: terminal horizontal 5 (`id=204`)
- `<leader>tv`: terminal vertical 1 (`id=300`)
- `<leader>t1v`: terminal vertical 2 (`id=301`)
- `<leader>t2v`: terminal vertical 3 (`id=302`)
- `<leader>t3v`: terminal vertical 4 (`id=303`)
- `<leader>t4v`: terminal vertical 5 (`id=304`)
- `<C-\\>`: abrir/cerrar terminal rápida
- `<leader>t<Esc>`: salir de modo terminal a modo normal
- `i`: volver a modo inserción dentro de la terminal
- `a`: volver a modo inserción dentro de la terminal

Las terminales nuevas se crean desde la raíz del proyecto detectada para el buffer actual.
Después, esa terminal concreta mantiene su propio directorio mientras siga viva.

### Windows

- `<leader>wh`: mover foco a ventana izquierda
- `<leader>wj`: mover foco a ventana inferior
- `<leader>wk`: mover foco a ventana superior
- `<leader>wl`: mover foco a ventana derecha
- `<leader>wq`: cerrar ventana actual
- `<leader>ws`: split horizontal
- `<leader>wv`: split vertical

### TODO comments

- `[t`: comentario TODO anterior
- `]t`: siguiente comentario TODO

### Completion (`nvim-cmp`)

- `<C-Space>`: abrir completion
- `<CR>`: confirmar sugerencia
- `<Tab>`: siguiente sugerencia o saltar snippet
- `<S-Tab>`: sugerencia anterior o volver en snippet

### Treesitter

- `<C-=>`: iniciar o expandir selección incremental
- `<C-+>`: expandir por scope
- `<C-->`: reducir selección

## Defaults De Plugins (`default`)

### Comment.nvim

- `gcc`: comentar/descomentar línea
- `gc` en visual: comentar selección
- `gc{motion}`: comentar movimiento
- `gbc`: comentario tipo bloque en línea
- `gb` en visual: comentario tipo bloque

### nvim-surround

- `ysiw"`: rodear palabra con `"`
- `ysiw)`: rodear palabra con `()`
- `ds"`: eliminar surround `"`
- `cs"'`: cambiar `"` por `'`
- `S` en visual: añadir surround a selección

### Neo-tree

Atajos útiles dentro del panel, usando defaults del plugin:

- `Enter`: abrir fichero o carpeta
- `a`: crear fichero/carpeta
- `d`: borrar
- `r`: renombrar
- `q`: cerrar panel
- `R`: refrescar

## Comandos (`default`)

### Neovim

- `:w`: guardar
- `:q`: cerrar ventana actual
- `:wq`: guardar y salir
- `:qa`: salir de todo
- `:qa!`: salir sin guardar
- `:e <ruta>`: abrir fichero
- `:bd`: cerrar buffer
- `:noh`: quitar resaltado de búsqueda
- `:split`: split horizontal
- `:vsplit`: split vertical
- `:terminal`: terminal nativa de Neovim
- `:checkhealth`: diagnóstico general
- `:messages`: ver mensajes recientes

### Plugins y tooling

- `:Lazy`: gestor de plugins
- `:Mason`: instalador de LSP/tools
- `:LspInfo`: estado de LSP
- `:MarkdownPreview`: abrir preview de Markdown en navegador
- `:MarkdownPreviewStop`: cerrar preview activa
- `:MarkdownPreviewToggle`: abrir/cerrar preview
- `:Telescope`: lanzar Telescope manualmente
- `:Neotree toggle left`: abrir/cerrar árbol
- `:Trouble diagnostics toggle`: diagnósticos en panel
- `:ToggleTerm`: abrir terminal con toggleterm
- `:TodoTelescope`: buscar TODOs
- `:lua require("kulala").run()`: ejecutar petición actual

## Atajos Nativos Comunes

### Movimiento

- `gg`: ir al inicio del fichero
- `G`: ir al final
- `0`: inicio de línea
- `^`: primer carácter no blanco
- `$`: fin de línea
- `w`: siguiente palabra
- `b`: palabra anterior
- `%`: saltar entre pares `()`, `{}`, `[]`

### Edición

- `u`: undo
- `Ctrl-r`: redo
- `dd`: borrar línea
- `yy`: copiar línea
- `p`: pegar después
- `P`: pegar antes
- `>>`: indentar línea
- `<<`: desindentar línea
- `ciw`: cambiar palabra actual
- `di(`: borrar dentro de `()`

### Búsqueda

- `/texto`: buscar hacia delante
- `?texto`: buscar hacia atrás
- `n`: siguiente coincidencia
- `N`: coincidencia anterior
- `*`: buscar palabra bajo cursor

### Ventanas y buffers

- `Ctrl-w h/j/k/l`: moverse entre ventanas
- `Ctrl-w s`: split horizontal
- `Ctrl-w v`: split vertical
- `Ctrl-w c`: cerrar ventana
- `:bnext`: siguiente buffer
- `:bprev`: buffer anterior

## Flujos Recomendados (`default`)

### Buscar y abrir

1. `<leader>ff` para ficheros.
2. `<leader>fg` para texto en el proyecto.
3. `<leader>ee` para el árbol.
4. `<leader>ef` para revelar el fichero actual.

### Código

1. `K` para hover.
2. `<leader>cd` para definition.
3. `<leader>cf` para format.
4. `<leader>ci` para implementation.
5. `<leader>cr` para referencias.
6. `<leader>ca` para code action.
7. `<leader>cn` para rename.

### Diagnósticos

1. `<leader>df` para el error de la línea.
2. `<leader>dd` para todos los diagnósticos.
3. `<leader>db` para solo el buffer actual.
4. `<leader>dl` para loclist.
5. `<leader>dq` para quickfix.

### Git

1. `<leader>ee` para ver archivos modificados en `neo-tree`.
2. `[h` y `]h` para navegar cambios.
3. `<leader>gp` para preview.
4. `<leader>gs` para stage parcial.
5. `<leader>gD` para diff del buffer.
6. `<leader>gq` para salir del modo diff.
7. `<leader>gb` para blame.

### Terminal

1. `<leader>tt` para la terminal flotante 1.
2. `<leader>t1t`, `<leader>t2t`, `<leader>t3t`, `<leader>t4t` para las otras flotantes.
3. `<leader>th` para la terminal horizontal 1.
4. `<leader>t1h`, `<leader>t2h`, `<leader>t3h`, `<leader>t4h` para las otras horizontales.
5. `<leader>tv` para la terminal vertical 1.
6. `<leader>t1v`, `<leader>t2v`, `<leader>t3v`, `<leader>t4v` para las otras verticales.

## Cambios respecto al esquema anterior

- `neo-tree` ya no usa `<leader>e` y `<leader>n`; ahora usa `<leader>ee` y `<leader>ef`.
- `Telescope` ya no usa `<C-p>`, `<C-f>`, `<C-S-p>`; ahora usa `<leader>ff`, `<leader>fg`, `<leader>fc`.
- LSP principal pasa de `gr*` a `<leader>c*`, excepto `grr` que se mantiene.
- `Trouble` pasa de `<leader>x*` a `<leader>d*` y parte de `<leader>c*`.
- Git cambia el diff de `<leader>gd` a `<leader>gD`.
- Se añade un grupo explícito para buffers y otro para ventanas.
