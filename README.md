# A Joint Precoding Framework for Wideband Reconfigurable Intelligent Surface-Aided Cell-Free Network

Código de simulación para el Trabajo de Fin de Grado (TFG).

## Descripción

Implementación de algoritmos de precodificación conjunta para redes cell-free con superficies inteligentes reconfigurables (RIS) de banda ancha.

## Estructura del Repositorio

```
code_1/
├── main/                    # Scripts principales de simulación
│   ├── main_*GHz_*.m       # Scripts por frecuencia (3.5, 8, 15 GHz) y algoritmo (greedy, óptimo)
│   └── main_*.m            # Otros scripts principales
│
├── algorithms/              # Implementaciones de algoritmos de optimización
│   ├── MyAlgorithm*.m      # Algoritmos principales y variantes
│   └── MMAlgorithm.m       # Algoritmo MM
│
├── channels/                # Generación y modelado de canales
│   ├── Channel_generate*.m # Generadores de canales principales
│   └── channel_*.m         # Funciones auxiliares de canales
│
├── geometry/                # Generación de posiciones y geometría
│   └── Position_generate*.m # Generadores de posiciones (BS, RIS, usuarios)
│
├── utils/                   # Utilidades y funciones auxiliares
│   ├── W_Theta_intialize.m # Inicialización de matrices
│   ├── *generate.m         # Funciones generadoras auxiliares
│   ├── *update.m           # Funciones de actualización
│   ├── cvx_solve_*.m       # Solvers de optimización convexa
│   └── RISselection*.m     # Funciones de selección de RIS
│
├── analysis/                # Scripts de análisis y tests
│   ├── analizar_*.m        # Scripts de análisis
│   ├── test_*.m            # Scripts de testing
│   └── compare_*.m         # Scripts de comparación
│
├── plotting/                # Scripts de visualización
│   └── plot_*.m            # Funciones de plotting
│
├── figures/                 # Figuras generadas
│   ├── *.fig               # Figuras de MATLAB
│   ├── *.jpg, *.png        # Imágenes exportadas
│   └── *.eps               # Figuras vectoriales
│
├── results/                 # Resultados de simulaciones
│   └── resultados_*.mat    # Archivos de datos de resultados
│
└── docs/                    # Documentación
    ├── capitulo_RIS.tex    # Documento LaTeX
    └── referencias_ris.bib # Referencias bibliográficas
```

## Requisitos

- MATLAB
- CVX (para optimización convexa)

## Uso

Los scripts principales se encuentran en la carpeta `main/`. Para ejecutar una simulación:

```matlab
% Ejemplo: Simulación a 3.5 GHz con algoritmo greedy
cd main
main_3_5GHz_greedy
```

### Scripts principales disponibles:

- **Por frecuencia y algoritmo:**
  - `main_3_5GHz_greedy.m` / `main_3_5GHz_optimo.m`
  - `main_8GHz_greedy.m` / `main_8GHz_optimo.m`
  - `main_15GHz_greedy.m` / `main_15GHz_optimo.m`

- **Otros scripts:**
  - `main_definitivo.m`: Script principal definitivo
  - `main_clean.m`: Versión limpia del script principal
  - `main_3GPP.m`: Simulación con modelos 3GPP

## Notas

- Los resultados de las simulaciones se guardan en `results/`
- Las figuras generadas se almacenan en `figures/`
- Los archivos `.mat` y `.fig` están ignorados por defecto en `.gitignore` para mantener el repositorio ligero

