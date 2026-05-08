1. X = 100 minutes, X is 50% faster than Y, Y = ?
Y=150min
  
2. X = 100 minutes, X is 3 times faster than Y, Y = ?
Y=300min
  
3. Program X has 100 instructions, with each instruction taking an average of 2 CPU cycles. The total CPU time for X is 50 ns. Find the CPU clock rate.
$$
\text{Clock Rate}=\frac{IC\times CPI}{\text{CPU Time}}=\frac{2\times100}{50\times10^{-9}}=4\times10^9\text{ Hz}=4\text{ GHz}
$$
  
  
4. Cycles per instruction is 2, Clock rate is 4 GHZ, find the MIPS.

$$
\text{MIPS}=\frac{\text{Clock Rate}}{CPI\times 10^6}=\frac{4\times10^{9}}{2\times 10^6}=2000
$$

5. If an enhancement speeds up fraction 50% of a task by 2 times, find the overall speedup.

  $$
\text{Speedup}_{\text{overall}}=\frac{1}{(1-f)+\frac{f}{S}}=\frac{1}{(1-0.5)+\frac{0.5}{2}}=\frac{4}{3}\approx1.333
$$
  
6. If an enhancement speeds up fraction of a task by 2 times, and the overall speedup is 1.5, find the fraction.
by the same formula: f = 2/3 

7. If a task can be sped up to at most 2 times, what fraction of it can be accelerated?

  $$
f=1-\frac{1}{\text{Speedup}_{\max}}=1-\frac{1}{2}=\frac{1}{2}
$$

8. Cost of wafer = 10000, dies per wafer = 1000, die yield = 80%, cost of testing = 5, cost of packaging = 5, final test yield = 50%, calculate the cost of IC.

  $$
\text{Cost of IC}=\frac{\text{Cost of Die}+\text{Cost of Testing}+\text{Cost of Packaging}}{\text{Final Test Yield}}=\frac{\frac{10000}{1000\times0.8}+5+5}{0.5}=45
$$
  

9. Module availability = 0.5. If FIT becomes 2 times as before, calculate the new Module availability.

$$
\text{new Module Availability}=\frac{1}{3}
$$
