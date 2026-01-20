

    #file="./javaclass/$1"

    linenum=$1
    file_path=$2
    file=$3
    echo "aaaaaaaaaaaaaa"+$file_path

    #在这里添加一个if来判断是否已经存在文件./merged/${file}_merged.dot
    #记得把最下面的那个rm指令给删除，只需要rm mergeddot
if [[ -f "./merged/${file}_merged.dot" ]]; then
        echo "文件存在"
else
        echo "文件不存在"

    python3 import.py $file_path > cg.txt #generate call graph
    echo "aaaaaaaaaa"

    #abstract caller and callee
    sed -n '/callgraph:/,$p' cg.txt > cgfilter.txt
    awk -F',' '{print substr($0, 2, index($0, ",") - 2)}' cgfilter.txt > caller.txt
    sed -i '1d' caller.txt
    callerarray=()
    while IFS= read -r line; do
        callerarray+=("$line")
    done < caller.txt
    sed -n 's/.*List(\([^)]*\)).*/\1/p' cgfilter.txt > callee.txt
    calleearray=()
    while IFS= read -r line; do
        calleearray+=("$line")
    done < callee.txt


#generate PDG and merge them.
    ./joern-parse $file_path
    ./joern-export /mnt/storage/shengchenduan/joern-cli/cpg.bin --repr pdg --out ./pdg/${file}
    touch ./merged/${file}_merged.dot
    echo "111"
    for dot_file in ./pdg/${file}/*.dot; do
        sed '1d;$d' $dot_file >> ./merged/${file}_merged.dot
    done
    echo "222"
    sed -i '1s/^/digraph merged_graph {\n/' ./merged/${file}_merged.dot
    touch subcall.txt
    #echo "${calleearray[@]}"
    echo "数组长度: ${#calleearray[@]}"

    # dot_lines=()
    # while IFS= read -r line; do
    #     dot_lines+=("$line")
    # done < "merged/${file}_merged.dot"

    # 创建或清空输出文件
    > subcall.txt
    # 遍历 calleearray 获取目标节点下一行信息
    # for element in "${calleearray[@]}"; do
    #     for i in "${!dot_lines[@]}"; do
    #         if [[ "${dot_lines[$i]}" == *"\"$element\" [label = <"* ]]; then
    #             next_line_index=$((i + 1))
    #             if (( next_line_index < ${#dot_lines[@]} )); then
    #                 next_line="${dot_lines[$next_line_index]}"
    #                 return_value=$(echo "$next_line" | awk -F'"' '{print $2}')
    #                 echo "\"$return_value\"" >> subcall.txt
    #             fi
    #             break
    #         fi
    #     done
    # done

######################################
#这个好像还能解决一下，不要每次都创建新的merge.dot
######################################

    # cd merged
    #Connect callers and callees in Dot file
    for element in "${calleearray[@]}"; do
        echo "$element"
        # echo "bbb"
        #line_number=$(grep -n "\"$element\" \[label = <" ./merged/${file}_merged.dot | cut -d: -f1)
        line_number=$(grep -n "\"$element\" \[label = <" ./merged/${file}_merged.dot | cut -d: -f1 | head -n1)
        #echo $line_number
        echo "aaaaaaaaa"


        echo $line_number
        # echo "ccc"
        result=$(awk -v line="$line_number" 'NR == line + 1' ./merged/${file}_merged.dot)
        # echo "ddd"
        #echo ' "'"$element"'" -> "'"${callerarray[$i]}"'" [ label = "CDG: "];' >> ./merged/${file}_merged.dot     
        return_value=$(echo "$result" | awk -F'"' '{print $2}')
        echo ' "'"$return_value"'"'>>subcall.txt
    done
    # cd ..
    echo "333"
    > subcall2.txt
    echo "subucall2"
    for element2 in "${callerarray[@]}"; do
        echo '-> "'"$element2"'"  [ label = "CDG: "];'>>subcall2.txt
    done
       echo "数组长度caller: ${#callerarray[@]}"
    echo "fff"
    paste -d ' ' subcall.txt subcall2.txt > callg.txt
    sed -i '/^ ""/d' callg.txt
    sed -i 's/^/ /' callg.txt 
    cat callg.txt >> ./merged/${file}_merged.dot
    echo "}" >> ./merged/${file}_merged.dot
    rm subcall2.txt
    rm subcall.txt


fi

# Doing backward slicing based on linenumber
    cd result
    mkdir ${file}_merged.dot
    cd ..
    touch output.txt
    javanum=$(wc -l < $file_path | tr -d ' ')
    echo $javanum
    for ((i=0; i<javanum; i++)); do
        echo "" >> output.txt
    done
    touch logsl.txt
    cd /mnt/storage/shengchenduan/joern-cli/merged
    echo "${file}_merged.dot"
    echo "filefilefiel"
    if grep -q "\<${linenum}<BR/>" "${file}_merged.dot"; then
        echo "2223333333333"
        
        grep "${linenum}<BR/>" "${file}_merged.dot" > "${file}.txt"
        while IFS= read -r line; do
            cd merged
            pwd
            nodenumber=$(echo "$line" | awk -F '"' '{print $2}')
            echo "$nodenumber"
            python3 bl_limit.py -n $nodenumber -d "${file}_merged.dot"
            cd /mnt/storage/shengchenduan/joern-cli
            #grep ./result/${file}_merged.dot/${nodenumber}label.txt
            awk -F'<BR/>' '{print $1}'  /mnt/storage/shengchenduan/joern-cli/result/${file}_merged.dot/${nodenumber}lable.txt > mid_line.txt
            awk -F ', ' '{print $NF}' mid_line.txt > lineu.txt
            echo "aaaaaa"
            sed -i '/^[^0-9]/d' lineu.txt
            cat lineu.txt > ./backwardlinenum/${file}_${linenum}.txt
            
            linenumber=()
            sort lineu.txt | uniq > temp.txt && mv temp.txt lineu.txt

            while IFS= read -r line; do
                linenumber+=("$line")
            done < lineu.txt


###################333########################################

            


            
                # 临时文件
            
            # touch output.txt
            # for ((i=0; i<javanum; i++)); do
            #     echo "" >> output.txt
            # done

            # 提取指定行并写入临时文件

            #touch logsl.txt
            
            echo "logsllllllllllllllll"
        #     for line in "${linenumber[@]}"; do
        #         echo "$line"
        #         sed -n "$((line))p" "$file_path">>logsl.txt
        #         sed -n "$((line-1))p" "$file_path">>logsl.txt
        #         sed -n "$((line+1))p" "$file_path">>logsl.txt
        # #         sed -n "${line}p" "$file_path" > tem.txt
        # #         #insert_line="${linenumber[]}"
        # #         sed -i '' "${line} {
        # #             r tem.txt
        # #             d
        # #         }" output.txt
        #      done
         done < "${file}.txt"

    # awk '/^[[:space:]]*LOG\./ {print $0}' logsl.txt > ./logslice/${file}_${linenum}_slice.txt
    # perl -ne 'print unless $seen{$_}++' ./logslice/${file}_${linenum}_slice.txt > ./logslice/${file}_${linenum}_slice_uni.txt
    # sed 's/^[[:space:]]*//' ./logslice/${file}_${linenum}_slice_uni.txt > ./logslice/${file}_${linenum}_slice_final.txt

    # 将临时文件内容写入输出文件的指定行
    # 假设你想将内容插入到 output.java 的第 linenumber[0] 行
else
    echo "failedaaaaaaaa"
fi
    # 清理临时文件
    cd /mnt/storage/shengchenduan/joern-cli
    #rm logsl.txt
    rm output.txt
    rm -r ./pdg/${file}
    # rm ./merged/${file}_merged.dot
    echo "backward slice finish"
    
