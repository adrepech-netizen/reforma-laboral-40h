# Código de Replicación: Impacto de la Jornada de 40 Horas en México

Este repositorio contiene las rutinas y scripts de programación en **Stata** utilizados para el procesamiento de datos y la simulación financiera del artículo: *"Efecto de la reforma laboral en México: Un modelo de estrés financiero sectorial (2026–2030)"*.

## Contenido del Repositorio
1. `01_procesamiento_enoe.do`: Script para la limpieza, cruce trimestral de microdatos de la ENOE (INEGI) y cálculo del Costo Laboral Unitario (CLU).
2. `02_simulador_stress_test.do`: Modelo de simulación de estrés financiero y erosión de utilidades en MiPyMEs por sector económico.

## Requisitos y Software
* **Software:** Stata 16 o superior.
* **Datos de origen:** Microdatos de la Encuesta Nacional de Ocupación y Empleo (ENOE), disponibles en el portal oficial del INEGI.

## Instrucciones de Uso
1. Descarga los archivos `.do` de este repositorio.
2. Asegúrate de modificar la global `$ruta` al inicio de tus scripts en Stata para que apunte a la carpeta local donde guardaste tus bases de datos `.dta` de INEGI.
3. Ejecuta primero el script `01_procesamiento_enoe.do` para generar la base anual consolidada y, posteriormente, el script `02_simulador_stress_test.do` para replicar el análisis de estrés y los gráficos.
