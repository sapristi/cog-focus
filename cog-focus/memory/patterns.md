# Patterns
<!-- Edit in place. Distilled rules from experience. Keep under 50 lines. -->
<!-- What works, what doesn't, how to approach things. -->

## Design

- **One surface beats two when capture and organization can coexist.** Only split when real friction proves separation is needed. Two surfaces add a promotion step, a second lookup, and ceremony without matching value.
- **Divide overlapping skills by ownership axis, not by de-duping step lists.** Ask "what does this skill uniquely own?" (e.g. reflect = content decisions; housekeeping = mechanical discipline). Steps follow from ownership.
- **Chain skills conditionally on staleness, not unconditionally.** Unconditional chaining turns quick ops into deep sessions. Gate via config (`last_*` timestamps) so the chain fires only when freshness demands it.

## Working Style

- **First prototype tends to over-engineer.** Watch for: multiple surfaces, promotion steps, tags-as-API. User pushback to simplify has been right every time so far — lean toward the smaller model earlier.
- **Challenge before agreeing.** When a proposal sounds reasonable but the premise is thin (e.g. redesigning an empty file), say so. Pushback is cheaper than a wrong prototype.
- **Write observations immediately.** Design decisions logged during the session retain "why"; reconstructed later they lose rationale.
