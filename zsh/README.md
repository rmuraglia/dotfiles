Note that the zsh config here is sort of conflated with some other tooling that I don't explicitly provision here, notably:

- [brew](https://brew.sh/)
- [oh my zsh](https://github.com/ohmyzsh/ohmyzsh) (aka omz)
- [pyenv](https://github.com/pyenv/pyenv)

The installation instructions for each of these tools is good, and so my recommendation is to follow the latest instructions, rather than relying on whatever I have here at this point in the past.

Overall this setup is super WIP as I'm in the middle of assessing if I want to break from omz.
It was great to help me get up and running after the bash to zsh transition, but I'm now finding that I don't even leverage most of the functionality, so perhaps I'd be best off porting over the minimal amount that I actually use.

btw, for reference, this is what the prompt is supposed to look like:

![sample zsh prompt](_img/zsh_prompt.png)

- the first line has a previous exit code indicator followed by a path: relative to the base of the repo if possible
- the second line is just broken out from the first to provide clarity when there are long paths
- the right side shows the git repo and branch, and the currently active pyenv, if not the global one

TODOs

- [ ] git dirty status could be better (misses stuff like deleted or untracked files)
- [ ] consolidate prompt color styling
- [ ] fully assess what oh my zsh does for me, and if I should migrate off of it?
