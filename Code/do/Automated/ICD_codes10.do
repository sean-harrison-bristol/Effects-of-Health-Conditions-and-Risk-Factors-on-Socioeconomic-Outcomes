*ICD-10 code
foreach var of varlist diag* {
  foreach icd in I20 I21 I22 I23 I24 I25 {
  qui replace v1 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C32 C33 C34 {
  qui replace v2 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F32 F33 {
  qui replace v3 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F32 F33 {
  qui replace v4 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in I63 {
  qui replace v5 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F01 F02 F03 G30 {
  qui replace v6 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F10 F11 F12 F13 F14 F15 F16 F18 F19 {
  qui replace v7 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F40 F41 {
  qui replace v8 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C18 C19 C20 C21 {
  qui replace v9 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in J45 {
  qui replace v10 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C50 {
  qui replace v11 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in G43 {
  qui replace v12 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in I60 I61 I62 {
  qui replace v13 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F10 {
  qui replace v14 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in M15 M16 M17 M18 M19 {
  qui replace v15 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in E11 {
  qui replace v16 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F11 {
  qui replace v17 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C61 {
  qui replace v18 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F20 {
  qui replace v19 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in N18 {
  qui replace v20 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C25 {
  qui replace v21 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C15 {
  qui replace v22 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F31 {
  qui replace v23 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in M05 M06 {
  qui replace v24 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C82 C83 C84 C85 C86 {
  qui replace v25 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in F34.1 {
  qui replace v26 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in I71 {
  qui replace v27 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C71 C72 {
  qui replace v28 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in D55 D56 D58 D59 {
  qui replace v29 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C91 C92 C93 C94 C95 {
  qui replace v30 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in G40 {
  qui replace v31 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C16 {
  qui replace v32 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C56 {
  qui replace v33 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C64 {
  qui replace v34 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in L20.82 L20.83 L20.84 {
  qui replace v35 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in G20 {
  qui replace v36 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in C67 {
  qui replace v37 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in D57 {
  qui replace v38 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in E11 {
  qui replace v39 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in G30 {
  qui replace v40 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in I63 I60 I61 I62 {
  qui replace v41 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist diag* {
  foreach icd in E10 {
  qui replace v42 = 1 if strpos(`var',"`icd'") > 0
  }
}
