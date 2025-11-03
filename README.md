
# LLM4Microwatt

This project explores the use of Large Language Models (LLMs) to accelerate hardware innovation by automatically generating RTL for architectural improvements in the open-source Microwatt CPU core. Our approach builds upon recent tools such as ChipChat and AutoChip, which generate RTL from natural language, and extends the concept to practical microarchitectural enhancements. This creates a bridge between AI-driven design and open hardware, enabling rapid prototyping and experimentation.

---

## Approach

1. Synthesize Microwatt core for OpenFrame platform  
2. Make microarchitectural changes to Microwatt core using LLMs  
3. Run simulations to verify the changes  
4. Re-run the synthesis flow to generate GDS layout  

---

## Progress

1. **Synthesize Microwatt core for OpenFrame platform**
   - Convert VHDL to Verilog — ✅ Completed  
   - Generate macros - ⚠️ Blocked
     - multiply_add_64x64 — ✅ Completed  
     - Microwatt_FP_DFFRFile — ✅ Completed  
     - RAM32_1RW1W — ❌ Hold time violations  
     - RAM512 — ❌ Hold time violations  
   - Harden the Microwatt core — ⚠️ Incomplete  

2. **Microarchitectural changes** — ⏳ Pending  
3. **Simulation to verify improvements** — ⏳ Pending  
4. **Final hardening & GDS generation** — ⏳ Pending  

---

## Challenges

### 1. Hardening the `multiply_add_64x64` Macro

Initial configuration:

```json
{
  "CLOCK_PERIOD": 15,
  "DIE_AREA": "0 0 550 550"
  ...
}
```

Placement failed due to >100% utilization:

```
[ERROR GPL-0301] Utilization 127.441 % exceeds 100%
```

Increasing die size to `0 0 900 900` avoided congestion but caused setup time violations. Raising the clock period to 20ns led to a successful build.

✅ **Final working config:**

```json
{
  "CLOCK_PERIOD": 20,
  "DIE_AREA": "0 0 900 900"
  ...
}
```

This emphasized the trade-offs between timing closure and silicon area for dense arithmetic blocks.


### 2. Generating `RAM32_1RW1W` and `RAM512` via DFFRAM

Synthesis of the needed RAM macros resulted in hold-time and physical rule violations:

```
[WARNING]: slew/fanout/capacitance violations
[ERROR]: hold violations
```

OpenRAM was evaluated as an alternative, but it does not support the specific RAM configurations required by Microwatt.

❌ **Outcome:** RAM macro generation remains unresolved and may require custom memory compilation or different tooling.


### 3. Hardening Microwatt Without Memory Macros

A full hardening run without custom memory macros was attempted:

Initial config:

```json
{
  "CLOCK_PERIOD": 20,
  "DIE_AREA": "0 0 5000 3000"
  ...
}
```

This failed due to routing congestion. Expanding the area to:

```json
{
  "CLOCK_PERIOD": 20,
  "DIE_AREA": "0 0 8000 7000"
  ...
}
```

produced a working GDS, but the area ballooned to ~56 mm² — far exceeding the ~15 mm² OpenFrame platform budget.

🔎 **Insight:** While technically feasible, macro-less implementation is impractical for real silicon area constraints.

---

## Conclusion

This project established a complete open-source hardware flow around Microwatt, converting VHDL to Verilog, hardening arithmetic units, and generating a full core GDS. Through hands-on experimentation, we learned critical lessons in memory macro generation, timing-area trade-offs, and congestion management in open toolchains.

---

## Reference

* Microwatt: [https://github.com/antonblanchard/microwatt](https://github.com/antonblanchard/microwatt)
* Microwatt-Caravel: [https://github.com/antonblanchard/microwatt-caravel](https://github.com/antonblanchard/microwatt-caravel)

---

