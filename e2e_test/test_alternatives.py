import os
import pytest
from cases import FIXTURES

@pytest.mark.parametrize("case_id,env,screen,text,goal", FIXTURES, ids=[c[0] for c in FIXTURES])
def test_alternative_and_error(run_case, case_id, env, screen, text, goal):
    fixture = os.getenv(env)
    if not fixture:
        pytest.skip(f"Dedicated fixture required: {env}")
    _, output = run_case(case_id, goal.replace("{fixture}", fixture), screen, text, needs_event=case_id in {"TC23","TC24","TC25"})
    if case_id == "TC19":
        assert output.get("observed_values", {}).get("has_registration_button") is False
