# Solar PV System Simulation

Simulation of a PV system in GNU Octave, built around the datasheet of a real panel (Kyocera KC200GT, 200 W).

![PV module characteristics](Phase1/images/iv_curves.png)

*I-V and P-V characteristics of the modelled panel at varying irradiance and temperature.*

## Phases

| Phase | Topic | Status | README |
|---|---|---|---|
| 1 | PV module modelling and P&O MPPT | Completed | [Phase 1](Phase1/README.md) |
| 2 | Boost Converter with Closed-Loop Voltage Control | Completed | [Phase 2](Phase2/README.md) |

## Completed

### Phase 1: PV Module Modelling and MPPT

- Single-diode model of the module, with the four unknown parameters extracted from datasheet values using `fsolve`.
- I-V and P-V characteristics at irradiance of 200 to 1000 W/m² and temperature of 25 to 75 °C.
- Perturb & Observe MPPT, with the effect of step size on convergence and oscillation.

**Key results**

| Quantity | Datasheet | Model |
|---|---|---|
| $P_{max}$ | 200.143 W | about 200 W |
| $V_{oc}$ at 25 °C | 32.9 V | 32.87 V |
| $V_{oc}$ at 75 °C | about 27 V | 27.33 V |
| P&O at 0.1 V step | | converges in about 100 iterations, oscillates within about 0.04 W of $P_{max}$ |

### Phase 2: Boost Converter with PI Control

- Averaged boost converter model, stepping a 10-module PV string (263 V) up to a 400 V DC link.
- Inductor and capacitor sized from ripple specifications.
- PI voltage control, with controller gains tuned and checked for stability.

**Key results**

| Quantity | Design | Simulated |
|---|---|---|
| $V_{out}$ | 400 V | 400.00 V |
| Duty cycle $D$ | 0.3425 | 0.3425 |
| $i_L$ | 7.6 A | 7.60 A |
| Stable gain | | $K_p = 0.0005$, $K_i = 0.1$ |

## Repository structure

```
solar-pv-simulation/
├── README.md
├── Phase1/
│   ├── README.md
│   ├── pv_module_main.m
│   ├── pv_model_po.m
│   └── images/
└── Phase2/
    ├── README.md
    ├── boost_conv.m
    └── images/
```