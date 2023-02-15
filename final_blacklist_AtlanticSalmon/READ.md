On 10th February 2023 meeting, we decided that we will combine blacklists for devmap (Roslin uChIPmentation and Aberdeen ChIPmentaiton) & 
bodymap (NMBU, classic ChIP) into one final file and use that for filtering all the ChIP-seq datasets. 
This is more conserved approach and will reduce false positives.

#### input files for bedops merge: 
- salmon_devmap_blacklist_roslin_with_aberdeen_75to150kmers.bed
- salmon_bodymap_blacklist_nmbuOnly_75to150kmers.bed
```ruby
bedops --merge salmon_devmap_blacklist_roslin_with_aberdeen_75to150kmers.bed salmon_bodymap_blacklist_nmbuOnly_75to150kmers.bed > Final_blacklist_atlantic_salmon_devmap_bodymap_combined.bed
```
