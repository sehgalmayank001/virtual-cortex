icon:: 📖
status-values:: to-read, reading, read

- ## All books
	- {{query (and [[books]] (not (page [[books]])))}}
- ## Reading
	- {{query (and [[books]] (property status reading))}}
- ## Read
	- {{query (and [[books]] (property status read))}}
- ## To read
	- {{query (and [[books]] (property status to-read))}}
