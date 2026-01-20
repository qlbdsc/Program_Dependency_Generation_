import pygraphviz as pgv
import subprocess, os, argparse


parser = argparse.ArgumentParser()
parser.add_argument('-n', "--number", type=int, help="line number", default=1)
parser.add_argument('-d', "--dotfile", type=str, help="name of dot file", default=0)
args = parser.parse_args()


def load_pdg(dot_file):
    """ 加载PDG (DOT文件) 并返回图对象 """
    graph = pgv.AGraph(dot_file)
    return graph

def backward_slice_with_labels(graph, target_node, max_hops=7):
    """
    计算目标节点的 backward slice（最多 max_hops 层），并获取每个节点的标签
    """
    visited = set()
    stack = [(target_node, 0)]  # 每个元素是 (节点, 当前hop深度)
    slice_with_labels = {}

    while stack:
        node, depth = stack.pop()
        if node not in visited and depth <= max_hops:
            visited.add(node)

            node_obj = graph.get_node(node)
            label = node_obj.attr.get("label", node)
            slice_with_labels[node] = label

            if depth < max_hops:
                predecessors = graph.predecessors(node)
                for pred in predecessors:
                    stack.append((pred, depth + 1))
    return slice_with_labels


# 加载PDG
dot_file = args.dotfile
graph = load_pdg(dot_file)

# 选择目标节点
target_node = args.number  # 替换为你的目标节点

# 生成backward slice（包含节点和标签）
slice_nodes_with_labels = backward_slice_with_labels(graph, target_node, max_hops=7)

# 输出结果
labelfilename = "/mnt/storage/shengchenduan/joern-cli/result/"+args.dotfile+"/"+str(args.number)+"lable.txt"
with open(labelfilename, "a") as file:
    for label in slice_nodes_with_labels.items():
        file.write(f"{label}\n")  # 写入文件
# for label in slice_nodes_with_labels.items():
#     print(f"{label}")

# import pygraphviz as pgv

# def load_pdg(dot_file):
#     # 加载DOT文件
#     graph = pgv.AGraph(dot_file)
#     return graph

# def backward_slice(graph, target_node):
#     # 初始化访问集合
#     visited = set()
#     # 使用DFS进行后向切片
#     stack = [target_node]
    
#     while stack:
#         node = stack.pop()
#         if node not in visited:
#             visited.add(node)
#             # 获取所有前驱节点（依赖节点）
#             predecessors = graph.predecessors(node)
#             stack.extend(predecessors)
    
#     return visited

# # 加载PDG
# dot_file = '0-pdg.dot'
# graph = load_pdg(dot_file)

# # 选择目标节点
# target_node = '30064771076'  # 替换为你的目标节点

# # 生成backward slice
# slice_nodes = backward_slice(graph, target_node)

# # 输出结果
# print("Backward Slice Nodes:", slice_nodes)


# import networkx as nx
# from networkx.drawing.nx_agraph import read_dot
# import pygraphviz

# # 1. 加载 DOT 文件
# def load_pdg(dot_file):
#     """
#     加载 DOT 文件并解析为 NetworkX 图对象。
#     """
#     try:
#         pdg = read_dot(dot_file)
#         print(f"成功加载 DOT 文件: {dot_file}")
#         return pdg
#     except Exception as e:
#         print(f"加载 DOT 文件失败: {e}")
#         return None

# # 2. 反向切片函数
# def backward_slice(pdg, start_node):
#     """
#     从指定的起始节点出发，执行反向切片。
#     """
#     visited = set()
#     stack = [start_node]
#     slice_nodes = set()

#     while stack:
#         node = stack.pop()
#         if node not in visited:
#             visited.add(node)
#             slice_nodes.add(node)
#             # 获取所有前驱节点（逆向遍历）
#             for predecessor in pdg.predecessors(node):
#                 stack.append(predecessor)

#     return slice_nodes

# # 3. 输出切片结果
# def print_slice_results(slice_nodes, node_to_code):
#     """
#     将切片节点映射回源代码并输出。
#     """
#     print("Backward Slice 结果:")
#     for node in slice_nodes:
#         if node in node_to_code:
#             print(f"节点 {node}: {node_to_code[node]}")
#         else:
#             print(f"节点 {node}: 无对应代码")

# # 4. 主函数
# def main():
#     # 加载 DOT 文件
#     dot_file = "0-pdg.dot"  # 替换为你的 DOT 文件路径
#     pdg = load_pdg(dot_file)
#     if not pdg:
#         return

#     # 定义节点到代码的映射（根据你的 DOT 文件内容填写）
#     node_to_code = {
#         "30064771072": "Credentials this.credentials = null;",
#         "30064771074": "accessKeyId = AliyunOSSUtils.getValueWithKey(conf, ACCESS_KEY_ID);",
#         "30064771076": "accessKeySecret = AliyunOSSUtils.getValueWithKey(conf, ACCESS_KEY_SECRET);",
#         "30064771082": "securityToken = AliyunOSSUtils.getValueWithKey(conf, SECURITY_TOKEN);",
#         "30064771093": "this.credentials = new DefaultCredentials(accessKeyId, accessKeySecret, securityToken);",
#         "30064771075": "getValueWithKey(conf, ACCESS_KEY_ID);",
#         "30064771077": "getValueWithKey(conf, ACCESS_KEY_SECRET);",
#         "30064771083": "getValueWithKey(conf, SECURITY_TOKEN);",
#         # 添加其他节点的映射...
#     }

#     # 定义切片标准
#     slice_criterion = "30064771093"  # 替换为你的切片标准节点
#     if slice_criterion not in pdg:
#         print(f"错误: 切片标准节点 {slice_criterion} 不在 PDG 中")
#         return

#     # 执行反向切片
#     slice_nodes = backward_slice(pdg, slice_criterion)

#     # 输出切片结果
#     print_slice_results(slice_nodes, node_to_code)

# if __name__ == "__main__":
#     main()