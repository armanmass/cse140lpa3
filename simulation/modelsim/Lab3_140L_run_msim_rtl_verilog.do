transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Arman/Desktop/Lab3 {C:/Users/Arman/Desktop/Lab3/Lab3_140L.v}
vlog -vlog01compat -work work +incdir+C:/Users/Arman/Desktop/Lab3 {C:/Users/Arman/Desktop/Lab3/countrce.v}

