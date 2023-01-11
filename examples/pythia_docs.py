# ---
# jupyter:
#   jupytext:
#     notebook_metadata_filter: all,-jupytext.text_representation.jupytext_version
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
#   language_info:
#     codemirror_mode:
#       name: ipython
#       version: 3
#     file_extension: .py
#     mimetype: text/x-python
#     name: python
#     nbconvert_exporter: python
#     pygments_lexer: ipython3
#     version: 3.10.9
# ---

# %%
# %matplotlib widget

# %%
# https://pythia.org/download/pdf/pythia8300.pdf
# Section: 10.4.1 PYTHON interface
# with corrections for typos and wrong Python code in the docs
import matplotlib.pyplot as plt
import numpy as np
import pythia8


# %%
# Wrapper around numpy histogram to allow fill functionality.
class HistoFiller(object):
    def __init__(self, bins):
        self.bins = bins
        self.hist, edges = np.histogram([], bins=bins, weights=[])
        self.widths = [edges[i + 1] - edges[i] for i in range(len(edges) - 1)]

    def fill(self, val, w=1.0):
        hist, edges = np.histogram(val, bins=self.bins, weights=w)
        self.hist += hist

    def get(self):
        scale = 1.0 / sum(self.hist)
        return [h / w * scale for h, w in zip(self.hist, self.widths)], [
            np.sqrt(h) * scale for h in self.hist
        ]


# %% [markdown]
# Set up and configure Pythia

# %%
pythia = pythia8.Pythia()
pythia.readString("SoftQCD:all = on")

# %% [markdown]
# Initialize the generator

# %%
pythia.init()

# %% [markdown]
# Declare the histogram

# %%
bin_width = 3.0
bins = [bin_width * x for x in range(20)]
multiparton_hist = HistoFiller(bins)

# %% [markdown]
# Event loop. Find particles and fill histogram.

# %%
n_events = 10_000

for _ in range(n_events):
    if not pythia.next():
        continue
    n_charged = sum(
        1 for p in pythia.event if p.isFinal() and p.isHadron() and p.isCharged()
    )

    multiparton_hist.fill(n_charged)

# %% [markdown]
# Visualize

# %%
y, yerr = multiparton_hist.get()

fig, ax = plt.subplots()

ax.errorbar(
    bins[:-1],
    y,
    xerr=[w / 2.0 for w in multiparton_hist.widths],
    yerr=yerr,
    drawstyle="steps-mid",
    fmt="-",
    color="black",
)

ax.set_xlabel(r"$dN_{ch}/d\eta$")
ax.set_ylabel(r"$P(dN_{ch}/d\eta)$")

file_extension = ["png", "pdf"]
for ext in file_extension:
    fig.savefig(f"pythia_docs_example.{ext}")
