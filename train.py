import sys
from dvclive import Live

epochs = int(sys.argv[1])

with Live(report=None, dvcyaml=False) as live:
    for i in range(epochs):
        live.log_metric("foometric", i, timestamp=True)
        live.next_step()
