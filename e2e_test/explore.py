"""Explicit opt-in only: uses the host's Pro profile and may incur model charges."""
import asyncio
import json
import os
import time
from pathlib import Path

def main():
    if os.getenv("ARTEMIS_ALLOW_PRO") != "1":
        raise SystemExit("Set ARTEMIS_ALLOW_PRO=1 only after configuring the team's model/host and budget")
    from artemis_client import ArtemisClient
    client = ArtemisClient(os.environ["ARTEMIS_BASE_URL"], token=os.getenv("ARTEMIS_TOKEN"))
    goal = ("Explore ONLY EventHub on the dedicated test device for 20 minutes. Use only the already signed-in "
            "Google test account. Exercise F1 discovery/registration, F2 schedule/cancellation and F4A scanner/recovery, "
            "profile, notifications, export and Firebase tools. Do not alter console data, expose credentials, "
            "use personal accounts, or trigger test crash without the explicit test device setup. "
            "Report concrete usability/accessibility/state bugs with reproduction steps and screenshot/trace references. "
            "If fixtures block a flow, report it, do not fabricate results. Stop by 25 minutes.")
    start = time.monotonic()
    result = asyncio.run(client.run(goal, profile="pro", device_serial=os.getenv("ARTEMIS_DEVICE","emulator-5554"), timeout=1800))
    elapsed = time.monotonic()-start
    evidence = Path(__file__).resolve().parents[1]/"evidence"/"artemis"
    evidence.mkdir(parents=True,exist_ok=True)
    payload={"trace_id":result.trace_id,"status":result.status,"elapsed_seconds":elapsed,
             "meets_15_to_30_minutes":900<=elapsed<=1800,"output":result.output}
    (evidence/f"exploratory-{result.trace_id}.json").write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding="utf-8")
    if not result.succeeded or not payload["meets_15_to_30_minutes"]:
        raise SystemExit("Exploration does not meet completion/duration requirement; inspect actual evidence")

if __name__=="__main__":main()
