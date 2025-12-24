#!/usr/bin/env bash
set -euo pipefail

RAW="data/processed/Urban2015_data_clean.tsv"
OUTDIR="data/processed"
mkdir -p "$OUTDIR"

python3 - <<'PY'
import pandas as pd

df = pd.read_csv("data/processed/Urban2015_data_clean.tsv", sep="\t")

# Standardize column names (optional): keep original if you prefer
# df.columns = [c.strip() for c in df.columns]

# Coerce numeric columns
num_cols = ["Threshold","N_Ext","Total_N","Percent","Weight","Logit","Pre_Ind_Rise","Year","Year_Pred"]
for c in num_cols:
    if c in df.columns:
        df[c] = pd.to_numeric(df[c], errors="coerce")

# Light cleaning: normalize Endemic values
if "Endemic" in df.columns:
    df["Endemic"] = df["Endemic"].astype(str).str.strip().replace({"nan": None})

# Save a clean CSV for R
df.to_csv("data/processed/urban2015_clean.csv", index=False)

# Build grouped summaries (weighted percent)
req = {"Region","Taxa","Year_Pred","Endemic","Percent","Weight"}
if req.issubset(df.columns):
    g = (df.dropna(subset=["Percent","Weight"])
           .groupby(["Region","Taxa","Year_Pred","Endemic"], dropna=False)
           .apply(lambda x: pd.Series({
               "n_rows": len(x),
               "sum_weight": x["Weight"].sum(),
               "weighted_percent": (x["Percent"]*x["Weight"]).sum() / x["Weight"].sum() if x["Weight"].sum()!=0 else None
           }))
           .reset_index())
    g.to_csv("data/processed/weighted_by_group.csv", index=False)

# Threshold sensitivity
req2 = {"Threshold","Year_Pred","Percent","Weight"}
if req2.issubset(df.columns):
    t = (df.dropna(subset=["Percent","Weight"])
           .groupby(["Threshold","Year_Pred"], dropna=False)
           .apply(lambda x: pd.Series({
               "n_rows": len(x),
               "mean_percent": x["Percent"].mean(),
               "weighted_mean_percent": (x["Percent"]*x["Weight"]).sum() / x["Weight"].sum() if x["Weight"].sum()!=0 else None
           }))
           .reset_index())
    t.to_csv("data/processed/threshold_sensitivity.csv", index=False)

print("Wrote:")
print(" - data/processed/urban2015_clean.csv")
print(" - data/processed/weighted_by_group.csv (if columns present)")
print(" - data/processed/threshold_sensitivity.csv (if columns present)")
PY
