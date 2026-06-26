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