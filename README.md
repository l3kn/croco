# CROCO

StarLOGO inspired agent based simulation framework

## Examples

### Slime mold

Each agent (mold cell)
follows a simple set of rules:

1. Drop some pheromone on the current patch
2. “Wiggle” (turn a little bit in a random direction)
3. “Sniff” in three directions (left, forward, right)
   and move in the direction where the pheromone level is highest

After each tick the pheromone spreads to the surrounding cells
and “evaporates” (`level *= 0.9`)

At the beginning, the cells are distributed randomly,
they start forming small groups
and after a while only a few large groups remain

![](images/slime_mold.gif)

### Termites

Initially each patch has a 12.5% chance of containing a wood chunk.

Each agent (termite)
follows only two rules:

If there is a wood chunk on the current patch:
1. If not carrying a wood chunk, pick it up
2. If carrying a wood chunk already, drop it (forming a pile)

After a while the number of piles
(patches with at least one chunk on it)
starts to shrink,
while their average size increases.

![](images/termites.gif)

# Credits

* [Turtles, Termites and Traffic Jams](https://mitpress.mit.edu/books/turtles-termites-and-traffic-jams)
