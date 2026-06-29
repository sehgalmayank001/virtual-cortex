icon:: 📅
type-values:: 1on1, interview, meeting, standup, sync, retro, planning

- ## All meetings
	- {{query (and [[meetings]] (not (page [[meetings]])))}}
- ## 1:1s
	- {{query (and [[meetings]] (property type "1on1"))}}
- ## Interviews
	- {{query (and [[meetings]] (property type interview))}}
