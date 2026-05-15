
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
.param Rd=12921.967881905988
.param Wn=0.00010936866542222153
.param VG=1.4360597345849873
.param Ln=1.740770606890932e-06




.end
