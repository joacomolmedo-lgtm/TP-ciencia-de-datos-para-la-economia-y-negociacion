# ========================= 03_inferencia.R ====================================
#Pruebas de inferencia estadística y contrastación de hipótesis

library(tidyverse)
library(survey)
library(here)

options(scipen = 999)

base_final <- readRDS(here("input", "eph_tres_periodos_limpia.rds"))
anios <- c(2017, 2021, 2025)

dis_eph <- svydesign(ids = ~1, weights = ~PONDIIO, data = base_final)

#método 1: t-test de Welch, ponderado, por año y nivel educativo
resultados_m1 <- list()
for (a in anios) {
  for (niv in levels(base_final$nivel_educativo)) {
    sub_design <- subset(dis_eph, anio_analisis == a & nivel_educativo == niv)
    n_formal   <- sum(sub_design$variables$condicion_formalidad == "Formal")
    n_informal <- sum(sub_design$variables$condicion_formalidad == "Informal")
    if (n_formal < 5 | n_informal < 5) next
    
    test <- svyttest(P21_clean ~ condicion_formalidad, design = sub_design)
    media_formal <- as.numeric(svymean(~P21_clean, design = subset(sub_design, condicion_formalidad == "Formal")))
    
    resultados_m1[[paste(a, niv)]] <- tibble(
      anio = a,
      nivel_educativo = niv,
      n_formal = n_formal,
      n_informal = n_informal,
      media_formal = media_formal,
      diferencia_medias = unname(test$estimate),
      estadistico_t = unname(test$statistic),
      p_valor = test$p.value,
      brecha_relativa_pct = round(abs(unname(test$estimate)) / media_formal * 100, 1)
    )
  }
}
tabla_m1 <- bind_rows(resultados_m1)
write_csv(tabla_m1, here("output", "inferencia_m1_t_test.csv"))
print(tabla_m1)

#método 2: regresión ponderada, interacción + controles
#se excluyeron region y sector_caes: combinados con la interacción generaban celdas con <10 casos en 2025 (sobre todo en "Primario Incompleto", 239 casos en total), afectando los coeficientes
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
  resultados_m2[[as.character(a)]] <- as_tibble(interaccion, rownames = "termino") |>
    mutate(anio = a) |>
    rename(estimacion = Estimate, error_std = `Std. Error`, t_valor = `t value`, p_valor = `Pr(>|t|)`)
}
tabla_m2 <- bind_rows(resultados_m2)
write_csv(tabla_m2, here("output", "inferencia_m2_regresion.csv"))
print(tabla_m2)

#método 3: chi-cuadrado ponderado, educación y sector
resultados_m3_educacion <- list()
resultados_m3_sector <- list()
for (a in anios) {
  sub_design <- subset(dis_eph, anio_analisis == a)
  
  test_edu <- svychisq(~nivel_educativo + condicion_formalidad, design = sub_design, statistic = "Chisq")
  resultados_m3_educacion[[as.character(a)]] <- tibble(anio = a, estadistico_chi2 = unname(test_edu$statistic), p_valor = test_edu$p.value)
  
  test_sec <- svychisq(~sector_caes + condicion_formalidad, design = sub_design, statistic = "Chisq")
  resultados_m3_sector[[as.character(a)]] <- tibble(anio = a, estadistico_chi2 = unname(test_sec$statistic), p_valor = test_sec$p.value)
}
write_csv(bind_rows(resultados_m3_educacion), here("output", "inferencia_m3_educacion.csv"))
write_csv(bind_rows(resultados_m3_sector), here("output", "inferencia_m3_sector.csv"))

cat("Script 03 finalizado sin errores.\n")