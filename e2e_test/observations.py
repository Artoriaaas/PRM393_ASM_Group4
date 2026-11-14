"""Normalize the host's two report schemas without inventing observations."""
import json
import re


def normalize_observations(output):
    if isinstance(output, str):
        cleaned = re.sub(r"^```(?:json)?\s*|\s*```$", "", output.strip())
        try:
            output = json.loads(cleaned)
        except json.JSONDecodeError:
            return {"unparsed": output}
    if not isinstance(output, dict):
        return output
    normalized = dict(output)
    if "final_screen" in output:
        nested = output.get("observed_values")
        if nested is None:
            normalized["observed_values"] = {"final_screen": output["final_screen"]}
        elif not isinstance(nested, dict) or nested.get("final_screen") != output["final_screen"]:
            normalized["observed_values"] = {}
            normalized["format_error"] = "conflicting final_screen observations"
    return normalized
