icon:: 🚨
status-values:: open, mitigated, resolved
severity-values:: sev0, sev1, sev2, sev3

- ## All incidents
	- {{query (and [[incidents]] (not (page [[incidents]])))}}
- ## Open
	- {{query (and [[incidents]] (property status open))}}
- ## Resolved
	- {{query (and [[incidents]] (property status resolved))}}
