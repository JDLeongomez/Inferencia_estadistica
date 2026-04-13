library(tidyverse)
library(patchwork)

# ============================================================
# DATOS: lanzamos una moneda 20 veces y observamos 14 caras
# ============================================================
n  <- 20   # lanzamientos
k  <- 14   # caras observadas
theta_seq <- seq(0.001, 0.999, length.out = 2000)

# Paleta compartida
col_freq  <- "#E05C4B"
col_like  <- "#4B9CD3"
col_bayes <- "#5BAD72"
col_prior <- "#B0B0B0"


# ============================================================
# 1. FRECUENTISTA
# ============================================================
# Pregunta: "Si la moneda fuera justa (θ=0.5), ¿qué tan raros son mis datos?"
# Estimador: MLE = k/n. IC: intervalo que captura el verdadero θ el 95% de las veces
#            en experimentos repetidos.

theta_mle <- k / n
ic        <- binom.test(k, n, p = 0.5, conf.level = 0.95)

cat("=== FRECUENTISTA ===\n")
cat(sprintf("MLE: %.3f\n", theta_mle))
cat(sprintf("p (H₀: θ=0.5): %.4f\n", ic$p.value))
cat(sprintf("IC 95%%: [%.3f, %.3f]\n\n", ic$conf.int[1], ic$conf.int[2]))

# Distribución muestral bajo H₀: θ = 0.5
p1 <- tibble(x = 0:n) |>
  mutate(
    prob  = dbinom(x, n, 0.5),
    zona  = x >= k | x <= (n - k)  # dos colas, por simetría
  ) |>
  ggplot(aes(x = x, y = prob, fill = zona)) +
  geom_col(width = 0.7, color = "white", linewidth = 0.3) +
  geom_vline(xintercept = k, linetype = "dashed", color = col_freq, linewidth = 0.8) +
  annotate("text", x = k + 0.6, y = 0.15, label = paste0("k = ", k),
           color = col_freq, size = 3.5, hjust = 0) +
  scale_fill_manual(
    values = c("FALSE" = "grey75", "TRUE" = col_freq),
    labels = c("FALSE" = "Región esperada", "TRUE"  = "p (dos colas)")
  ) +
  scale_x_continuous(breaks = seq(0, n, 2)) +
  labs(
    title    = "1 · Frecuentista",
    subtitle = sprintf("H₀: θ = 0.5 | MLE = %.2f | IC₉₅%%: [%.2f, %.2f] | p = %.3f",
                       theta_mle, ic$conf.int[1], ic$conf.int[2], ic$p.value),
    x = "Número de caras (en 20 lanzamientos)",
    y = "P(X = x | θ = 0.5)",
    fill = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", plot.subtitle = element_text(size = 9))


# ============================================================
# 2. VEROSIMILITUD  — estilo Lakens, modernizado
# ============================================================
# Comparamos dos hipótesis puntuales: H0 y H1
# y vemos cuál es más compatible con los datos

n <- 20  # mismos datos
k <- 14  # mismos datos

H0 <- 0.50        # hipótesis nula clásica
H1 <- k / n       # hipótesis alternativa = MLE (máxima verosimilitud)

LR_H1_H0 <- dbinom(k, n, H1) / dbinom(k, n, H0)  # cuánto más verosímil es H1

cat("=== VEROSIMILITUD ===\n")
cat(sprintf("L(H1) / L(H0) = %.2f\n", LR_H1_H0))
cat(sprintf("Los datos son %.1fx más compatibles con θ=%.2f que con θ=%.2f\n\n",
            LR_H1_H0, H1, H0))

theta_seq <- seq(0, 1, length.out = 1000)
like_df   <- tibble(theta = theta_seq, like = dbinom(k, n, theta))

# Puntos y segmentos para el ratio
pts <- tibble(
  theta = c(H0, H1),
  like  = c(dbinom(k, n, H0), dbinom(k, n, H1)),
  label = c(sprintf("H₀ = %.1f", H0), sprintf("H₁ = %.2f (MLE)", H1))
)

p2 <- ggplot(like_df, aes(x = theta, y = like)) +
  geom_line(color = col_like, linewidth = 1) +
  # segmentos horizontales desde cada hipótesis hasta el MLE
  geom_segment(aes(x = H0, xend = H1, y = dbinom(k, n, H0), yend = dbinom(k, n, H0)),
               linetype = "dashed", color = "grey40") +
  geom_segment(aes(x = H1, xend = H1, y = dbinom(k, n, H0), yend = dbinom(k, n, H1)),
               linetype = "dashed", color = "grey40") +
  # barra vertical que muestra la diferencia = el ratio
  annotate("rect",
           xmin = H1 - 0.005, xmax = H1 + 0.005,
           ymin = dbinom(k, n, H0), ymax = dbinom(k, n, H1),
           fill = col_like, alpha = 0.8) +
  geom_point(data = pts, aes(x = theta, y = like), size = 3, color = "grey20") +
  geom_text(data = pts, aes(x = theta, y = like, label = label),
            hjust = c(1.1, -0.1), vjust = 0.5, size = 3.2) +
  annotate("text", x = H1 + 0.06, y = (dbinom(k, n, H0) + dbinom(k, n, H1)) / 2,
           label = sprintf("LR = %.1fx", LR_H1_H0),
           color = col_like, fontface = "bold", size = 3.5) +
  scale_x_continuous(breaks = seq(0, 1, 0.1)) +
  labs(
    title    = "2 · Verosimilitud",
    subtitle = sprintf("LR(H₁/H₀) = %.1f: los datos son %.1f veces más compatibles con θ = %.2f que con θ = %.1f",
                       LR_H1_H0, LR_H1_H0, H1, H0),
    x = "θ (probabilidad de cara)",
    y = "Verosimilitud  L(θ | datos)"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.subtitle = element_text(size = 9))


# ============================================================
# 3. BAYESIANA — un solo prior, tres curvas: prior / datos / posterior
# ============================================================
# Prior: Beta(3, 3) — creencia débil de que la moneda es "más o menos justa"
# Posterior: Beta(3 + k, 3 + n - k)

a <- 3; b <- 3
a_post <- a + k
b_post <- b + (n - k)

media_post <- a_post / (a_post + b_post)
ic_low     <- qbeta(0.025, a_post, b_post)
ic_high    <- qbeta(0.975, a_post, b_post)

cat("=== BAYESIANA ===\n")
cat(sprintf("Prior: Beta(%d, %d)  →  media = %.2f\n", a, b, a / (a + b)))
cat(sprintf("Posterior: Beta(%d, %d)  →  media = %.3f\n", a_post, b_post, media_post))
cat(sprintf("Intervalo de credibilidad 95%%: [%.3f, %.3f]\n", ic_low, ic_high))

# Escalar verosimilitud para superponerla visualmente
like_raw     <- dbinom(k, n, theta_seq)
prior_vals   <- dbeta(theta_seq, a, b)
post_vals    <- dbeta(theta_seq, a_post, b_post)
scale_factor <- max(post_vals) / max(like_raw)

bayes_df <- tibble(
  theta     = theta_seq,
  Prior     = prior_vals,
  Datos     = like_raw * scale_factor,
  Posterior = post_vals
) |>
  pivot_longer(-theta, names_to = "dist", values_to = "dens") |>
  mutate(dist = factor(dist, c("Prior", "Datos", "Posterior")))

cols_bayes <- c(
  "Prior"     = col_prior,
  "Datos"     = "grey20",
  "Posterior" = col_bayes
)

lty_bayes <- c("Prior" = "dashed", "Datos" = "dotted", "Posterior" = "solid")

p3 <- ggplot(bayes_df, aes(x = theta, y = dens, color = dist, linetype = dist)) +
  geom_ribbon(
    data = ~ filter(.x, dist == "Posterior"),
    aes(ymin = 0, ymax = dens), fill = col_bayes, alpha = 0.12, color = NA
  ) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = media_post, linetype = "dashed",
             color = col_bayes, linewidth = 0.6, alpha = 0.7) +
  annotate("text", x = media_post + 0.02, y = max(post_vals) * 0.6,
           label = sprintf("media\nposterior\n= %.2f", media_post),
           color = col_bayes, size = 3, hjust = 0) +
  scale_color_manual(values = cols_bayes) +
  scale_linetype_manual(values = lty_bayes) +
  scale_x_continuous(breaks = seq(0, 1, 0.1)) +
  labs(
    title    = "3 · Bayesiana",
    subtitle = sprintf("Prior Beta(%d,%d) + datos → Posterior Beta(%d,%d) | IC₉₅%%: [%.2f, %.2f]",
                       a, b, a_post, b_post, ic_low, ic_high),
    x = "θ (probabilidad de cara)",
    y = "Densidad  (verosimilitud escalada)",
    color = NULL, linetype = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    plot.subtitle   = element_text(size = 9)
  )


# ============================================================
# FIGURA FINAL
# ============================================================
p1 / p2 / p3 +
  plot_annotation(
    title   = "Tres aproximaciones a la inferencia estadística",
    subtitle = sprintf("Datos: %d caras en %d lanzamientos (θ̂ = %.2f)", k, n, theta_mle),
    theme = theme(
      plot.title    = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 10, color = "grey40")
    )
  )
