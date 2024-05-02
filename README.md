# DFIR-LiveResponse



## Summary

Bash scripts that have been created to run DFIR tools for MacOS through the Live-Response feature on MDE.



## Procedure

In general:
- Upload the tool to be executed in the investigated host to MDE Live-Response library. Sometimes it will need to be modified due to Microsoft limitations on file size or other factors.
- Upload the Bash script wrapper to the MDE Live-Response library.
- Create a Live-Response session into the desired host to be investigated.
- Copy the tool file from the MDE library to the host (**put** command).
- Run the bash script wrapper.

