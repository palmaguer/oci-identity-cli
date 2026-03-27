# Placeholder

```sh
jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.]) ) as $rows | $cols, $rows[] | @csv' data/anf_orcv_preprod_jobroles.json
jq -r '(map(.Resources[]) | add | unique) as $cols | map(. as $row | $cols | map($row[.]) ) as $rows | $cols, $rows[] | @csv' data/anf_orcv_preprod_jobroles.json
jq -r '.Resources[]' data/anf_orcv_preprod_jobroles.json | jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.]) ) as $rows | $cols, $rows[] | @csv'
```
