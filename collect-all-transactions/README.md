## Collect All Transactions

The list of transactions pertaining to a specific Cosmos address is accessible on Mintscan, but the data is paginated. This is a script that crawls all transactions associated with the specified address, and collates and stores the information in a CSV file.

### Usage

```
./collect-all-transactions <address>
```

The data shall be collated in a file named `data.csv`.