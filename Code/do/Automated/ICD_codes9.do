*ICD-9 code
foreach var of varlist s_41203* s_41205* {
  foreach icd in 410, 411, 412, 413, 414 {
  qui replace x1 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 161, 162 {
  qui replace x2 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 311, 296.2, 296.3 {
  qui replace x3 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 311, 296.2, 296.3 {
  qui replace x4 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 433, 434, 435 {
  qui replace x5 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 290, 311.0 {
  qui replace x6 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 303, 304, 305, 291, 292 {
  qui replace x7 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 300.0 {
  qui replace x8 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 153, 154 {
  qui replace x9 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 493 {
  qui replace x10 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 174 {
  qui replace x11 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 346 {
  qui replace x12 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 430, 431, 432, 436, 437 {
  qui replace x13 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 303, 291, 305.0 {
  qui replace x14 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 715 {
  qui replace x15 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 250 {
  qui replace x16 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 304.0 {
  qui replace x17 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 185 {
  qui replace x18 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 295 {
  qui replace x19 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 585 {
  qui replace x20 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 157 {
  qui replace x21 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 150 {
  qui replace x22 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 296.0, 296.4, 296.5, 296.6, 296.7, 296.8 {
  qui replace x23 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 714 {
  qui replace x24 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 200, 202.0, 202.1, 202.2, 202.7, 202.8 {
  qui replace x25 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 300.4 {
  qui replace x26 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 441 {
  qui replace x27 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 191, 192 {
  qui replace x28 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 282, 283 {
  qui replace x29 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 204, 205, 206, 207, 208 {
  qui replace x30 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 345 {
  qui replace x31 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 151 {
  qui replace x32 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 183 {
  qui replace x33 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 189 {
  qui replace x34 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 692 {
  qui replace x35 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 332 {
  qui replace x36 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 188 {
  qui replace x37 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 282.5, 282.6 {
  qui replace x38 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 999999999 {
  qui replace x39 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 311.0 {
  qui replace x40 = 1 if strpos(`var',"`icd'") > 0
  }
}
foreach var of varlist s_41203* s_41205* {
  foreach icd in 433, 434, 435, 430, 431, 432, 436, 437 {
  qui replace x41 = 1 if strpos(`var',"`icd'") > 0
  }
}
