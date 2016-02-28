archive=$1
json=$2

GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf "${GREEN}Downloading...${NC}\n"
node download.js "$archive"
printf "${GREEN}Download finished.${NC}\n"
printf "${GREEN}Extracting...${NC}\n"
gunzip -kf "$archive"/**/*.gz
printf "${GREEN}Extracted${NC}\n"
printf "${GREEN}Generating...${NC}\n"
node generate.js "$archive" "$json"
printf "${GREEN}Generated ${json}${NC}\n"