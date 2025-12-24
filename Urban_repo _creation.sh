# Begin in the project root folder
mkdir urban2015
cd urban2015
mkdir -p data/raw data/processed scripts R reports logs
# Copy csv file and transform to tsv
cp /mnt/c/Users/marty/OneDrive/Desktop/MyProjects/Urban2015_data.csv data/raw/Urban2015_data.tsv
awk 'NR==1{gsub(/\./,"_"); gsub(/ /,"_")}1' data/raw/Urban2015_data.tsv > data/processed/Urban2015_data_clean.tsv
head -n 1 data/processed/Urban2015_data_clean.tsv | cat -A # verify changed headers


nano scripts/01_profile_validate.sh # Create py script using nano
chmod +x scripts/01_profile_validate.sh
./scripts/01_profile_validate.sh | tee logs/01_profile_validate.log # Run script

# Create script for 02_build intermediates
nano scripts/02_build_intermediate.sh
chmod +x scripts/02_build_intermediates.sh
./scripts/02_build_intermediates.sh

# Data Analysis will be conducted in R studio
Rscript R/01_analysis.R # Run R script
# Ensure R packages are installed in WSL.

nano scripts/run_all.sh #one command runner
chmod +x scripts/run_all.sh
./scripts/run_all.sh