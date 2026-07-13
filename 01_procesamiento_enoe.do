clear all
set more off
global ruta "C:\Users\migue\Downloads\Servicio\ENOE_2025"

* ---------------------------------------------------------------------------
* PARTE 1
* ---------------------------------------------------------------------------
* ====================================================================
* FASE 1: LIMPIEZA Y CRUCE (TRIMESTRE POR TRIMESTRE)
* ====================================================================

* --- TRIMESTRE 1 ---
use "$ruta/COE1T1.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
save "$ruta/COE1T1_limpio.dta", replace

use "$ruta/COE2T1.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
save "$ruta/COE2T1_limpio.dta", replace

use "$ruta/SDEMT1.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$ruta/COE1T1_limpio.dta"
drop if _merge == 2
drop _merge
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$ruta/COE2T1_limpio.dta"
drop if _merge == 2
drop _merge
gen trimestre = 1
save "$ruta/Trimestre_1_Completo.dta", replace

* --- TRIMESTRE 2 ---
use "$ruta/COE1T2.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
save "$ruta/COE1T2_limpio.dta", replace

use "$ruta/COE2T2.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
save "$ruta/COE2T2_limpio.dta", replace

use "$ruta/SDEMT2.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$ruta/COE1T2_limpio.dta"
drop if _merge == 2
drop _merge
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$ruta/COE2T2_limpio.dta"
drop if _merge == 2
drop _merge
gen trimestre = 2
save "$ruta/Trimestre_2_Completo.dta", replace

* --- TRIMESTRE 3 ---
use "$ruta/COE1T3.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
save "$ruta/COE1T3_limpio.dta", replace

use "$ruta/COE2T3.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
save "$ruta/COE2T3_limpio.dta", replace

use "$ruta/SDEMT3.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$ruta/COE1T3_limpio.dta"
drop if _merge == 2
drop _merge
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$ruta/COE2T3_limpio.dta"
drop if _merge == 2
drop _merge
gen trimestre = 3
save "$ruta/Trimestre_3_Completo.dta", replace

* --- TRIMESTRE 4 ---
use "$ruta/COE1T4.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
save "$ruta/COE1T4_limpio.dta", replace

use "$ruta/COE2T4.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
save "$ruta/COE2T4_limpio.dta", replace

use "$ruta/SDEMT4.dta", clear
duplicates drop cd_a ent con v_sel n_hog h_mud n_ren, force
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$ruta/COE1T4_limpio.dta"
drop if _merge == 2
drop _merge
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$ruta/COE2T4_limpio.dta"
drop if _merge == 2
drop _merge
gen trimestre = 4
save "$ruta/Trimestre_4_Completo.dta", replace

* ====================================================================
* FASE 2: UNIR LOS 4 TRIMESTRES EN UNA SOLA BASE ANUAL
* ====================================================================
use "$ruta/Trimestre_1_Completo.dta", clear
append using "$ruta/Trimestre_2_Completo.dta"
append using "$ruta/Trimestre_3_Completo.dta"
append using "$ruta/Trimestre_4_Completo.dta"

* Ajuste para promedio anual
replace fac_tri = fac_tri / 4

* ====================================================================
* FASE 3: RENOMBRAR Y FILTRAR (CON RIGOR METODOLÓGICO)
* ====================================================================

* 1. Filtros Demográficos Base (PET, Residentes y Entrevistas Completas)
keep if r_def == 0 & (c_res == 1 | c_res == 3) & (eda >= 15 & eda <= 98)

* 2. Renombrar variables clave
rename hrsocup horas_semanales

rename ingocup ingreso_mensual
rename rama rama_actividad
rename pos_ocu posicion
rename p3m1 acceso_salud 

* 3. Filtros del Mercado Laboral
keep if posicion == 1
keep if emp_ppal == 2
keep if ingreso_mensual > 0
keep if horas_semanales > 40 & horas_semanales <= 48
* ====================================================================
* FASE 4: ESCENARIO REFORMA 40 HORAS + SALARIO MÍNIMO META (2027-2030)
* ====================================================================

* 1. Definir el costo base actual (2025-2026 se mantienen en las horas originales reportadas)
gen costo_hora_base = ingreso_mensual / (horas_semanales * 4.3)

/* Proyección combinada:
  - Reducción de jornada: 2 horas menos por año a partir de 2027.
  - Salario Mínimo Meta: Se toma el valor diario de la imagen y se mensualiza (* 30.4).
    Si el ingreso mensual del trabajador es menor al mínimo meta, se ajusta al mínimo.
*/

* Definimos los Salarios Mínimos Meta Diarios provistos en la imagen
local sm_diario_2027 = 353.6037
local sm_diario_2028 = 396.8879
local sm_diario_2029 = 445.4705
local sm_diario_2030 = 500.0000

foreach año in 2027 2028 2029 2030 {
    
    * A. Horas meta para el año en curso (reducción gradual)
    local hrs_meta = 48 - (2 * (`año' - 2027))
    
    * B. Calcular el ingreso mensual mínimo legal para este año (Salario Diario * 30.4 días)
    local ing_min_mes = `sm_diario_`año'' * 30.4
    
    * C. Determinar el nuevo ingreso mensual (si gana menos que el nuevo mínimo, se sube al mínimo)
    gen ing_mensual_`año' = ingreso_mensual
    replace ing_mensual_`año' = `ing_min_mes' if ingreso_mensual < `ing_min_mes'
    
    * D. Nuevo costo por hora ajustado por jornada reducida Y salario mínimo meta
    gen c_hora_`año' = ing_mensual_`año' / (`hrs_meta' * 4.3)
    
    * E. Incremento porcentual del costo por hora respecto a la situación base de 2025
    gen inc_clu_`año' = ((c_hora_`año' - costo_hora_base) / costo_hora_base) * 100
}

* ====================================================================
* FASE 5: COLAPSO Y EXPORTACIÓN
* ====================================================================

* Colapsar para obtener el promedio del incremento por sector
collapse (mean) inc_clu_2027 inc_clu_2028 inc_clu_2029 inc_clu_2030 ///
         (sum) total_afectados=fac_tri, by(rama_actividad)

* Cálculo de importancia relativa del sector
egen total_nacional = sum(total_afectados)
gen peso_sectorial = (total_afectados / total_nacional) * 100

* Etiquetar variables para claridad en el Excel
label var inc_clu_2027 "Inc % Costo 2027 (46hrs + SM `$sm_diario_2027')"
label var inc_clu_2028 "Inc % Costo 2028 (44hrs + SM `$sm_diario_2028')"
label var inc_clu_2029 "Inc % Costo 2029 (42hrs + SM `$sm_diario_2029')"
label var inc_clu_2030 "Inc % Costo 2030 (40hrs + SM `$sm_diario_2030')"

* Ordenar por impacto final
gsort -inc_clu_2030

* Exportar resultados final
export excel using "$ruta/Impacto_Reforma_y_SalarioMeta_2027_2030.xlsx", firstrow(varlabels) replace