#!/bin/bash

dir=$(dirname "$0")
pwd=$(pwd)

SIGN=`echo $dir | cut -b 1`

case "$SIGN" in
  "/")
        DIR=$dir
        ;;
  ".")
        DIR=$pwd/$dir
        ;;
   *)
        echo "Error while getting directory"
        exit -1
        ;;
esac

. $DIR/config

case "$1" in
    "start")
            #echo "Start"
            rm -f $DIR/end

            if [ ! -d $WORKERDIR ]; then
              mkdir $WORKERDIR
            fi

            for WORKERNAME in `cat $DIR/$HOSTS | awk '{print $1}' | sort -u`; do
              NO_CPUS=`cat $DIR/$HOSTS | grep "$WORKERNAME " | awk '{print $2}' | sort -u | tail -n 1`
              for WORKERCPU in `seq $NO_CPUS`; do
                echo "$WORKERNAME $WORKERCPU"
                if [ "x$DOMAIN" = "x" ]; then
                  echo "ssh $WORKERUSERNAME@$WORKERNAME \"(cd $DIR; $DIR/start_worker.sh $WORKERNAME $WORKERCPU)\""
                  ssh $WORKERUSERNAME@$WORKERNAME "(cd $DIR; $DIR/start_worker.sh $WORKERNAME $WORKERCPU)"
                else
                  echo "ssh $WORKERUSERNAME@$WORKERNAME$DOMAIN \"(cd $DIR; $DIR/start_worker.sh $WORKERNAME $WORKERCPU)\""
                  ssh $WORKERUSERNAME@$WORKERNAME$DOMAIN "(cd $DIR; $DIR/start_worker.sh $WORKERNAME $WORKERCPU)"
                fi
                #echo "DONE $?"
              done
            done

            ;;
    "stop")
            echo "Stop"
            touch $DIR/end
            ;;
    "forcestop")
            touch "Stop"

            if [ ! -d $WORKERDIR ]; then
              mkdir $WORKERDIR
            fi

            for WORKERNAME in `cat $DIR/$HOSTS | awk '{print $1}' | sort -u`; do
              NO_CPUS=`cat $DIR/$HOSTS | grep "$WORKERNAME " | awk '{print $2}' | sort -u | tail -n 1`
              for WORKERCPU in `seq $NO_CPUS`; do
                echo "$WORKERNAME $WORKERCPU"
                WORKERPID=`cat $DIR/$WORKERDIR/$WORKERNAME.$WORKERCPU.pid`
                if [ "x$DOMAIN" = "x" ]; then
                  ssh $WORKERUSERNAME@$WORKERNAME "kill $WORKERPID; killall sleep"
                else
                  ssh $WORKERUSERNAME@$WORKERNAME$DOMAIN "kill $WORKERPID; killall sleep"
                fi
                #echo "DONE $?"
                rm $DIR/$WORKERDIR/$WORKERNAME.$WORKERCPU.pid
              done
            done

            ;;
    "status")
            #echo "Status"
            if [ -d $DIR/$WORKERDIR ]; then
              NUM_WORKER=`(cd $DIR/$WORKERDIR; ls *.pid 2> /dev/null | wc -w)`

              if [ $NUM_WORKER -gt 0 ]; then
                exit 1
              fi
            fi
            exit 0
            ;;
    "cpus")
            if [ ! -d $DIR/$WORKERDIR ]; then
              exit 0
            fi
            NUM_WORKER=`(cd $DIR/$WORKERDIR; ls *.pid 2> /dev/null | wc -w)`
            exit $NUM_WORKER
            ;;
    "commit")
            NUM_WORKER=0
            NUM_RUNJOB=0
            while [ $NUM_WORKER -eq $NUM_RUNJOB ]; do
              NUM_WORKER=`(cd $DIR/$WORKERDIR; ls *.pid 2> /dev/null | wc -w)`
              NUM_RUNJOB=`(cd $DIR/$WORKERDIR; ls *.job 2> /dev/null | wc -w)`

              if [ $NUM_WORKER -eq $NUM_RUNJOB ]; then
                sleep 1
              fi
            done

            for i in `(cd $DIR/$WORKERDIR; ls *.pid)`; do
              JOBFILE=`echo $i | sed "s#pid#job#g"`
              if [ ! -f $DIR/$WORKERDIR/$JOBFILE ]; then
                echo "#!/bin/bash" > $DIR/$WORKERDIR/$JOBFILE
                echo ". ~/.bashrc" >> $DIR/$WORKERDIR/$JOBFILE
                echo "cd $PWD" >> $DIR/$WORKERDIR/$JOBFILE
                echo $JOBCOMMAND >> $DIR/$WORKERDIR/$JOBFILE
                echo "cd $DIR" >> $DIR/$WORKERDIR/$JOBFILE
                break
              fi
            done
            ;;
    "psstatus")
            for WORKERNAME in `cat $DIR/$HOSTS | awk '{print $1}' | sort -u`; do
              echo "$WORKERNAME"
              if [ "x$DOMAIN" = "x" ]; then
                ssh $WORKERUSERNAME@$WORKERNAME "ps -le | grep 14275"
              else
                ssh $WORKERUSERNAME@$WORKERNAME$DOMAIN "ps -le | grep 14275"
              fi
            done
           ;;
    "*")
            echo "Unknown command"
            ;;
esac

exit 0
