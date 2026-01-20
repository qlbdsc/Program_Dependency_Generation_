# Program_Dependency_Generation
PDG Generation
This is a tool that can generate a PDG (Program Dependence Graph) for Java files. The key feature is that it does not require the entire Java project to be successfully compiled. The input consists of the file path and the line number. And the final output is the line numbers of backward slice in your Java file.
We have 3 files in total.

# Implement Step
### 1.Install Joern.
### 2. Run ./backwardslice.sh
Example Command Line: ./joernbsnum.sh $linenum $AdressofJavaFile $JavaFileName

./joernbsnum.sh 22 /mnt/storage/example.java example.java
