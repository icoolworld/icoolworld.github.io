#!/bin/bash

#markdown file to jekyll blogs

# 判断是否为日期
function isValidDate(){
    date -d "$1" "+%F"|grep -q "$1" 2>/dev/null
    #if [ $? = 0 ]; then
    #    echo "true"
    #else
    #    echo "false"
    #fi
    return $?
}

#将文件名格式变是YYYY-MM-DD-TITLE.md 格式
#根据目录名来做文章的分类
#随机加上日期
function renameFile(){
    for file in `ls $1`
    do
        if [ -d $1"/"$file ]
        then
            #最后一级目录名
            lastdir=$file
            renameFile $1"/"$file
        else
            if test -f $1"/"$file; then
                if [ "${file##*.}" = "md" ]; then
                    #echo $lastdir
                    rnd=$(rand 1451577600 1510794529)
                    #随机日期
                    rnddate=`timetodate "$rnd"`
                    #echo $rnddate
                    #echo $1"/"$file
                    newfile=$rnddate"-"$file
                    #文件名,不包含扩展名
                    title=${file%%.*}
                    datastr=${title:0:10}
                    isValidDate $datastr
                    isValidDateStr=$?
                    # 文件包含日期,跳出循环
                    if [ $isValidDateStr == 0 ]; then
                        echo $isValidDateStr"==continue=="
                        continue
                    fi
                    #修改后的文件名
                    mv $1"/"$file  $1"/"$newfile
                    echo $1"/"$newfile
                    gbk2utf8 $1"/"$newfile
                    #文件开头添加内容
                    sed  -i "1i\---\nlayout: post\ntitle: ${title}\ncategories: ${lastdir}\n---\n" $1"/"$newfile
                else
                    rm -rf $1"/"$file
                fi
            fi
        fi
    done
}

#生成随机数
function rand(){
    min=$1
    max=$2
    expr $(date +%N) %  $[$max - $min  + 1] + $min
}

#时间戳转日期
function timetodate(){
    datetime=$1
    date -d @${datetime}  "+%Y-%m-%d"
}

function gbk2utf8(){
    path=$1
    echo "Converting $path (gbk --> utf-8) ... "
    if file "$path"|grep -q UTF-8 >/dev/null ; then
        echo "Already converted"
    else
        iconv -f gbk $opt -t utf-8 "$path" > /tmp/$$.tmp
        if [ $? -eq 0 ] ; then
            echo "Success"
            mv -f /tmp/$$.tmp "$path"
        else
            echo "Failed"
        fi
    fi
}

function main() {
    renameFile ./_posts
}

main


