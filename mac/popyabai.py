#!/usr/local/bin/python3

import json
import subprocess
import argparse

###############################################################################
# Helper functions


def get_spaces():
    """Return information about avaliable spaces."""
    query_cmd = ['yabai', '-m', 'query', '--spaces']
    query_proc = subprocess.run(query_cmd, capture_output=True)
    query_data = json.loads(query_proc.stdout)
    return query_data


def has_next_space():
    """Return true if there exists a space after the focuesed space."""
    spaces = get_spaces()
    if spaces[-1]['has-focus']:
        return False


def create_next_space():
    """Create a new space after the focused space."""
    create_cmd = ['yabai', '-m', 'space', '--create']
    subprocess.run(create_cmd)


def destroy_space(id):
    """Destroy space with given id."""
    destroy_cmd = ['yabai', '-m', 'space', '--destroy', str(id)]
    subprocess.run(destroy_cmd)


def destroy_unused_spaces():
    spaces = get_spaces()
    for space in reversed(spaces):
        if len(space['windows']) == 0 and not space['has-focus']:
            destroy_space(space['index'])


def yabaia_focus_space(direction):
    """Call yabai focus space command."""
    cmd = ['yabai', '-m', 'space', '--focus', direction]
    subprocess.run(cmd)


def yabai_move_window_to_space(direction):
    """Call yabai move window to space command."""
    cmd = ['yabai', '-m', 'window', '--space', direction]
    subprocess.run(cmd)


def focus_space(direction):
    """Focus prev/next space. If next and space doesn't exist, create it."""
    # Create next space if needed
    if direction == 'next' and not has_next_space():
        create_next_space()

    yabaia_focus_space(direction)
    destroy_unused_spaces()


def move_window_to_space(direction):
    """Move window to next/prev space. If next and space doesn't exist, create it."""
    # Create next space if needed
    if direction == 'next' and not has_next_space():
        create_next_space()

    yabai_move_window_to_space(direction)
    yabaia_focus_space(direction)
    destroy_unused_spaces()

################################################################################
# Driver code


def window(args):
    """Execute window operations."""
    if args.space:
        move_window_to_space(args.space)


def space(args):
    """Execute space operations."""
    if args.focus:
        focus_space(args.focus)


def main():
    """Parse command line arguments and call driver func for selected mode."""
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()
    subparsers.required = True

    window_parser = subparsers.add_parser('window')
    window_opts = window_parser.add_mutually_exclusive_group(required=True)
    window_opts.add_argument(
        '-s',
        '--space',
        choices=['next', 'prev'],
        help='Move window to next/prev space.')
    window_parser.set_defaults(func=window)

    space_parser = subparsers.add_parser('space')
    space_opts = space_parser.add_mutually_exclusive_group(required=True)
    space_opts.add_argument(
        '-f',
        '--focus',
        choices=['next', 'prev'],
        help='Change focus to next/prev space.')
    space_parser.set_defaults(func=space)

    args = parser.parse_args()
    args.func(args)


if __name__ == '__main__':
    main()
