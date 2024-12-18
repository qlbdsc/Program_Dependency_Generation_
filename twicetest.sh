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
counter=0
result_counter=0
export result_counter
while IFS= read -r line; do
    # 从每一行中提取 Package、Class 和 Method
echo start execution.....................
read -r package class method <<< "$line"
new_package=$(echo "$package" | sed 's/\./\//g')
#echo “。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。methodfinder start”
#修改点---hadoop-azure
#java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies.jar -i /Users/scduan/Desktop/SCLogger/hadoop-trunk/hadoop-tools/hadoop-azure/src/main/java/"$new_package"/"$class".java -o varlist.txt -m "$method" -s ./sources.txt -c ./classes.txt
#VarList=$(cat varlist.txt)
    #methodfinder
#echo “。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。varlist start”
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies-methodfinder.jar /Users/scduan/Desktop/SCLogger/hadoop-trunk/hadoop-tools "$package" "$class" "$method" > funclog.txt
#funclog=$(cat funclog.txt)
if [ ! -s "funclog.txt" ]; then
        echo "don't have target method aaaaaaaaaaaaa"
        continue  # 如果 funclog 为空，则跳过当前循环
    fi
#echo $funclog >> funclogcase1.txt
cat funclog.txt >> funclogcase1.txt
# 读取文件的第一行
first_line=$(head -n 1 funclog.txt)
# 提取最后一个空格到冒号之间的内容
extracted=$(echo "$first_line" | grep -oE ' [^ ]*:')

# 去掉开头的空格和末尾的冒号
result=$(echo "$extracted" | sed 's/^ //; s/:$//')


#echo "aaaaaaaaaaaaaa"
awk '/^[[:space:]]*LOG\./ {print NR}' funclog.txt > groundtruthnum.txt
sed '/^[[:space:]]*LOG\./d' funclog.txt >funcnolog.txt
funcnolog=$(cat funcnolog.txt)
sed -i '' '1s/.*/public class A {/' fuåncnolog.txt 
echo "}" >> funcnolog.txt 
#echo “。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。blocksplit start”
java -jar blockid-0.0.1-SNAPSHOT-jar-with-dependencies.jar -p funcnolog.txt 
funccomment=$(cat funcnolog.txt)
echo '。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。calle start'
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies_log.jar -i /Users/scduan/Desktop/SCLogger/callgraph_file_selection/1twicetest/project.txt -p $package -c $class -m $method -d /Users/scduan/Desktop/SCLogger/hadoop-trunk >callee.txt
#sed '1,/#split/d' Code.txt > calleemethod.txt
echo '。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。calleemethod start'
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies_prompt.jar -i /Users/scduan/Desktop/SCLogger/callgraph_file_selection/1twicetest/project.txt -p $package -c $class -m $method -d /Users/scduan/Desktop/SCLogger/hadoop-trunk >calleemethod.txt
methodcode=$(cat calleemethod.txt)
sed 's/^\[//;s/\]$//' callee.txt > calleekuohao.txt
sed 's/}, /}\n/g' calleekuohao.txt > calleesort.txt
#python3 log_methods_generator.py --cg /Users/scduan/Desktop/SCLogger/callgraph_file_selection/1twicetest/project.txt --output loggraph.txt
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
You are a highly professional Java developer with 15 years of coding experience, well-versed in adding logs to code. Their logging practices consistently make a significant impact on code debug.
You can mimic answering them in the background five times and provide me with the most frequently appearing answer. Please read the following instruction and provide a response.
Instruction:
If I want to insert only one logging statement in the following code, please provide me with the source code that includes the newly inserted log without any other things.


To complete this task, let’s think step by step.:
First, identify the Try-Catch Block, Branching Block, Looping Block, Method Declaration Block, and Return-value-check Block based on the comments in the code.
Then, identify the statements in the method that already contain logging functionality, such as "throw new Exception", and avoid adding logs before or after these positions again.
Next, determine if a logging statement is needed in the Try-Catch Block. If it is needed, please give me the best choice within this same kind of blocks.
Then, determine if a logging statement is needed in the Branching Block. If it is needed, please give me the best choice within this same kind of blocks.
Afterward, determine if a logging statement is needed in the Looping Block. If it is needed, please give me the best choice within this same kind of blocks.
Next, determine if a logging statement is needed in the Method Declaration Block. If it is needed, please give me the best choice within this same kind of blocks.
Finally, determine if a logging statement is needed in the Return-value-check Block. If it is needed, please give me the best choice within this same kind of blocks.

The target method is blow：
$funccomment 
Let’s think step by step. First, 
$methodcode 
Second, the succeeding and proceeding logs are:
$logslice 

EOF
)
counter=$((counter + 1))
echo "$prompt" > ./prompt/"${counter}_P_${result}.txt"
#python3 openai_demo.py --p "$prompt" > predictionresult6.txt

rm log.txt
done < twicetest.txt
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


# You are a highly professional Java developer with 15 years of coding experience, well-versed in adding logs to code. Their logging practices consistently make a significant impact on code debug.

# To complete this task, please follow the steps below:
# First, identify the Try-Catch Block, Branching Block, Looping Block, Method Declaration Block, and Return-value-check Block based on the comments in the code.
# Then, identify the  "throw new Exception" code in the source code. If have, please do not consider to insert a log into this position.
# Next, determine if a logging statement is needed in the Try-Catch Block. If it is needed, please give me the best choice within this same kind of blocks.
# Then, determine if a logging statement is needed in the Branching Block. If it is needed, please give me the best choice within this same kind of blocks.
# Afterward, determine if a logging statement is needed in the Looping Block. If it is needed, please give me the best choice within this same kind of blocks.
# Next, determine if a logging statement is needed in the Method Declaration Block. If it is needed, please give me the best choice within this same kind of blocks.
# Finally, determine if a logging statement is needed in the Return-value-check Block. If it is needed, please give me the best choice within this same kind of blocks.

# The target method is blow：
# public class A { //first line
# /** 
#  * Execute the file operation parallel using threads. All threads works on a single working set of files stored in input 'contents'. The synchronization between multiple threads is achieved through retrieving atomic index value from the array. Once thread gets the index, it retrieves the file and initiates the file operation. The advantage with this method is that file operations doesn't get serialized due to any thread. Also, the input copy is not changed such that caller can reuse the list for other purposes. This implementation also considers that failure of operation on single file is considered as overall operation failure. All threads bail out their execution as soon as they detect any single thread either got exception or operation is failed.
#  * @param contents List of blobs on which operation to be done.
#  * @param threadOperation The actual operation to be executed by each thread on a file.
#  * @param operationStatus Returns true if the operation is success, false if operation is failed.
#  * @throws IOException
#  */
# boolean executeParallel(FileMetadata[] contents,AzureFileSystemThreadTask threadOperation) throws IOException {//This is start of Method Declaration Block1
#   boolean operationStatus=false;
#   boolean threadsEnabled=false;
#   int threadCount=this.threadCount;
#   ThreadPoolExecutor ioThreadPool=null;
#   long start=Time.monotonicNow();
#   threadCount=Math.min(contents.length,threadCount);
#   if (threadCount > 1) {//This is start of Branching Block1
#     try {//This is start of Try-Catch Block1
#       ioThreadPool=getThreadPool(threadCount);
#       threadsEnabled=true;
#     }
#  catch (    Exception e) {
#     }//This is end of Try-Catch Block1
#   }
#  else {
#   }//This is end of Branching Block1
#   if (threadsEnabled) {//This is start of Branching Block2
#     boolean started=false;
#     AzureFileSystemThreadRunnable runnable=new AzureFileSystemThreadRunnable(contents,threadOperation,operation);
#     for (int i=0; i < threadCount && runnable.lastException == null && runnable.operationStatus; i++) {//This is start of Looping Block1
#       try {//This is start of Try-Catch Block2
#         ioThreadPool.execute(runnable);
#         started=true;
#       }
#  catch (      RejectedExecutionException ex) {
#       }//This is end of Try-Catch Block2
#     }//This is end of Looping Block1
#     ioThreadPool.shutdown();
#     try {//This is start of Try-Catch Block3
#       ioThreadPool.awaitTermination(Long.MAX_VALUE,TimeUnit.DAYS);
#     }
#  catch (    InterruptedException intrEx) {
#       ioThreadPool.shutdownNow();
#       Thread.currentThread().interrupt();
#     }//This is end of Try-Catch Block3
#     int threadsNotUsed=threadCount - runnable.threadsUsed.get();
#     if (threadsNotUsed > 0) {//This is start of Branching Block3
#     }//This is end of Branching Block3
#     if (!started) {//This is start of Branching Block4
#       threadsEnabled=false;
#     }
#  else {
#       IOException lastException=runnable.lastException;
#       if (lastException == null && runnable.operationStatus && runnable.filesProcessed.get() < contents.length) {//This is start of Branching Block5
#         lastException=new IOException(operation + " failed as operation on subfolders and files failed.");
#       }//This is end of Branching Block5
#       if (lastException != null) {//This is start of Branching Block6
#         throw lastException;
#       }//This is end of Branching Block6
#       operationStatus=runnable.operationStatus;
#     }//This is end of Branching Block4
#   }//This is end of Branching Block2
#   if (!threadsEnabled) {//This is start of Branching Block7
#     for (int i=0; i < contents.length; i++) {//This is start of Looping Block2
#       if (!threadOperation.execute(contents[i])) {//This is start of Branching Block8
#         return false;
#       }//This is end of Branching Block8
#     }//This is end of Looping Block2
#     operationStatus=true;
#   }//This is end of Branching Block7
#   long end=Time.monotonicNow();
#   return operationStatus;
# }//This is end of Method Declaration Block1

# } 
# Let’s think step by step. First, 
# Method A called by method B.
# Method B is 
# @Override @Deprecated public boolean delete(Path path) throws IOException {
#   return delete(path,true);
# }

# Target method called by method A.
# Method A is 
# private boolean deleteWithoutAuth(Path f,boolean recursive,boolean skipParentFolderLastModifiedTimeUpdate) throws IOException {
#   LOG.debug("Deleting file: {}",f);
#   Path absolutePath=makeAbsolute(f);
#   Path parentPath=absolutePath.getParent();
#   String key=pathToKey(absolutePath);
#   FileMetadata metaFile=null;
#   try {
#     metaFile=store.retrieveMetadata(key);
#   }
#  catch (  IOException e) {
#     Throwable innerException=checkForAzureStorageException(e);
#     if (innerException instanceof StorageException && isFileNotFoundException((StorageException)innerException)) {
#       return false;
#     }
#     throw e;
#   }
#   if (null == metaFile) {
#     return false;
#   }
#   if (!metaFile.isDirectory()) {
#     if (parentPath.getParent() != null) {
#       String parentKey=pathToKey(parentPath);
#       FileMetadata parentMetadata=null;
#       try {
#         parentMetadata=store.retrieveMetadata(parentKey);
#       }
#  catch (      IOException e) {
#         Throwable innerException=checkForAzureStorageException(e);
#         if (innerException instanceof StorageException) {
#           if (isFileNotFoundException((StorageException)innerException)) {
#             throw new IOException("File " + f + " has a parent directory "+ parentPath+ " whose metadata cannot be retrieved. Can't resolve");
#           }
#         }
#         throw e;
#       }
#       if (parentMetadata == null) {
#         throw new IOException("File " + f + " has a parent directory "+ parentPath+ " whose metadata cannot be retrieved. Can't resolve");
#       }
#       if (!parentMetadata.isDirectory()) {
#         throw new AzureException("File " + f + " has a parent directory "+ parentPath+ " which is also a file. Can't resolve.");
#       }
#       if (parentMetadata.getBlobMaterialization() == BlobMaterialization.Implicit) {
#         LOG.debug("Found an implicit parent directory while trying to" + " delete the file {}. Creating the directory blob for" + " it in {}.",f,parentKey);
#         store.storeEmptyFolder(parentKey,createPermissionStatus(FsPermission.getDefault()));
#       }
#  else {
#         if (!skipParentFolderLastModifiedTimeUpdate) {
#           updateParentFolderLastModifiedTime(key);
#         }
#       }
#     }
#     try {
#       if (store.delete(key)) {
#         instrumentation.fileDeleted();
#       }
#  else {
#         return false;
#       }
#     }
#  catch (    IOException e) {
#       Throwable innerException=checkForAzureStorageException(e);
#       if (innerException instanceof StorageException && isFileNotFoundException((StorageException)innerException)) {
#         return false;
#       }
#       throw e;
#     }
#   }
#  else {
#     LOG.debug("Directory Delete encountered: {}",f);
#     if (parentPath.getParent() != null) {
#       String parentKey=pathToKey(parentPath);
#       FileMetadata parentMetadata=null;
#       try {
#         parentMetadata=store.retrieveMetadata(parentKey);
#       }
#  catch (      IOException e) {
#         Throwable innerException=checkForAzureStorageException(e);
#         if (innerException instanceof StorageException) {
#           if (isFileNotFoundException((StorageException)innerException)) {
#             throw new IOException("File " + f + " has a parent directory "+ parentPath+ " whose metadata cannot be retrieved. Can't resolve");
#           }
#         }
#         throw e;
#       }
#       if (parentMetadata == null) {
#         throw new IOException("File " + f + " has a parent directory "+ parentPath+ " whose metadata cannot be retrieved. Can't resolve");
#       }
#       if (parentMetadata.getBlobMaterialization() == BlobMaterialization.Implicit) {
#         LOG.debug("Found an implicit parent directory while trying to" + " delete the directory {}. Creating the directory blob for" + " it in {}. ",f,parentKey);
#         store.storeEmptyFolder(parentKey,createPermissionStatus(FsPermission.getDefault()));
#       }
#     }
#     long start=Time.monotonicNow();
#     final FileMetadata[] contents;
#     try {
#       contents=store.list(key,AZURE_LIST_ALL,AZURE_UNBOUNDED_DEPTH);
#     }
#  catch (    IOException e) {
#       Throwable innerException=checkForAzureStorageException(e);
#       if (innerException instanceof StorageException && isFileNotFoundException((StorageException)innerException)) {
#         return false;
#       }
#       throw e;
#     }
#     long end=Time.monotonicNow();
#     LOG.debug("Time taken to list {} blobs for delete operation: {} ms",contents.length,(end - start));
#     if (contents.length > 0) {
#       if (!recursive) {
#         throw new IOException("Non-recursive delete of non-empty directory " + f);
#       }
#     }
#     AzureFileSystemThreadTask task=new AzureFileSystemThreadTask(){
#       @Override public boolean execute(      FileMetadata file) throws IOException {
#         if (!deleteFile(file.getKey(),file.isDirectory())) {
#           LOG.warn("Attempt to delete non-existent {} {}",file.isDirectory() ? "directory" : "file",file.getKey());
#         }
#         return true;
#       }
#     }
# ;
#     AzureFileSystemThreadPoolExecutor executor=getThreadPoolExecutor(this.deleteThreadCount,"AzureBlobDeleteThread","Delete",key,AZURE_DELETE_THREADS);
#     if (!executor.executeParallel(contents,task)) {
#       LOG.error("Failed to delete files / subfolders in blob {}",key);
#       return false;
#     }
#     if (store.retrieveMetadata(metaFile.getKey()) != null && !deleteFile(metaFile.getKey(),metaFile.isDirectory())) {
#       LOG.error("Failed delete directory : {}",f);
#       return false;
#     }
#     Path parent=absolutePath.getParent();
#     if (parent != null && parent.getParent() != null) {
#       if (!skipParentFolderLastModifiedTimeUpdate) {
#         updateParentFolderLastModifiedTime(key);
#       }
#     }
#   }
#   LOG.debug("Delete Successful for : {}",f);
#   return true;
# } 
# Second, the succeeding and proceeding logs are:
# LOG.debug("Deleting file: {}",f);
# LOG.debug("Found an implicit parent directory while trying to" + " delete the file {}. Creating the directory blob for" + " it in {}.",f,parentKey);
# LOG.debug("Directory Delete encountered: {}",f);
# LOG.debug("Found an implicit parent directory while trying to" + " delete the directory {}. Creating the directory blob for" + " it in {}. ",f,parentKey);
# LOG.debug("Time taken to list {} blobs for delete operation: {} ms",contents.length,(end - start));
# LOG.warn("Attempt to delete non-existent {} {}",file.isDirectory() ? "directory" : "file",file.getKey());
# LOG.error("Failed to delete files / subfolders in blob {}",key);
# LOG.error("Failed delete directory : {}",f);
# LOG.debug("Delete Successful for : {}",f); 



# You can mimic answering them in the background ten times and provide me with the most frequently appearing answer. Only give the answer without any other things.
# Strictly follow the answer format below 
# Try-Catch Block: <Line Number> <previous line>
# Branching Block: <Line Number> <previous line>
# Looping Block: <Line Number> <previous line>
# Method Declaration Block: <Line Number> <previous line>
# Return-value-check Block: <Line Number> <previous line>