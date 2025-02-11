%{
Readme for code for submission to eLife, 'Pleomorphic effects of three small-molecule inhibitors on transcription elongation by Mycobacterium tuberculosis RNA polymerase'
 by Omar Herrera-Asmat, Alexander B. Tong, et al.
Also available on bioRxiv at https://doi.org/10.1101/2025.02.07.637008

Raw instrument data (QPD voltages, AOD frequencies) were converted to force and distance using ./RawDataProcessing/AProcessDataV2.m, using the preset for the 'Boltzmann' instrument.

Traces are viewed for quality using ./DataGUIs/PhageGUIv4.m. Traces are selected by eye for length and noise, as tether-to-tether variations can cause some traces to have more noise, or stochastic effects can cause tethers to break early.

Molecular Ruler alignment is done with ./Misc/PolRepeats/RulerAlignV2.m. In short, the trace is binned along extension to form a residence time histogram, and a periodicity is guessed, extracting eight trial repeats from the residence time histogram. The optimal periodicity is searched for, and is chosen as the periodicity that makes the residence time patterns of the repeats overlap the best. In this optimal periodicity, the offset is assigned by placing the designed pauses at the strongest pauses in the repeat (i.e., the repeat histogram is 'rotated' until the strongest pauses appear on the designed pause locations)

Dwell-time distribution analysis is done with ./DataGUIs/Fitting/pol_dwelldist_p*.m. The traces are fit to a one base-pair staircase to extract the residence time of each trace at each incorporation event. These times are fit to a sum of N exponentials, where N is chosen by fitting to first one, then two, etc. exponentials until the fit gets worse, as assessed by the Akaike information criterion.



For more information, contact Alex Tong (tonga@berkeley.edu)
%}
