# A Joint Precoding Framework for Wideband Reconfigurable Intelligent Surface-Aided Cell-Free Network

Código de simulación para el Trabajo de Fin de Grado (TFG).

## Descripción

Implementación de algoritmos de precodificación conjunta para redes cell-free con superficies inteligentes reconfigurables (RIS) de banda ancha.

## Estructura

- `main_*GHz_*.m`: Scripts principales de simulación para diferentes frecuencias (3.5, 8, 15 GHz) y algoritmos (greedy, óptimo)
- `MyAlgorithm*.m`: Implementaciones de los algoritmos de optimización
- `Channel_generate.m`: Generación de canales
- `Position_generate*.m`: Generación de posiciones de estaciones base, RIS y usuarios

## Requisitos

- MATLAB
- CVX (para optimización convexa)

## Uso

Ejecutar los scripts `main_*GHz_*.m` según la frecuencia y algoritmo deseado.

