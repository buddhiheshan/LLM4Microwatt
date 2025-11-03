# Base SDC constraints for Microwatt-LL
# Clock constraint for ext_clk at 50MHz (20ns period)

create_clock [get_ports ext_clk] -name core_clock -period 20.0

