#!/bin/sh

if [ "x$JISTBASEDIR" = "x" ]; then
  JISTBASEDIR=$BRN_TOOLS_PATH/brn.sim
fi

JISTCLICK_HOME=$JISTBASEDIR/brn.jist.click
export CLICK_HOME=$BRN_TOOLS_PATH/click-brn
export JISTCOMMON_HOME=$JISTBASEDIR/brn.jist
export JISTCLICK_HOME=$JISTBASEDIR/brn.jist.click
export JIST_HOME=$JISTBASEDIR/jist.swans

(cd $JISTCLICK_HOME; ant run -Drun.class=brn.sim.scenario.jistsimulation.JistSimulation -Drun.args="$1"; RESULT=$?) | grep "\[java\]" | grep -v "Controller:INFO:" | sed "s#^[[:space:]]*\[java\][[:space:]]##g"

exit $RESULT

