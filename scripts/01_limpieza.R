# SCRIPT 01: Limpieza, clasificación sectorial y tratamiento de outliers
# Curso: Ciencia de Datos para Economía y Negocios | FCE-UBA
# Docente: Nicolás Sidicaro

# 0. Paquetes y configuración
library(tidyverse)
library(eph)
library(here)

options(scipen = 999) # Evita notación científica

# ---- 1. Descarga y combinación de microdatos (EPH) --------------------------
# Decisión: 3er trimestre de 2017, 2021 y 2025 (cortes transversales, no serie
# continua), volviendo a T3 para mantener coherencia con lo entregado en I1 e I2.
eph_2017 <- get_microdata(year = 2017, period = 3, type = "individual") %>% mutate(anio_analisis = 2017)
eph_2021 <- get_microdata(year = 2021, period = 3, type = "individual") %>% mutate(anio_analisis = 2021)
eph_2025 <- get_microdata(year = 2025, period = 3, type = "individual") %>% mutate(anio_analisis = 2025)

eph_raw <- bind_rows(eph_2017, eph_2021, eph_2025)

# ---- 2. Clasificación sectorial CAES ----------------------------------------
# Decisión: usar organize_caes() del paquete eph, antes de seleccionar columnas,
# porque la función necesita PP04B_COD presente en la base completa.
eph_caes <- organize_caes(base = eph_raw)

# ---- 3. Selección de variables y filtro de población objetivo --------------
# Decisión: CAT_OCUP == 3 (asalariados), además de ESTADO == 1 (ocupados).
# Por qué: corrección explícita de Sidicaro en I1 — "me quedaría con
# informalidad asalariada... filtren por asalariados". Sin este filtro,
# PP07H (descuento jubilatorio) se aplicaba también a cuentapropistas y
# patrones, donde no tiene el mismo significado como proxy de informalidad.
# sector_caes usa caes_eph_label (14 ramas), pensada por el paquete para el
# tamaño de muestra de la EPH, evitando celdas vacías en el chi-cuadrado.
base_trabajo <- eph_caes %>%
  select(anio_analisis, ESTADO, CAT_OCUP, PP07H, P21, NIVEL_ED, PONDIIO, CH04, CH06, REGION, caes_eph_label) %>%
  filter(
    ESTADO == 1,
    CAT_OCUP == 3,
    NIVEL_ED != 7
  )

# ---- 4. Evidencia de datos faltantes (Punto 6 de la consigna) --------------
# Decisión: cuantificar P21 == -9 (no responde) y P21 == 0 antes de filtrar,
# para mostrar evidencia numérica en vez de solo afirmar que se trataron.
tabla_missing_ingresos <- base_trabajo %>%
  group_by(anio_analisis) %>%
  summarise(
    total_observaciones = n(),
    ingresos_en_cero     = sum(P21 == 0),
    no_responde_missing  = sum(P21 == -9 | is.na(P21)),
    prop_datos_invalidos = (ingresos_en_cero + no_responde_missing) / total_observaciones
  )

dir.create(here("output"), showWarnings = FALSE)
write_csv(tabla_missing_ingresos, here("output", "evidencia_datos_faltantes.csv"))

# ---- 5. Filtro de ingresos válidos ------------------------------------------
# Decisión: excluir P21 == -9 (no responde) y P21 == 0, además de NA.
# Por qué: -9 es código de "no responde" en la EPH, no un ingreso real.
base_filtrada <- base_trabajo %>%
  filter(P21 > 0, P21 != -9, !is.na(P21))

# ---- 6. Tratamiento de outliers: winsorización al percentil 99 -------------
# Decisión: valores por encima del P99 de cada año se "achatan" a ese
# percentil, en vez de eliminarse.
# Por qué: preserva el tamaño de muestra (relevante para la potencia del
# chi-cuadrado en M3) y evita que valores extremos distorsionen la media.
base_limpia <- base_filtrada %>%
  group_by(anio_analisis) %>%
  mutate(
    p99 = quantile(P21, 0.99),
    es_outlier = P21 > p99,
    P21_clean = if_else(es_outlier, p99, P21)
  ) %>%
  ungroup()

# ---- 7. Variables categóricas legibles y controles --------------------------
# Decisión: traducir códigos a etiquetas de texto, y construir edad² como
# control no lineal para la regresión (M2) — el ingreso sube con la edad
# en la adultez y cae al envejecer, no es una relación lineal.
base_final <- base_limpia %>%
  mutate(
    condicion_formalidad = if_else(PP07H == 1, "Formal", "Informal"),
    sexo = if_else(CH04 == 1, "Varón", "Mujer"),
    edad = CH06,
    edad2 = CH06^2,
    nivel_educativo = case_when(
      NIVEL_ED == 1 ~ "Primario Incompleto",
      NIVEL_ED == 2 ~ "Primario Completo",
      NIVEL_ED == 3 ~ "Secundario Incompleto",
      NIVEL_ED == 4 ~ "Secundario Completo",
      NIVEL_ED == 5 ~ "Superior Incompleto",
      NIVEL_ED == 6 ~ "Superior Completo"
    ),
    nivel_educativo = factor(nivel_educativo, levels = c(
      "Primario Incompleto", "Primario Completo",
      "Secundario Incompleto", "Secundario Completo",
      "Superior Incompleto", "Superior Completo"
    )),
    sector_caes = caes_eph_label
  )

# ---- 8. Guardado del archivo intermedio (compartimentación) ----------------
dir.create(here("input"), showWarnings = FALSE)
saveRDS(base_final, here("input", "eph_tres_periodos_limpia.rds"))

cat("Script 01 finalizado sin errores. Archivo guardado en input/eph_tres_periodos_limpia.rds\n")