# =============================================================================
# SCRIPT 02: Estadísticas Descriptivas Numéricas y Visualización Editorializada
# Curso: Ciencia de Datos para Economía y Negocios | FCE-UBA
# Docente: Nicolás Sidicaro
# =============================================================================

# ---- 0. Paquetes y Configuración --------------------------------------------
library(tidyverse)
library(here)
library(scales)
library(ggtext)

options(scipen = 999)

# ---- 1. Lectura del Insumo Intermedio (Compartimentación) -------------------
base_final <- readRDS(here("input", "eph_tres_periodos_limpia.rds"))

# ---- 2. ESTADÍSTICAS DESCRIPTIVAS NUMÉRICAS (Clase 05 & Clase 12) ------------
# Función auxiliar: mediana ponderada. median() sin ponderar mezclaría dos
# criterios distintos en la misma tabla, porque media_ingreso sí usa PONDIIO
# (la EPH tiene muestreo complejo, cada caso representa una cantidad distinta
# de personas en la población real).
weighted_median <- function(x, w) {
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cum_w <- cumsum(w) / sum(w)
  x[which(cum_w >= 0.5)[1]]
}

# Calculamos parámetros utilizando las funciones nativas de tidyverse (Clase 03)
stats_ingresos <- base_final %>% 
  group_by(anio_analisis, condicion_formalidad) %>% 
  summarise(
    total_observaciones = n(),
    poblacion_expandida = sum(PONDIIO),
    media_ingreso       = weighted.mean(P21_clean, w = PONDIIO),
    mediana_ingreso     = weighted_median(P21_clean, PONDIIO),
    desvio_estandar     = sqrt(sum(PONDIIO * (P21_clean - weighted.mean(P21_clean, w = PONDIIO))^2) / sum(PONDIIO)),
    coef_variacion      = (desvio_estandar / media_ingreso) * 100,
    .groups = "drop"
  ) %>% 
  mutate(across(where(is.numeric), ~ round(.x, 1)))

# Exportación del CSV para armar las tablas en las diapositivas
write_csv(stats_ingresos, here("output", "tablas_estadisticas_descriptivas.csv"))

# ---- 3. GRÁFICO COMUNICACIONAL CORREGIDO (Año 2025 - Clase 19) ---------------
tabla_prop <- base_final %>% 
  group_by(anio_analisis, nivel_educativo, condicion_formalidad) %>% 
  summarise(n = sum(PONDIIO), .groups = "drop_last") %>% 
  mutate(prop = n / sum(n)) %>% 
  ungroup()

grafico_comunicacional <- ggplot(data = filter(tabla_prop, anio_analisis == 2025), 
                                 aes(x = nivel_educativo, y = prop, fill = condicion_formalidad)) + 
  geom_col(position = position_stack(reverse = TRUE), width = 0.6) +
  scale_fill_manual(values = c("Formal" = "#23B84B", "Informal" = "#B82345")) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "**A mayor nivel educativo, mayor proporción de trabajadores formales**",
    subtitle = "Proporción de asalariados registrados y no registrados según máximo nivel de instrucción (Año 2025)",
    caption = "Fuente: EPH, INDEC. Tercer Trimestre 2025.",
    x = "Nivel Educativo Alcanzado",
    y = "Porcentaje de Trabajadores",
    fill = "Condición Laboral:"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title.position = "plot",
    plot.title = element_markdown(size = rel(1.15), face = "bold", color = "#2a2a2a"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(angle = 15, hjust = 1)
  )

ggsave(here("output", "grafico_comunicacional_final.png"), grafico_comunicacional, width = 8, height = 5.5, dpi = 300)

# ---- 4. GRÁFICO EXPLORATORIO CORREGIDO (Año 2025 - Clase 18) -----------------
tabla_brechas <- base_final %>% 
  group_by(anio_analisis, nivel_educativo, condicion_formalidad) %>% 
  summarise(salario_promedio = weighted.mean(P21_clean, w = PONDIIO), .groups = "drop")

grafico_exploratorio <- ggplot(data = filter(tabla_brechas, anio_analisis == 2025), 
                               aes(x = nivel_educativo, y = salario_promedio, color = condicion_formalidad)) +
  geom_point(size = 4) +
  geom_line(aes(group = nivel_educativo), color = "#c7c7c7", linewidth = 1) +
  scale_color_manual(values = c("Formal" = "#23B84B", "Informal" = "#B82345")) +
  scale_y_continuous(labels = scales::label_comma(big.mark = ".", decimal.mark = ",")) +
  labs(
    title = "Brecha de Ingresos entre Asalariados Formales e Informales",
    subtitle = "Ingreso medio de la ocupación principal por nivel de instrucción (Año 2025)",
    caption = "Fuente: EPH, INDEC. Valores expresados en pesos corrientes.",
    x = "Nivel Educativo Alcanzado",
    y = "Ingreso de la Ocupación Principal (ARS)",
    color = "Condición de Registro:"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = rel(1.15)),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(angle = 15, hjust = 1)
  )

ggsave(here("output", "grafico_exploratorio_final.png"), grafico_exploratorio, width = 8, height = 5.5, dpi = 300)

cat("Script 02 completado. Insumos guardados en /output\n")