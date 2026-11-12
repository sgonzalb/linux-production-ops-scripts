import csv
import sys

def validate(filepath="sample_batch.csv"):
    with open(filepath, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        if not rows:
            print("No records found.")
            sys.exit(1)
        for row in rows:
            if float(row["amount"]) <= 0:
                print(f"Invalid amount in {row['transaction_id']}")
                sys.exit(1)
    print(f"Validation passed: {len(rows)} records OK.")
    sys.exit(0)

if __name__ == "__main__":
    validate()
