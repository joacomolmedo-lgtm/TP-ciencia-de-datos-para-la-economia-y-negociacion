8. Metodología y resultados

Los métodos se presentan en orden creciente de complejidad: primero el test de
diferencia de medias (t de student), después la regresión que controla por otras
variables, y por último los dos chi-cuadrados de independencia, que
responden las hipótesis complementarias. Los tres se calculan ponderando por
PONDIIO (ponderador de ingresos de la EPH), usando el paquete `survey`
(`svyttest`, `svyglm`, `svychisq`), que vimos en clase

Test sobre la hipótesis principal (se establece si la brecha existe):
Test de diferencia de medias de ingresos por educación.

Elegimos este test porque antes de preguntar si la brecha de ingresos entre
formales e informales se amplía con la educación, hay que establecer que esa
brecha existe. El test de diferencia responde la pregunta más básica dentro de cada nivel
educativo, ¿hay una diferencia de ingresos significativa entre formal e
informal?
La técnica propuestas es el t-test de Welch (`svyttest`), corrido por separado para cada una
de las 18 combinaciones de año (2017/2021/2025) y nivel educativo (6 niveles).
Aclaración sobre supuestos y el abordaje del t-test clásico que asume varianzas
iguales entre los dos grupos comparados. La versión de Welch no requiere ese
supuesto, lo cual es relevante acá porque no hay razón para esperar que la
varianza del ingreso sea igual entre formales e informales (de hecho, el
ingreso informal suele ser más disperso, al no estar sujeto a escalas
salariales formales). Se usa la versión ponderada (PONDIIO) en vez del t-test
base de R, porque sin ponderar el resultado describe la muestra encuestada,
no la población.
Como resultado obtuvimos la brecha es estadísticamente significativa en las 18
combinaciones (p < 0,001 en todos los casos). La brecha relativa (diferencia
de medias como % del ingreso formal, calculada así para neutralizar el
efecto de la inflación entre años) se amplía a medida que sube la educación
hasta "Superior Incompleto" (de 40% a 58%, según el año), pero se reduce
en "Superior Completo" (32%, estable en los tres años). Este patrón,
amplificación y luego freno en el tramo más alto, se repite de forma casi
idéntica en 2017, 2021 y 2025, lo que sugiere que no es un fenómeno
coyuntural de un año puntual.
La interpretación respecto a la hipótesis es la confirmación de que la brecha existe en todos los niveles y momentos analizados, pero matizando la hipótesis principal ya que, la ampliación no es estrictamente directa a medida que aumenta la educación, se revierte (revierte no en el sentido absoluto de la palabra sino, que la brecha no sigue amplificando y de hecho disminuye) en el tramo superior completo. 
Regresión de la brecha educativa (también sobre la hipótesis principal)

Este test se eligió ya que la t de student (o diferencia de medias) muestra la brecha en cada nivel educativo por separado, pero no controla por otros factores que también influyen en el ingreso. La regresión evalúa si la interacción entre formalidad y educación se sostiene
una vez controlados sexo, edad y edad², es decir, si la amplificación de la brecha es atribuible a la educación en sí, o podría explicarse por otras diferencias entre los grupos.
La técnica utilizada es la regresión lineal ponderada (`svyglm`) con la siguiente especificación: 
La interacción “condición de formalidad por el nivel educativo” es el término que responde la hipótesis principal; sexo, edad y edad² son controles (entran para descontar su efecto, no son el centro de la pregunta). Edad² se incluye porque la relación entre edad e ingreso no es lineal: sube en la adultez y cae al envejecer.
Aclaramos un supuesto clave y cómo se aborda: 
Además de requerir errores estándar correctos para datos ponderados (resuelto con `svyglm` en vez de `lm` + `weights`), el modelo necesita suficientes observaciones en cada combinación de variables para estimar con precisión. Inicialmente se incluyeron región y
sector de actividad como controles adicionales, pero se descartaron: al cruzarse con la interacción educación×formalidad, generaban 34 de 168 celdas posibles con menos de 10 casos en 2025 (sobre todo en combinaciones con "Primario Incompleto"), produciendo errores estándar inestables y coeficientes sin sentido económico. Sector de actividad no se pierde como variable de análisis: tiene su propio método dedicado (Chi-cuadrado sobre la educacion, hipótesis
complementaria 2).
El resultado en 2017, los coeficientes de la interacción son negativos, significativos (p < 0,05 en los 5 niveles, respecto a "Primario Incompleto") y crecen en magnitud de forma consistente con el nivel educativo, confirmando la hipótesis principal con los controles
incluidos. En 2021, el patrón es similar pero más débil (los dos primeros coeficientes no alcanzan significancia). En 2025, ningún coeficiente de la interacción es significativo y los errores estándar son anormalmente grandes (mayores que la propia estimación), esto no sabemos si se debe a la inflación o al tamaño reducido del grupo "Primario Incompleto" en 2025 (87 formales + 152 informales = 239 casos en total, frente a miles en los demás niveles).
La interpretación respecto a la hipótesis hecha la regresión, confirma la hipótesis
principal con mayor solidez en 2017, de forma más débil en 2021, y no permite afirmar ni refutar nada para 2025 con la evidencia disponible (ya sea por el número de casos o la necesidad de una deflactación) se documenta como limitación, no se fuerza una lectura optimista de un resultado no concluyente.

Chi-cuadrado de educación (hipótesis complementaria 1)

Este test se eligió porque la hipótesis complementaria 1 no pregunta cuánto se gana, sino qué tan probable es ser informal según el nivel educativo. Es una pregunta sobre la distribución de una variable categórica (formal/informal) en función de otra (nivel educativo), lo cual corresponde a un test de independencia, no a una comparación de medias.
La técnica elegida fue el chi-cuadrado de independencia ponderado (`svychisq`), sobre la tabla de contingencia nivel educativo × condición de formalidad, para cada año.
Supuestos y su correspondiente abordaje: 
El chi-cuadrado requiere frecuencias esperadas suficientes en cada celda de la tabla. Con 6 niveles educativos y miles de casos por año, este supuesto se cumple sin necesidad de ajustes.
El resultado es significativo con la máxima fuerza posible en los tres años (p prácticamente cero). La proporción de informales cae de forma sostenida a medida que sube la educación: de aproximadamente 78% en "Primario Incompleto" a 34% en "Superior Completo" (datos de 2025), patrón estable en los tres períodos. La interpretación dado el resultado es la confirmación de la hipótesis complementaria 1 con el resultado más sólido de los cuatro métodos.

Chi-cuadrado de sector (hipótesis complementaria 2)

La razón por la que se eligió este test es la misma lógica que el Chi-cuadrado de educación, pero para la hipótesis de que la informalidad se concentra en sectores de actividad específicos, de forma estructural y persistente en el tiempo.
La técnica es el chi-cuadrado de independencia ponderado, sobre la tabla sector de actividad (clasificación CAES, 14 ramas) × condición de formalidad, para cada año. Se usó la agregación `caes_eph_label` del paquete `eph`, pensada específicamente para el tamaño de muestra de la EPH, en lugar de clasificaciones más finas, para evitar celdas con muy pocos casos.
Los supuestos y su abordaje son el mismo supuesto de frecuencias esperadas
que M3a. Se verificó que ninguna celda del cruce sector×formalidad×año
quedará con un número de casos insuficiente para el test.
Su resultado es significativo con la misma fuerza máxima en los tres años.
Servicio Doméstico y Construcción son, por amplio margen, los sectores con
mayor informalidad en los tres períodos (Servicio Doméstico: 73,4%/75,5%/80,5%; Construcción: 66,3%/68,5%/65,0%). Administración Pública y
Enseñanza son consistentemente los de menor informalidad. Comercio se ubica
en un rango intermedio, con más variación entre años que el resto (42,4%/38,9%/44,5%).

Nuestra interpretación es una confirmación de la hipótesis complementaria 2, con una característica relevante: existe un núcleo de sectores (servicio doméstico, construcción) con concentración de informalidad extremadamente estable, mientras que otros sectores muestran más variabilidad año a año, la persistencia estructural es más fuerte en
algunos sectores que en otros, no es uniforme en toda la economía.


9. Conclusión

El objetivo de este trabajo fue evaluar si la brecha de ingresos entre asalariados formales e informales en Argentina se amplía a medida que aumenta el nivel educativo (hipótesis principal), y si la informalidad está asociada inversamente al nivel educativo y se concentra de forma estructural en sectores específicos de la economía (hipótesis complementarias 1 y 2). El análisis se realizó sobre tres cortes transversales de la EPH (tercer trimestre de 2017, 2021 y 2025), restringidos a asalariados ocupados.

Sobre la hipótesis principal
La evidencia confirma la existencia de la brecha, pero matiza la forma en que se amplía con la educación. El test de diferencia de ingresos por educación (el test de diferencia de medias) muestra una brecha relativa significativa en las 18 combinaciones de año y nivel educativo analizadas, que efectivamente crece a medida que sube el nivel educativo, de aproximadamente 40% a 58%, según el año, pero solo hasta "Superior Incompleto". En "Superior Completo", la brecha se reduce de forma marcada y consistente en los tres años (32%), sin invertir su signo: los formales siguen ganando más que los informales en ese tramo, pero la distancia relativa entre ambos deja de crecer y retrocede. Este patrón, idéntico en su forma en 2017, 2021 y 2025, sugiere que no se trata de un fenómeno coyuntural de un año puntual, sino de una característica estructural de cómo se relacionan educación y formalidad en el mercado laboral argentino.

La regresión que controla por sexo, edad y edad² (regresion de la brecha educativa) refuerza esta lectura de forma desigual entre los tres años. En 2017, la interacción entre formalidad y nivel educativo es negativa, significativa y creciente en magnitud en los cinco niveles evaluados (respecto a "Primario Incompleto"), la confirmación más sólida de que la brecha se amplía con la educación, aun controlando otros factores. En 2021 el patrón se repite con menor fuerza estadística. En 2025, los resultados no son concluyentes, los coeficientes de la interacción no alcanzan significancia y presentan errores estándar inestables, suponemos debido al tamaño reducido del grupo "Primario Incompleto" en ese año (239 casos en total) o efectos de la inflación. Esto no permite afirmar ni refutar la hipótesis principal para 2025 con la evidencia de la regresión, una limitación que se reconoce explícitamente, sin forzar una lectura optimista de un resultado que no la sostiene.

En conjunto, la hipótesis principal “se comprueba de forma parcial y matizada”, existe una brecha que se amplía con la educación, pero no de manera estricta, y la evidencia que controla por otros factores es sólida en 2017, más débil en 2021, y no concluyente en 2025.

Sobre la hipótesis complementaria 1

El chi-cuadrado de educación confirma esta hipótesis con el resultado más sólido de los cuatro métodos: la asociación entre nivel educativo y condición de formalidad es significativa con la máxima fuerza posible, de manera estable en los tres años. La proporción de informales cae de forma sostenida a medida que aumenta el nivel educativo, de aproximadamente 78% en "Primario Incompleto" a 34% en "Superior Completo" en 2025, un gradiente que se repite en 2017 y 2021 con magnitudes similares. “Se comprueba” con
evidencia consistente y estable en el tiempo.

Sobre la hipótesis complementaria 2

El chi-cuadrado de sector confirma también esta hipótesis, con la misma fuerza estadística que la anterior. La informalidad no se distribuye de manera homogénea entre sectores de actividad: Servicio Doméstico y Construcción son, por amplio margen, los sectores con mayor tasa de informalidad en los tres períodos analizados, mientras que Administración Pública y Enseñanza se mantienen consistentemente como los de menor informalidad. Sin embargo, la estabilidad no es uniforme en toda la economía: Servicio Doméstico muestra una tendencia creciente (de 73,4% en 2017 a 80,5% en 2025), Construcción se mantiene prácticamente invariable (entre 65% y 68,5%), y sectores como Comercio presentan más variación año a año que el núcleo más persistente. “Se comprueba” la hipótesis, con el matiz de que la persistencia estructural es más marcada en algunos sectores que en otros.

En síntesis la evidencia respalda el argumento central del trabajo, este es, la informalidad
laboral en Argentina no es un fenómeno aleatorio ni homogéneo. Está asociada de forma clara y estable al nivel educativo, tanto en su probabilidad de ocurrencia (hipótesis complementaria 1) como en su efecto sobre el ingreso (hipótesis principal), aunque esta segunda relación muestra un límite en el tramo de mayor calificación que no estaba previsto
en la formulación original de la hipótesis. Y está concentrada de forma estructural en determinados sectores de actividad (hipótesis complementaria 2), con un núcleo en servicio doméstico y construcción, que se mantiene prácticamente inalterado a lo largo de ocho años que incluyen contextos macroeconómicos muy distintos entre sí.

10. Propuesta Metodológica y Líneas de Investigación Futura

Con el objetivo de profundizar el alcance del presente estudio y subsanar las limitaciones intrínsecas de los cortes transversales utilizados, se proponen dos extensiones metodológicas para futuras investigaciones:

En primer lugar, la incorporación de la Dimensión Longitudinal y Trayectoria Laboral. La presente especificación del modelo multivariado (regresión) controla el ciclo de vida mediante la inclusión de la edad y su término cuadrático como variables aproximadas de la experiencia general. Sin embargo, esta aproximación es susceptible de introducir un sesgo por variable omitida, al no capturar de forma directa la densidad de aportes ni la estabilidad en el puesto de trabajo. 
Una extensión natural del proyecto consiste en explotar la estructura de panel rotativo de la EPH (diseño 2-2-2) para realizar un seguimiento longitudinal de los individuos a lo largo de cuatro trimestres. Esto permitiría controlar de manera efectiva por efectos fijos individuales, aislando características no observables del trabajador (como habilidades blandas o motivación) y modelar las transiciones laborales entre la formalidad y la informalidad, evaluando si el tiempo de permanencia en el sector no registrado (antigüedad) profundiza de forma monótona la penalización salarial observada sobre el capital humano.

En segundo lugar la Desagregación y Análisis de Heterogeneidad Regional (profundización). El mercado de trabajo en Argentina presenta profundas asimetrías estructurales según la región geográfica bajo análisis. La agregación a nivel nacional ejecutada en este trabajo puede asimilar bajo un mismo promedio situaciones disímiles, como las elevadas tasas de informalidad del Noreste (NEA) o Noroeste (NOA) frente a las dinámicas salariales de la región Patagónica o el Gran Buenos Aires.
Se propone expandir el marco empírico mediante una desagregación a nivel de Aglomerados Urbanos o Regiones Estadísticas de la EPH, incorporando variables de control de entorno macro-regional. Esto posibilitará testear si la magnitud y la significatividad del coeficiente de interacción entre educación e informalidad laboral se encuentran condicionadas por la estructura productiva dominante local (ej. economías de enclave versus centros urbanos de servicios personalizados), aportando un diagnóstico con mayor capilaridad espacial para el diseño de políticas públicas dirigidas.

Además de estas líneas de profundización, y por último vale la pena señalar limitaciones concretas del análisis actual. El modelo de regresión excluyó región y sector de actividad como controles, porque al combinarse con la interacción educación×formalidad generaban celdas con muy pocos casos en 2025; esto significa que la regresión no descarta que parte del efecto atribuido a la interacción esté capturando, en realidad, diferencias regionales o sectoriales no controladas. Asimismo, el indicador de informalidad (PP07H, descuento jubilatorio) no distingue entre la ausencia de aportes y el aporte a regímenes jubilatorios alternativos (cajas provinciales), lo que introduce un margen de error de clasificación no cuantificable con los datos disponibles.
