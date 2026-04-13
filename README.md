# Inferencia Estadística: tres aproximaciones al mismo problema

[![Quarto](https://img.shields.io/badge/Quarto-RevealJS-blue?logo=quarto)](https://quarto.org)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Presentación introductoria sobre los tres enfoques principales de inferencia estadística — **frecuentista**, **verosimilitud** y **bayesiano** — ilustrados con un ejemplo sencillo: lanzar una moneda 20 veces y observar 14 caras.

## 🌐 Ver la presentación

👉 **[jdleongomez.github.io/Inferencia_estadistica](https://jdleongomez.github.io/Inferencia_estadistica)**

## Contenido

La presentación cubre:

- Probabilidad y parámetros: qué es θ y cómo se distribuyen los resultados
- El problema de la inferencia: de los datos al parámetro
- **Frecuentista**: hipótesis nula, valor p e intervalos de confianza
- **Verosimilitud**: la función L(θ), el MLE y la razón de verosimilitud
- **Bayesiana**: prior, verosimilitud y posterior — actualización paso a paso
- Comparación de los tres enfoques

## Reproducibilidad

La presentación está escrita en [Quarto](https://quarto.org) con formato RevealJS. Todo el código R está integrado en `index.qmd`.

**Dependencias en R:**

```r
install.packages(c("tidyverse", "patchwork"))
```

**Para renderizar localmente:**

```bash
quarto render index.qmd
```

## Archivos

| Archivo/Directorio | Descripción |
|---|---|
| `index.qmd` | Fuente principal de la presentación |
| `styles.css` | Estilos personalizados |
| `codigo.R` | Código R independiente con las tres aproximaciones |
| `img/` | Imágenes usadas en la presentación |
| `_extensions/` | Extensiones de Quarto |

## Autor

**Juan David Leongómez**, PhD, MSc  
Facultad de Psicología · Universidad El Bosque · Bogotá, Colombia  
🌐 [jdleongomez.info](https://jdleongomez.info/es) · 
[![ORCID](https://img.shields.io/badge/ORCID-0000--0002--0092--6298-brightgreen?logo=orcid)](https://orcid.org/0000-0002-0092-6298)

## Licencia

[Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
