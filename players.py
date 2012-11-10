import time

import stbt


def find_player(selected_image, unselected_image):
    """Navigates to the specified player.

    Precondition: In the OnDemand Players screen.

    Uses `unselected_image` to find where the player is on screen;
    navigates there;
    uses `selected_image` to know that it has reached the player.
    """

    page_changes = [0]
    def next_page():
        if page_changes[0] < 3:
            stbt.press("FASTFORWARD")
            time.sleep(1)
            page_changes[0] += 1
        else:
            raise stbt.MatchTimeout(None, unselected_image, 0)

    while not _player_selected(selected_image):
        target = stbt.detect_match(unselected_image).next()
        if target.match:
            source = _matches("images/any-player-selected.png").next()
            stbt.debug("find_player: source=%d,%d target=%d,%d" % (
                    source.position.x, source.position.y,
                    target.position.x, target.position.y))
            stbt.press(_next_key(source.position, target.position))
            _wait_for_selection_to_move(source)
        else:
            next_page()


def _player_selected(image):
    return stbt.detect_match(image).next().match


def _wait_for_selection_to_move(source):
    for m in _matches("images/any-player-selected.png"):
        if m.position != source.position:
            break
    # Wait for animation to end, so selection is stable
    stbt.wait_for_match("images/any-player-selected.png",
                        consecutive_matches=2)


def _matches(image):
    """Like detect_match, but only yields matching results."""
    for result in stbt.detect_match(image):
        if result.match:
            yield result


def _next_key(source, target):
    """Returns the key to press to get closer to the target position.

    >>> _next_key(stbt.Position(0,0), stbt.Position(0,50))
    'CURSOR_DOWN'
    >>> _next_key(stbt.Position(0,50), stbt.Position(0,0))
    'CURSOR_UP'
    >>> _next_key(stbt.Position(0,0), stbt.Position(50,0))
    'CURSOR_RIGHT'
    >>> _next_key(stbt.Position(50,0), stbt.Position(0,0))
    'CURSOR_LEFT'
    """

    if _less(target.x, source.x):
        return "CURSOR_LEFT"
    if _less(source.y, target.y):
        return "CURSOR_DOWN"
    if _less(target.y, source.y):
        return "CURSOR_UP"
    if _less(source.x, target.x):
        return "CURSOR_RIGHT"
    raise stbt.UITestError(
        "_next_key called when the target player already found")


def _less(a, b, tolerance=20):
    """An implementation of '<' with a tolerance of what is considered equal."""
    return a < (b - tolerance)
