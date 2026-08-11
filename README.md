# Multi-market crank launcher for Serum DEX

This is a historical 2021 fork of
[`project-serum/serum-dex`](https://github.com/project-serum/serum-dex). It adds a
small operational utility for running the Serum `consume-events` crank across
multiple markets while reducing unnecessary polling when queues are empty.

The Serum DEX implementation and the rest of this monorepo are upstream code.
My changes are limited to the crank launcher, its configuration, and the idle
polling behaviour in `dex/crank`.

## What changed

- Starts one `consume-events` process per configured market.
- Writes a separate log for each market.
- Waits between process launches to avoid a burst of simultaneous requests.
- Uses a configurable delay before polling an empty event queue again.
- Keeps deployment-specific RPC URLs, program IDs, wallets, markets, and
  keypair paths out of source control.

The original customization is visible in
[commit `9cf2735`](https://github.com/vognam/serum-dex/commit/9cf27356ef4e75919cdf40984d307386f9bf9b40).

## Status

This repository is retained as a record of historical Solana infrastructure
work. Its Serum and Solana dependencies date from 2021 and it is not actively
maintained. Do not use it against current networks or with valuable keys without
reviewing and updating the upstream dependencies and auditing the complete
transaction path.

## Run the launcher

The launcher is POSIX-compatible and is intended to be run from `dex/crank`.
You will need the Rust and Solana toolchain expected by the upstream repository.

1. Create a local market list:

   ```sh
   cd dex/crank
   cp markets.example.txt markets.txt
   ```

2. Replace the placeholders in `markets.txt` with one Solana market public key
   per line. Empty lines and lines beginning with `#` are ignored.

3. Set the deployment-specific values:

   ```sh
   export RPC_URL="<SOLANA_RPC_URL>"
   export DEX_PROGRAM_ID="<SERUM_DEX_PROGRAM_ID>"
   export COIN_WALLET="<COIN_FEE_WALLET>"
   export PC_WALLET="<PRICE_CURRENCY_FEE_WALLET>"
   ```

4. Start the crank processes with an absolute path to a Solana keypair:

   ```sh
   ./run.sh /absolute/path/to/payer-keypair.json
   ```

The launcher remains in the foreground and supervises the child processes.
Press `Ctrl-C` to stop them. Logs are written to `dex/crank/logs` by default.

### Optional configuration

| Variable | Default | Purpose |
| --- | ---: | --- |
| `MARKETS_FILE` | `markets.txt` | File containing one market public key per line |
| `LOG_DIR` | `logs` | Directory for per-market logs |
| `NUM_WORKERS` | `1` | Crank workers per market |
| `EVENTS_PER_WORKER` | `1` | Events consumed by each worker |
| `IDLE_SLEEP_SECONDS` | `30` | Delay before polling an empty event queue again |
| `START_DELAY_SECONDS` | `1` | Delay between launching market processes |

For example:

```sh
IDLE_SLEEP_SECONDS=60 START_DELAY_SECONDS=2 ./run.sh /absolute/path/to/payer-keypair.json
```

## Security notes

- Store the payer keypair outside this repository.
- Do not commit deployment addresses or generated logs.
- Use a dedicated key with only the permissions and funds required for cranking.
- Treat this as historical reference code, not a maintained production release.

## Licence

The upstream project is licensed under the Apache License 2.0. See
[`LICENSE`](LICENSE).
