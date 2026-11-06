import pytest
from cases import CASES

CASES = [case for case in CASES if case[0] in ['TC10', 'TC11', 'TC15', 'TC16']]
@pytest.mark.parametrize("case_id,goal,screen,text,needs_event", CASES, ids=[c[0] for c in CASES])
def test_flow(run_case, case_id, goal, screen, text, needs_event):
    run_case(case_id, goal, screen, text, needs_event)
