#!/bin/bash
# java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies.jar -i $1 -o /Users/scduan/Desktop/bashscript/result.txt -m closeBlock -s ./sources.txt -c ./classes.txt

# java -jar loggen-0.0.1-SNAPSHOT-jar-with-dependencies.jar -i /Users/scduan/Desktop/SCLogger/CG/CG.csv -p org.apache.hadoop.fs.aliyun.oss -c OSSDataBlocks\$DiskBlock -m closeBlock -d $2 >Code.txt

# java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies-methodfinder.jar /Users/scduan/Desktop/SCLogger/hadoop-trunk/hadoop-tools "${package_names[$i]}" "${class_names[$i]}" "${method_names[$i]}" 
#编码格式记得改成utf8，用vscode就可以改了
#先判断每一行的第二个是否有slf4j，把有的行数挑出来，然后划分生成pcm文件的格式然后去预测
#grep -E " .+slf4j" your_file.txt
#awk '{print $1}' your_file.txt 筛选空格前的 sed 's/^..//' your_file.txt
#sed -E 's/(.*)\.([^.]+):([^:]+)\(.*/\1 \2 \3/' ddd.txt >aaa2.txt
#sort input.txt | uniq > output.txt
#让methodfinder重新去寻找，然后对应着去看

while IFS= read -r line; do
    # 从每一行中提取 Package、Class 和 Method
echo start execution.....................
read -r package class method <<< "$line"
new_package=$(echo "$package" | sed 's/\./\//g')
#echo “。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。methodfinder start”
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies.jar -i /Users/scduan/Desktop/SCLogger/hadoop-trunk/hadoop-tools/hadoop-aliyun/src/main/java/"$new_package"/"$class".java -o varlist.txt -m "$method" -s ./sources.txt -c ./classes.txt
VarList=$(cat varlist.txt)
    #methodfinder
#echo “。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。varlist start”
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies-methodfinder.jar /Users/scduan/Desktop/SCLogger/hadoop-trunk/hadoop-tools "$package" "$class" "$method" > funclog.txt
funclog=&(cat funclog.txt)
if [ ! -s "funclog.txt" ]; then
        echo "don't have target method aaaaaaaaaaaaa"
        continue  # 如果 funclog 为空，则跳过当前循环
    fi
#echo "$funclog" >> funclogcase.txt
cat funclog.txt >> funclogcase.txt
#echo "aaaaaaaaaaaaaa"
sed '/LOG\./d' funclog.txt >funcnolog.txt
funcnolog=$(cat funcnolog.txt)
sed -i '' '1s/.*/public class A {/' funcnolog.txt 
echo "}" >> funcnolog.txt 
#echo “。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。blocksplit start”
java -jar blockid-0.0.1-SNAPSHOT-jar-with-dependencies.jar -p funcnolog.txt
funccomment=$(cat funcnolog.txt)
#echo “。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。calle start”
java -jar loggen-0.0.1-SNAPSHOT-jar-with-dependencies.jar -i /Users/scduan/Desktop/SCLogger/CG/CG.csv -p $package -c $class -m $method -d /Users/scduan/Desktop/SCLogger/hadoop-trunk >Code.txt
sed '/#split/,$d' Code.txt > callee.txt
#sed '1,/#split/d' Code.txt > calleemethod.txt
#echo “。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。calleemethod start”
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies_prompt.jar -i /Users/scduan/Desktop/SCLogger/CG/CG.csv -p $package -c $class -m $method -d /Users/scduan/Desktop/SCLogger/hadoop-trunk >calleemethod.txt
methodcode=$(cat calleemethod.txt)
sed 's/^\[//;s/\]$//' callee.txt > calleekuohao.txt
sed 's/}, /}\n/g' calleekuohao.txt > calleesort.txt
python3 log_methods_generator.py --cg /Users/scduan/Desktop/SCLogger/aaa.txt --output loggraph.txt
./splitloggraph.sh >splitloggraph.txt

comm -12 <(sort calleesort.txt) <(sort splitloggraph.txt) > log_matchmethod.txt

./methodfinder.sh
grep -E '^\s*LOG\.' log.txt >logwithspace.txt
sed 's/^[[:space:]]*//' logwithspace.txt > finalllog.txt
logslice=$(cat finalllog.txt)

    
    #把log删掉，删掉后用来做target method
    #用gpt划分出block来（我已经划分了20个了）
    #3 再加上callee and caller
    #4 再加上related log
    #5
#echo "aaaaaaaaaaaaaaaaaaaaaaa$funccomment"
prompt=$(cat << EOF 
Instruction:
If I want to insert logging statements in the following code, please provide me with the source code that includes the newly inserted log.

A prerequisite is to do not consider inserting a new log at the "throw statement" in source code.

To complete this task, please follow the steps below:
First, identify the Try-Catch Block, Branching Block, Looping Block, Method Declaration Block, and Return-value-check Block based on the comments in the code.
Next, determine if a logging statement is needed in each Try-Catch Block. If it is needed, please insert a log in each block you think requires one.
Then, determine if a logging statement is needed in each Branching Block. If it is needed, please insert a log in each block you think requires one.
Afterward, determine if a logging statement is needed in each Looping Block. If it is needed, please insert a log in each block you think requires one.
Next, determine if a logging statement is needed in each Method Declaration Block. If it is needed, please insert a log in each block you think requires one.
Finally, determine if a logging statement is needed in each Return-value-check Block. If it is needed, please insert a log in each block you think requires one.


The target method is blow：
Target method：
$funccomment 
Let’s think step by step. First, 
$methodcode 
Second, the succeeding and proceeding logs are:
$logslice 
Third, available variables of this method are:
$VarList

EOF
)

echo "$prompt" >> promptexample2.txt
#python3 openai_demo.py --p "$prompt" >> predictionresult6.txt
rm log.txt
done < aaa3.txt

prompt1=$(cat << EOF 
Instruction:
If I want to insert only one logging statement in the following code, please provide me with the source code that includes the newly inserted log.

A prerequisite is to do not consider inserting a new log at the "throw statement" in source code.

To complete this task, please follow the steps below:
First, identify the Try-Catch Block, Branching Block, Looping Block, Method Declaration Block, and Return-value-check Block based on the comments in the code.
Next, determine if a logging statement is needed in the Try-Catch Block.
Then, determine if a logging statement is needed in the Branching Block. 
Afterward, determine if a logging statement is needed in the Looping Block. 
Next, determine if a logging statement is needed in the Method Declaration Block. 
Finally, determine if a logging statement is needed in the Return-value-check Block. 
after this, give me the line where you think it’s most appropriate to insert the log.

The target method is blow：
Target method：
$funccomment 
Let’s think step by step. First, 
$methodcode 
Second, the succeeding and proceeding logs are:
$logslice 
Third, available variables of this method are:
$VarList

EOF
)

prompt2=$(cat << EOF 
You are a highly professional Java developer with 15 years of coding experience, well-versed in adding logs to code. Their logging practices consistently make a significant impact on code maintenance.
Please read the following instruction and provide a response.
Instruction:
If I want to insert only one logging statement in the following code, please provide me with the source code that includes the newly inserted log.


To complete this task, please follow the steps below:
First, identify the Try-Catch Block, Branching Block, Looping Block, Method Declaration Block, and Return-value-check Block based on the comments in the code.
Next, determine if a logging statement is needed in the Try-Catch Block. If it is needed, please give me the best choice within this same kind of blocks.
Then, determine if a logging statement is needed in the Branching Block. If it is needed, please give me the best choice within this same kind of blocks.
Afterward, determine if a logging statement is needed in the Looping Block. If it is needed, please give me the best choice within this same kind of blocks.
Next, determine if a logging statement is needed in the Method Declaration Block. If it is needed, please give me the best choice within this same kind of blocks.
Finally, determine if a logging statement is needed in the Return-value-check Block. If it is needed, please give me the best choice within this same kind of blocks.
After this, select one position where it is most needed from the above and insert it into the source code at the target method.
If the optimal log appears on the line before or after the `throw` statement, please ignore it and choose the next best log to insert into the source code.


The target method is blow：
Target method：
$funccomment 
Let’s think step by step. First, 
$methodcode 
Second, the succeeding and proceeding logs are:
$logslice 
Third, available variables of this method are:
$VarList

EOF
)

#LOG.debug("Closed {}", this);LOG.debug("Block[{}]: Buffer file {} exists —close upload stream";
#LOG.debug("Closed {}", this);LOG.debug("Block[{}]: Buffer file {} exists —close upload stream";

# the target method called by methodA:
#         /**
#         * The close operation will delete the destination file if it still
#         * exists.
#         * @throws IOException IO problems
#         */
#         @SuppressWarnings("UnnecessaryDefault")
#         @Override
#         protected void innerClose() throws IOException {
#           final DestState state = getState();
#           LOG.debug("Closing {}", this);
#           switch (state) {
#           case Writing:
#             if (bufferFile.exists()) {
#               // file was not uploaded
#               LOG.debug("Block[{}]: Deleting buffer file as upload did not start",
#                   getIndex());
#               closeBlock();
#             }
#             break;

#           case Upload:
#             LOG.debug("Block[{}]: Buffer file {} exists —close upload stream",
#                 getIndex(), bufferFile);
#             break;

#           case Closed:
#             closeBlock();
#             break;

#           default:
#             // this state can never be reached, but checkstyle complains, so
#             // it is here.
#           }
#         }, 
#         methodA called by methodB:
#         @Override
#         public void close() throws IOException {
#           if (enterClosedState()) {
#             LOG.debug("Closed {}", this);
#             innerClose();
#           }
#         }
#         target method call the method C: 
#         protected void blockReleased() {
#           if (statistics != null) {
#             statistics.blockReleased();
#           }
#         }
#         method C call the method D:
#         /**
#           * Closing the block will release the buffer.
#           */
#           @Override
#           protected void innerClose() {
#             if (blockBuffer != null) {
#               releaseMemory(bufferSize);
#               blockReleased();
#               bytesReleased(bufferSize);
#               releaseBuffer(blockBuffer);
#               blockBuffer = null;
#             }
#           }


# void closeBlock() {
#         // Branching Block 1 start
#         if (!closed.getAndSet(true)) {
#             // Method Declaration Block start
#             blockReleased();
#             // Method Declaration Block end
#             // Method Declaration Block start
#             diskBlockReleased();
#             // Method Declaration Block end
#             // Branching Block 2 start
#             if (!bufferFile.delete() && bufferFile.exists()) {
#             }
#             // Branching Block 2 end
#         } else {
#         }
#         // Branching Block 1 end
#     }