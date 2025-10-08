# FLARE — **Fallback Logic for Anomaly Response Event**

## PROJECT OVERVIEW

**FLARE** is a real-time hardware-based fallback communication controller designed to demonstrate how a small satellite (or any embedded system) can detect high-energy disturbances—like simulated solar flares—and autonomously switch to a **safe communication state**.
This prototype was implemented using a **Nexys A7 FPGA board**, an **LM393 comparator**, and a **light-dependent resistor (LDR)** to emulate flare detection.

---

## PROBLEM STATEMENT

Small satellites (CubeSats, student payloads, or low-cost communication systems) are vulnerable to **solar flare–induced signal losses** and **electromagnetic disturbances**.
Existing mitigations (ground-based alerts, redundant radios, or software fallback) are often:

* **Slow**, because they rely on communication from Earth.
* **Power-heavy**, due to redundant hardware.
* **Unreliable**, since the main CPU may also fail during radiation events.

**Goal:**
Design a **low-cost**, **fast**, and **independent** fallback mechanism that triggers instantly when radiation or signal anomalies are detected — even if the main CPU is offline.

---

## USE CASES

* CubeSat radio blackout fallback control.
* Ground-based communication link safety switching.
* Hardware demonstration of sensor-driven failsafe systems.
* FPGA-based real-time monitoring applications.

---

## DESIGN REQUIREMENTS

* **Input:** Analog voltage representing sensor data (LDR output via LM393 comparator).
* **Processing:** Finite State Machine (FSM) inside FPGA with states:

  * `NORMAL` – standard communication active.
  * `FALLBACK` – flare detected, switch to safe mode.
  * `RECOVER` – system returns to normal after flare clears.
* **Output:**

  * LEDs indicate current mode.
  * 7-segment display shows visual state output (text/letters).
* **Reaction time:** Within microseconds (hardware event).
* **Autonomous:** No CPU or software dependency.

---

## DESIGN METHODOLOGY

* Implemented as a **hardware finite state machine** on the FPGA.
* The **LM393 comparator** converts the analog LDR signal to a digital logic level.
* FPGA input pin receives the comparator output (`flare_detect`).
* Based on the input, LEDs and 7-segment displays show the mode transitions.
* Design ensures **real-time switching** between `NORMAL`, `FALLBACK`, and `RECOVER`.

---

## HARDWARE SETUP

**Main Components:**

* Nexys A7 FPGA board
* LM393 Comparator
* LDR (Light Dependent Resistor)
* Potentiometer (to adjust sensitivity)
* Resistors (10 kΩ pull-up and 100 kΩ feedback)

**Basic Wiring:**

| Component                    | Connection                      | Description                      |
| ---------------------------- | ------------------------------- | -------------------------------- |
| LM393 VCC                    | 3.3 V                           | Power supply                     |
| LM393 GND                    | GND                             | Ground                           |
| LM393 OUT                    | FPGA Digital Pin (flare_detect) | Comparator output                |
| LDR + Potentiometer          | LM393 IN+ / IN−                 | Sensor divider input             |
| Pull-up Resistor             | OUT → 3.3 V                     | Ensures stable logic level       |
| Feedback Resistor (optional) | OUT → IN+                       | Adds hysteresis to prevent noise |
| Capacitor (optional)         | Sensor node → GND               | Reduces flicker/noise            |

---

## FUNCTIONAL FLOW

| State        | Input Condition   | Output (LED / 7-Seg)    | Description                |
| ------------ | ----------------- | ----------------------- | -------------------------- |
| **NORMAL**   | No flare detected | Normal LED ON           | System in normal operation |
| **FALLBACK** | Flare detected    | Fallback LED ON         | Switches to safe mode      |
| **RECOVER**  | Flare cleared     | Both LEDs briefly blink | Returns to normal mode     |

---

## FUNCTIONAL SIMULATION & TESTING

**Simulation Objective:** Validate state transitions and timing response.

**Procedure:**

1. Apply a simulated `flare_detect` input signal.
2. Observe transitions between `NORMAL → FALLBACK → RECOVER`.
3. Confirm LED and 7-segment updates correctly reflect state.

**Physical Test:**

1. Upload bitstream to Nexys A7.
2. Shine a torch on the LDR to simulate flare.
3. Observe LED or display changes.
4. Adjust potentiometer to tune flare threshold.

---

## TROUBLESHOOTING GUIDE

| Symptom                         | Possible Cause                             | Solution                            |
| ------------------------------- | ------------------------------------------ | ----------------------------------- |
| LEDs don’t respond              | Comparator output not connected / floating | Add 10 kΩ pull-up resistor          |
| Comparator gives analog voltage | Missing pull-up resistor                   | Connect OUT → 3.3 V through 10 kΩ   |
| LED logic inverted              | Comparator polarity mismatch               | Invert logic in HDL code            |
| Flickering output               | No hysteresis / noisy sensor               | Add feedback resistor and capacitor |
| Works with switch but not LDR   | Wrong pin or analog-only pin used          | Connect OUT to digital-capable pin  |

---

## DESIGN COMPARISON TABLE

| Method                                           | Reaction Time         | Complexity  | Power    | Mass         | Cost    | Dependency           | Suitable For                  |
| ------------------------------------------------ | --------------------- | ----------- | -------- | ------------ | ------- | -------------------- | ----------------------------- |
| Ground-based monitoring (e.g., NOAA/ISRO alerts) | Slow (minutes–hours)  | Low         | Low      | N/A          | Low     | Ground networks      | Forecasting only              |
| Onboard CPU-based fallback                       | Medium                | Medium-High | Moderate | Moderate     | Medium  | CPU & Software       | Larger satellites             |
| Redundant radio hardware                         | Fast                  | High        | High     | High         | High    | Extra RF modules     | High-value missions           |
| **FPGA-based comparator fallback (FLARE)**       | **Very fast (µs–ms)** | **Low**     | **Low**  | **Very low** | **Low** | **Independent FPGA** | **CubeSats & failsafe demos** |

---

## RESULTS & ANALYSIS

* **All state transitions observed correctly** on both simulation and hardware.
* **Reaction time:** Instantaneous hardware response (<1 ms).
* **Low power consumption:** LM393 + FPGA logic consume minimal current.
* **Robustness:** Operates even when CPU or communication software fails.

---

## CHALLENGES

* Handling noisy sensor signals without false triggers.
* Determining comparator polarity (active-high vs active-low).
* Maintaining stable logic levels without floating inputs.

---

## CONCLUSION

**FLARE** successfully demonstrates a lightweight, reliable, and fast fallback system suitable for small satellite or embedded communication modules.
It is **independent**, **real-time**, and **scalable**, serving as a base for radiation-hardened or mission-grade implementations.

---

## FUTURE IMPROVEMENTS

* Replace LDR with radiation or UV flux sensor for real mission simulation.
* Add UART telemetry for state logging.
* Integrate triple modular redundancy (TMR) for radiation resilience.
* Add auto-calibration of comparator threshold based on environment.

---


