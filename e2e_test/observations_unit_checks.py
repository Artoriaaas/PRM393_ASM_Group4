import unittest
from observations import normalize_observations


class ObservationsTest(unittest.TestCase):
    def test_flat_and_nested_reports_keep_actual_values(self):
        for raw in [{"final_screen": "A03", "observed_texts": ["Chưa tìm thấy"]},
                    '{"observed_values":{"final_screen":"A03"},"observed_texts":[]}']:
            self.assertEqual(normalize_observations(raw)["observed_values"]["final_screen"], "A03")

    def test_missing_or_conflicting_screen_is_not_inferred(self):
        for raw in ["SUCCESS", {}, {"final_screen":"A03","observed_values":{"final_screen":"A02"}}]:
            self.assertNotEqual(normalize_observations(raw).get("observed_values",{}).get("final_screen"), "A03")

    def test_setup_failure_is_preserved(self):
        raw = {"final_screen":"A03", "precondition_failed":"no network", "observed_texts":[]}
        self.assertEqual(normalize_observations(raw)["precondition_failed"], "no network")


if __name__ == "__main__":
    unittest.main()
