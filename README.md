# TP ciencia de datos para la economia y negociacion
Este es el repositorio README.md del trabajo practico realizado por Joaquin Olmedo, Joaquín Escalante, Mauro Recalde, en el primer custrimestre de 2026. Este repopsitorio y su respectivo reademe seran modificados a lo largo del cuatrimeste en el cual se tiene como objetivo aumentar conocimientos en programacion y analisis de datos iniciando estudios y trabajos con el programa R.
# Brechas de ingreso formal/informal y su relación con educación y sector de actividad

**Grupo 12** — Joaquín Olmedo, Mauro Recalde, Joaquín Escalante
Ciencia de Datos para Economía y Negocios | FCE-UBA | Prof. Nicolás Sidicaro

## Tema

Análisis de la informalidad laboral entre asalariados en Argentina, usando microdatos
de la EPH (INDEC), en tres cortes transversales: 3er trimestre de 2017, 2021 y 2025.

**Hipótesis principal:** la brecha de ingresos entre asalariados formales e informales
se amplía a medida que aumenta el nivel educativo.

**Hipótesis complementarias:**
1. La probabilidad de informalidad está asociada inversamente al nivel educativo.
2. La informalidad no se distribuye al azar entre sectores de actividad: se concentra
   de forma estructural y persistente en sectores específicos (construcción, servicio
   doméstico, comercio).

## Estructura del repositorio
├── input/              # Datos procesados, listos para análisis

├── output/

│   ├── tablas/          # Tablas exportadas en CSV

│   └── graficos/        # Gráficos exportados en PNG

├── scripts/             # Códigos del proyecto, numerados por orden de ejecución

├── BITACORA.md          # Registro de decisiones metodológicas

└── README.md
Nota: la carpeta `raw/` no se versiona — los datos se descargan directamente de la
API de la EPH (paquete `eph`) en `01_limpieza.R`, no hace falta guardarlos crudos.

## Cómo correr el proyecto

Ejecutar los scripts en este orden, cada uno se apoya en el output del anterior:

1. **`scripts/01_limpieza.R`** — descarga los 3 trimestres de la EPH, filtra
   asalariados ocupados, clasifica sector con CAES, trata datos faltantes y
   outliers. Genera `input/eph_tres_periodos_limpia.rds` y
   `output/evidencia_datos_faltantes.csv`.
2. **`scripts/02_descriptivos.R`** — calcula estadísticas descriptivas ponderadas
   y genera los dos gráficos principales. Genera `output/tablas_estadisticas_descriptivas.csv`,
   `output/grafico_comunicacional_final.png`, `output/grafico_exploratorio_final.png`.
3. **`scripts/03_inferencia.R`** — corre los 4 métodos de inferencia estadística
   (t-test ponderado, regresión ponderada, dos chi-cuadrados). Genera los CSV de
   `output/inferencia_*` y el detalle de los modelos en `output/detalle_modelo_m2_*.txt`.

Requiere los paquetes `tidyverse`, `eph`, `here`, `survey`, `scales`, `ggtext`
(instalar con `install.packages()` si no están disponibles).

## Métodos utilizados

| Método | Técnica | Hipótesis que evalúa |
|---|---|---|
| M1 | t-test de Welch ponderado, por nivel educativo | Principal |
| M2 | Regresión ponderada con interacción educación×formalidad | Principal |
| M3 | Chi-cuadrado: nivel educativo × formalidad | Complementaria 1 |
| M3 | Chi-cuadrado: sector CAES × formalidad | Complementaria 2 |

## Limitaciones conocidas

- `PP07H` (descuento jubilatorio) no distingue entre ausencia de aportes y
  aportes a regímenes alternativos (cajas jubilatorias provinciales).
- M2 no incluye región ni sector como controles: combinados con la interacción
  educación×formalidad, generaban celdas con muy pocos casos para el tamaño
  de muestra de 2025.
- Los coeficientes de M2 para 2025 no son concluyentes, por el tamaño reducido
  del grupo "Primario Incompleto" en ese año (239 casos).

Ver `BITACORA.md` para el detalle completo de decisiones metodológicas.
