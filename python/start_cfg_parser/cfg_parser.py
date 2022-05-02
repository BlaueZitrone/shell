from anytree import Node, RenderTree
root = Node("root", content="RootNode")
currentNode = root
fh = open("sample.cfg", "r")
line = fh.readline()
databuffer = ""

for c in line:
  match(c):
    case('{'):
      currentNode = Node("", parent=currentNode, content="")
    case('}'):
      currentNode.content = databuffer
      databuffer = ""
      currentNode = currentNode.parent
    case(','):
      currentNode.content = databuffer
      databuffer = ""
      currentNode = Node("", parent=currentNode.parent)
    case(_):
      databuffer += c

# for pre, _, node in RenderTree(root):
#   print(pre, node.content)

with open("result.txt", "w", encoding="utf-8") as f:
  for pre, _, node in RenderTree(root):
    f.write(pre + node.content + "\n")
# print(RenderTree(root).by_attr("content"))
# print("Hallo, ich bin Chen", file=open("result.txt", "w"))