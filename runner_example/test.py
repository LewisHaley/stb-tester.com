import stbt

stbt.wait_for_match('videotestsrc-redblue.png', consecutive_matches=24)
stbt.press('checkers-8')
stbt.wait_for_match('videotestsrc-checkers-8.png', consecutive_matches=24)
stbt.wait_for_motion(consecutive_frames=24)
