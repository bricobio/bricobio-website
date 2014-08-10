# bricobio-website

Development for bricobio.com / bricobio.github.io

## Development Roadmap

- [ ] revamp home page
  - [x] 3 jumbotron images for splash page
  - [ ] {{go to there link}} for bacteriart on homepage
  - [ ] fix logo colors
  - [ ] fix colors
  - [ ] footer
  - [ ] "update card” less styles update
- [ ] add pages for links that should lead to new page
  - [ ] page for maker faire
  - [ ] functioning blog
- [ ] images stored in cloudinary
- [ ] redirects: .com > .org > herokuapp
- [ ] install disqus comments for blog

## Milestones
Date Due | Date Achieved | Step
--- | --- | ---
sunday | | revamped home page & what's needed to achieve this
wednesday | | maker faire page

## Contributing to Bricobio.com

**To add a blog entry, please go [here](https://github.com/bricobio/bricobio-website/new/master/public/posts)**

**To create new pages or refine existing ones**, please follow this guide. Basic familiarity with javascript, HTML, and the command line are needed to understand what's going on inside. (***More details below in Footnotes section.***)

The structure of a harp app is detailed at [harpjs.com/docs](http://harpjs.com/docs). We are using component to keep our Bootstrap LESS files up to date.


0. Make sure git is installed on your system.

  ```bash
  git --version
  ```
  > **Note:** We are using git-flow to build up this website. If you're unfamiliar, see:
  >   - [A good introduction to git](git-scm.com/book), widely recommended to help you get your environment set up and get through the basic commands. Skipping around is expected, but getting through chapter 3 is a good idea.
  >   - [Understanding git conceptually](www.sbf5.com/~cduan/technical/git/), which was the key for me to get the hang of it, and
  >   - [A description of git-flow](https://www.atlassian.com/git/workflows) Some other workflows are also described here. Recommended to read Centralized and Branching before git-flow.

1. Install Node.js. Follow the instructions here: [http://nodejs.org/](http://nodejs.org/)
2. Install harpjs [harpjs.com](http://harpjs.com/docs/environment/install). If you are on Mac or Linux, you can follow along with the terminal commands below. If you're on Windows, please visit the links for further installation details.

  ```bash
  sudo npm install -g harp
  ```
3. We'll be working with the latest release of harp as much as possible, so before starting a coding session, don't forget to make sure your harp installation is up to date.

  ```bash
  sudo npm update -g harp
  ```

4. Navigate to your development folder and run the following commands to clone the git repository and checkout the develop branch.

  ```bash
  cd ~/bricobio-dev/ # or whichever folder you prefer
  git clone https://github.com/bricobio-website.git
  git checkout -b develop origin/develop
  ```

5. We are not following the best practice for developing on harp, since its new site setup workflows still require a significant amount of fiddling. As such, our .gitignore files are basically empty. *This is a great place for a contribution from you: set up a workflow for local installs of harp with our site's requirements that are repeatable everywhere!*
5. Look at existing progress, and familiarize yourself with the contributions workflow.
  - **[Contributions workflow guidelines](https://docs.google.com/document/d/1REjL3IRt9BcbnEVfj-5WO0Z7E_AME8RYaz_7b-s3f5s/edit?usp=sharing)** in Google Drive.
  - **[Trello page to bring coders and non-coders together to work on the same project](https://trello.com/b/PV2IKZoA/website).**

6. Use a feature branch to develop a new feature. Then merge to the develop branch.

  > There are backups via [@thomasingalls](https://github.com/thomasingalls), who is, himself, learning how to git. Mistakes are forgivable and expected. This is a perfect place to get your hands dirty for the first time with collaborative development.

6. When your contribution is on github and ready for prime-time, send Thomas a message, and he will upload the site by ftp to the bricobio.com servers.

## Footnotes
We're using harp.js as a static site generator for bricobio.com pages. It's a flexible platform under active development, and it allows very rapid deployment without fussing with a tricky setup process. To code in harp, we use the Jade templating language with Twitter's Bootstrap LESS files (latest versions, as often as possible).

Unfortunately, at the moment, the harpjs documentation is a bit less than complete. The harp github project is a great place to keep up to date with what's changing inside, and with what bugs others have found.

Future development, if it goes in this direction, will be able to retain harp the middleware that builds parts of, for example, an expressjs site.
