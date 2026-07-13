* ---------------------------------------------------------------------------
* PARTE 2: SIMULACIÓN DE EROSIÓN CON COSTOS REALES (ENOE + SALARIO META)
* ---------------------------------------------------------------------------
clear
set obs 3 

gen sector = ""
replace sector = "Comercio" in 1
replace sector = "Industria" in 2
replace sector = "Servicios" in 3

* 1. Estructura de Costos Base 2026 (48h)
gen ingresos = 2000000

gen c_lab_2026 = 400000 in 1
replace c_lab_2026 = 800000 in 2
replace c_lab_2026 = 900000 in 3

gen otros_costos = 1400000 in 1
replace otros_costos = 900000 in 2
replace otros_costos = 500000 in 3

gen margen_2026 = (ingresos - (c_lab_2026 + otros_costos)) / ingresos * 100

* ===========================================================================
* 2. ASIGNACIÓN DE INCREMENTOS REALES POR AÑO
* ===========================================================================
* Introducimos los valores exactos expresados en decimales 

* --- Año 2027 ---
gen inc_2027 = 0.21 in 1     // Comercio: 21%
replace inc_2027 = 0.13 in 2 // Industria: 13%
replace inc_2027 = 0.15 in 3 // Servicios: 15%

* --- Año 2028 ---
gen inc_2028 = 0.38 in 1     // Comercio: 38%
replace inc_2028 = 0.27 in 2 // Industria: 27%
replace inc_2028 = 0.28 in 3 // Servicios: 28%

* --- Año 2029 ---
gen inc_2029 = 0.59 in 1     // Comercio: 59%
replace inc_2029 = 0.45 in 2 // Industria: 45%
replace inc_2029 = 0.46 in 3 // Servicios: 46%

* --- Año 2030 ---
gen inc_2030 = 0.85 in 1     // Comercio: 85%
replace inc_2030 = 0.68 in 2 // Industria: 68%
replace inc_2030 = 0.68 in 3 // Servicios: 68%

* ===========================================================================
* 3. CÁLCULO DE MÁRGENES ANUALES DE UTILIDAD
* ===========================================================================
foreach año in 2027 2028 2029 2030 {
    * Aplicamos el incremento específico medido por la ENOE para cada año
    gen c_lab_`año' = c_lab_2026 * (1 + inc_`año')
    gen margen_`año' = (ingresos - (c_lab_`año' + otros_costos)) / ingresos * 100
}

* ===========================================================================
* 4. REESTRUCTURACIÓN DE DATOS (De Ancho a Largo para graficar)
* ===========================================================================
keep sector margen_*
reshape long margen_, i(sector) j(ano)
rename margen_ margen_utilidad

* ===========================================================================
* 5. LOS GRÁFICOS INDEPENDIENTES 
* ===========================================================================

twoway ///
    (line margen_utilidad ano if sector == "Comercio", lcolor(dknavy) lwidth(medthick) m(o)) ///
    (line margen_utilidad ano if sector == "Industria", lcolor(forest_green) lwidth(medthick) m(d)) ///
    (line margen_utilidad ano if sector == "Servicios", lcolor(cranberry) lwidth(medthick) m(t)), ///
    title("{bf:Erosión del Margen Operativo por Sector}", size(medium) color(black)) ///
    subtitle("Impacto de Reforma 40h + Salario Mínimo Meta (\$500 en 2030)", size(small) color(gs6)) ///
    ytitle("Margen Operativo (%)", size(small)) ///
    xtitle("Año de Implementación", size(small)) ///
    xlabel(2026 "2026" 2027 "2027" 2028 "2028" 2029 "2029" 2030 "2030*", labsize(small)) ///
    ylabel(-10(5)35, grid glstyle(dot) labsize(small)) ///
    legend(order(1 "Comercio" 2 "Industria" 3 "Servicios") rows(1) position(6) ring(1)) ///
    graphregion(color(white)) bgcolor(white) ///
    note("*El año 2030 contempla el escenario acumulado (40h + SM Meta)", size(vsmall) color(gs8))

twoway ///
    (line margen_utilidad ano if sector == "Comercio", lcolor(dknavy) lwidth(medthick) m(o)) ///
    (line margen_utilidad ano if sector == "Industria", lcolor(forest_green) lwidth(medthick) m(d)) ///
    (line margen_utilidad ano if sector == "Servicios", lcolor(cranberry) lwidth(medthick) m(t)), ///
    title(, size(medium) color(black)) ///
    subtitle(, size(small) color(gs6)) ///
    ytitle("Margen Operativo (%)", size(small)) ///
    xtitle("Año de Implementación", size(small)) ///
    xlabel(2026 "2026" 2027 "2027" 2028 "2028" 2029 "2029" 2030 "2030*", labsize(small)) ///
    ylabel(-10(5)35, grid glstyle(dot) labsize(small)) ///
    legend(order(1 "Comercio" 2 "Industria" 3 "Servicios") rows(1) position(6) ring(1)) ///
    graphregion(color(white)) bgcolor(white) ///
    note("*El año 2030 contempla el escenario acumulado (40h + SM Meta)", size(vsmall) color(gs8))

* Verificación en consola 
list sector ano margen_utilidad, sepby(sector) clean