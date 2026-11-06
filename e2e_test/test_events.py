import pytest
from cases import CASES

CASES = [case for case in CASES if case[0] in ['TC03', 'TC04', 'TC05', 'TC06']]
@pytest.mark.parametrize("case_id,goal,screen,text,needs_event", CASES, ids=[c[0] for c in CASES])
def test_flow(run_case, case_id, goal, screen, text, needs_event):
    run_case(case_id, goal, screen, text, needs_event)
