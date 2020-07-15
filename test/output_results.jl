alpha_md = raw"""|        flag |    name |      f(x) |   time |   iter |
|-------------|---------|-----------|--------|--------|
|     failure | prob001 | -6.89e-01 |  62.37 |     70 |
|     failure | prob002 | -7.63e-01 | 353.13 |     10 |
| first_order | prob003 |  3.97e-01 | 767.60 |     10 |
| first_order | prob004 |  8.12e-01 |  43.14 |     80 |
| first_order | prob005 | -3.46e-01 | 267.99 |     30 |
| first_order | prob006 | -1.88e-01 |  66.85 |     80 |
| first_order | prob007 | -1.61e+00 | 156.64 |     60 |
| first_order | prob008 | -2.48e+00 | 605.30 |     40 |
| first_order | prob009 |  2.28e+00 | 135.75 |     40 |
|     failure | prob010 |  2.20e-01 | 838.12 |     50 |
"""

alpha_tex = raw"""\begin{longtable}{rrrrr}
\hline
flag & name & \(f(x)\) & time & iter \\\hline
\endhead
\hline
\multicolumn{5}{r}{{\bfseries Continued on next page}}\\
\hline
\endfoot
\endlastfoot
failure & prob001 & \(-6.89\)e\(-01\) & \( 6.24\)e\(+01\) & \(    70\) \\
failure & prob002 & \(-7.63\)e\(-01\) & \( 3.53\)e\(+02\) & \(    10\) \\
first\_order & prob003 & \( 3.97\)e\(-01\) & \( 7.68\)e\(+02\) & \(    10\) \\
first\_order & prob004 & \( 8.12\)e\(-01\) & \( 4.31\)e\(+01\) & \(    80\) \\
first\_order & prob005 & \(-3.46\)e\(-01\) & \( 2.68\)e\(+02\) & \(    30\) \\
first\_order & prob006 & \(-1.88\)e\(-01\) & \( 6.68\)e\(+01\) & \(    80\) \\
first\_order & prob007 & \(-1.61\)e\(+00\) & \( 1.57\)e\(+02\) & \(    60\) \\
first\_order & prob008 & \(-2.48\)e\(+00\) & \( 6.05\)e\(+02\) & \(    40\) \\
first\_order & prob009 & \( 2.28\)e\(+00\) & \( 1.36\)e\(+02\) & \(    40\) \\
failure & prob010 & \( 2.20\)e\(-01\) & \( 8.38\)e\(+02\) & \(    50\) \\\hline
\end{longtable}
"""

alpha_txt = raw"""┌─────────────┬─────────┬───────────┬────────┬────────┐
│        flag │    name │      f(x) │   time │   iter │
├─────────────┼─────────┼───────────┼────────┼────────┤
│     failure │ prob001 │ -6.89e-01 │  62.37 │     70 │
│     failure │ prob002 │ -7.63e-01 │ 353.13 │     10 │
│ first_order │ prob003 │  3.97e-01 │ 767.60 │     10 │
│ first_order │ prob004 │  8.12e-01 │  43.14 │     80 │
│ first_order │ prob005 │ -3.46e-01 │ 267.99 │     30 │
│ first_order │ prob006 │ -1.88e-01 │  66.85 │     80 │
│ first_order │ prob007 │ -1.61e+00 │ 156.64 │     60 │
│ first_order │ prob008 │ -2.48e+00 │ 605.30 │     40 │
│ first_order │ prob009 │  2.28e+00 │ 135.75 │     40 │
│     failure │ prob010 │  2.20e-01 │ 838.12 │     50 │
└─────────────┴─────────┴───────────┴────────┴────────┘
"""

alpha_hi_tex = raw"""\begin{longtable}{rrrrr}
\hline
flag & name & \(f(x)\) & time & iter \\\hline
\endhead
\hline
\multicolumn{5}{r}{{\bfseries Continued on next page}}\\
\hline
\endfoot
\endlastfoot
\cellcolor{red}{failure} & \cellcolor{red}{prob001} & \cellcolor{red}{\(-6.89\)e\(-01\)} & \cellcolor{red}{\( 6.24\)e\(+01\)} & \cellcolor{red}{\(    70\)} \\
\cellcolor{red}{failure} & \cellcolor{red}{prob002} & \cellcolor{red}{\(-7.63\)e\(-01\)} & \cellcolor{red}{\( 3.53\)e\(+02\)} & \cellcolor{red}{\(    10\)} \\
first\_order & prob003 & \( 3.97\)e\(-01\) & \( 7.68\)e\(+02\) & \(    10\) \\
first\_order & prob004 & \( 8.12\)e\(-01\) & \( 4.31\)e\(+01\) & \(    80\) \\
first\_order & prob005 & \(-3.46\)e\(-01\) & \( 2.68\)e\(+02\) & \(    30\) \\
first\_order & prob006 & \(-1.88\)e\(-01\) & \( 6.68\)e\(+01\) & \(    80\) \\
first\_order & prob007 & \(-1.61\)e\(+00\) & \( 1.57\)e\(+02\) & \(    60\) \\
first\_order & prob008 & \(-2.48\)e\(+00\) & \( 6.05\)e\(+02\) & \(    40\) \\
first\_order & prob009 & \( 2.28\)e\(+00\) & \( 1.36\)e\(+02\) & \(    40\) \\
\cellcolor{red}{failure} & \cellcolor{red}{prob010} & \cellcolor{red}{\( 2.20\)e\(-01\)} & \cellcolor{red}{\( 8.38\)e\(+02\)} & \cellcolor{red}{\(    50\)} \\\hline
\end{longtable}
"""

joined_tex = raw"""\begin{longtable}{rrrrrrrrrrr}
\hline
id & name & flag\_alpha & f\_alpha & t\_alpha & flag\_beta & f\_beta & t\_beta & flag\_gamma & f\_gamma & t\_gamma \\\hline
\endhead
\hline
\multicolumn{11}{r}{{\bfseries Continued on next page}}\\
\hline
\endfoot
\endlastfoot
\(     1\) & prob001 & failure & \(-6.89\)e\(-01\) & \( 6.24\)e\(+01\) & first\_order & \(-1.05\)e\(+00\) & \( 1.77\)e\(+02\) & first\_order & \( 6.34\)e\(-02\) & \( 3.26\)e\(+01\) \\
\(     2\) & prob002 & failure & \(-7.63\)e\(-01\) & \( 3.53\)e\(+02\) & failure & \( 8.16\)e\(-01\) & \( 8.00\)e\(+01\) & first\_order & \( 1.19\)e\(-01\) & \( 6.86\)e\(+02\) \\
\(     3\) & prob003 & first\_order & \( 3.97\)e\(-01\) & \( 7.68\)e\(+02\) & first\_order & \( 1.53\)e\(-01\) & \( 6.82\)e\(+02\) & first\_order & \( 2.71\)e\(+00\) & \( 8.41\)e\(+02\) \\
\(     4\) & prob004 & first\_order & \( 8.12\)e\(-01\) & \( 4.31\)e\(+01\) & failure & \(-3.30\)e\(-01\) & \( 9.29\)e\(+02\) & failure & \(-6.91\)e\(-01\) & \( 1.90\)e\(+02\) \\
\(     5\) & prob005 & first\_order & \(-3.46\)e\(-01\) & \( 2.68\)e\(+02\) & failure & \( 1.44\)e\(+00\) & \( 9.73\)e\(+02\) & failure & \(-5.51\)e\(-02\) & \( 1.62\)e\(+02\) \\
\(     6\) & prob006 & first\_order & \(-1.88\)e\(-01\) & \( 6.68\)e\(+01\) & first\_order & \(-4.43\)e\(-01\) & \( 6.52\)e\(+02\) & first\_order & \( 4.23\)e\(-01\) & \( 8.97\)e\(+02\) \\
\(     7\) & prob007 & first\_order & \(-1.61\)e\(+00\) & \( 1.57\)e\(+02\) & first\_order & \( 1.10\)e\(+00\) & \( 5.97\)e\(+02\) & first\_order & \(-1.43\)e\(+00\) & \( 9.54\)e\(+01\) \\
\(     8\) & prob008 & first\_order & \(-2.48\)e\(+00\) & \( 6.05\)e\(+02\) & first\_order & \(-2.51\)e\(-01\) & \( 4.79\)e\(+02\) & failure & \(-4.50\)e\(-01\) & \( 7.77\)e\(+02\) \\
\(     9\) & prob009 & first\_order & \( 2.28\)e\(+00\) & \( 1.36\)e\(+02\) & failure & \( 2.92\)e\(-01\) & \( 6.32\)e\(+01\) & failure & \(-8.81\)e\(-01\) & \( 8.68\)e\(+02\) \\
\(    10\) & prob010 & failure & \( 2.20\)e\(-01\) & \( 8.38\)e\(+02\) & first\_order & \(-3.47\)e\(+00\) & \( 4.71\)e\(+02\) & first\_order & \( 1.08\)e\(+00\) & \( 8.38\)e\(+02\) \\\hline
\end{longtable}
"""

joined_md = raw"""|     id |    name |  flag_alpha |   f_alpha |   t_alpha |   flag_beta |    f_beta |    t_beta |  flag_gamma |   f_gamma |   t_gamma |
|--------|---------|-------------|-----------|-----------|-------------|-----------|-----------|-------------|-----------|-----------|
|      1 | prob001 |     failure | -6.89e-01 |  6.24e+01 | first_order | -1.05e+00 |  1.77e+02 | first_order |  6.34e-02 |  3.26e+01 |
|      2 | prob002 |     failure | -7.63e-01 |  3.53e+02 |     failure |  8.16e-01 |  8.00e+01 | first_order |  1.19e-01 |  6.86e+02 |
|      3 | prob003 | first_order |  3.97e-01 |  7.68e+02 | first_order |  1.53e-01 |  6.82e+02 | first_order |  2.71e+00 |  8.41e+02 |
|      4 | prob004 | first_order |  8.12e-01 |  4.31e+01 |     failure | -3.30e-01 |  9.29e+02 |     failure | -6.91e-01 |  1.90e+02 |
|      5 | prob005 | first_order | -3.46e-01 |  2.68e+02 |     failure |  1.44e+00 |  9.73e+02 |     failure | -5.51e-02 |  1.62e+02 |
|      6 | prob006 | first_order | -1.88e-01 |  6.68e+01 | first_order | -4.43e-01 |  6.52e+02 | first_order |  4.23e-01 |  8.97e+02 |
|      7 | prob007 | first_order | -1.61e+00 |  1.57e+02 | first_order |  1.10e+00 |  5.97e+02 | first_order | -1.43e+00 |  9.54e+01 |
|      8 | prob008 | first_order | -2.48e+00 |  6.05e+02 | first_order | -2.51e-01 |  4.79e+02 |     failure | -4.50e-01 |  7.77e+02 |
|      9 | prob009 | first_order |  2.28e+00 |  1.36e+02 |     failure |  2.92e-01 |  6.32e+01 |     failure | -8.81e-01 |  8.68e+02 |
|     10 | prob010 |     failure |  2.20e-01 |  8.38e+02 | first_order | -3.47e+00 |  4.71e+02 | first_order |  1.08e+00 |  8.38e+02 |
"""

missing_md = raw"""|         A |       B |       C |       D |
|-----------|---------|---------|---------|
|  1.00e+00 | missing | missing | missing |
|   missing |       1 |       a | missing |
|  3.00e+00 |       3 |       b | notmiss |
"""

missing_ltx = raw"""\begin{longtable}{rrrr}
\hline
A & B & C & D \\\hline
\endhead
\hline
\multicolumn{4}{r}{{\bfseries Continued on next page}}\\
\hline
\endfoot
\endlastfoot
\( 1.00\)e\(+00\) &            &   & missing \\
                  & \(     1\) & a & missing \\
\( 3.00\)e\(+00\) & \(     3\) & b & notmiss \\\hline
\end{longtable}
"""