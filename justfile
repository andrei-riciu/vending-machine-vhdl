setup:
    mkdir -p proj
    vivado -mode batch -source scripts/setup.tcl -log ./proj/vivado.log -journal ./proj/vivado.jou

sim:
    vivado -mode gui proj/proj.xpr -source scripts/simulate.tcl -log ./proj/vivado.log -journal ./proj/vivado.jou

clean:
    rm -rf proj/
    rm -rf .Xil/
