import os
import subprocess
import argparse

# 定义命令行参数解析
parser = argparse.ArgumentParser(description="Run Joern analysis on a Java file.")
parser.add_argument("cpg_path", type=str, help="Path to the Java file for analysis.")
args = parser.parse_args()

# 从命令行参数获取 CPG 路径
cpg_path = args.cpg_path

# 生成 Joern 脚本
# joern_script = f"""
# import java.nio.file.Paths
# import io.joern.console._
# import io.shiftleft.codepropertygraph.Cpg
# import io.shiftleft.codepropertygraph.cpgloading.CpgLoader


# val inputPath = Paths.get("/Users/scduan/bin/joern/joern-cli/workspace/java/cpg.bin")
# val persistPath = Paths.get("./pdg")

# val cpg = CpgLoader.loadFromOverflowDb(inputPath, persistPath)

# run.callgraph

# val result = cpg.call.map(c =>
#   (c.id, c.methodFullName, c.method.id, c.callee.id.toList, c.lineNumber)
# ).toList

# println("callgraph:")
# result.foreach(println)

# """
joern_script = f"""
val cpgPath = "{cpg_path}"
importCode(cpgPath,"java")
val result = cpg.call.map(c => (c.id, c.methodFullName, c.method.id, c.callee.id.toList, c.lineNumber)).toList
println("callgraph:")
result.foreach(println) 
"""

# 将脚本写入临时文件
with open("temp.sc", "w") as f:
    f.write(joern_script)

# 运行 Joern
subprocess.run(["joern", "--script", "temp.sc"])

# 清理临时文件
os.remove("temp.sc")



'''import io.joern.console._
import io.shiftleft.codepropertygraph.Cpg
import io.joern.dataflowengineoss.language._

val cpg = CpgLoader.loadFromOverflowDB("/your/cpg/path") // 如果你先用 javasrc2cpg 生成好了 cpg.bin

run.callgraph(cpg) // ✅ 只加载 call graph overlay

val result = cpg.call.map(c => (
  c.id, 
  c.methodFullName, 
  c.method.id, 
  c.callee.id.toList, 
  c.lineNumber
)).toList

println("callgraph:")
result.foreach(println)
'''