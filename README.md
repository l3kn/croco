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

![](images/slime_mold/slime_mold1.png)

At the beginning, the cells are distributed randomly

![](images/slime_mold/slime_mold2.png)

They start forming small groups

![](images/slime_mold/slime_mold7.png)

And after a while only a few large groups remain

![](images/slime_mold/slime_mold10.png)

### Termites

Initially each patch has a 12.5% chance of containing a wood chunk.

Each agent (termite)
follows only two rules:

If there is a wood chunk on the current patch:
1. If not carrying a wood chunk, pick it up
2. If carrying a wood chunk already, drop it (forming a pile)

![](images/termites/termites0.png)

After a while the number of piles
(patches with at least one chunk on it)
starts to shrink,
while their average size increases.

![](images/termites/termites2.png)
![](images/termites/termites4.png)

![](images/termites/termites_graph.png)

# Credits

* [Turtles, Termites and Traffic Jams](https://mitpress.mit.edu/books/turtles-termites-and-traffic-jams)
