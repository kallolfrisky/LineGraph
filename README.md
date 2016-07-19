# LineGraph
Demo line graph in objective c to support large amount of data.

# Performance Issues
1. Too slow rendering for large volume of data

# Current Solutions
1. For large volume of data sampling is used to reduce the frequency. (Not a good solution)
2. Data processing is performed on different thread to avoid main thread blocking

# Todo:
Need a solution in code level to draw large volume of data like 
80000 to 100000 with line graph in objective C allowing zooming in and out facilities.
