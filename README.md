# Overview
This fork has slight modifications such that you can crank multiple markets at once using one command without excessive network requests.

## How to use
The only change is in `/dex/crank` so navigate to this folder. The scripts only works on a mac!!! What it essentially does is run multiple crank background processes with an increased delay. To use this:
* Paste a list of all the market addresses in `market.txt`. Each should be on a new line.
* The delay to check the queue when its empty is currently set at 30 seconds. Feel free to change this in `line 574` in `dex/crank/src/lib.rs`.
* Run the command `sh run.sh <path-to-keypair>` to fire off the cranks. It's a pretty simple script so go ahead and modify to your need.
* Check the associated logs in the `<marketId>-log.txt` to see how the cranks are doing.
* To see a list of all background processes including cranks running on your machine run the command `ps`.
* To stop all the cranks run `killall crank`. Closing the terminal will stop the cranks. Putting your mac to sleep will pause the cranks.
