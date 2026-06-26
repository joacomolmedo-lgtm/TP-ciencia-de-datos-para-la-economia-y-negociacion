# =============================================================================
# SCRIPT 03: Pruebas de inferencia estadística y contrastación de hipótesis
# Curso: Ciencia de Datos para Economía y Negocios | FCE-UBA
# Docente: Nicolás Sidicaro
# =============================================================================

# ---- 0. Paquetes y configuración --------------------------------------------
library(tidyverse)
library(survey)
library(here)

options(scipen = 999)

# ---- 1. Lectura de datos limpios (compartimentación) ------------------------
base_final <- readRDS(here("input", "eph_tres_periodos_limpia.rds"))
anios <- c(2017, 2021, 2025)

# ---- 2. Diseño muestral ------------------------------------------------------
dis_eph <- svydesign(ids = ~1, weights = ~PONDIIO, data = base_final)

# ---- 3. MÉTODO 1: t-test de Welch, ponderado, por año y nivel educativo -----
cat("=== MÉTODO 1: t-test de Welch (ponderado, por nivel educativo) ===\n")

resultados_m1 <- list()
for (a in anios) {
  for (niv in levels(base_final$nivel_educativo)) {
    sub_design <- subset(dis_eph, anio_analisis == a & nivel_educativo == niv)
    n_formal   <- sum(sub_design$variables$condicion_formalidad == "Formal")
    n_informal <- sum(sub_design$variables$condicion_formalidad == "Informal")
    
    if (n_formal < 5 | n_informal < 5) next
    
    test <- svyttest(P21_clean ~ condicion_formalidad, design = sub_design)
    media_formal <- svymean(~P21_clean, design = subset(sub_design, condicion_formalidad == "Formal"))
    
    resultados_m1[[paste(a, niv)]] <- tibble(
      anio = a,
      nivel_educativo = niv,
      n_formal = n_formal,
      n_informal = n_informal,
      media_formal = as.numeric(media_formal),
      diferencia_medias = unname(test$estimate),
      estadistico_t = unname(test$statistic),
      p_valor = test$p.value,
      brecha_relativa_pct = round(abs(unname(test$estimate)) / as.numeric(media_formal) * 100, 1)
    )
  }
}

tabla_m1 <- bind_rows(resultados_m1)
write_csv(tabla_m1, here("output", "inferencia_m1_t_test.csv"))
print(tabla_m1)

# ---- 4. MÉTODO 2: regresión ponderada con interacción y controles ----------
# se excluyeron factor(REGION) y sector_caes de los controles: combinados con
# la interacción educación x formalidad, generaban demasiadas combinaciones
# para el tamaño de muestra de 2025 (34 de 168 celdas posibles quedaban con
# menos de 10 casos, sobre todo en "Primario Incompleto"), produciendo
# errores estándar inestables y coeficientes sin sentido económico.
# sector ya se evalúa con su propio método (chi-cuadrado, hipótesis
# complementaria 2), así que M2 no pierde poder explicativo relevante para
# su propia pregunta (si la brecha educación x formalidad se sostiene
# controlando por características del trabajador). se documenta como
# limitación en la sección 10 del informe.
cat("\n=== MÉTODO 2: regresión ponderada (interacción + controles) ===\n")

resultados_m2 <- list()
for (a in anios) {
  sub_design <- subset(dis_eph, anio_analisis == a)
  
  modelo_m2 <- svyglm(
    P21_clean ~ condicion_formalidad * nivel_educativo + sexo + edad + edad2,
    design = sub_design
  )
  
  sink(here("output", paste0("detalle_modelo_m2_", a, ".txt")))
  print(summary(modelo_m2))
  sink()
  
  coefs <- summary(modelo_m2)$coefficients
  interaccion <- coefs[grepl("condicion_formalidadInformal:nivel_educativo", rownames(coefs)), ]
  
  resultados_m2[[as.character(a)]] <- as_tibble(interaccion, rownames = "termino") %>%
    mutate(anio = a) %>%
    rename(estimacion = Estimate, error_std = `Std. Error`, t_valor = `t value`, p_valor = `Pr(>|t|)`)
}

tabla_m2 <- bind_rows(resultados_m2)
write_csv(tabla_m2, here("output", "inferencia_m2_regresion.csv"))
print(tabla_m2)

# ---- 5. MÉTODO 3, hipótesis complementaria 1: chi-cuadrado educación -------
cat("\n=== MÉTODO 3 (hipótesis complementaria 1): chi-cuadrado educación x formalidad ===\n")

resultados_m3_educacion <- list()
for (a in anios) {
  sub_design <- subset(dis_eph, anio_analisis == a)
  test_chi <- svychisq(~nivel_educativo + condicion_formalidad, design = sub_design, statistic = "Chisq")
  
  resultados_m3_educacion[[as.character(a)]] <- tibble(
    anio = a,
    estadistico_chi2 = unname(test_chi$statistic),
    p_valor = test_chi$p.value
  )
}

tabla_m3_educacion <- bind_rows(resultados_m3_educacion)
write_csv(tabla_m3_educacion, here("output", "inferencia_m3_educacion.csv"))
print(tabla_m3_educacion)

# ---- 6. MÉTODO 3, hipótesis complementaria 2: chi-cuadrado sector ----------
cat("\n=== MÉTODO 3 (hipótesis complementaria 2): chi-cuadrado sector x formalidad ===\n")

resultados_m3_sector <- list()
for (a in anios) {
  sub_design <- subset(dis_eph, anio_analisis == a)
  test_chi <- svychisq(~sector_caes + condicion_formalidad, design = sub_design, statistic = "Chisq")
  
  resultados_m3_sector[[as.character(a)]] <- tibble(
    anio = a,
    estadistico_chi2 = unname(test_chi$statistic),
    p_valor = test_chi$p.value
  )
}

tabla_m3_sector <- bind_rows(resultados_m3_sector)
write_csv(tabla_m3_sector, here("output", "inferencia_m3_sector.csv"))
print(tabla_m3_sector)

cat("\nScript 03 completado: M1, M2 y los dos chi-cuadrados corridos y exportados a /output\n")

# ---- 7. Proporción de informalidad por sector (apoyo descriptivo a M3-sector) -
# el chi-cuadrado confirma que hay asociación, pero no dice en qué sectores
# se concentra -- esta tabla lo muestra explícitamente, ponderada por PONDIIO.
tabla_prop_sector <- base_final %>%
  group_by(anio_analisis, sector_caes, condicion_formalidad) %>%
  summarise(n = sum(PONDIIO), .groups = "drop_last") %>%
  mutate(prop = round(n / sum(n) * 100, 1)) %>%
  ungroup() %>%
  filter(condicion_formalidad == "Informal") %>%
  arrange(anio_analisis, desc(prop))

write_csv(tabla_prop_sector, here("output", "tabla_proporcion_informalidad_sector.csv"))
print(tabla_prop_sector, n = Inf)