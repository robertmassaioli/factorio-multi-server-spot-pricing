#!/bin/bash

# Function to check if GNU date (gdate) is available
check_gdate() {
    if command -v gdate >/dev/null 2>&1; then
        echo "gdate"
    else
        echo "date"
    fi
}

# Assign the appropriate date command
DATE_CMD=$(check_gdate)

# Set the time period for the current month
if [ "$DATE_CMD" = "gdate" ]; then
    start_date=$($DATE_CMD -d "$(date +%Y-%m-01)" +%Y-%m-%d)
    end_date=$($DATE_CMD -d "$(date +%Y-%m-01) +1 month" +%Y-%m-%d)
else
    start_date=$($DATE_CMD -v1d +%Y-%m-%d)
    end_date=$($DATE_CMD -v+1m -v1d -v-1d +%Y-%m-%d)
end_date=$($DATE_CMD -v+1m -v1d -v-1d +%Y-%m-%d)
fi

# Set default target currency
target_currency=${1:-AUD}

# Run the AWS CLI command and store the output
aws_output=$(aws ce get-cost-and-usage \
    --time-period Start=${start_date},End=${end_date} \
    --granularity MONTHLY \
    --metrics "BlendedCost" "UsageQuantity" \
    --group-by Type=DIMENSION,Key=SERVICE Type=DIMENSION,Key=USAGE_TYPE \
    --output json 2>&1)

# Check if the command was successful
if [ $? -ne 0 ]; then
    echo "Error running AWS CLI command:"
    echo "$aws_output"
    exit 1
fi

# Check if the output is valid JSON
if ! echo "$aws_output" | jq empty > /dev/null 2>&1; then
    echo "AWS CLI output is not valid JSON:"
    echo "$aws_output"
    exit 1
fi

# Process the output with jq, sort by Usage Quantity, and format it as a table
echo "Service | Usage Quantity | Usage Type | Cost (USD)" > table_data.txt
echo "--------|----------------|------------|------------" >> table_data.txt

echo "$aws_output" | jq -r '.ResultsByTime[0].Groups[] |
    select(.Metrics.BlendedCost.Amount | tonumber > 0.009) |
    [
        .Keys[0],
        (.Metrics.BlendedCost.Amount | tonumber),
        .Keys[1],
        (.Metrics.BlendedCost.Amount | tonumber | (. * 1000 | round | . / 1000))
    ]' | jq -r -s 'sort_by(.[1]) | reverse | .[] |
    [
        .[0],
        (.[1] | round | tostring),
        .[2],
        (.[3] | tostring)
    ] | join(" | ")' >> table_data.txt

# Check if any data was processed
if [ ! -s table_data.txt ]; then
    echo "No data was processed. The output may be empty or in an unexpected format."
    echo "Raw AWS CLI output:"
    echo "$aws_output"
    exit 1
fi

# Display the table
column -t -s '|' table_data.txt

# Calculate the total cost in USD
total_cost_usd=$(echo "$aws_output" | jq -r '.ResultsByTime[0].Groups[] | .Metrics.BlendedCost.Amount | tonumber' | awk '{sum += $1} END {printf "%.2f", sum}')

# Get the exchange rate
exchange_rate=$(curl -s "https://api.exchangerate-api.com/v4/latest/USD" | jq -r ".rates.$target_currency")

# Calculate the converted cost
converted_cost=$(echo "$total_cost_usd * $exchange_rate" | bc -l)

# Print the total costs
echo -e "\nTotal Cost (USD): \$$total_cost_usd"
printf "Total Cost (%s): %s%.2f\n" "$target_currency" "$([[ $target_currency == AUD ]] && echo 'A$' || echo '$')" "$converted_cost"

# Clean up
rm table_data.txt