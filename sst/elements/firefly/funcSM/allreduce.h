// Copyright 2013 Sandia Corporation. Under the terms
// of Contract DE-AC04-94AL85000 with Sandia Corporation, the U.S.
// Government retains certain rights in this software.
//
// Copyright (c) 2013, Sandia Corporation
// All rights reserved.
//
// This file is part of the SST software package. For license
// information, see the LICENSE file in the top level directory of the
// distribution.

#ifndef COMPONENTS_FIREFLY_FUNCSM_ALLREDUCE_H
#define COMPONENTS_FIREFLY_FUNCSM_ALLREDUCE_H

#include "funcSM/collectiveTree.h"

namespace SST {
namespace Firefly {

class AllreduceFuncSM :  public CollectiveTreeFuncSM 
{
  public:
    AllreduceFuncSM( SST::Params& params ) : CollectiveTreeFuncSM( params ) { }

    virtual void handleStartEvent( SST::Event* e, Retval& retval ) {
        CollectiveTreeFuncSM::handleStartEvent( e, retval );
    }

    virtual void handleEnterEvent( Retval& retval) {
        CollectiveTreeFuncSM::handleEnterEvent( retval );
    }

    virtual std::string protocolName() { return "CtrlMsgProtocol"; }
};

}
}

#endif
