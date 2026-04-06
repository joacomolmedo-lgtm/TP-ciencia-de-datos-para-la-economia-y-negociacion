# TP-ciencia-de-datos-para-la-economia-y-negociacion
Este es el inicio de un trabajo practico realizado por joaquin olmedo en el primer custrimestre de 2026. Este repopsitorio y su respectivo reademe seran modificados a lo largo del cuatrimeste en el cual tengo como objetivo aumentar mis conocimientos en programacion y analisis de datos iniciando mis estudios con el programa R.
# TEMA A DEFINIR 

## Integrantes

- Joaquin Olmedo

## Objetivo

A DEFINIR

## Datos

- **Fuente principal:**
  BUSCAR FUENTES DE DATOS EN GITHUB
- **Fuente complementaria:**
  
- **Período:** 
- **Unidad de análisis:** 

## Análisis realizado

1. A DEFINIR

## Estructura del repositorio

```
proyecto/
├── raw/              # Bases originales descargadas de INDEC
├── auxiliar/          # Proyecciones de población
├── input/             # Bases procesadas y listas para el análisis
├── output/
│   ├── tablas/        # Tablas de resultados exportadas
│   └── graficos/      # Visualizaciones generadas
├── script/
│   ├── 01_limpieza.R
│   ├── 02_exploratorio.R
│   ├── 03_analisis.R
│   └── 04_visualizaciones.R
├── utils/
│   └── calcular_tasa_crecimiento.R
└── README.md
```

## Reproducción

### Paquetes necesarios

```r
install.packages(c("tidyverse", "readxl", "scales"))
```

### Orden de ejecución

1. `script/01_limpieza.R` — Lee las bases de `raw/` y `auxiliar/`, genera
   los archivos en `input/`.
2. `script/02_exploratorio.R` — Análisis descriptivo inicial.
3. `script/03_analisis.R` — Cálculos principales.
4. `script/04_visualizaciones.R` — Genera los gráficos en `output/graficos/`.

## Conclusiones principales

El análisis muestra que la dispersión del PBG per cápita entre provincias
se mantuvo estable en el período estudiado, sin evidencia clara de convergencia.
Las provincias con perfil extractivo presentaron mayor volatilidad,
consistente con la hipótesis inicial.
```
