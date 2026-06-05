# ==============================================================================
# PROJEKT: Analiza strategii zjazdów do Pit Stopu w Formule 1
# ==============================================================================

library(ggplot2)
library(corrplot)
library(dplyr)
library(caret)
library(rpart)
library(rpart.plot)
library(class)

# ==============================================================================
# --- 1. Wczytanie i czyszczenie danych ---
# ==============================================================================
data <- read.csv('/Users/majazontek/Desktop/UCZELNIA/projekty/f1 pred/f1_strategy_dataset_v4.csv')
data <- na.omit(data)

cols_to_keep <- c("TyreLife", "Position", "Compound", "LapTime_Delta", 
                  "Cumulative_Degradation", "RaceProgress", "PitNextLap")
df <- data[, cols_to_keep]

df$PitNextLap <- as.factor(df$PitNextLap)
df$Compound <- as.factor(df$Compound)

print("Struktura zbioru danych:")
str(df)

# ==============================================================================
# --- 2. Analiza eksploracyjna (EDA) ---
# ==============================================================================
wykres_celu <- ggplot(df, aes(x = PitNextLap, fill = PitNextLap)) +
  geom_bar() +
  scale_fill_manual(values = c("lightblue", "salmon")) +
  theme_minimal() +
  labs(title = "Rozkład zmiennej celu (PitNextLap)",
       x = "Czy zjazd na następnym okrążeniu? (0 = Nie, 1 = Tak)",
       y = "Liczba obserwacji") +
  theme(legend.position = "none")

print(wykres_celu)

wykres_opony <- ggplot(df, aes(x = TyreLife)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "white") +
  theme_minimal() +
  labs(title = "Rozkład wieku opon (TyreLife)",
       x = "Liczba okrążeń na danym zestawie",
       y = "Częstość")

print(wykres_opony)

df_num <- df %>% select_if(is.numeric)
cor_matrix <- cor(df_num)

corrplot(cor_matrix, method = "color", type = "upper", 
         addCoef.col = "black", tl.col = "black", tl.srt = 45,
         title = "Macierz korelacji zmiennych numerycznych",
         mar = c(0,0,2,0))

# ==============================================================================
# --- 3. Podział na zbiór uczący i testowy ---
# ==============================================================================
set.seed(2026) 
trainIndex <- createDataPartition(df$PitNextLap, p = 0.8, list = FALSE)
train_data <- df[trainIndex, ]
test_data  <- df[-trainIndex, ]

# ==============================================================================
# --- 4. Modele predykcyjne ---
# ==============================================================================

# 4.1. Regresja Logistyczna
model_log <- glm(PitNextLap ~ ., data = train_data, family = "binomial")

cat("\n--- PODSUMOWANIE REGRESJI LOGISTYCZNEJ ---\n")
print(summary(model_log))

# 4.2. Drzewo Decyzyjne
model_tree <- rpart(PitNextLap ~ ., data = train_data, method = "class", 
                    control = rpart.control(cp = 0.005))

rpart.plot(model_tree, main="Drzewo decyzyjne zjazdu do PIT")

cat("\n--- REGUŁY DRZEWA DECYZYJNEGO (ŚCIEŻKI) ---\n")
rpart.rules(model_tree)

# 4.3. k-Najbliższych Sąsiadów (kNN)
train_x <- model.matrix(PitNextLap ~ . - 1, data = train_data)
test_x  <- model.matrix(PitNextLap ~ . - 1, data = test_data)

train_x <- scale(train_x)
test_x <- scale(test_x, center = attr(train_x, "scaled:center"), scale = attr(train_x, "scaled:scale"))

train_y <- train_data$PitNextLap
test_y  <- test_data$PitNextLap

pred_knn <- knn(train = train_x, test = test_x, cl = train_y, k = 5)

# ==============================================================================
# --- 5. Ewaluacja modeli ---
# ==============================================================================
pred_log_prob <- predict(model_log, newdata = test_data, type = "response")
pred_log_class <- as.factor(ifelse(pred_log_prob > 0.5, 1, 0))

pred_tree_class <- predict(model_tree, newdata = test_data, type = "class")

cat("\n=============================================\n")
cat("1. REGRESJA LOGISTYCZNA\n")
cat("=============================================\n")
print(confusionMatrix(pred_log_class, test_y, positive = "1")$byClass)

cat("\n=============================================\n")
cat("2. k-NAJBLIŻSZYCH SĄSIADÓW (kNN, k=5)\n")
cat("=============================================\n")
print(confusionMatrix(pred_knn, test_y, positive = "1")$byClass)

cat("\n=============================================\n")
cat("3. DRZEWO DECYZYJNE\n")
cat("=============================================\n")
print(confusionMatrix(pred_tree_class, test_y, positive = "1")$byClass)

# ==============================================================================
# --- 6. Wizualizacja Macierzy Pomyłek ---
# ==============================================================================

cm_log <- confusionMatrix(pred_log_class, test_y, positive = "1")
cm_data <- as.data.frame(cm_log$table)

wykres_regresja <- ggplot(data = cm_data, aes(x = Reference, y = Prediction)) +
  geom_tile(aes(fill = Freq), color = "white") +
  geom_text(aes(label = sprintf("%d", Freq)), vjust = 0.5, size = 6) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  theme_minimal() +
  labs(title = "Macierz Pomyłek - Regresja Logistyczna",
       x = "Rzeczywistość (Co się stało na torze?)",
       y = "Predykcja (Co przewidział model?)",
       fill = "Liczba\nobserwacji") +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

print(wykres_regresja)

cm_knn <- confusionMatrix(pred_knn, test_y, positive = "1")
cm_knn_data <- as.data.frame(cm_knn$table)

wykres_knn <- ggplot(data = cm_knn_data, aes(x = Reference, y = Prediction)) +
  geom_tile(aes(fill = Freq), color = "white") +
  geom_text(aes(label = sprintf("%d", Freq)), vjust = 0.5, size = 6) +
  scale_fill_gradient(low = "white", high = "seagreen") +
  theme_minimal() +
  labs(title = "Macierz Pomyłek - k-Najbliższych Sąsiadów (kNN)",
       x = "Rzeczywistość (Co się stało na torze?)",
       y = "Predykcja (Co przewidział model?)",
       fill = "Liczba\nobserwacji") +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

print(wykres_knn)

cm_tree <- confusionMatrix(pred_tree_class, test_y, positive = "1")
cm_tree_data <- as.data.frame(cm_tree$table)

wykres_tree <- ggplot(data = cm_tree_data, aes(x = Reference, y = Prediction)) +
  geom_tile(aes(fill = Freq), color = "white") +
  geom_text(aes(label = sprintf("%d", Freq)), vjust = 0.5, size = 6) +
  scale_fill_gradient(low = "white", high = "darkorange") +
  theme_minimal() +
  labs(title = "Macierz Pomyłek - Drzewo Decyzyjne",
       x = "Rzeczywistość (Co się stało na torze?)",
       y = "Predykcja (Co przewidział model?)",
       fill = "Liczba\nobserwacji") +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

print(wykres_tree)