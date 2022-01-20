#!/usr/bin/env python3
import os
import argparse
import re
import gitlab
# '-> see https://python-gitlab.readthedocs.io/en/stable/api-objects.html
import math
import sys
import textwrap


def readchar():
    # set stdin to raw mode, this probably only works on
    # unixes
    import tty, termios
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    tty.setraw(sys.stdin.fileno())
    ch = sys.stdin.read(1)
    termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    return ch


def ask(msg):
    print(str(msg) + " [yN] ", end='', flush=True)
    ch = readchar()
    if ch != '\n':
        print('', flush=True)
    if ord(ch) == 3:
        print('(end of text)') # see man ascii
        sys.exit(1)
    if ord(ch) == 4:
        print('(end of transmission)') # see man ascii
        sys.exit(1)
    return ch in "yY"


def main():
    """
    Stars all repositories that where the logged in user has contributions.
    Helpful for those who have 'starred repositories' as their gitlab
    start-/home-page.
    """
    parser = argparse.ArgumentParser(description=main.__doc__)
    #parser.add_argument('--min', metavar='COMMITNUMBER',
    #                    type=int,
    #                    help='minimum number of contributions to star a project')
    parser.add_argument('--interactive', '-i', action='store_const',
                        const=True, default=False,
                        help='ask before each starring operation')
    parser.add_argument('--apply', action='store_const',
                        const=True, default=False,
                        help='whether to actually apply stars')
    parser.add_argument('GITLABCONFIG',
                        help='which section in ~/.python-gitlab.cfg to use')
    args = parser.parse_args(sys.argv[1:])

    if args.apply != True:
        print("Dry run activated!")

    cfg_file_path = os.path.expanduser('~/.python-gitlab.cfg')
    gl = gitlab.Gitlab.from_config(args.GITLABCONFIG, [cfg_file_path])
    gl.auth()
    current_user = gl.user
    user_emails = current_user.emails.list()
    print("Looking for projects containing commits from these emails:")
    # user_emails_str = [] # for testing projs_with_name
    user_emails_str = [current_user.email]
    user_emails_str += [str(e.email) for e in user_emails]
    print("  " + ' '.join(user_emails_str))

    print("Fetching project list from gitlab ...")
    gl_projects = gl.projects.list(simple=True, lazy=True, all=True)
    starred_projects = gl.projects.list(simple=True, starred=True, all=True)
    starred_project_ids = {}
    for p in starred_projects:
        starred_project_ids[p.id] = p
    print("Traversing projects ...")
    projs_contributed_to = [] # tuples of stared(boolean) and project
    projs_with_name = [] # tuples of new_email and project
    for p in gl_projects:
        # get https://docs.gitlab.com/ee/api/repositories.html#contributors
        #print('{} -> {}'.format(p.name, p.id))
        #print(str(r))
        found = False
        new_email = None
        for contributor in p.repository_contributors():
            if contributor['email'] in user_emails_str:
                projs_contributed_to.append((p.id in starred_project_ids, p))
                found = True
                break
            if contributor['name'] == current_user.name:
                new_email = contributor['email']
        if not found and new_email is not None:
            projs_with_name.append((new_email, p))

    if len(projs_with_name) > 0:
        print(textwrap.dedent("""
        I found the following projects with contributions from someone
        with the name '{}' but with none of your e-mail addresses.
        Consider adding them under {}/profile/emails -- for the rest
        of the script, the following repositories are ignored:
        """.format(current_user.name, gl.url)))
        for email, p in projs_with_name:
            print('  - {} contributed to {} {}'.format(email, p.name, p.web_url))
        print("")

    print("I found the following projects with contributions from your email:")
    unstarred_count = 0
    for starred, p in projs_contributed_to:
        ch = '*' if starred else ' '
        print('  [{}] {} {}'.format(ch, p.name, p.web_url))
        if not starred:
            unstarred_count += 1
    print("")

    if unstarred_count == 0:
        print("all projects with contributions from you are starred. nothing to do!")
    else:
        prefix = '[DRY-RUN] ' if args.apply != True else '==> '
        print("{}starring yet unstarred projects ({} in total) from the above list:"
              .format(prefix, unstarred_count))
        for starred, p in projs_contributed_to:
            if starred:
                continue
            if args.interactive and not ask('Star {} ({})?'.format(p.name, p.web_url)):
                continue
            print("{}starring {} ...".format(prefix, p.web_url))
            if args.apply == True:
                p.star()



x = main()
if x is not None:
    sys.exit(x)
