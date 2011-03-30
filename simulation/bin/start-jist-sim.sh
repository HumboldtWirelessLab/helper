#!/bin/sh

JISTCLICK_HOME=$BRN_TOOLS_PATH/brn.sim/brn.jist.click

export CLICK_HOME=$BRN_TOOLS_PATH/click-brn
export JISTCOMMON_HOME=$BRN_TOOLS_PATH/brn.sim/brn.jist
export JISTCLICK_HOME=$BRN_TOOLS_PATH/brn.sim/brn.jist.click
export JIST_HOME=$BRN_TOOLS_PATH/brn.sim/jist.swans

(cd $JISTCLICK_HOME; ant run -Drun.class=test.brn.mesh.jistsimulation.JistSimulation -Drun.args="$1") | grep "\[java\]" | grep -v "Controller:INFO:" | sed "s#^[[:space:]]*\[java\][[:space:]]##g"
