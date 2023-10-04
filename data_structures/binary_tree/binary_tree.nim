## Binary search tree
##
## A binary search tree is a data structure that preserves the order
## on elements along the insertion of the elements in the tree. Each node have
## three attributes a data and link to a left and right subtrees.
## It satisfy the following properties:
## 1. An element only appears once
## 2. Each element of the subtree of the left child has a lower value than the node's data
## 3. Each element of the right subtree has elements of larger value than the node's data
##
## A specific kind of BST is the AVL tree in which each leaf has either the same depth or their depths differ by one.

type
  BinarySearchTree[T] = ref object
    data: T
    leftChild, rightChild: BinarySearchTree[T]

proc initBinarySearchTree*[T](data: T): BinarySearchTree[T] =
  new(result)
  result.data = data

proc insert*[T](root: var BinarySearchTree[T], newValue: T) =
  ## Adds a node to an initialized binary search tree.
  if root == nil:
    root = initBinarySearchTree[T](newValue)
  if newValue < root.data:
    insert[T](root.leftChild, newValue)
  elif newValue > root.data:
    insert[T](root.rightChild, newValue)

proc insert*[T](root: var BinarySearchTree[T], values: seq[T]) =
  ## Adds a list of nodes to an initialized binary search tree.
  for value in values:
    insert[T](root, value)

proc printBstRec(tree: BinarySearchTree) =
  if tree != nil:
    stdout.write($tree.data & " ")
    if tree.leftChild != nil:
      stdout.write("<")
      printBstRec(tree.leftChild)
    if tree.rightChild != nil:
      stdout.write(">")
      printBstRec(tree.rightChild)

proc printInfixBstRec*(tree: BinarySearchTree): string =
  ## Outputs data of a binary search tree in a sorted manner.
  if tree != nil:
    result = result & printInfixBstRec(tree.leftChild)
    result = result & $tree.data & " "
    result = result & printInfixBstRec(tree.rightChild)

proc printPostfixBstRec*(tree: BinarySearchTree) =
  if tree != nil:
    printPostfixBstRec(tree.leftChild)
    printPostfixBstRec(tree.rightChild)
    stdout.write($tree.data & " ")

proc printPrefixBst*(tree: BinarySearchTree) =
  ## Outputs a binary search tree following the preorder traversal (prefix notation).
  ## The type T must have a `$` proc.
  ## Ensures we have an end of line at the end of the output.
  if tree != nil:
    printBstRec(tree)
    echo()

proc `$`*(tree: BinarySearchTree): string =
  ## Default output of a binary search tree outputs elements
  ##  encountered in an inorder traversal.
  if tree != nil:
    return printInfixBstRec(tree) & "\n"

proc printPostfixBst*(tree: BinarySearchTree) =
  ## Outputs a binary search tree following the postorder traversal (postfix notation).
  ## The type T must have a `$` proc.
  ## Ensures we have an end of line at the end of the output.
  if tree != nil:
    printPostfixBstRec(tree.left)
    echo()

proc search*[T](tree: BinarySearchTree, data: T): bool =
  ## Finds a value in the Binary Search Tree in O(log(n)).
  if tree == nil: return false
  elif tree.data == data: return true
  else:
    if data < tree.data:
      return search(tree.leftChild, data)
    else:
      return search(tree.rightChild, data)

proc height*(tree: BinarySearchTree): int =
  ## Useful for maintaining an AVL tree during insertion of an element.
  if tree == nil:
    return -1
  return 1 + max(height(tree.leftChild), height(tree.rightChild))

## The following operations permit to keep the tree branches balanced 
## (meaning the height of the leaves only differ by at most one)
## A rotation inverts the position of the root with its children and 
## moves a subtree to the new children. When rotating, one preserves
## the order of the elements.
proc rotateRight*(tree: BinarySearchTree): BinarySearchTree =
  if tree.leftChild == nil: return tree
  let g = tree.leftChild
  let v = g.rightChild
  g.rightChild = tree
  tree.leftChild = v
  return g

proc rotateLeft*(tree: BinarySearchTree): BinarySearchTree =
  if tree.rightChild == nil: return 
  let g = tree.rightChild
  let v = g.leftChild
  g.leftChild = tree
  tree.rightChild = v
  return g

proc balanceBST*(t: var BinarySearchTree) =
  ## To balance a binary search tree, we need to perform at most 
  ## two rotations.
  let hg = height(t.leftChild)
  let hd = height(t.rightChild)
  # We rotate to the direction of the subtree at the lowest height.
  if hg - hd == 2:
    # We perform an additional rotation when the subtrees of the left node
    # are also unbalanced
    if height(t.leftChild.leftChild) < height(t.leftChild.rightChild):
      t.leftChild = rotateLeft(t.leftChild)
    t = rotateRight(t)
  elif hg - hd == -2:
    if height(t.rightChild.rightChild) < height(t.rightChild.leftChild):
      t.rightChild = rotateRight(t.rightChild)
    t = rotateLeft(t)

proc balanceInsert*[T](t: var BinarySearchTree, data: T) =
  ## Keep the tree balanced after an insertion.
  insert[T](t, data)
  balanceBST(t)

when isMainModule:
  var root = initBinarySearchTree[int](13)
  insert[int](root, @[10, 10, 17, 8, 12, 9, 23, 20, 15])
  printPrefixBst(root)
  echo $root
  echo("Is 6 in the BST?: ", search(root, 6))
  assert root.data == 13
  assert root.leftChild.data == 10
  assert root.leftChild.rightChild.data == 12
  insert[int](root, 6)
  insert[int](root, 18)
  balanceInsert[int](root, 13)

  var test = initBinarySearchTree[int](4)
  insert[int](test, @[2,3,1])
  printPrefixBst(test) # 4 <2 <1 >3
  echo $test
  test = rotateRight(test)
  printPrefixBst(test) # 2 <1 >4 <3
