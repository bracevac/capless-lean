macro "apply!" e:term : tactic => `(tactic| apply $e <;> trivial)
macro "apply?" e:term : tactic => `(tactic| apply $e <;> try trivial)
