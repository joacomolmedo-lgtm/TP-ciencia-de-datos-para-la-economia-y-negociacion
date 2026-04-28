# TP-ciencia-de-datos-para-la-economia-y-negociacion
Este es el repositorio README.md del trabajo practico realizado por joaquin olmedo, , en el primer custrimestre de 2026. Este repopsitorio y su respectivo reademe seran modificados a lo largo del cuatrimeste en el cual se tiene como objetivo aumentar conocimientos en programacion y analisis de datos iniciando estudios y trabajos con el programa R.
# TEMA  
El trabajo analiza la estructura del mercado laboral argentino a través de la EPH (Encuesta Permanente de Hogares del INDEC). El eje central es la brecha de ingresos entre trabajadores formales e informales, su evolución temporal y cómo varía según sector de actividad, nivel educativo y género. El período seleccionado permitirá testear la rigidez de la informalidad ante diferentes ciclos macroeconómicos de Argentina, incluyendo años de estancamiento, la crisis por pandemia y la posterior recuperación. La pregunta de fondo es si la informalidad laboral en Argentina es un fenómeno homogéneo o si tiene patrones diferenciados según características del trabajador y del mercado.
## Integrantes

- Joaquin Olmedo (911371)
- Joaquín Escalante (917915)
- Mauro Recalde (902291)
  
## Objetivo

# Hipotesis
La brecha de ingresos entre trabajadores formales e informales es significativa, persistente en el tiempo, y se amplía con el nivel educativo: a mayor educación, mayor es la penalización salarial por trabajar en el sector informal. 
Conjeturamos que esto se debe a una segmentación del mercado laboral donde el sector informal no cuenta con la estructura organizacional necesaria para absorber y remunerar productivamente el capital humano de alta calificación.
El nivel educativo determina simultáneamente el acceso al empleo formal y el nivel de ingresos: a menor nivel educativo, mayor probabilidad de estar en el sector informal y menores ingresos dentro de ese sector. Esto genera una doble penalización para los trabajadores menos calificados quedan excluidos del empleo formal y, dentro del informal, perciben los ingresos más bajos. 
Doble entrada de la hipótesis:
1) Los más educados ganan proporcionalmente menos respecto a lo que ganarían en el sector formal es decir, la brecha formal/informal se amplía con la educación. 2) A menor nivel educativo, mayor probabilidad de estar en el sector informal. La educación es una barrera de entrada al empleo formal. Y trabajar en el sector informal implica menores ingresos, independientemente del nivel educativo. Por lo que hay una doble penalización y una muestra de una relación entre nivel educativo y formalidad/informalidad.
# Hipotesis secundaria
La informalidad laboral tiene una distribución sectorial no aleatoria: ciertos sectores de actividad (construcción, trabajo doméstico, comercio minorista) concentran sistemáticamente mayores tasas de informalidad que otros (industria manufacturera, sector público, servicios financieros), y esta estructura sectorial se mantiene relativamente estable a lo largo del tiempo.

## Datos

- **Fuente principal:**
- Encuesta Permanente de Hogares (EPH) 
·       Ingreso de la ocupación principal (numérica continua): ingreso mensual declarado en pesos corrientes de la ocupación principal del individuo
·       Condición de informalidad (categórica binaria): si el trabajador tiene descuento jubilatorio — proxy estándar de formalidad en la EPH
·       Nivel educativo (categórica ordinal): sin instrucción / primaria / secundaria / superior no universitaria / universitaria completa e incompleta
·       Sector de actividad (categórica nominal): rama de actividad económica según clasificación CIIU — agrupada en sectores grandes
·       Sexo (categórica binaria): variable de control para analizar si la brecha formal/informal interactúa con la brecha de género
·       Aglomerado (categórica nominal): ciudad o región donde vive el encuestado — permite análisis geográfico
·       Período (temporal): trimestre y año de la encuesta — permite análisis de evolución temporal
·       Categoría ocupacional (categórica nominal): patrón / cuenta propia / asalariado / trabajador familiar — relevante porque la informalidad tiene distinta naturaleza según categoría

- **Fuente complementaria:**
·       IPC del INDEC (fuente: INDEC): para deflactar los ingresos nominales y construir series de ingreso real comparables entre trimestres y años
·       Canasta básica total (INDEC): como benchmark de referencia para contextualizar los ingresos (cuántos trabajadores informales quedan por debajo de la línea de pobreza)

- **Período:**
  A DEFINIR
- **Unidad de análisis:** 
A DEFINIR 
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
