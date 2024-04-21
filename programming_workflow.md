#  Programming Workflow Cheatsheet

## To Start an Assignment:
  ```bash
  open {web-url}
  # get the {git-url}
  cd ~/classes/comp122/deliverables
  git clone clone {git-url}
  cd ~/classes/comp122/deliverables/{assignment}
  ```

   You can now work, in turn, each of the tasks:  java, java_tac, and mips.
   The following three subsections, outlines the commands you need to execute

### To Start the Java Task

  ```bash
  cd java
  git branch -c java
  git --set-upstream-to=origin java
  touch {file}
  git add {file}
  git commit -m 'creating file' 
  git push orign java
  ```

### Incrementally Work on the Java Task

  ```bash
  cd java
  git switch java
  for(( ; ; )) ; do 
    subl .
    make test_java
    git commit -m 'insert message' -a
  done
  git pull origin java ; git push origin java
  make validate_java
  ```

### To Finish the Java Task

  ```bash
  git switch main
  git merge java
  git tag java_submitted
  git pull ; git push
  git push origin java_submitted
  make confirm_java
  ```

## To Finish the assignment

  ```bash
  git switch main
  git main
  make confirm
  ```


## To Obtain your Grade Report

  After the Professor announces, via slack, that grades are avaliable.
  ```bash
  git pull
  cat grade.report
  ```


#  [Git Command List Cheatsheet](git_cheatsheet.md)

