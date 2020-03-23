import fastjet
from fastjet import PseudoJet
from fastjet import JetDefinition


def main():
    particles = []
    particles.append(PseudoJet(100.0, 0.0, 0.0, 100.0))  # px, py, pz, E
    particles.append(PseudoJet(150.0, 0.0, 0.0, 150.0))
    R = 0.4
    jet_def = JetDefinition(fastjet.antikt_algorithm, R)
    jets = jet_def(particles)
    print(jet_def)
    for jet in jets:
        print(jet)


if __name__ == "__main__":
    main()
