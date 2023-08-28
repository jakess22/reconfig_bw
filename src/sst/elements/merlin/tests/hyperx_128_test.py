#!/usr/bin/env python
#
# Copyright 2009-2023 NTESS. Under the terms
# of Contract DE-NA0003525 with NTESS, the U.S.
# Government retains certain rights in this software.
#
# Copyright (c) 2009-2023, NTESS
# All rights reserved.
#
# This file is part of the SST software package. For license
# information, see the LICENSE file in the top level directory of the
# distribution.

import sst
from sst.merlin.base import *
from sst.merlin.endpoint import *
from sst.merlin.interface import *
from sst.merlin.topology import *

from sst.ember import *


if __name__ == "__main__":


    PlatformDefinition.setCurrentPlatform("firefly-defaults")

    ### Setup the topology
    topo = topoFatTree()
    topo.shape = "2,2:2,2:1"
    
    # Set up the routers
    router = hr_router()

    # FL
    router.reconfig_rtr = "0"
    router.max_rtr_bw = "1GB/s"
    router.monitor_window = "3us"

    # commonly used, but not needed for FL router
    router.link_bw = "1GB/s"

    router.flit_size = "8B"
    router.xbar_bw = "1GB/s"
    router.input_latency = "20ns"
    router.output_latency = "20ns"
    router.input_buf_size = "4kB"
    router.output_buf_size = "4kB"
    router.num_vns = 2
    router.xbar_arb = "merlin.xbar_arb_lru"

    topo.router = router
    topo.link_latency = "20ns"
    
    ### set up the endpoint
    networkif = ReorderLinkControl()
    networkif.link_bw = "4GB/s"
    networkif.input_buf_size = "1kB"
    networkif.output_buf_size = "1kB"

    # Set up VN remapping
    #networkif.vn_remap = [0]
    
    ep = EmberMPIJob(0,topo.getNumNodes())
    ep.network_interface = networkif
    ep.addMotif("Init")
    ep.addMotif("Allreduce")
    ep.addMotif("Allreduce")
    #ep.addMotif("Allreduce")

    ep.addMotif("Fini")
    ep.nic.nic2host_lat= "100ns"

    system = System()
    system.setTopology(topo)
    system.allocateNodes(ep,"linear")

    system.build()    

    sst.setStatisticLoadLevel(9)
    sst.enableAllStatisticsForAllComponents({"type":"sst.AccumulatorStatistic"})


    sst.setStatisticOutput("sst.statOutputCSV")
    #sst.setStatisticOutput("sst.statOutputConsole") 

    sst.setStatisticOutputOptions({
        "filepath" : "dyn_stats.csv",
        "separator" : ", "
    })

