# Stack
## A stack is an abstract data type that serves as a collection of
## elements with two principal operations: push() and pop(). push() adds an
## element to the top of the stack, and pop() removes an element from the top
## of a stack. The order in which elements come off of a stack are
## Last In, First Out (LIFO).
{.push raises: [].}

type
  Stack*[T] = object
    stack: seq[T]
    limit: int
  StackUnderflowDefect* = object of Defect
  StackOverflowDefect* = object of Defect

func initStack[T](st: var Stack[T]) =
  st.stack = @[]
  st.limit = 10

func bool[T](st: Stack[T]): bool =
  ## Returns whether the container is empty or not
  len(st.stack) >= 1

func pop[T](st: var Stack[T]) =
  ## Removes the last element of the stack
  if len(st.stack) == 0:
    raise newException(StackUnderflowDefect, "Stack has underflowed")
  discard system.pop(st.stack)

func push[T](st: var Stack[T], data: T) =
  ## Adds an element to the stack
  if len(st.stack) >= st.limit:
    raise newException(StackOverflowDefect, "Stack's container is full")
  st.stack.add(data)

func peek[T](st: Stack[T]): T =
  ## Peek at the top-most element of the stack
  if len(st.stack) == 0:
    raise newException(StackUnderflowDefect, "Can not peek at empty stack")
  st.stack[^1]

func size[T](st: Stack[T]): T =
  ## Return the size of the stack
  st.stack.len

func isFull[T](st: Stack[T]): bool =
  return st.size() == st.limit

when isMainModule:
  echo "Create the stack."
  var a = Stack[int]()
  echo "Limit of the stack: ", a.limit
  echo "Initiate the Stack."
  initStack(a)
  echo "Limit of the stack: ", a.limit
  echo "Is container non empty ?: ", bool(a)
  echo "Inserting an element: 2"
  a.push(2)
  echo "Size of the stack: ", a.size
  echo "Last element: ", peek(a)
  echo "Is container non empty ?: ", bool(a)
  echo "Is container full ?: ", isFull(a)
  a.limit = 2
  a.push(3)
  echo a.stack
  echo "Is container full ?: ", isFull(a)
  a.pop()
  echo a.stack
  a.pop()
  # a.pop()
