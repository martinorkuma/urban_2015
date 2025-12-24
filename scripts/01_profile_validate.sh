#!/usr/bin/env bash
set -euo pipefail

RAW="data/processed/Urban2015_data_clean.tsv"
OUTDIR="data/processed"
LOGDIR="logs"

mkdir -p "$OUTDIR" "$LOGDIR" reports

echo "== File preview =="
head -n 3 "$RAW" | sed -n '1,3p'

echo "== Delimiter check (tab vs comma) =="
python3 - <<'PY'
from pathlib import Path
p = Path("data/processed/Urban2015_data_clean.tsv")
line = p.read_text().splitlines()[0]
tabs = line.count("\t")
commas = line.count(",")
print(f"Header tabs={tabs} commas={commas}")
print("Treating as TSV" if tabs >= commas else "Treating as CSV")
PY

echo "== Basic row/col counts =="
python3 - <<'PY'
import csv
from pathlib import Path
p = Path("data/processed/Urban2015_data_clean.tsv")
with p.open(newline="", encoding="utf-8") as f:
    r = csv.reader(f, delimiter="\t")
    header = next(r)
    n = sum(1 for _ in r)
print("columns:", len(header))
print("rows:", n)
print("header:", header)
PY

echo "== Missingness by column (top) =="
python3 - <<'PY'
import pandas as pd
df = pd.read_csv("data/processed/Urban2015_data_clean.tsv", sep="\t")
miss = df.isna().mean().sort_values(ascending=False)
print(miss.head(20).to_string())
miss.to_csv("reports/missingness_by_col.csv", header=["missing_fraction"])
PY

echo "== Quick categorical levels =="
python3 - <<'PY'
import pandas as pd
df = pd.read_csv("data/processed/Urban2015_data_clean.tsv", sep="\t")
cat_cols = ["Region","Taxa","Endemic","Model_Type","Disp_Mod","Temperature_Model_Scale"]
for c in cat_cols:
    if c in df.columns:
        vals = df[c].dropna().astype(str).value_counts().head(15)
        print("\n", c, "\n", vals.to_string())
PY

echo "== Range checks (numeric) =="
python3 - <<'PY'
import pandas as pd
df = pd.read_csv("data/processed/Urban2015_data_clean.tsv", sep="\t")
num_cols = ["Threshold","N_Ext","Total_N","Percent","Weight","Logit","Pre_Ind_Rise","Year","Year_Pred"]
for c in num_cols:
    if c in df.columns:
        s = pd.to_numeric(df[c], errors="coerce")
        print(f"{c}: min={s.min()} max={s.max()} n_na={s.isna().sum()}")
PY

echo "== Percent consistency check vs N_Ext/Total_N =="
python3 - <<'PY'
import pandas as pd
import numpy as np

df = pd.read_csv("data/processed/Urban2015_data_clean.tsv", sep="\t")
for c in ["N_Ext","Total_N","Percent"]:
    if c not in df.columns:
        raise SystemExit(f"Missing required column: {c}")

n_ext = pd.to_numeric(df["N_Ext"], errors="coerce")
tot = pd.to_numeric(df["Total_N"], errors="coerce")
pct = pd.to_numeric(df["Percent"], errors="coerce")

calc = np.where((tot.notna()) & (tot != 0), n_ext / tot, np.nan)
diff = np.abs(pct - calc)

out = df.copy()
out["pct_calc"] = calc
out["abs_diff"] = diff
top = out.loc[~np.isnan(diff)].sort_values("abs_diff", ascending=False).head(25)

top.to_csv("reports/percent_check_top25.csv", index=False)
print("Wrote reports/percent_check_top25.csv")
print("Top diff summary:")
print(top[["N_Ext","Total_N","Percent","pct_calc","abs_diff"]].head(10).to_string(index=False))
PY

echo "Done. Wrote reports/missingness_by_col.csv and reports/percent_check_top25.csv"
