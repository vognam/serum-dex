#!/bin/sh

echo Starting rust cranks for the markets

cat markets.txt | while read line || [[ -n $line ]];
do
   echo Starting crank for market $line
   
   cargo run \
   -- https://api.devnet.solana.com consume-events \
   --dex-program-id DESVgJVGajEgKGXhb6XmqDHGz3VjdgP7rEVESBgxmroY \
   --payer $1 \
   --coin-wallet CZypB3ehx6mEtk9vsHREXF4YxZXzNSEx6qjM9BW848ri \
   --pc-wallet CZypB3ehx6mEtk9vsHREXF4YxZXzNSEx6qjM9BW848ri \
   --market $line \
   --num-workers 1 \
   --events-per-worker 1 \
   --log-directory ./$line-log.txt & # run in the background

   sleep 1 # wait a second before starting next market crank
done

## todo
# args for payer
# sleep on rust program
# sleep on bash script