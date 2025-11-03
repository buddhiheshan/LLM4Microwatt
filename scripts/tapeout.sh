#!/bin/bash -e
set -x

# Where to do tape out - WARNING: needs ~20GB of disk

export MPW=~/projects/LLM4Microwatt/scratch

export PDK=sky130A

export ROUTING_CORES=$(nproc)

export OPENLANE_ROOT=$MPW/OpenLane
export PDK_ROOT=$OPENLANE_ROOT/pdks
export CARAVEL_USER_PROJECT_ROOT=$MPW/caravel_user_project
export CARAVEL_ROOT=$CARAVEL_USER_PROJECT_ROOT/caravel
export MCW_ROOT=$CARAVEL_USER_PROJECT_ROOT/mgmt_core_wrapper

# Clone the repos and initial setup
mkdir -p $MPW

cd $MPW
git clone --depth 1 https://github.com/antonblanchard/DFFRAM -b microwatt-20221228
git clone --depth 1 https://github.com/antonblanchard/microwatt -b caravel-mpw7-20221125

cd $MPW/..

make setup

#Convert VHDL to verilog
cd $MPW/microwatt
make DOCKER=1 FPGA_TARGET=caravel microwatt_asic.v

cp $MPW/microwatt/microwatt_asic.v $MPW/../verilog/rtl/microwatt.v

# RAM generation
cat > $MPW/DFFRAM/ram512_pin_order.cfg << EOF
#S
A0.*
Di0.*
CLK
Do0.*
WE0.*
EN0.*
EOF

cat > $MPW/DFFRAM/ram32_1rw1r_pin_order.cfg << EOF
#N
CLK
EN0.*
EN1.*
WE0.*
A0.*
A1.*
Di0.*
Do1.*
#S
Do0.*
EOF

# Build cache and main RAM DFFRAMs
cd $MPW/DFFRAM
./dffram.py --pdk-root $PDK_ROOT --size 32x64 --variant 1RW1R --min-height 180 --pin_order=ram32_1rw1r_pin_order.cfg
./dffram.py --pdk-root $PDK_ROOT --size 512x64 --vertical-halo 100 --horizontal-halo 20 --pin_order=ram512_pin_order.cfg

# copy in RAMS
for RAM in 512x64_DEFAULT 32x64_1RW1R
do
	cd $MPW/DFFRAM/build/$RAM/products
	tar cf - . | (cd $CARAVEL_USER_PROJECT_ROOT && tar xvf -)
	cd -
done

# Build other macros
cd $MPW/..
make multiply_add_64x64
make Microwatt_FP_DFFRFile

make microwatt