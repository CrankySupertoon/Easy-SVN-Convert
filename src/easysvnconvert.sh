#!/bin/bash
clear
echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo What do you want to do!
echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo 1 - Checkout from Google Code
echo 2 - Exit
echo ===============================================================================

while true; do
    read -p "Selection: " sel
    case $sel in
        [1]* )
        workingdir=$(pwd)
        export workingdir=$workingdir
        clear
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        echo What is your Google Code Project Slug?
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        read -p "Slug: " gcodeslug
        export gcodeslug=$gcodeslug
        clear
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        echo Cloning Google Code Repo...
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        rm -rf /tmp/easysvnconvert/
        mkdir /tmp/easysvnconvert/ && cd /tmp/easysvnconvert/
        wget https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/$gcodeslug/repo.svndump.gz
        7z x repo.svndump.gz
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        echo Checking out Google Code Repo...
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        svnadmin create /tmp/easysvnconvert/$gcodeslug/
        svnadmin load /tmp/easysvnconvert/$gcodeslug/ < repo.svndump
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        echo Generate Authors List...
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        svn checkout file:///tmp/easysvnconvert/$gcodeslug/
        cd "$gcodeslug"
        svn log -q | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u > authors.txt
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        echo Convert Codebase to Git Repo...
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        svnserve --foreground -d &
        git svn --stdlayout -A authors.txt clone svn://localhost/tmp/easysvnconvert/$gcodeslug/
        pkill -f svnserve
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        echo Convert Branches and Tags to Git Repo...
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        cd "$gcodeslug"
        wget https://bitbucket.org/atlassian/svn-migration-scripts/downloads/svn-migration-scripts.jar
        java -Dfile.encoding=utf-8 -jar svn-migration-scripts.jar clean-git --force
        for i in `git branch -r | grep -v 'tags\|trunk' `; do git checkout ${i/origin\// };  done
        for i in `git branch -r | grep 'tags'`; do git checkout $i; git tag ${i/origin\/tags\// }; done
        rm "svn-migration-scripts.jar"
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        echo Cleaning Up...
        echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        cd "$workingdir"
        mv "/tmp/easysvnconvert/$gcodeslug/$gcodeslug" "$workingdir/git-$gcodeslug"
        rm -rf /tmp/easysvnconvert
         while [ true ]
        do
            echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
            echo Completed! Repo located at "$workingdir/git-$gcodeslug"
            echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
            read -r -p "Press any key to continue..." key
            exit
        done
        ;;
        [2]* )
        exit
        ;;
        * ) echo "";;
    esac
done
