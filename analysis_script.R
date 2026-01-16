## NOX5 Expression Analysis Pipeline

## Load libraries
library(dplyr)
library(stringr)
library(lme4)
library(lmerTest)
library(ggplot2)
library(ggbeeswarm)

## Expected input objects
# AG_NOX5_QUOD_MyExpt_V2_IdentifySecondaryObjects_3
# Threhsolds
# metadata

## Output directories
dir.create("figures", showWarnings = FALSE)
dir.create("tables", showWarnings = FALSE)

## Select relevant CellProfiler columns
df <- AG_NOX5_QUOD_MyExpt_V2_IdentifySecondaryObjects_3 %>%
  select(
    ImageNumber,
    ObjectNumber,
    FileName_Binary,
    Intensity_MeanIntensity_C1,
    Intensity_MeanIntensity_C2,
    Intensity_MeanIntensity_C3,
    Intensity_MeanIntensity_C4
  )

## Extract donor ID
df <- df %>%
  mutate(
    donor_id = str_extract(FileName_Binary, "\\d{3}"),
    donor_id = as.numeric(donor_id)
  )

## Rename channels
df <- df %>%
  rename(
    NOX5     = Intensity_MeanIntensity_C1,
    insulin  = Intensity_MeanIntensity_C2,
    glucagon = Intensity_MeanIntensity_C4
  )

## Join donor-specific thresholds
thresholds <- Threhsolds %>%
  rename(
    insulin_threshold  = insulin,
    glucagon_threshold = glucagon
  )

df <- df %>%
  left_join(thresholds, by = "donor_id")

## Assign cell type
df <- df %>%
  mutate(
    cell_type = case_when(
      insulin >= insulin_threshold & insulin >= glucagon ~ "Beta",
      glucagon >= glucagon_threshold & glucagon > insulin ~ "Alpha",
      insulin >= insulin_threshold & glucagon >= glucagon_threshold ~ "Bi-hormonal",
      TRUE ~ "Other"
    )
  )

## Extract islet number
df <- df %>%
  mutate(
    islet_number = str_extract(FileName_Binary, "Islet \\d+") %>%
      str_extract("\\d+") %>%
      as.numeric()
  )


## Alpha / Beta counts per islet
alpha_beta_df <- df %>%
  group_by(donor_id, islet_number) %>%
  summarise(
    alpha_cells = sum(cell_type == "Alpha"),
    beta_cells  = sum(cell_type == "Beta"),
    .groups = "drop"
  ) %>%
  mutate(alpha_beta_ratio = alpha_cells / beta_cells)


## Merge metadata
df <- df %>%
  left_join(metadata, by = "donor_id")

alpha_beta_df <- alpha_beta_df %>%
  left_join(metadata, by = "donor_id")


## Transform variables
df <- df %>%
  mutate(
    NOX5_sqrt = sqrt(NOX5),
    cell_type = factor(cell_type),
    group = factor(group),
    gender = factor(gender),
    donor_id = factor(donor_id),
    islet_number = factor(islet_number)
  )


## Linear Mixed Model
lmm_nox5 <- lmer(
  NOX5_sqrt ~ group * cell_type + gender + age +
    (1 | donor_id) + (1 | islet_number),
  data = df
)

sink("tables/LMM_summary.txt")
summary(lmm_nox5)
sink()


## FIGURE NOX5 by cell type
p1 <- ggplot(df, aes(cell_type, NOX5)) +
  geom_violin(aes(fill = cell_type), trim = FALSE, alpha = 0.4) +
  geom_quasirandom(size = 0.3, alpha = 0.3) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3) +
  labs(y = "NOX5 Expression", x = "Cell Type") +
  theme_classic()

ggsave("figures/NOX5_by_cell_type.png", p1, width = 6, height = 4)


## FIGURE NOX5 in beta cells by group
p2 <- df %>%
  filter(cell_type == "Beta") %>%
  ggplot(aes(group, NOX5)) +
  geom_violin(aes(fill = group), trim = FALSE, alpha = 0.4) +
  geom_quasirandom(size = 0.3, alpha = 0.3) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3) +
  labs(y = "NOX5 Expression (Beta Cells)", x = "Group") +
  theme_classic()

ggsave("figures/NOX5_Beta_by_group.png", p2, width = 7, height = 4)


## FIGURE NOX5 in alpha cells by group
p3 <- df %>%
  filter(cell_type == "Alpha") %>%
  ggplot(aes(group, NOX5)) +
  geom_violin(aes(fill = group), trim = FALSE, alpha = 0.4) +
  geom_quasirandom(size = 0.3, alpha = 0.3) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3) +
  labs(y = "NOX5 Expression (Alpha Cells)", x = "Group") +
  theme_classic()

ggsave("figures/NOX5_Alpha_by_group.png", p3, width = 7, height = 4)


## FIGURE Alpha:Beta ratio by group
p4 <- ggplot(alpha_beta_df, aes(group, alpha_beta_ratio)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.5) +
  geom_jitter(width = 0.15, alpha = 0.6) +
  scale_y_log10() +
  labs(y = "Alpha:Beta Ratio", x = "Group") +
  theme_classic()

ggsave("figures/AlphaBeta_ratio_by_group.png", p4, width = 7, height = 4)

## FIGURE Ratio vs age
p5 <- ggplot(alpha_beta_df, aes(age, alpha_beta_ratio)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_log10() +
  labs(y = "Alpha:Beta Ratio", x = "Age") +
  theme_classic()

ggsave("figures/AlphaBeta_ratio_vs_age.png", p5, width = 6, height = 4)


## Save processed tables
write.csv(df, "tables/cell_level_data.csv", row.names = FALSE)
write.csv(alpha_beta_df, "tables/alpha_beta_ratios.csv", row.names = FALSE)

