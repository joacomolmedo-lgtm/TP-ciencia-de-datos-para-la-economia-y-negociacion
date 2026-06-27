## 24/06/2026 — Corrección del pipeline de datos para la entrega final

**Qué se hizo:**
- Se volvió al 3er trimestre (T3) para 2017/2021/2025, en lugar del T4 que tenía
  el script heredado, para mantener coherencia con lo entregado en I1 e I2.
- Se agregó el filtro `CAT_OCUP == 3` (asalariados), que faltaba en el script
  heredado y era una corrección explícita del profesor en I1.
- Se incorporó `organize_caes()` del paquete `eph` para clasificar el sector
  de actividad, usando la columna `caes_eph_label` (14 ramas, pensada para
  el tamaño de muestra de la EPH).
- Se trataron los outliers de ingreso por winsorización al percentil 99,
  en vez de eliminación directa.

**Por qué:**
- El filtro de asalariados es necesario porque PP07H (descuento jubilatorio)
  solo tiene sentido como proxy de informalidad en relación de dependencia.
- `caes_eph_label` se eligió sobre `caes_seccion_label` y `caes_division_label`
  porque agrupa en categorías más amplias, evitando celdas vacías en el
  chi-cuadrado por sector.
- La winsorización preserva el N (importante para la potencia del
  chi-cuadrado) en vez de descartar observaciones.

**Alternativas descartadas:**
- Eliminar directamente los outliers en vez de winsorizar: se descartó porque
  reduce el tamaño de muestra sin necesidad.
- Usar `caes_division_label` (más granular): se descartó por riesgo de
  celdas con muy pocos casos en algunos sectores y años.

**Qué se aprendió:**
- El script heredado no replicaba exactamente lo acordado en I2 (M2 corrido
  como ANOVA en vez de regresión, sin ponderar, sin la variable de sector).
  Se está rehaciendo en este momento.

**Variables derivadas agregadas (Script01):**
- `sexo`, `edad`, `edad2`: controles para la regresión M2 (interacción
  formalidad×educación). Edad al cuadrado porque la relación edad-ingreso
  no es lineal (sube en adultez, cae al envejecer).
- `sector_caes`: a partir de `caes_eph_label` (paquete eph), para el
  chi-cuadrado de la hipótesis complementaria 2 (distribución sectorial
  de la informalidad), ausente en el script heredado.

**Evidencia de datos faltantes (output/evidencia_datos_faltantes.csv):**
2017: 15,1% inválidos | 2021: 15,4% | 2025: 19,0% — mayormente no-respuesta
(código -9), no ingresos en cero. Proporción estable entre períodos.

**Outliers:** 381 casos winsorizados al P99 sobre 39.488 válidos (~0,96%),
consistente con el criterio aplicado (~1% esperado por construcción).

## 25-26/06/2026 — Corrección de descriptivos e inferencia para la entrega final

**Qué se hizo:**
- Se corrigió un bug en la mediana de `Script02.R`: el cálculo original
  (`aggregate(...)$P21_clean[1]`) siempre tomaba la primera fila del resultado,
  por lo que daba el mismo valor en los 6 grupos. Se reemplazó por una función
  de mediana ponderada propia, consistente con la media (que ya usaba PONDIIO).
- Se reescribió `Script03.R` usando el paquete `survey` (`svyttest`, `svyglm`,
  `svychisq`) en vez de `t.test`/`lm`/`chisq.test` sin ponderar.
- M1 (t-test) se corrió estratificado por nivel educativo además de por año
  (18 combinaciones), no solo por año como en el script heredado.
- M2 (regresión) se corrió como `svyglm` con interacción
  formalidad×nivel_educativo + sexo + edad + edad², excluyendo región y
  sector como controles.
- M3 se dividió en dos chi-cuadrados ponderados: educación×formalidad
  (hipótesis complementaria 1) y sector×formalidad (hipótesis
  complementaria 2, antes ausente del script heredado).

**Por qué:**
- `survey` está indicado explícitamente por el profesor para el TP
  (Clase 09, diapositiva 13: "Para inferencia correcta con ponderadores
  se usa el paquete survey").
- Región y sector se excluyeron de M2 porque, combinados con la interacción,
  generaban 34 de 168 celdas con menos de 10 casos en 2025 (sobre todo en
  "Primario Incompleto"), produciendo errores estándar inestables.

**Qué se aprendió:**
- Los errores estándar anormalmente grandes de M2 en 2025 no se deben a la
  inflación (que solo afecta la magnitud nominal de los coeficientes, no su
  precisión), sino al tamaño reducido de "Primario Incompleto" ese año
  (239 casos). Se confirmó contando las celdas con `n < 10` antes de
  descartar esa explicación.

**Resultado clave:** M1 confirma la hipótesis principal en los 18 grupos,
con un matiz (la brecha relativa se reduce en "Superior Completo", no sigue
amplificándose). M2 confirma con solidez en 2017, más débil en 2021, no
concluyente en 2025. Los dos chi-cuadrados confirman ambas hipótesis
complementarias con la máxima significancia en los tres años.

├── input/                              # Datos procesados, listos para análisis

├── output/                             # Tablas (CSV), gráficos (PNG) y detalle de modelos (TXT)

│   └── 08_metodologia_resultados.md    # Desarrollo extenso de metodología, resultados y conclusión

├── scripts/                             # Códigos del proyecto, numerados por orden de ejecución

├── Entrega_Final_Grupo12.pptx          # Presentación de la entrega final

├── BITACORA.md                         # Registro de decisiones metodológicas

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

El desarrollo completo de cada método (por qué se eligió, supuestos, resultados
e interpretación) está en `output/08_metodologia_resultados.md`.

## Limitaciones conocidas

- `PP07H` (descuento jubilatorio) no distingue entre ausencia de aportes y
  aportes a regímenes alternativos (cajas jubilatorias provinciales).
- M2 no incluye región ni sector como controles: combinados con la interacción
  educación×formalidad, generaban celdas con muy pocos casos para el tamaño
  de muestra de 2025.
- Los coeficientes de M2 para 2025 no son concluyentes, por el tamaño reducido
  del grupo "Primario Incompleto" en ese año (239 casos).

Ver `BITACORA.md` para el detalle completo de decisiones metodológicas.