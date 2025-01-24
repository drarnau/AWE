# Replication files for [_Does the Added Worker Effect Matter?_](https://arnau.eu/AWE.pdf)

[This repository](https://github.com/drarnau/AWE) provides instructions and code to replicate all figures and tables in [_Does the Added Worker Effect Matter?_](https://arnau.eu/AWE.pdf) by [Nezih Guner](https://www.cemfi.es/~guner/), [Yuliya Kulikova](https://sites.google.com/site/yuliyakulikova/), and [Arnau Valladares-Esteban](https://arnau.eu).

## How to reproduce figures and tables
First, obtain from [IPUMS-CPS](https://cps.ipums.org/) all monthly samples from January 1976 to December 2022 with the following variables: `YEAR`, `SERIAL`, `MONTH`, `HWTFINL`, `CPSID`, `ASECFLAG`, `MISH`, `STATECENSUS`, `PERNUM`, `WTFINL`, `CPSIDP`, `RELATE`, `AGE`, `SEX`, `RACE`, `MARST`, `NCHILD`, `NCHLT5`, `EMPSTAT`, `OCC2010`, `IND1950`, `WHYUNEMP`, `EDUC`, and `PANLWT`. Download the data in cross-sectional-rectangular-person structure. Save it in `.dta` format in `data/raw/IPUMS-CPS`.

Second, [obtain an API key from FRED](https://fred.stlouisfed.org/docs/api/api_key.html) in order to access GDP and recession macroeconomic data.

Third, edit `0_RunAll.do` to reflect the setting of your machine. In particular, set the FRED API key in line 18, specify the path to these files in your machine in line 21, and specify the name of the IPUMS-CPS raw data file in line 68.

Lastly, run `0_RunAll.do`. The plots and tables created by the code are stored in `graphs/` and `tables/`. `FiguresAndTables.pdf` presents all exhibits as displayed in the paper. `FiguresAndTables.pdf` can be created by compiling `FiguresAndTables.tex`.

Please note that due to the computation of condidence intervals through bootspraping the code execution time can be long. As a reference, using the following CPU:
```shell
Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
Address sizes:       46 bits physical, 48 bits virtual
CPU(s):              24
On-line CPU(s) list: 0-23
Thread(s) per core:  2
Core(s) per socket:  12
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
CPU family:          6
Model:               85
Model name:          Intel(R) Xeon(R) Gold 6136 CPU @ 3.00GHz
Stepping:            4
CPU MHz:             3000.000
CPU max MHz:         3700.0000
CPU min MHz:         1200.0000
BogoMIPS:            6000.00
L1d cache:           384 KiB
L1i cache:           384 KiB
L2 cache:            12 MiB
L3 cache:            24.8 MiB
NUMA node0 CPU(s):   0-23
```
Running the following OS:
```shell
Operating System: Ubuntu 20.04.6 LTS
Kernel: Linux 5.15.0-126-generic
Architecture: x86-64
```
The total execution time to replicate the exhibits presented in the paper is of around 15 days, 5 hours, and 22 minutes.
