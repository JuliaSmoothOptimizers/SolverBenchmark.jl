alpha_md = raw"""|        flag |    name |      f(x) |   time |   iter |
|-------------|---------|-----------|--------|--------|
|     failure | prob001 |  1.11e+00 | 587.79 |      5 |
|     failure | prob002 |  1.22e+00 | 951.06 |      5 |
| first_order | prob003 |  1.35e+00 | 951.06 |      5 |
|     failure | prob004 |  1.49e+00 | 587.79 |      5 |
|     failure | prob005 |  1.65e+00 |   0.00 |      5 |
| first_order | prob006 |  1.82e+00 | 587.79 |      3 |
|     failure | prob007 |  2.01e+00 | 951.06 |      3 |
|     failure | prob008 |  2.23e+00 | 951.06 |      3 |
| first_order | prob009 |  2.46e+00 | 587.79 |      3 |
|     failure | prob010 |  2.72e+00 |   0.00 |      3 |
"""

alpha_tex = raw"""\begin{longtable}{rrrrr}
\hline
flag & name & \(f(x)\) & time & iter \\\hline
\endfirsthead
\hline
flag & name & \(f(x)\) & time & iter \\\hline
\endhead
\hline
\multicolumn{5}{r}{{\bfseries Continued on next page}}\\
\hline
\endfoot
\endlastfoot
failure & prob001 & \( 1.11\)e\(+00\) & \( 5.88\)e\(+02\) & \(     5\) \\
failure & prob002 & \( 1.22\)e\(+00\) & \( 9.51\)e\(+02\) & \(     5\) \\
first\_order & prob003 & \( 1.35\)e\(+00\) & \( 9.51\)e\(+02\) & \(     5\) \\
failure & prob004 & \( 1.49\)e\(+00\) & \( 5.88\)e\(+02\) & \(     5\) \\
failure & prob005 & \( 1.65\)e\(+00\) & \( 1.00\)e\(-03\) & \(     5\) \\
first\_order & prob006 & \( 1.82\)e\(+00\) & \( 5.88\)e\(+02\) & \(     3\) \\
failure & prob007 & \( 2.01\)e\(+00\) & \( 9.51\)e\(+02\) & \(     3\) \\
failure & prob008 & \( 2.23\)e\(+00\) & \( 9.51\)e\(+02\) & \(     3\) \\
first\_order & prob009 & \( 2.46\)e\(+00\) & \( 5.88\)e\(+02\) & \(     3\) \\
failure & prob010 & \( 2.72\)e\(+00\) & \( 1.00\)e\(-03\) & \(     3\) \\\hline
\end{longtable}
"""

alpha_txt = raw"""┌─────────────┬─────────┬───────────┬────────┬────────┐
│        flag │    name │      f(x) │   time │   iter │
├─────────────┼─────────┼───────────┼────────┼────────┤
│     failure │ prob001 │  1.11e+00 │ 587.79 │      5 │
│     failure │ prob002 │  1.22e+00 │ 951.06 │      5 │
│ first_order │ prob003 │  1.35e+00 │ 951.06 │      5 │
│     failure │ prob004 │  1.49e+00 │ 587.79 │      5 │
│     failure │ prob005 │  1.65e+00 │   0.00 │      5 │
│ first_order │ prob006 │  1.82e+00 │ 587.79 │      3 │
│     failure │ prob007 │  2.01e+00 │ 951.06 │      3 │
│     failure │ prob008 │  2.23e+00 │ 951.06 │      3 │
│ first_order │ prob009 │  2.46e+00 │ 587.79 │      3 │
│     failure │ prob010 │  2.72e+00 │   0.00 │      3 │
└─────────────┴─────────┴───────────┴────────┴────────┘
"""

alpha_hi_tex = raw"""\begin{longtable}{rrrrr}
\hline
flag & name & \(f(x)\) & time & iter \\\hline
\endfirsthead
\hline
flag & name & \(f(x)\) & time & iter \\\hline
\endhead
\hline
\multicolumn{5}{r}{{\bfseries Continued on next page}}\\
\hline
\endfoot
\endlastfoot
\cellcolor{red}{failure} & \cellcolor{red}{prob001} & \cellcolor{red}{\( 1.11\)e\(+00\)} & \cellcolor{red}{\( 5.88\)e\(+02\)} & \cellcolor{red}{\(     5\)} \\
\cellcolor{red}{failure} & \cellcolor{red}{prob002} & \cellcolor{red}{\( 1.22\)e\(+00\)} & \cellcolor{red}{\( 9.51\)e\(+02\)} & \cellcolor{red}{\(     5\)} \\
first\_order & prob003 & \( 1.35\)e\(+00\) & \( 9.51\)e\(+02\) & \(     5\) \\
\cellcolor{red}{failure} & \cellcolor{red}{prob004} & \cellcolor{red}{\( 1.49\)e\(+00\)} & \cellcolor{red}{\( 5.88\)e\(+02\)} & \cellcolor{red}{\(     5\)} \\
\cellcolor{red}{failure} & \cellcolor{red}{prob005} & \cellcolor{red}{\( 1.65\)e\(+00\)} & \cellcolor{red}{\( 1.00\)e\(-03\)} & \cellcolor{red}{\(     5\)} \\
first\_order & prob006 & \( 1.82\)e\(+00\) & \( 5.88\)e\(+02\) & \(     3\) \\
\cellcolor{red}{failure} & \cellcolor{red}{prob007} & \cellcolor{red}{\( 2.01\)e\(+00\)} & \cellcolor{red}{\( 9.51\)e\(+02\)} & \cellcolor{red}{\(     3\)} \\
\cellcolor{red}{failure} & \cellcolor{red}{prob008} & \cellcolor{red}{\( 2.23\)e\(+00\)} & \cellcolor{red}{\( 9.51\)e\(+02\)} & \cellcolor{red}{\(     3\)} \\
first\_order & prob009 & \( 2.46\)e\(+00\) & \( 5.88\)e\(+02\) & \(     3\) \\
\cellcolor{red}{failure} & \cellcolor{red}{prob010} & \cellcolor{red}{\( 2.72\)e\(+00\)} & \cellcolor{red}{\( 1.00\)e\(-03\)} & \cellcolor{red}{\(     3\)} \\\hline
\end{longtable}
"""

joined_tex = raw"""\begin{longtable}{rrrrrrrrrrr}
\hline
id & name & flag\_alpha & f\_alpha & t\_alpha & flag\_beta & f\_beta & t\_beta & flag\_gamma & f\_gamma & t\_gamma \\\hline
\endfirsthead
\hline
id & name & flag\_alpha & f\_alpha & t\_alpha & flag\_beta & f\_beta & t\_beta & flag\_gamma & f\_gamma & t\_gamma \\\hline
\endhead
\hline
\multicolumn{11}{r}{{\bfseries Continued on next page}}\\
\hline
\endfoot
\endlastfoot
\(     1\) & prob001 & failure & \( 1.11\)e\(+00\) & \( 5.88\)e\(+02\) & failure & \( 1.11\)e\(+00\) & \( 5.88\)e\(+02\) & failure & \( 1.11\)e\(+00\) & \( 5.88\)e\(+02\) \\
\(     2\) & prob002 & failure & \( 1.22\)e\(+00\) & \( 9.51\)e\(+02\) & failure & \( 1.22\)e\(+00\) & \( 9.51\)e\(+02\) & failure & \( 1.22\)e\(+00\) & \( 9.51\)e\(+02\) \\
\(     3\) & prob003 & first\_order & \( 1.35\)e\(+00\) & \( 9.51\)e\(+02\) & first\_order & \( 1.35\)e\(+00\) & \( 9.51\)e\(+02\) & first\_order & \( 1.35\)e\(+00\) & \( 9.51\)e\(+02\) \\
\(     4\) & prob004 & failure & \( 1.49\)e\(+00\) & \( 5.88\)e\(+02\) & failure & \( 1.49\)e\(+00\) & \( 5.88\)e\(+02\) & failure & \( 1.49\)e\(+00\) & \( 5.88\)e\(+02\) \\
\(     5\) & prob005 & failure & \( 1.65\)e\(+00\) & \( 1.00\)e\(-03\) & failure & \( 1.65\)e\(+00\) & \( 1.00\)e\(-03\) & failure & \( 1.65\)e\(+00\) & \( 1.00\)e\(-03\) \\
\(     6\) & prob006 & first\_order & \( 1.82\)e\(+00\) & \( 5.88\)e\(+02\) & first\_order & \( 1.82\)e\(+00\) & \( 5.88\)e\(+02\) & first\_order & \( 1.82\)e\(+00\) & \( 5.88\)e\(+02\) \\
\(     7\) & prob007 & failure & \( 2.01\)e\(+00\) & \( 9.51\)e\(+02\) & failure & \( 2.01\)e\(+00\) & \( 9.51\)e\(+02\) & failure & \( 2.01\)e\(+00\) & \( 9.51\)e\(+02\) \\
\(     8\) & prob008 & failure & \( 2.23\)e\(+00\) & \( 9.51\)e\(+02\) & failure & \( 2.23\)e\(+00\) & \( 9.51\)e\(+02\) & failure & \( 2.23\)e\(+00\) & \( 9.51\)e\(+02\) \\
\(     9\) & prob009 & first\_order & \( 2.46\)e\(+00\) & \( 5.88\)e\(+02\) & first\_order & \( 2.46\)e\(+00\) & \( 5.88\)e\(+02\) & first\_order & \( 2.46\)e\(+00\) & \( 5.88\)e\(+02\) \\
\(    10\) & prob010 & failure & \( 2.72\)e\(+00\) & \( 1.00\)e\(-03\) & failure & \( 2.72\)e\(+00\) & \( 1.00\)e\(-03\) & failure & \( 2.72\)e\(+00\) & \( 1.00\)e\(-03\) \\\hline
\end{longtable}
"""

joined_md =
  raw"""|     id |    name |  flag_alpha |   f_alpha |   t_alpha |   flag_beta |    f_beta |    t_beta |  flag_gamma |   f_gamma |   t_gamma |
|--------|---------|-------------|-----------|-----------|-------------|-----------|-----------|-------------|-----------|-----------|
|      1 | prob001 |     failure |  1.11e+00 |  5.88e+02 |     failure |  1.11e+00 |  5.88e+02 |     failure |  1.11e+00 |  5.88e+02 |
|      2 | prob002 |     failure |  1.22e+00 |  9.51e+02 |     failure |  1.22e+00 |  9.51e+02 |     failure |  1.22e+00 |  9.51e+02 |
|      3 | prob003 | first_order |  1.35e+00 |  9.51e+02 | first_order |  1.35e+00 |  9.51e+02 | first_order |  1.35e+00 |  9.51e+02 |
|      4 | prob004 |     failure |  1.49e+00 |  5.88e+02 |     failure |  1.49e+00 |  5.88e+02 |     failure |  1.49e+00 |  5.88e+02 |
|      5 | prob005 |     failure |  1.65e+00 |  1.00e-03 |     failure |  1.65e+00 |  1.00e-03 |     failure |  1.65e+00 |  1.00e-03 |
|      6 | prob006 | first_order |  1.82e+00 |  5.88e+02 | first_order |  1.82e+00 |  5.88e+02 | first_order |  1.82e+00 |  5.88e+02 |
|      7 | prob007 |     failure |  2.01e+00 |  9.51e+02 |     failure |  2.01e+00 |  9.51e+02 |     failure |  2.01e+00 |  9.51e+02 |
|      8 | prob008 |     failure |  2.23e+00 |  9.51e+02 |     failure |  2.23e+00 |  9.51e+02 |     failure |  2.23e+00 |  9.51e+02 |
|      9 | prob009 | first_order |  2.46e+00 |  5.88e+02 | first_order |  2.46e+00 |  5.88e+02 | first_order |  2.46e+00 |  5.88e+02 |
|     10 | prob010 |     failure |  2.72e+00 |  1.00e-03 |     failure |  2.72e+00 |  1.00e-03 |     failure |  2.72e+00 |  1.00e-03 |
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
\endfirsthead
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
