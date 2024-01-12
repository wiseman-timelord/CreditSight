# CreditSight-Ps
Finanace planner details still to be finalized, prediction and history, ascii line graphs and numbers.

Part 1:
By using day records like for example
  1DayRecords = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	10DayRecords = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	100DayRecords = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	1000DayRecodss = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
We are able to have large scale, history and prediction, the later records will be of a lesser quality, but, it would result in a high compitence to, remember and predict, based upon a quality history input.

Part 2:
Line graphs, there will be history and prediction, at first every character on the line will represent a day, then the history will all shift over one each time there a new day, when it gets to end they all will shift over by one, so that todays day is always a new character, however, each day the history shifts there will be a new character on historygraph, while other history will shift over, and it should scale to the remainter of the space in the box. 
```
Histoy:
|----------------------------------------------------------------|
|                                                                |
|     *                                                          |
|    £ £           £££ £   £                                     |
| £££   £       £££   £ £££ £                                    |
|£       £     £                                                 |
|         x   x                                                  |
|          X X                                                   |
|           X                                                    |
|                                                                |
|----------------------------------------------------------------|
```
