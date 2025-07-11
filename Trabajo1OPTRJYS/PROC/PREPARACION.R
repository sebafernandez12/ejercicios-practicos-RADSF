##Instalamos y cargamos los paquetes necesarios 
load("Base de datos EBS 2023.RData") 
options(repos = c(CRAN = "https://cloud.r-project.org")) 
install.packages("forcats") 
install.packages("knitr") 
install.packages("kableExtra") 
install.packages("labelled") 
install.packages("ggcorrplot") 
library(ggcorrplot) 
library(forcats) 
library(dplyr) 
library(haven) 
library(knitr) 
library(kableExtra) 
library(ggplot2) 
library(labelled) 
library(corrplot) 
pacman::p_load(haven,tidyverse,sjlabelled, dplyr, stargazer,sjmisc,summarytools, kableExtra,sjPlot, corrplot, ggplot2)
##Cargamos y renombramos la base de datos 
load("Base de datos EBS 2023.RData") 
data <- EBS_2023_vp  
##Visualizamos la base de datos
View(data) 
##Filtramos la base de datos con las variables que utilizaremos
data_filtrada <- data %>%
  select(sg01, a1, a7, ee2) 
View(data_filtrada) 
##Pasamos las variables a numericas para posteriormente recodificarlas
data_filtrada <- data_filtrada %>%
  mutate(
    sg01_num = as_numeric(sg01),
    a1_num   = as_numeric(a1),
    a7_num   = as_numeric(a7),
    ee2_num  = as_numeric(ee2)
  ) 
##Filtramos antes de recodificar
data_filtrada <- data_filtrada %>%
  filter(
    sg01_num %in% c(1, 2),
    a1_num %in% 1:5,
    a7_num %in% 1:5,
    ee2_num %in% c(1, 2)
  ) 

##Recodificamos las variables 
data_filtrada <- data_filtrada %>%
  mutate(
    sexo = factor(sg01_num, levels = c(1, 2), labels = c("Hombre", "Mujer")),
    
    satisfaccion_vida = factor(a1_num,
                               levels = 1:5,
                               labels = c("Muy insatisfecho", "Insatisfecho",
                                          "Indiferente", "Satisfecho", 
                                          "Muy satisfecho")),
    
    satisfaccion_ingresos = factor(a7_num,
                                   levels = 1:5,
                                   labels = c("Muy insatisfecho", "Insatisfecho"
                                              ,
                                             "Indiferente", "Satisfecho", 
                                              "Muy satisfecho")),
    
    interes_estudios = factor(ee2_num,
                              levels = c(1, 2),
                              labels = c("Sí", "No"))
  ) 
##Verificamos que se hayan recodificado correctamente 
str(data_filtrada) 
##Tabla 1 sexo
tabla_sexo <- data_filtrada %>%
  count(sexo) %>%
  mutate(Porcentaje = round(n / sum(n) * 100, 1)) %>%
  rename(Sexo = sexo, Frecuencia = n) 

kable(tabla_sexo, format = "html", caption = "Distribución de la muestra por sexo") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), 
                full_width = F, position = "center") 
##Tabla 2 Satisfacción con la vida 
tabla_vida <- data_filtrada %>%
  count(satisfaccion_vida) %>%
  mutate(Porcentaje = round(n / sum(n) * 100, 1)) %>%
  rename(`Satisfacción con la vida` = satisfaccion_vida, Frecuencia = n) 

kable(tabla_vida, format = "html", caption = "Distribución de satisfacción con la vida") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
                full_width = F, position = "center") 
#Tabla 3 Satisfacción con el ingreso
tabla_ingresos <- data_filtrada %>%
  count(satisfaccion_ingresos) %>%
  mutate(Porcentaje = round(n / sum(n) * 100, 1)) %>%
  rename(`Satisfacción con los ingresos` = satisfaccion_ingresos, Frecuencia = n) 

kable(tabla_ingresos, format = "html", caption = "Distribución de satisfacción con los ingresos") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
                full_width = F, position = "center") 
##Tabla 4 Intereses por seguir estudiando 
tabla_estudios <- data_filtrada %>%
  count(interes_estudios) %>%
  mutate(Porcentaje = round(n / sum(n) * 100, 1)) %>%
  rename(`Interés por estudiar` = interes_estudios, Frecuencia = n) 

kable(tabla_estudios, format = "html", caption = "Distribución de interés por estudiar") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
                full_width = F, position = "center") 
##Graficamos la variable satis_vida por sexo
ggplot(data_filtrada, aes(x = satisfaccion_vida, fill = sexo)) +
  geom_bar(position = "dodge") +
  labs(title = "Satisfacción con la vida según sexo",
       x = "Nivel de satisfacción con la vida",
       y = "Frecuencia",
       fill = "Sexo") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1)) 
##Graficamos la variable interes por seguir estudiando por sexo
ggplot(data_filtrada, aes(x = interes_estudios, fill = sexo)) +
  geom_bar(position = "dodge") +
  labs(title = "Interés en continuar estudios en los próximos 5 años",
       x = "Respuesta",
       y = "Frecuencia",
       fill = "Sexo") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5)) 
##Graficamos la variable satis_ingreso por sexo
ggplot(data_filtrada, aes(x = satisfaccion_ingresos, fill = sexo)) +
  geom_bar(position = "dodge") +
  labs(title = "Satisfacción con los ingresos según sexo",
       x = "Nivel de satisfacción",
       y = "Frecuencia",
       fill = "Sexo") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1)) 
###Análisis de correlación entre satisfacción de vida, ingreso e
###interes por seguir estudiando
# Seleccionamos las variables para la correlación
satis_cor <- data_filtrada %>%
  select(a1_num, a7_num, ee2_num) 

#Calculamos la matriz
cor_matrix <- cor(satis_cor, use = "complete.obs", method = "pearson") 

# Renombrar las filas y columnas para que tengan nombres más claros
colnames(cor_matrix) <- c("Satis_Vida", "Satis_Ingresos", "Interés_Estudiar") 
rownames(cor_matrix) <- c("Satis_Vida", "Satis_Ingresos", "Interés_Estudiar") 
##Gráficamos
ggcorrplot(cor_matrix,
           lab = TRUE,
           lab_size = 4,
           type = "lower",
           colors = c("red", "white", "blue"),
           title = "Matriz de Correlación entre Variables de Satisfacción",
           ggtheme = theme_minimal() +
             theme(plot.title = element_text(hjust = 0.5))) 
##Indice sumativo entre satisfacción con la vida e ingresos 
data_filtrada <- data_filtrada %>%
  mutate(indice_satisfaccion = a1_num + a7_num) 

#Resumen del indice
summary(data_filtrada$indice_satisfaccion) 

#Gráficos el indice
ggplot(data_filtrada, aes(x = indice_satisfaccion)) +
  geom_histogram(binwidth = 1, fill = "dodgerblue", color = "black", boundary = 0) +
  scale_x_continuous(breaks = seq(2, 10, by = 1)) +
  labs(
    title = "Índice de satisfacción subjetiva",
    x = "Índice de satisfacción (vida + ingresos)",
    y = "Frecuencia"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 13),  # <- más pequeño y centrado
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10))
  ) 
##Estimamos modelos de regresión lineal y modelos de regresión multiple
# Modelo 1: Regresión lineal simple
modelo_1 <- lm(a1_num ~ a7_num, data = data_filtrada)

# Modelo 2: Regresión lineal múltiple
modelo_2 <- lm(a1_num ~ a7_num + ee2_num, data = data_filtrada) 

# Modelo 3: Regresión lineal múltiple (ingresos + interés por estudiar + sexo)
modelo_3 <- lm(a1_num ~ a7_num + ee2_num + factor(sg01_num), data = data_filtrada) 


##Tabla de modelo de regresiones
tab_model(modelo_1, modelo_2, modelo_3,
          show.ci = FALSE,
          show.std = TRUE,
          title = "Modelos de regresión: factores asociados a la satisfacción con la vida",
          dv.labels = c("Modelo 1: Solo ingresos",
                        "Modelo 2: Ingresos + interés por estudiar",
                        "Modelo 3: Ingresos + interés + sexo")) 
##Gráfico de valores predichos de modelo 2 de regresión
# Crear nueva variable con valores predichos
data_filtrada$pred_modelo_2 <- predict(modelo_2) 
##Graficamos 
ggplot(data_filtrada, aes(x = a7_num, y = pred_modelo_2)) +
  geom_jitter(alpha = 0.2, width = 0.2, color = "darkblue") +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(
    title = "Predicción Modelo 2",
    x = "Satisfacción con los ingresos",
    y = "Satisfacción con la vida (V.predicho)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 13, face = "bold"),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10))
  ) 







