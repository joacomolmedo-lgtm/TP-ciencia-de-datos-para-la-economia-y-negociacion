# ============================ 01_limpieza.R =================================
#Limpieza, clasificación sectorial y tratamiento de outliers

library(tidyverse)
library(eph)
library(here)

options(scipen = 999)

eph_2017 <- get_microdata(year = 2017, period = 3, type = "individual") |> mutate(anio_analisis = 2017)
eph_2021 <- get_microdata(year = 2021, period = 3, type = "individual") |> mutate(anio_analisis = 2021)
eph_2025 <- get_microdata(year = 2025, period = 3, type = "individual") |> mutate(anio_analisis = 2025)

eph_raw <- bind_rows(eph_2017, eph_2021, eph_2025)

#organize_caes() tiene que correr antes del select(), porque necesita PP04B_COD presente en la base completa para poder clasificar
eph_caes <- organize_caes(base = eph_raw)

#selección de variables y filtro de población objetivo
#CAT_OCUP == 3 (asalariados), se agregan CH06 (edad) y REGION como controles, y caes_eph_label como sector***
base_trabajo <- eph_caes |>
  select(anio_analisis, ESTADO, CAT_OCUP, PP07H, P21, NIVEL_ED, PONDIIO, CH04, CH06, REGION, caes_eph_label) |>
  filter(
    ESTADO == 1,
    CAT_OCUP == 3,
    NIVEL_ED != 7
  )

#evidencia de datos faltantes
tabla_missing_ingresos <- base_trabajo |>
  group_by(anio_analisis) |>
  summarise(
    total_observaciones = n(),
    ingresos_en_cero     = sum(P21 == 0),
    no_responde_missing  = sum(P21 == -9 | is.na(P21)),
    prop_datos_invalidos = (ingresos_en_cero + no_responde_missing) / total_observaciones
  )

dir.create(here("output"), showWarnings = FALSE)
write_csv(tabla_missing_ingresos, here("output", "evidencia_datos_faltantes.csv"))

#filtro de ingresos válidos
base_filtrada <- base_trabajo |>
  filter(P21 > 0, P21 != -9, !is.na(P21))

#tratamiento de outliers, winsorización al percentil 99
base_limpia <- base_filtrada |>
  group_by(anio_analisis) |>
  mutate(
    p99 = quantile(P21, 0.99),
    es_outlier = P21 > p99,
    P21_clean = if_else(es_outlier, p99, P21)
  ) |>
  ungroup()

#variables categóricas legibles y controles, sexo, edad y edad2 son los controles que necesita la regresión lineal
#edad2 porque la relación edad e ingreso, no es lineal, sube en la adultez y cae al envejecer
base_final <- base_limpia |>
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

dir.create(here("input"), showWarnings = FALSE)
saveRDS(base_final, here("input", "eph_tres_periodos_limpia.rds"))

cat("Script 01 finalizado sin errores.\n")