import asyncio
import json
import os
import re
import time
import urllib.request
from pathlib import Path

import pytest

@pytest.fixture
def run_case():
    base = os.getenv("ARTEMIS_BASE_URL")
    account = os.getenv("ARTEMIS_TEST_ACCOUNT_EMAIL")
    if not base or not account:
        pytest.skip("Set ARTEMIS_BASE_URL and ARTEMIS_TEST_ACCOUNT_EMAIL; no device/model calls made")
    sdk = pytest.importorskip("artemis_client")
    client = sdk.ArtemisClient(base, token=os.getenv("ARTEMIS_TOKEN"))
    event = os.getenv("ARTEMIS_EVENT_TITLE")
    evidence = Path(__file__).resolve().parents[1] / "evidence" / "artemis"
    evidence.mkdir(parents=True, exist_ok=True)

    def run(case_id, goal, expected_screen, expected_text, needs_event=False):
        if needs_event and not event:
            pytest.skip("ARTEMIS_EVENT_TITLE must name an approved test event with resettable registration")
        goal = goal.replace("{account}", account).replace("{event}", event or "")
        instruction = (
            "Test ONLY EventHub (com.eventhub.app) on the assigned dedicated test device. "
            "Each case is independent: return to login through Account > Logout if necessary. "
            "Use only the explicitly named Google test account already added to Android; never use personal accounts, "
            "type passwords, change security settings, edit Firebase console, or invent observations. "
            + goal + " Do not report completed on Account or any other screen before this goal is achieved. Return ONLY JSON with observed_values.final_screen (screen code), "
            "observed_texts (exact text actually visible), and precondition_failed (null or reason). "
            "Expected final screen code: " + expected_screen + ". Put this JSON in report_task_status explanation. If setup is missing, report precondition_failed; do not fake success."
        )
        started = time.monotonic()
        result = asyncio.run(client.run(instruction, profile="flash", device_serial=os.getenv("ARTEMIS_DEVICE", "emulator-5554"), timeout=600))
        duration = time.monotonic() - started
        output = result.output
        # Pinned host omits Flash final reports from TaskResult. Read the
        # report actually recorded in that exact session, never invent output.
        if output is None:
            with urllib.request.urlopen(
                f"{base.rstrip('/')}/api/sessions/{result.trace_id}/steps", timeout=15
            ) as response:
                steps = json.load(response)
            for step in reversed(steps if isinstance(steps, list) else []):
                action = step.get("action_taken") or {}
                if isinstance(action, str):
                    try:
                        action = json.loads(action)
                    except json.JSONDecodeError:
                        continue
                if action.get("action") == "report_task_status":
                    output = (action.get("args") or {}).get("explanation")
                    break
        if isinstance(output, str):
            output = re.sub(r"^```(?:json)?\s*|\s*```$", "", output.strip())
            try:
                output = json.loads(output)
            except json.JSONDecodeError:
                output = {"unparsed": output}
        payload = {"case_id": case_id, "trace_id": result.trace_id, "status": result.status,
                   "elapsed_seconds": duration, "output": output, "error": result.error,
                   "run": os.getenv("ARTEMIS_RUN", "1")}
        sanitized = json.dumps(payload, ensure_ascii=False, indent=2).replace(account, "<TEST_ACCOUNT>")
        (evidence / f"{case_id}-run-{payload['run']}-{result.trace_id}.json").write_text(sanitized, encoding="utf-8")
        assert result.succeeded, f"Task status={result.status}; trace={result.trace_id}"
        assert isinstance(output, dict), "Agent must report structured observations, not just SUCCESS"
        if output.get("precondition_failed"):
            pytest.skip(f"Setup missing (trace {result.trace_id}): {output['precondition_failed']}")
        assert output.get("observed_values", {}).get("final_screen") == expected_screen
        observed = output.get("observed_texts", [])
        assert isinstance(observed, list)
        assert any(expected_text in text for text in observed if isinstance(text, str)), f"Missing observed text: {expected_text}"
        return result, output
    return run
