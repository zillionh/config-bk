prj_dir=$PWD;
echo "find Makefile, *.[chs], *.[ch]pp, *.cc, *.java in $prj_dir";
cd /
find $prj_dir -name "Makefile*" > $prj_dir/cscope.files
find $prj_dir -name "*.[chsS]" >> $prj_dir/cscope.files
find $prj_dir -name "*.[ch]pp" >> $prj_dir/cscope.files
find $prj_dir -name "*.cc" >> $prj_dir/cscope.files
find $prj_dir -name "*.java" >> $prj_dir/cscope.files

