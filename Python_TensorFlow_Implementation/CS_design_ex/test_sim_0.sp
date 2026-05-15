

Vdd N001 0 5

Vin in 0 SINE({VG} 1m 1e3) AC 1

M1 out in 0 0 N_1u l={Ln} w={Wn}

C2 out 0 1p

R1 N001 out {Rd}

.model NMOS NMOS

.model PMOS PMOS

.lib C:\Users\Mohamed\AppData\Local\LTspice\lib\cmp\standard.mos

.ac dec   100 1k 1e9

 *.op

.inc cmosedu_models.lib

.param Rd=25000
.param Wn=0.0002
.param VG=1.1
.param Ln=5e-06








.end

