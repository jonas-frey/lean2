/*
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Author: Leonardo de Moura
*/
#pragma once
#include "library/blast/action_result.h"
#include "library/blast/hypothesis.h"

namespace lean {
namespace blast {
/** \brief Assert the given hypothesis into the congruence closure module */
action_result assert_cc_action(hypothesis_idx hidx);
/** \brief Check if target can be proved using equivalence classes */
action_result target_cc_action();
}}
