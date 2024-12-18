while IFS= read -r line
do
  # 用 awk 解析每行，分离 package name, class name 和 method name
  aaa=$(echo "$line" | cut -d':' -f1)
  package=$(echo "$aaa" | awk -F'.' '{OFS="."; NF--; print $0}')
  class=$(echo "$aaa" | awk -F'.' '{print $(NF)}' | awk -F':' '{print $1}')
  bbb=$(echo "$line" | awk -F':' '{print $2}' )
  method=$(echo "$bbb" | awk -F'(' '{print $1}' )

  # 输出结果
  echo "Method{packageName='$package', className='$class', methodName='$method'}"
done < loggraph.txt
