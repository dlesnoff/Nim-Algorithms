# Knapsack problem
## Given a set of n items, each with a weight w_i and a value v_i, determine
## which items to include in the collection so that the total weight:
## $$\sum_{i=1}^n$ w_i x_i$
## is less than or equal to a given limit W and the total value:
## $$\sum_{i=1}^n$ v_i x_i$
## is as large as possible.

{.push raises: [].}

# 0-1 Knapsack problem
type
  Item = object
    w, v: float
  Knapsack = ref object
    items: seq[Item]
    limit: float
    n: int
  OptimalKnapsack = tuple[optimalValue:float, chosenItems:seq[bool]]

func computeValue(k: Knapsack, chosenItems: seq[bool]): float =
  for i in 0 ..< k.n:
    if chosenItems[i]:
      result += k.items[i].v

func computeWeight(k: Knapsack, chosenItems: seq[bool]): float =
  for i in 0 ..< k.n:
    if chosenItems[i]:
      result += k.items[i].w

func fitsInKnapsack(k: Knapsack, chosenItems: seq[bool]): bool =
  result = computeWeight(k, chosenItems) <= k.limit

func optimalValue(k: Knapsack): OptimalKnapsack =
  var
    dp = newSeq[float](k.n + 1)
  result = (optimalValue: 0.0, chosenItems: newSeq[bool](k.n))
  for i in 0 ..< k.n:
    for j in countdown(k.n, 1):
      if dp[j] < dp[j - 1] + k.items[i].v:
        dp[j] = dp[j - 1] + k.items[i].v
        result.chosenItems[i] = true
      else:
        result.chosenItems[i] = false
  result.optimalValue = dp[k.n]

# Bounded Knapsack problem
# Unbounded Knapsack problem
when isMainModule:
  var
    k = Knapsack(
      items: @[
        Item(w: 2.0, v: 12.0),
        Item(w: 1.0, v: 10.0),
        Item(w: 3.0, v: 20.0),
        Item(w: 2.0, v: 15.0)
      ],
      limit: 5.0,
      n: 4
    )
  var optimalSolution = optimalValue(k)
  echo "Optimal value: ", optimalSolution.optimalValue
  echo "Chosen Items in optimal solution: ", optimalSolution.chosenItems
  echo "Value of chosen items: ", computeValue(k, optimalSolution.chosenItems)