# Linked List
## A Linked List is a data structure made of cells, dispatched on non-contiguous
## locations in heap memory. Each cell contains a data and a pointer to the
## next cell. The last cell has a pointer to nil. This a singled linked list
## which means that each cell has a pointer to the next cell, but not to the
## previous one. This generic implementation can be used with any type.
{.push raises: [].}

type
  CellObj*[T] = object
    data*: T
    next*: Cell[T]
  Cell*[T] = ref CellObj[T]
  LinkedList*[T] = object
    tail*: Cell[T]

func newCell*[T](data: T): Cell[T] = Cell[T](data: data, next: nil)

func `$`*[T](list: Cell[T]): string =
  var list = list
  while list != nil:
    result &= $(list.data) & " -> "
    list = list.next
  result &= "tail"

func len*[T](list: Cell[T]): Natural =
  var cell: Cell[T] = list
  while cell != nil:
    inc result
    cell = cell.next

func belongsTo*[T](list: Cell[T], data: T): bool =
  var list: Cell[T] = list
  while list != nil:
    if list.data == data:
      return true
    list = list.next
  return false

func find*[T](list: Cell[T], data: T): Cell[T] =
  var list: Cell[T] = list
  while list != nil:
    if list.data == data:
      return list
    list = list.next
  return nil

func modifyCell*[T](list: Cell[T], pos: Natural, data: T) =
  var i = 0
  while list != nil:
    if i == pos:
      list.data = data
      return
    inc i
    list = list.next

func insertCell*[T](list: Cell[T], pos: Natural, data: T): ref Cell[T] =
  ## Insert a cell at position pos
  ## If pos is greater than the number of elements, the cell is inserted at the end
  if (list.isNil() or pos == Natural(0)):
    result = newCell(data)
    result.next = list
  else:
    result = list
    var i = pos
    while list.next != nil and i > 1:
      list = list.next
      dec i
    let n = newCell(data)
    n.next = list
    list.next = n

func removeCell*[T](list: Cell[T], pos: Natural): ref Cell[T] =
  ## Remove a cell at position pos
  ## If pos is greater than the number of elements, the last cell is removed
  if (list.isNil()):
    return nil
  elif (pos == Natural(0)):
    result = list.next
  else:
    result = list
    var i = pos
    while list.next != nil and i > 1:
      list = list.next
      dec i
    let n = list.next.next
    del list.next
    list.next = n

when isMainModule:
  import std/unittest
  suite "Linked List":
    test "newCell":
      var list = newCell(1)
      check list.data == 1
      check list.next.isNil()
    
    test "len":
      var list = newCell(1)
      check len(list) == 1
      list = newCell(1)
      list.next = newCell(2)
      check len(list) == 2

    test "belongsTo":
      var list = newCell(7)
      list.next = newCell(9)
      list.next.next = newCell(1)
      check belongsTo(list, 1)
      check belongsTo(list, 7)
      check belongsTo(list, 9)
      check not belongsTo(list, 4)