# 13-02-2023 Tatiana Orli Sandberg Raileanu
# The motivation of this script was a file with a list of species and strains reads counts, where I needed to join counts for all bacterial strains of the same species, based on the species name.
# This script reads a CSV file named "input_file.csv" and counts the occurrences of each bacterial species in it. 
# The file is assumed to have two columns: the first column is the species name, and the second column is the count.

import csv

# Create output file
outfile = open("species_counts_from_kraken_and_16S.csv", "w")

species_count = dict() # Initializes a dictionary named species_count to store the species names and their counts.

with open('input_file.csv', 'r') as file:
    reader = csv.reader(file)
    for row in reader:  # Loops through each row in the reader object.
        if len(row) != 1: # If the length of the row is not equal to 1 (i.e., if it has two columns), the script retrieves the species name and count from the first and second columns of the row, respectively. It splits the species name by space, taking only the first two parts as the species name and ignoring the rest.
            species_name = row[0]
            count = row[1]
            species_name = species_name.split(' ')[0] + ' ' + species_name.split(' ')[1] # get only the species name, ignoring the strain
            if species_name in species_count.keys(): # If the species name is already in the species_count dictionary, the count is added to the existing count. If it's not, a new key-value pair is added to the dictionary, with the species name as the key and the count as the value.
              species_count[species_name] = species_count[species_name] + int(count)
            else: 
              species_count[species_name] = int(count)
        else:
            print(f"Skipping row with invalid format: {row}")  #If the length of the row is equal to 1, the script skips the row and prints a message indicating that it has an invalid format.

# After the loop, the script calculates the total count of all species by summing up the values in the species_count dictionary.          
total_count = sum(species_count.values())

out = csv.writer(outfile)

# Loop to print the final dictionary to an output file
for new_keys, new_values in species_count.items(): # The script opens the file for writing, creates a writer object from it, and writes the key-value pairs in the species_count dictionary to the file, with the species name in the first column and the count in the second column. The file is then closed.
    out.writerow([new_keys, new_values])

# close outputfile
outfile.close()