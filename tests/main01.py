# main01.py is a part of the PYTHIA event generator.
# Copyright (C) 2019 Torbjorn Sjostrand.
# PYTHIA is licenced under the GNU GPL v2 or later, see COPYING for details.
# Please respect the MCnet Guidelines, see GUIDELINES for details.

# Keywords: basic usage; charged multiplicity; python;

# This is a simple test program. It fits on one slide in a talk.  It
# studies the charged multiplicity distribution at the LHC.

# Modified by Matthew Feickert to be Python3 compliant and location independent

# Import the Pythia module
import pythia8

pythia = pythia8.Pythia()
print(pythia.settings.fvec("Charmonium:gg2ccbar(3S1)[3S1(8)]g"))
pythia.readString("Beams:eCM = 8000.")
pythia.readString("HardQCD:all = on")
pythia.readString("PhaseSpace:pTHatMin = 20.")
pythia.init()
mult = pythia8.Hist("charged multiplicity", 100, -0.5, 799.5)
# Begin event loop. Generate event. Skip if error. List first one.
for iEvent in range(0, 100):
    if not pythia.next():
        continue
    # Find number of all final charged particles and fill histogram.
    nCharged = 0
    for prt in pythia.event:
        if prt.isFinal() and prt.isCharged():
            nCharged += 1
    mult.fill(nCharged)
# End of event loop. Statistics. Histogram. Done.
pythia.stat()
print(mult)
